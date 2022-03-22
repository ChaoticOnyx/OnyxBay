#define ABDUCTOR_MAX_TEAMS 4
GLOBAL_LIST_INIT(possible_abductor_names, list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega"))

GLOBAL_DATUM_INIT(abductor_agent, /datum/antagonist/abductor/agent, new)
GLOBAL_DATUM_INIT(abductor_scientis, /datum/antagonist/abductor/scientist, new)
GLOBAL_DATUM_INIT(abductor_solo, /datum/antagonist/abductor/scientist/onemanteam, new)

/datum/antagonist/abductor
	id = "MODE_ABDUCTOR"
	role_text = "\improper Abductor"
	role_text_plural = "\improper Abductors"
	landmark_id = "Abductor"
	leader_welcome_text = "You are the leader of the Syndicate Operatives; hail to the chief. Use :t to speak to your underlings."
	welcome_text = "To speak on the strike team's private channel use :t."
	flags = ANTAG_OVERRIDE_JOB | ANTAG_CLEAR_EQUIPMENT | ANTAG_RANDOM_EXCEPTED
	antaghud_indicator = "hudabductor"
	mob_path = /mob/living/carbon/human/abductor
	hard_cap = 2
	hard_cap_round = 8
	initial_spawn_req = 1
	initial_spawn_target = 2
	faction = "syndicate"
	station_crew_involved = FALSE
	var/outfit
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
	flags = ANTAG_OVERRIDE_JOB | ANTAG_CLEAR_EQUIPMENT

/datum/antagonist/abductor/update_antag_mob(datum/mind/player, preserve_appearance)
	. = ..()
	finalize_abductor(player)

/datum/antagonist/abductor/proc/get_sub_role(datum/mind/player)
	player.abductor.agent = agent
	player.abductor.scientist = scientist

//TODO make normal spawn system
/datum/antagonist/abductor/proc/finalize_abductor(datum/mind/player)
	//Equip
	var/mob/living/carbon/human/H = player.current
	player.abductor = new()
	player.abductor.team = new()
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
