#define ABDUCTOR_MAX_TEAMS 4
GLOBAL_LIST_INIT(possible_abductor_names, list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega"))
GLOBAL_DATUM_INIT(abductor, /datum/antagonist/abductor, new)

/datum/antagonist/abductor
	id = MODE_ABDUCTOR
	role_text = "\improper Abductor"
	role_text_plural = "\improper Abductors"
	landmark_id = "Abductor"
	leader_welcome_text = "You are the leader of the Syndicate Operatives; hail to the chief. Use :t to speak to your underlings."
	welcome_text = "To speak on the strike team's private channel use :t."
	flags = ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB | ANTAG_CLEAR_EQUIPMENT | ANTAG_RANDOM_EXCEPTED
	antaghud_indicator = "hudabductor"
	mob_path = /mob/living/carbon/human/abductor
	hard_cap = 2
	hard_cap_round = 8
	initial_spawn_req = 1
	initial_spawn_target = 2
	faction = "syndicate"
	station_crew_involved = FALSE
	var/outfit = /decl/hierarchy/outfit/abductor
	var/agent = FALSE
	var/scientist = FALSE

/datum/antagonist/abductor/agent
	id = "Abductor Agent"
	role_text = "\improper Abductor Agent"
	agent = TRUE
	landmark_id = "abductor_agent"
	outfit = /decl/hierarchy/outfit/abductor/agent
	welcome_text = "Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve."

/datum/antagonist/abductor/scientist
	id = "Abductor Scientist"
	role_text = "\improper Abductor Scientist"
	scientist = TRUE
	landmark_id = "abductor"
	outfit = /decl/hierarchy/outfit/abductor/scientist
	welcome_text = "Use your experimental console and surgical equipment to monitor your agent and experiment upon abducted humans."

/datum/antagonist/abductor/scientist/onemanteam
	id = "Abductor Solo"
	role_text = "\improper Abductor Solo"
	agent = TRUE
	scientist = TRUE
	outfit = /decl/hierarchy/outfit/abductor/scientist/onemanteam

/datum/antagonist/abductor/update_antag_mob(datum/mind/player, preserve_appearance, datum/team/team)
	. = ..()
	finalize_abductor(player, team)

/datum/antagonist/abductor/proc/get_sub_role(datum/mind/player)
	player.abductor.agent = agent
	player.abductor.scientist = scientist

/datum/antagonist/abductor/get_extra_panel_options(datum/mind/player)
	return "<a href='?src=\ref[src];make_scientist=\ref[player.current]'>\[Abductor Scientist\].</a>\
	<a href='?src=\ref[src];make_agent=\ref[player.current]'>\[Abductor Agent\].</a>\
	<a href='?src=\ref[src];make_solo=\ref[player.current]'>\[Abductor Solo\].</a>\
	<a href='?src=\ref[src];select_team=\ref[player.current]'>\[Select Team\].</a>"

/datum/antagonist/abductor/Topic(href, href_list)
	if (..())
		return

	if(href_list["make_scientist"])
		var/mob/living/carbon/human/player_scientist = locate(href_list["make_scientist"])
		if(!isabductor(player_scientist))
			to_chat(usr, "\red [player_scientist] isn't abductor!!")
			return

		player_scientist.mind.abductor.scientist = 1
		outfit = /decl/hierarchy/outfit/abductor/scientist

	if(href_list["make_agent"])
		var/mob/living/carbon/human/player_agent = locate(href_list["make_agent"])
		if(!isabductor(player_agent))
			to_chat(usr, "\red [player_agent] isn't abductor!!")
			return

		player_agent.mind.abductor.agent = 1
		outfit = /decl/hierarchy/outfit/abductor/agent

	if(href_list["make_solo"])
		var/mob/living/carbon/human/player_solo = locate(href_list["make_solo"])
		if(!isabductor(player_solo))
			to_chat(usr, "\red [player_solo] isn't abductor!!")
			return

		player_solo.mind.abductor.scientist = 1
		player_solo.mind.abductor.agent = 1
		outfit = /decl/hierarchy/outfit/abductor/scientist/onemanteam

	if(href_list["select_team"])
		var/mob/living/carbon/human/player = locate(href_list["select_team"])
		if(!isabductor(player))
			to_chat(usr, "\red [player] isn't abductor!!")
			return

		var/new_team = input("Select new team for [player].", "New team", null) as null|anything in GLOB.abductor_teams
		if(new_team=="Create New Team")
			player.mind.abductor.team = new()
			new_team=player.mind.abductor.team
			log_and_message_admins("[key_name(usr)] changed team for [player]")
			return

		if(!isnull(new_team))
			player.mind.abductor.team = new_team
			log_and_message_admins("[key_name(usr)] changed team for [player]")

/datum/antagonist/abductor/proc/finalize_abductor(datum/mind/player, datum/team/team)
	//Equip
	var/mob/living/carbon/human/H = player.current
	if(isnull(H.mind.abductor))
		H.mind.abductor=new()

	H.mind.abductor.team=team
	H.real_name = "[H.mind.abductor.team.name] [role_text]"
	H.set_species("Abductor")

	player.objectives += player.abductor.team.objectives
	var/obj_count = 1
	to_chat(player, "<span class='notice'>Your current objectives:</span>")
	for(var/datum/objective/objective in player.objectives)
		to_chat(player, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	get_sub_role(player)
	//Teleport to ship
	for(var/obj/effect/landmark/abductor/LM in GLOB.landmarks_list)
		if(LM.team_number == H.mind.abductor.team.team_number)
			H.forceMove(LM.loc)
			break

/datum/antagonist/abductor/equip(mob/living/carbon/human/player)
	if(!..())
		return 0

	var/decl/hierarchy/outfit/abductor = outfit_by_type(outfit)
	abductor.equip(player)
	return 1


// OBJECTIVES
/datum/objective/experiment
	target_amount = 6

/datum/objective/experiment/New()
	explanation_text = "Experiment on [target_amount] humans."

/datum/objective/experiment/check_completion()
	for(var/obj/machinery/abductor/experiment/E in GLOB.machines)
		if(!istype(team, /datum/team/abductor_team))
			return FALSE
		var/datum/team/abductor_team/T = team
		if(E.team_number == T.team_number)
			return E.points >= target_amount
	return FALSE

//TODO Make normal spawn system
/datum/antagonist/abductor/attempt_auto_spawn(called_by_storyteller = FALSE)
	if(!can_late_spawn() && !called_by_storyteller)
		return 0

	update_current_antag_max(SSticker.mode)
	var/active_antags = get_active_antag_count()
	log_debug_verbose("[uppertext(id)]: Found [active_antags]/[cur_max] active [role_text_plural].")

	if(active_antags >= cur_max && !called_by_storyteller)
		log_debug_verbose("Could not auto-spawn a [role_text], active antag limit reached.")
		return 0

	build_candidate_list(SSticker.mode, flags & (ANTAG_OVERRIDE_MOB|ANTAG_OVERRIDE_JOB))
	if(!candidates.len)
		log_debug_verbose("Could not auto-spawn a [role_text], no candidates found.")
		return 0

	attempt_spawn() //auto-spawn antags one at a time
	if(pending_antagonists.len < initial_spawn_req)
		log_debug_verbose("Could not auto-spawn a [role_text], none of the available candidates could be selected.")
		return 0

	if(pending_antagonists.len > initial_spawn_req)

		var/datum/mind/player_scientist = pick(pending_antagonists)
		pending_antagonists -= player_scientist

		var/datum/mind/player_agent = pick(pending_antagonists)
		pending_antagonists -= player_agent

		var/datum/antagonist/abductor/scientist/scientist = new()
		var/datum/antagonist/abductor/agent/agent = new()
		var/datum/team/abductor_team/abuct_team = new()

		if(!scientist.add_antagonist(player_scientist, ignore_role=FALSE, do_not_equip=FALSE, move_to_spawn=FALSE, do_not_announce=TRUE, preserve_appearance=TRUE, team = abuct_team))
			log_debug_verbose("Could not auto-spawn a [scientist.role_text], failed to add antagonist.")
			return 0

		if(!agent.add_antagonist(player_agent, ignore_role=FALSE, do_not_equip=FALSE, move_to_spawn=FALSE, do_not_announce=TRUE, preserve_appearance=TRUE, team = abuct_team))
			log_debug_verbose("Could not auto-spawn a [agent.role_text], failed to add antagonist.")
			return 0



		if(called_by_storyteller)
			player_scientist.was_antag_given_by_storyteller = TRUE
			player_scientist.antag_was_given_at = roundduration2text()

			player_agent.was_antag_given_by_storyteller = TRUE
			player_agent.antag_was_given_at = roundduration2text()

	else

		var/datum/mind/player_solo = pick(pending_antagonists)
		pending_antagonists -= player_solo

		var/datum/antagonist/abductor/scientist/onemanteam/solo = new()
		var/datum/team/abductor_team/solo_team = new()

		if(!solo.add_antagonist(player_solo, ignore_role=FALSE, do_not_equip=FALSE, move_to_spawn=FALSE, do_not_announce=TRUE, preserve_appearance=TRUE, team=solo_team))
			log_debug_verbose("Could not auto-spawn a [solo.role_text], failed to add antagonist.")
			return 0

		if(called_by_storyteller)
			player_solo.was_antag_given_by_storyteller = TRUE
			player_solo.antag_was_given_at = roundduration2text()


	reset_antag_selection()

	return 1

//Selects players that will be spawned in the antagonist role from the potential candidates
//Selected players are added to the pending_antagonists lists.
//Attempting to spawn an antag role with ANTAG_OVERRIDE_JOB should be done before jobs are assigned,
//so that they do not occupy regular job slots. All other antag roles should be spawned after jobs are
//assigned, so that job restrictions can be respected.
/datum/antagonist/abductor/attempt_spawn(spawn_target = null)
	if(spawn_target == null)
		spawn_target = initial_spawn_target

	// Update our boundaries.
	if(!candidates.len)
		return 0

	//Grab candidates randomly until we have enough.
	while(candidates.len && pending_antagonists.len < spawn_target)
		var/datum/mind/player = pick(candidates)
		candidates -= player
		draft_antagonist(player)

	return 1
