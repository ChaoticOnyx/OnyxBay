#define VOTE_FONT(text) ("<font color='purple'>" + text + "</font>")
SUBSYSTEM_DEF(vote)
	name = "Voting"
	wait = 1 SECOND
	priority = SS_PRIORITY_VOTE
	init_order = SS_INIT_VOTE
	flags = SS_NO_TICK_CHECK | SS_KEEP_TIMING
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	/// A list of all generated action buttons
	var/list/datum/action/generated_actions = list()
	/// All votes that we can possible vote for.
	var/list/datum/vote/possible_votes = list()
	/// The vote we're currently voting on.
	var/datum/vote/current_vote
	/// A list of all ckeys who have voted for the current vote.
	var/list/voted = list()
	/// A list of all ckeys currently voting for the current vote.
	var/list/voting = list()

/datum/controller/subsystem/vote/Initialize()
	. = ..()
	for(var/vote_type in subtypesof(/datum/vote))
		var/datum/vote/vote = new vote_type()
		if(!vote.is_accessible_vote())
			qdel(vote)
			continue

		possible_votes[vote.name] = vote


// Called by master_controller
/datum/controller/subsystem/vote/fire()
	if(!current_vote)
		return
	tgui_update()
	current_vote.time_remaining = round((current_vote.started_time + config.vote.period - world.time) / 10)
	if(current_vote.time_remaining < 0)
		process_vote_result()
		SStgui.close_uis(src)
		reset()

/// Resets all of our vars after votes conclude / are cancelled.
/datum/controller/subsystem/vote/proc/reset()
	voted.Cut()
	voting.Cut()

	current_vote?.reset()
	current_vote = null

	QDEL_LIST(generated_actions)
	tgui_update()

/**
 * Process the results of the vote.
 * Collects all the winners, breaks any ties that occur,
 * prints the results of the vote to the world,
 * and finally follows through with the effects of the vote.
 */
/datum/controller/subsystem/vote/proc/process_vote_result()

	// First collect all the non-voters we have.
	var/list/non_voters = GLOB.ckey_directory.Copy() - voted
	// Remove AFK or clientless non-voters.
	for(var/non_voter_ckey in non_voters)
		var/client/non_voter_client = non_voters[non_voter_ckey]
		if(!non_voter_client || non_voter_client.is_afk())
			non_voters -= non_voter_ckey

	// Now get the result of the vote.
	// This is a list, as we could have a tie (multiple winners).
	var/list/winners = current_vote.get_vote_result(non_voters)

	// Now we should determine who actually won the vote.
	var/final_winner
	// 1 winner? That's the winning option
	if(length(winners) == 1)
		final_winner = winners[1]

	// More than 1 winner? Tiebreaker between all the winners
	else if(length(winners) > 1)
		final_winner = current_vote.tiebreaker(winners)

	// Announce the results of the vote to the world.
	var/to_display = current_vote.get_result_text(winners, final_winner, non_voters)

	log_vote(to_display)
	to_chat(world, SPAN_INFO(VOTE_FONT("\n[to_display]")))

	// Finally, doing any effects on vote completion
	if (final_winner) // if no one voted final_winner will be null
		current_vote.finalize_vote(final_winner)

/**
 * One selection per person, and the selection with the most votes wins.
 */
/datum/controller/subsystem/vote/proc/submit_single_vote(mob/voter, their_vote)
	if(!current_vote)
		return
	if(!voter?.ckey)
		return
	if(config.vote.no_dead_vote && voter.stat == DEAD && !voter.client?.holder)
		return

	// If user has already voted, remove their specific vote
	if(voter.ckey in current_vote.choices_by_ckey)
		var/their_old_vote = current_vote.choices_by_ckey[voter.ckey]
		current_vote.choices[their_old_vote]--

	else
		voted += voter.ckey

	current_vote.choices_by_ckey[voter.ckey] = their_vote
	current_vote.choices[their_vote]++

	return TRUE

/**
 * Any number of selections per person, and the selection with the most votes wins.
 */
