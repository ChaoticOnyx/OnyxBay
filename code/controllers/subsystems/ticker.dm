SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	wait = 10
	priority = SS_PRIORITY_TICKER
	init_order = SS_INIT_TICKER
	flags = SS_NO_TICK_CHECK | SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/pregame_timeleft = 3 MINUTES
	var/list/gamemode_vote_results  //Will be a list, in order of preference, of form list(config_tag = number of votes).
	var/bypass_gamemode_vote = TRUE //Intended for use with admin tools. Will avoid voting and ignore any results.

	var/master_mode = "secret"    //The underlying game mode (so "secret" or the voted mode). Saved to default back to previous round's mode in case the vote failed. This is a config_tag.
	var/datum/game_mode/mode        //The actual gamemode, if selected.
	var/round_progressing = 1       //Whether the lobby clock is ticking down.

	var/list/bad_modes = list()     //Holds modes we tried to start and failed to.
	var/revotes_allowed = 0         //How many times a game mode revote might be attempted before giving up.

	var/end_game_state = END_GAME_NOT_OVER
	var/delay_end = 0               //Can be set true to postpone restart.
	var/delay_notified = 0          //Spam prevention.
	var/restart_timeout = 1 MINUTE

	var/force_end = FALSE

	var/list/minds = list()         //Minds of everyone in the game.
	var/list/antag_pool = list()
	var/looking_for_antags = 0

/datum/controller/subsystem/ticker/Initialize()
	to_world("<span class='info'><B>Welcome to the pre-game lobby!</B></span>")
	to_world("Please, setup your character and select ready. Game will start in [round(pregame_timeleft/10)] seconds")
	return ..()

/datum/controller/subsystem/ticker/fire(resumed = 0)
	switch(GAME_STATE)
		if(RUNLEVEL_LOBBY)
			pregame_tick()
		if(RUNLEVEL_SETUP)
			setup_tick()
		if(RUNLEVEL_GAME)
			playing_tick()
		if(RUNLEVEL_POSTGAME)
			post_game_tick()

/datum/controller/subsystem/ticker/proc/pregame_tick()
	if(round_progressing && last_fire)
		pregame_timeleft -= world.time - last_fire
	if(pregame_timeleft <= 0)
		Master.SetRunLevel(RUNLEVEL_SETUP)
		return

	if(!bypass_gamemode_vote && (pregame_timeleft <= config.vote_autogamemode_timeleft SECONDS) && !gamemode_vote_results)
		if(!SSvote.active_vote)
			SSvote.initiate_vote(/datum/vote/gamemode, automatic = 1)

/datum/controller/subsystem/ticker/proc/setup_tick()
	switch(choose_gamemode())
		if(CHOOSE_GAMEMODE_SILENT_REDO)
			return
		if(CHOOSE_GAMEMODE_RETRY)
			pregame_timeleft = 15 SECONDS
			Master.SetRunLevel(RUNLEVEL_LOBBY)
			bad_modes = list()
			to_world("<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby to try again.")
			return
		if(CHOOSE_GAMEMODE_REVOTE)
			revotes_allowed--
			pregame_timeleft = initial(pregame_timeleft)
			gamemode_vote_results = null
			Master.SetRunLevel(RUNLEVEL_LOBBY)
			to_world("<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby for a revote.")
			return
		if(CHOOSE_GAMEMODE_RESTART)
			to_world("<B>Unable to choose playable game mode.</B> Restarting world.")
			world.Reboot("Failure to select gamemode. Tried [english_list(bad_modes)].")
			return
	// This means we succeeded in picking a game mode.
	GLOB.using_map.setup_economy()
	Master.SetRunLevel(RUNLEVEL_GAME)

	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H.mind || player_is_antag(H.mind, only_offstation_roles = 1) || !job_master.ShouldCreateRecords(H.mind.assigned_role))
			continue
		CreateModularRecord(H)

	SSstoryteller.setup()

	callHook("roundstart")

	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.post_setup()
		to_world("<span class='info'><B>Enjoy the game!</B></span>")

		for (var/mob/M in GLOB.player_list)
			M.playsound_local(M.loc, GLOB.using_map.welcome_sound, 75)

		//Holiday Round-start stuff	~Carn
		Holiday_Game_Start()

	if(!length(GLOB.admins))
		send2adminirc("Round has started with no admins online.")

