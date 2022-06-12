GLOBAL_DATUM_INIT(borers, /datum/antagonist/borer, new)

/datum/antagonist/borer
	id = MODE_BORER
	role_text = "Cortical Borer"
	role_text_plural = "Cortical Borers"
	flags = ANTAG_RANDSPAWN | ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB
	mob_path = /mob/living/simple_animal/borer/initial
	welcome_text = "Use your Infest power to crawl into the ear of a host and fuse with their brain. You can only take control temporarily, and at risk of hurting your host, so be clever and careful; your host is encouraged to help you however they can. Talk to your fellow borers with ,x."
	antag_indicator = "hudborer"
	antaghud_indicator = "hudborer"

	faction_role_text = "Borer Thrall"
	faction_descriptor = "Unity"
	faction_welcome = "You are now a thrall to a cortical borer. Please listen to what they have to say; they're in your head."
	faction = "borer"

	hard_cap = 5
	hard_cap_round = 8
	initial_spawn_req = 3
	initial_spawn_target = 5

	spawn_announcement_title = "Lifesign Alert"
	spawn_announcement_delay = 5000

	station_crew_involved = FALSE

/datum/antagonist/borer/Initialize()
	spawn_announcement = replacetext(GLOB.using_map.unidentified_lifesigns_message, "%STATION_NAME%", station_name())
	spawn_announcement_sound = GLOB.using_map.unidentified_lifesigns_sound
	. = ..()
	if(config.game.borer_min_age)
		min_player_age = config.game.borer_min_age

/datum/antagonist/borer/get_extra_panel_options(datum/mind/player)
	return "<a href='?src=\ref[src];move_to_spawn=\ref[player.current]'>\[put in host\]</a>"

/datum/antagonist/borer/antags_are_dead()
	for(var/datum/mind/antag in current_antagonists)
		if(antag.current.stat != DEAD)
			return FALSE
	return TRUE

/datum/antagonist/borer/create_objectives(datum/mind/player)
	if(!..())
		return

	var/datum/objective/borer_survive/survive_objective = new
	survive_objective.owner = player
	player.objectives += survive_objective

	var/datum/objective/borer_reproduce/reproduce_objective = new
	reproduce_objective.owner = player
	player.objectives += reproduce_objective

	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = player
	player.objectives += escape_objective

/datum/antagonist/borer/proc/get_vents()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in GLOB.atmos_machinery)
		if(!temp_vent.welded && temp_vent.network && (temp_vent.loc.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			if(temp_vent.network.normal_members.len > 50)
				vents += temp_vent
	return vents

/datum/antagonist/borer/place_mob(mob/living/mob)
	var/mob/living/simple_animal/borer/borer = mob
	if(istype(borer))
		var/mob/living/carbon/human/host
		for(var/mob/living/carbon/human/H in SSmobs.mob_list)
			if(H.mind && H.stat != DEAD && !H.has_brain_worms())
				var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
				if(head && !BP_IS_ROBOTIC(head))
					host = H
					break
		if(istype(host))
			var/obj/item/organ/external/head = host.get_organ(BP_HEAD)
			if(head)
				borer.host = host
				head.implants += borer
				borer.forceMove(host)
				if(!borer.host_brain)
					borer.host_brain = new(borer)
				borer.host_brain.SetName(host.name)
				borer.host_brain.real_name = host.real_name
				return
	mob.forceMove(get_turf(pick(get_vents()))) // Place them at a vent if they can't get a host.