/datum/controller/subsystem/vote/proc/submit_multi_vote(mob/voter, their_vote)
	if(!current_vote)
		return
	if(!voter?.ckey)
		return
	if(config.vote.no_dead_vote && voter.stat == DEAD && !voter.client?.holder)
		return

	else
		voted += voter.ckey

	if(current_vote.choices_by_ckey[voter.ckey + their_vote] == 1)
		current_vote.choices_by_ckey[voter.ckey + their_vote] = 0
		current_vote.choices[their_vote]--

	else
		current_vote.choices_by_ckey[voter.ckey + their_vote] = 1
		current_vote.choices[their_vote]++

	return TRUE

/**
 * Initiates a vote, allowing all players to vote on something.
 *
 * * vote_type - The type of vote to initiate. Can be a [/datum/vote] typepath, a [/datum/vote] instance, or the name of a vote datum.
 * * vote_initiator_name - The ckey (if player initiated) or name that initiated a vote. Ex: "UristMcAdmin", "the server"
 * * vote_initiator - If a person / mob initiated the vote, this is the mob that did it
 * * forced - Whether we're forcing the vote to go through regardless of existing votes or other circumstances. Note: If the vote is admin created, forced becomes true regardless.
 */
/datum/controller/subsystem/vote/proc/initiate_vote(vote_type, vote_initiator_name, mob/vote_initiator, forced = FALSE)

	// Even if it's forced we can't vote before we're set up
	if(GAME_STATE < RUNLEVEL_LOBBY)
		if(vote_initiator)
			to_chat(vote_initiator, SPAN_WARNING("You cannot start vote now, the server is not done initializing."))
		return FALSE

	// Check if we have unlimited voting power.
	// Admin started (or forced) voted will go through even if there's an ongoing vote,
	// if voting is on cooldown, or regardless if a vote is config disabled (in some cases)
	var/unlimited_vote_power = forced || !!admin_datums[vote_initiator?.ckey]

	if(current_vote && !unlimited_vote_power)
		if(vote_initiator)
			to_chat(vote_initiator, SPAN_WARNING("There is already a vote in progress! Please wait for it to finish."))
		return FALSE

	// Get our actual datum
	var/datum/vote/to_vote
	// If we were passed a path: find the path in possible_votes
	if(ispath(vote_type, /datum/vote))
		var/datum/vote/vote_path = vote_type
		to_vote = possible_votes[initial(vote_path.name)]

	// If we were passed an instance: use the instance
	else if(istype(vote_type, /datum/vote))
		to_vote = vote_type

	// If we got neither a path or an instance, it could be a vote name, but is likely just an error / null
	else
		to_vote = possible_votes[vote_type]
		if(!to_vote)
			util_crash_with("Voting initiate_vote was passed an invalid vote type. (Got: [vote_type || "null"])")

	// No valid vote found? No vote
	if(!istype(to_vote))
		if(vote_initiator)
			to_chat(vote_initiator, SPAN_WARNING("Invalid voting choice."))
		return FALSE

	// Vote can't be initiated in our circumstances? No vote
	if(!to_vote.can_be_initiated(vote_initiator, unlimited_vote_power))
		return FALSE

	// Okay, we're ready to actually create a vote -
	// Do a reset, just to make sure
	reset()

	// Try to create the vote. If the creation fails, no vote
	if(!to_vote.create_vote(vote_initiator, forced))
		return FALSE

	// Okay, the vote's happening now, for real. Set it up.
	current_vote = to_vote

	var/duration = config.vote.period/10
	var/to_display = current_vote.initiate_vote(vote_initiator_name, duration)

	log_vote(to_display)
	to_chat(world, EXAMINE_BLOCK(SPAN_INFO(VOTE_FONT("\n[SPAN_BOLD(to_display)]\n\
		Type <b>vote</b> or click <a href='byond://winset?command=vote'>here</a> to place your votes.\n\
		You have [duration] seconds to vote."))))

	// And now that it's going, give everyone a voter action
	notify_ghosts("Vote: [current_vote.override_question || current_vote.name]", sound(current_vote.vote_sound), src, image('icons/hud/actions.dmi',"vote"), NOTIFY_VOTE)

	for(var/mob/living/new_voter in GLOB.player_list)
		if(!isliving(new_voter))
			continue
		var/datum/action/vote/voting_action = new()
		voting_action.name = "Vote: [current_vote.override_question || current_vote.name]"
		voting_action.Grant(new_voter)

		generated_actions += voting_action

		sound_to(new_voter, sound(current_vote.vote_sound))
		winset(new_voter.client, "mainwindow", "flash=5")

	return TRUE