/datum/controller/subsystem/ticker/proc/playing_tick()
	mode.process()
	var/mode_finished = mode_finished()

	if((mode_finished && game_finished()) || force_end)
		Master.SetRunLevel(RUNLEVEL_POSTGAME)
		end_game_state = END_GAME_READY_TO_END
		INVOKE_ASYNC(src, .proc/declare_completion)
		if(config.allow_map_switching && GLOB.all_maps.len > 1)
			if (config.auto_map_vote)
				SSvote.initiate_vote(/datum/vote/map/end_game, automatic = 1)
			else if (config.auto_map_switching)
				// Select random map exclude the current
				var/datum/map/current_map = GLOB.using_map
				var/datum/map/next_map = current_map

				while (next_map.type == current_map.type)
					next_map = GLOB.all_maps[pick(GLOB.all_maps)]

				to_world("<span class='notice'>Map has been changed to: <b>[next_map.name]</b></span>")
				fdel("data/use_map")
				text2file("[next_map.type]", "data/use_map")

	else if(mode_finished && (end_game_state <= END_GAME_NOT_OVER))
		end_game_state = END_GAME_MODE_FINISH_DONE
		mode.cleanup()
		log_and_message_admins(": All antagonists are deceased or the gamemode has ended.") //Outputs as "Event: All antagonists are deceased or the gamemode has ended."
		SSvote.initiate_vote(/datum/vote/transfer, automatic = 1)

/datum/controller/subsystem/ticker/proc/post_game_tick()
	switch(end_game_state)
		if(END_GAME_AWAITING_MAP)
			return
		if(END_GAME_READY_TO_END)
			end_game_state = END_GAME_ENDING
			callHook("roundend")
			if (universe_has_ended)
				if(mode.station_was_nuked)
					feedback_set_details("end_proper","nuke")
				else
					feedback_set_details("end_proper","universe destroyed")
				if(!delay_end)
					to_world("<span class='notice'><b>Rebooting due to destruction of [station_name()] in [restart_timeout/10] seconds</b></span>")

			else
				feedback_set_details("end_proper","proper completion")
				if(!delay_end)
					to_world("<span class='notice'><b>Restarting in [restart_timeout/10] seconds</b></span>")

			if(blackbox)
				blackbox.save_all_data_to_sql()
			handle_tickets()
			SSstoryteller.collect_statistics()
		if(END_GAME_ENDING)
			restart_timeout -= (world.time - last_fire)
			if(restart_timeout <= 0)
				world.Reboot()
			if(delay_end)
				notify_delay()
				end_game_state = END_GAME_DELAYED
		if(END_GAME_AWAITING_TICKETS)
			handle_tickets()
		if(END_GAME_DELAYED)
			if(!delay_end)
				end_game_state = END_GAME_ENDING
		else
			end_game_state = END_GAME_READY_TO_END
			log_error("Ticker arrived at round end in an unexpected endgame state.")


/datum/controller/subsystem/ticker/stat_entry()
	switch(GAME_STATE)
		if(RUNLEVEL_LOBBY)
			..("[round_progressing ? "START:[round(pregame_timeleft/10)]s" : "(PAUSED)"]")
		if(RUNLEVEL_SETUP)
			..("SETUP")
		if(RUNLEVEL_GAME)
			..("GAME")
		if(RUNLEVEL_POSTGAME)
			switch(end_game_state)
				if(END_GAME_NOT_OVER)
					..("ENDGAME ERROR")
				if(END_GAME_AWAITING_MAP)
					..("MAP VOTE")
				if(END_GAME_MODE_FINISH_DONE)
					..("MODE OVER, WAITING")
				if(END_GAME_READY_TO_END)
					..("ENDGAME PROCESSING")
				if(END_GAME_DELAYED)
					..("PAUSED")
				if(END_GAME_AWAITING_TICKETS)
					..("AWAITING TICKETS")
				if(END_GAME_ENDING)
					..("END IN [round(restart_timeout/10)]s")

