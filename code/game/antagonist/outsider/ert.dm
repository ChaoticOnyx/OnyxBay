GLOBAL_DATUM_INIT(ert, /datum/antagonist/ert, new)

/datum/antagonist/ert
	id = MODE_ERT
	role_text = "Emergency Responder"
	role_text_plural = "Emergency Responders"
	welcome_text = "As member of the Emergency Response Team, you answer only to your leader and company officials."
	antag_text = "You are an <b>anti</b> antagonist! Within the rules, \
		try to save the installation and its inhabitants from the ongoing crisis. \
		Try to make sure other players have <i>fun</i>! If you are confused or at a loss, always adminhelp, \
		and before taking extreme actions, please try to also contact the administration! \
		Think through your actions and make the roleplay immersive! <b>Please remember all \
		rules aside from those without explicit exceptions apply to the ERT.</b>"
	landmark_id = "Emergency Responder"
	id_type = /obj/item/card/id/centcom/ERT

	flags = ANTAG_OVERRIDE_JOB | ANTAG_SET_APPEARANCE | ANTAG_HAS_LEADER | ANTAG_CHOOSE_NAME | ANTAG_RANDOM_EXCEPTED
	antaghud_indicator = "hudloyalist"

	valid_species = list(SPECIES_HUMAN) // NT don't like xenos.

	hard_cap = 4
	hard_cap_round = 6
	initial_spawn_req = 3
	initial_spawn_target = 4

	station_crew_involved = FALSE

	var/is_station_secure = TRUE
	var/message_from_station

/datum/antagonist/ert/create_default(mob/source)
	var/mob/living/carbon/human/M = ..()
	if(istype(M)) M.age = rand(25,45)

/datum/antagonist/ert/Initialize()
	..()
	if(config.game.ert_min_age)
		min_player_age = config.game.ert_min_age

/datum/antagonist/ert/create_global_objectives()
	if(!..())
		return FALSE
	global_objectives = list()
	global_objectives |= new /datum/objective/ert/resolve_conflict()
	return TRUE

/datum/antagonist/ert/proc/add_global_objective(datum/objective/mission)
	global_objectives.Add(mission)
	for(var/datum/mind/player in current_antagonists)
		player.objectives.Add(mission)

/datum/antagonist/ert/proc/remove_global_objective(datum/objective/mission)
	global_objectives.Remove(mission)
	for(var/datum/mind/player in current_antagonists)
		player.objectives.Remove(mission)

/datum/antagonist/ert/greet(datum/mind/player)
	if(!leader_welcome_text)
		leader_welcome_text = "Attention!\n\
		You have been selected as leader of an emergency respond team.\n\
		You answer only to [GLOB.using_map.boss_name] and have the full right to override any orders of the captains at the facility.\n\
		Nevertheless, it is advisable to attempt to cooperate with the captain whenever possible.\n\
		Your main task is to complete the mission assigned to you at the [GLOB.using_map.company_name]'s facility to save the company's assets and return to base with your team.\n\
		Your first priority at this time is to prepare the required equipment for mission and then head to the facility.\n\
		[message_from_station ? "Received message from the station:\n[message_from_station]" : "No additional information was received from the facility."]"
	if(!..())
		return
	to_chat(player.current, "As a member of one of Nanotrasen's elite Emergency Response Teams, you are tasked with being deployed to [station_name()] in distress and attempt to bring it back to a functional status. Theres no telling what you might encounter in your mission. Good luck. You're gonna need it.")
	to_chat(player.current, "You should first gear up and discuss a plan with your team. More members may be joining, don't move out before you're ready.")
	if(player != leader)
		to_chat(player.current, "You must obey your commanding officer - [leader.current].")

/datum/antagonist/ert/equip(mob/living/carbon/human/player)

	//Special radio setup
	player.equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(src), slot_l_ear)
	player.equip_to_slot_or_del(new /obj/item/clothing/under/ert(src), slot_w_uniform)
	player.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	player.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/swat(src), slot_gloves)
	player.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)

	create_id(role_text, player)
	return 1