/datum/controller/subsystem/vote/tgui_state()
	return GLOB.tgui_always_state

/datum/controller/subsystem/vote/tgui_interact(mob/user, datum/tgui/ui)
	// Tracks who is currently voting
	voting |= user.client?.ckey
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VotePanel")
		ui.open()

/datum/controller/subsystem/vote/tgui_data(mob/user)
	var/list/data = list()

	var/is_lower_admin = !!user.client?.holder
	var/is_upper_admin = check_rights(R_ADMIN, TRUE, user.client)

	data["user"] = list(
		"ckey" = user.client?.ckey,
		"isLowerAdmin" = is_lower_admin,
		"isUpperAdmin" = is_upper_admin,
		// What the current user has selected in any ongoing votes.
		"singleSelection" = current_vote?.choices_by_ckey[user.client?.ckey],
		"multiSelection" = current_vote?.choices_by_ckey,
	)

	data["voting"]= is_lower_admin ? voting : list()

	var/list/all_vote_data = list()
	for(var/vote_name in possible_votes)
		var/datum/vote/vote = possible_votes[vote_name]
		if(!istype(vote))
			continue

		var/list/vote_data = list(
			"name" = vote_name,
			"canBeInitiated" = vote.can_be_initiated(forced = is_lower_admin),
			"config" = vote.is_config_enabled(),
			"message" = vote.message,
		)

		if(vote == current_vote)
			var/list/choices = list()
			for(var/key in current_vote.choices)
				choices += list(list(
					"name" = key,
					"votes" = current_vote.choices[key],
				))

			data["currentVote"] = list(
				"name" = current_vote.name,
				"question" = current_vote.override_question,
				"timeRemaining" = current_vote.time_remaining,
				"countMethod" = current_vote.count_method,
				"choices" = choices,
				"vote" = vote_data,
			)

		all_vote_data += list(vote_data)

	data["possibleVotes"] = all_vote_data

	return data

/datum/controller/subsystem/vote/tgui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/voter = usr

	switch(action)
		if("cancel")
			if(!voter.client?.holder)
				return

			message_admins("[key_name_admin(voter)] has cancelled the current vote.")
			SStgui.close_uis(src)
			reset()
			return TRUE

		if("toggleVote")
			var/datum/vote/selected = possible_votes[params["voteName"]]
			if(!istype(selected))
				return
			return selected.toggle_votable(voter)

		if("callVote")
			var/datum/vote/selected = possible_votes[params["voteName"]]
			if(!istype(selected))
				return

			// Whether the user actually can initiate this vote is checked in initiate_vote,
			// meaning you can't spoof initiate a vote you're not supposed to be able to
			return initiate_vote(selected, voter.key, voter)

		if("voteSingle")
			return submit_single_vote(voter, params["voteOption"])

		if("voteMulti")
			return submit_multi_vote(voter, params["voteOption"])


/datum/controller/subsystem/vote/ui_close(mob/user)
	voting -= user.client?.ckey

//Helper for certain votes.
/datum/controller/subsystem/vote/proc/restart_world()
	set waitfor = FALSE
	to_world("World restarting due to vote...")
	feedback_set_details("end_error","restart vote")
	sleep(50)
	log_game("Rebooting due to restart vote")
	world.Reboot()

/// Mob level verb that allows players to vote on the current vote.
/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	SSvote.tgui_interact(usr)

/// Datum action given to mobs that allows players to vote on the current vote.
/datum/action/vote
	name = "Vote!"
	button_icon_state = "vote"

/datum/action/vote/IsAvailable(feedback = FALSE)
	return TRUE // Democracy is always available to the free people

/datum/action/vote/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	owner.vote()
	Remove(owner)

// We also need to remove our action from the player actions when we're cleaning up.
/datum/action/vote/Remove(mob/living/removed_from)
	if(removed_from)
		removed_from.actions -= src

	return ..()

#undef VOTE_FONT