/datum/controller/subsystem/ticker/Recover()
	pregame_timeleft = SSticker.pregame_timeleft
	gamemode_vote_results = SSticker.gamemode_vote_results
	bypass_gamemode_vote = SSticker.bypass_gamemode_vote

	master_mode = SSticker.master_mode
	mode = SSticker.mode
	round_progressing = SSticker.round_progressing

	end_game_state = SSticker.end_game_state
	delay_end = SSticker.delay_end
	delay_notified = SSticker.delay_notified

	minds = SSticker.minds

/*
Helpers
*/

/datum/controller/subsystem/ticker/proc/choose_gamemode()
	. = (revotes_allowed && !bypass_gamemode_vote) ? CHOOSE_GAMEMODE_REVOTE : CHOOSE_GAMEMODE_RETRY

	var/mode_to_try = master_mode //This is the config tag
	var/datum/game_mode/mode_datum

	//Decide on the mode to try.
	if(!bypass_gamemode_vote && gamemode_vote_results)
		gamemode_vote_results -= bad_modes
		if(length(gamemode_vote_results))
			mode_to_try = gamemode_vote_results[1]
			. = CHOOSE_GAMEMODE_RETRY //Worth it to try again at least once.
		else
			mode_to_try = "extended"

	if(!mode_to_try)
		return
	if(mode_to_try in bad_modes)
		return

	var/totalPlayers = 0
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.client && player.ready)
			totalPlayers++
	//Find the relevant datum, resolving secret in the process.
	var/list/base_runnable_modes = config.GetRunnableModesForPlayers(totalPlayers) //format: list(config_tag = weight)
	if(mode_to_try == "random" || mode_to_try == "secret")
		var/list/runnable_modes = base_runnable_modes - bad_modes
		if(secret_force_mode != "secret") // Config option to force secret to be a specific mode.
			mode_datum = config.pick_mode(secret_force_mode)
		else if(!length(runnable_modes))  // Indicates major issues; will be handled on return.
			bad_modes += mode_to_try
			return
		else
			mode_datum = config.pick_mode(pickweight(runnable_modes))
			if(length(runnable_modes) > 1) // More to pick if we fail; we won't tell anyone we failed unless we fail all possibilities, though.
				. = CHOOSE_GAMEMODE_SILENT_REDO
	else
		mode_datum = config.pick_mode(mode_to_try)
	if(!istype(mode_datum))
		bad_modes += mode_to_try
		return

	//Deal with jobs and antags, check that we can actually run the mode.
	job_master.ResetOccupations()
	mode_datum.create_antagonists()
	mode_datum.pre_setup()
	job_master.DivideOccupations(mode_datum) // Apparently important for new antagonist system to register specific job antags properly.

	if(!mode_datum.isStartRequirementsSatisfied(totalPlayers))
		mode_datum.fail_setup()
		job_master.ResetOccupations()
		bad_modes += mode_datum.config_tag
		return

	//Declare victory, make an announcement.
	. = CHOOSE_GAMEMODE_SUCCESS
	mode = mode_datum
	master_mode = mode_to_try
	if(mode_to_try == "secret")
		to_world("<B>The current game mode is - Secret!</B>")
	else
		mode.announce()

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/new_player/player in GLOB.player_list)
		if(player && player.ready && player.mind)
			if(player.mind.assigned_role=="AI")
				player.close_spawn_windows()
				player.AIize()
			else if(!player.mind.assigned_role)
				continue
			else
				if(player.create_character())
					qdel(player)
		else if(player && !player.ready)
			player.new_player_panel()

/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			minds += player.mind

/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless = TRUE
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Captain")
				captainless = FALSE
			if(!player_is_antag(player.mind, only_offstation_roles = 1))
				job_master.EquipRank(player, player.mind.assigned_role, 0)
				equip_custom_items(player)
	if(captainless)
		for(var/mob/M in GLOB.player_list)
			if(!istype(M, /mob/new_player))
				to_chat(M, "Captainship not forced on anyone.")

/datum/controller/subsystem/ticker/proc/attempt_late_antag_spawn(list/antag_choices)
	var/datum/antagonist/antag = antag_choices[1]
	while(antag_choices.len && antag)
		var/needs_ghost = antag.flags & (ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB)
		if (needs_ghost)
			looking_for_antags = 1
			antag_pool.Cut()
			to_world("<b>A ghost is needed to spawn \a [antag.role_text].</b>\nGhosts may enter the antag pool by making sure their [antag.role_text] preference is set to high, then using the toggle-add-antag-candidacy verb. You have 3 minutes to enter the pool.")

			sleep(3 MINUTES)
			looking_for_antags = 0
			antag.update_current_antag_max(mode)
			antag.build_candidate_list(mode, needs_ghost)
			for(var/datum/mind/candidate in antag.candidates)
				if(!(candidate in antag_pool))
					antag.candidates -= candidate
					log_debug("[candidate.key] was not in the antag pool and could not be selected.")
		else
			antag.update_current_antag_max(mode)
			antag.build_candidate_list(mode, needs_ghost)
			for(var/datum/mind/candidate in antag.candidates)
				if(isghostmind(candidate))
					antag.candidates -= candidate
					log_debug("[candidate.key] is a ghost and can not be selected.")
		if(length(antag.candidates) >= antag.initial_spawn_req)
			antag.attempt_spawn()
			antag.finalize_spawn()
			additional_antag_types.Add(antag.id)
			return 1
		else
			if(antag.initial_spawn_req > 1)
				to_world("Failed to find enough [antag.role_text_plural].")

			else
				to_world("Failed to find a [antag.role_text].")

			antag_choices -= antag
			if(length(antag_choices))
				antag = antag_choices[1]
				if(antag)
					to_world("Attempting to spawn [antag.role_text_plural].")
	return 0

/datum/controller/subsystem/ticker/proc/game_finished()
	if(mode.explosion_in_progress)
		return 0
	if(config.continous_rounds)
		return evacuation_controller.round_over() || mode.station_was_nuked || mode.blob_domination
	else
		return mode.check_finished() || (evacuation_controller.round_over() && evacuation_controller.emergency_evacuation) || universe_has_ended

/datum/controller/subsystem/ticker/proc/mode_finished()
	if(config.continous_rounds)
		return mode.check_finished()
	else
		return game_finished()

/datum/controller/subsystem/ticker/proc/notify_delay()
	if(!delay_notified)
		to_world("<span class='notice'><b>An admin has delayed the round end</b></span>")
	delay_notified = 1

/datum/controller/subsystem/ticker/proc/handle_tickets()
	for(var/datum/ticket/ticket in tickets)
		if(ticket.is_active())
			if(!delay_notified)
				message_staff("<span class='warning'><b>Automatically delaying restart due to active tickets.</b></span>")
			notify_delay()
			end_game_state = END_GAME_AWAITING_TICKETS
			return
	message_staff("<span class='warning'><b>No active tickets remaining, restarting in [restart_timeout/10] seconds if an admin has not delayed the round end.</b></span>")
	end_game_state = END_GAME_ENDING

/datum/controller/subsystem/ticker/proc/declare_completion()
	to_world("<br><br><br><H1>A round of [mode.name] has ended!</H1>")
	for(var/client/C in GLOB.clients)
		if(!C.credits && C.get_preference_value(/datum/client_preference/cinema_credits) == GLOB.PREF_YES)
			C.RollCredits()

	display_report()

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in minds)
		var/temprole = Mind.special_role
		if(temprole)							//if they are an antagonist of some sort.
			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

/datum/controller/subsystem/ticker/proc/start_now(mob/user)
	if(!(GAME_STATE == RUNLEVEL_LOBBY))
		return
	if(istype(SSvote.active_vote, /datum/vote/gamemode))
		SSvote.cancel_vote(user)
		bypass_gamemode_vote = 1
	Master.SetRunLevel(RUNLEVEL_SETUP)
	return 1
