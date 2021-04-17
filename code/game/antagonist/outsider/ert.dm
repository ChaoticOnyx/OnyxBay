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
	leader_welcome_text = "You shouldn't see this"
	landmark_id = "Response Team"
	id_type = /obj/item/weapon/card/id/centcom/ERT

	flags = ANTAG_OVERRIDE_JOB | ANTAG_SET_APPEARANCE | ANTAG_HAS_LEADER | ANTAG_CHOOSE_NAME | ANTAG_RANDOM_EXCEPTED
	antaghud_indicator = "hudloyalist"

	valid_species = list(SPECIES_HUMAN) // NT don't like xenos.

	hard_cap = 4
	hard_cap_round = 6
	initial_spawn_req = 3
	initial_spawn_target = 4

	station_crew_involved = FALSE

	var/is_station_secure = TRUE

/datum/antagonist/ert/create_default(mob/source)
	var/mob/living/carbon/human/M = ..()
	if(istype(M)) M.age = rand(25,45)

/datum/antagonist/ert/Initialize()
	..()
	leader_welcome_text = "As leader of the Emergency Response Team, you answer only to [GLOB.using_map.boss_name], and have authority to override the Captain where it is necessary to achieve your mission goals. It is recommended that you attempt to cooperate with the captain where possible, however."

/datum/antagonist/ert/create_global_objectives()
	if(!..())
		return FALSE
	global_objectives = list()
	global_objectives |= new /datum/objective/ert_station_save()
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
	if(!..())
		return
	to_chat(player.current, "The Emergency Response Team works for Asset Protection; your job is to protect [GLOB.using_map.company_name]'s ass-ets. There is a code red alert on [station_name()], you are tasked to go and fix the problem.")
	to_chat(player.current, "You should first gear up and discuss a plan with your team. More members may be joining, don't move out before you're ready.")

/datum/antagonist/ert/equip(mob/living/carbon/human/player)

	//Special radio setup
	player.equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(src), slot_l_ear)
	player.equip_to_slot_or_del(new /obj/item/clothing/under/ert(src), slot_w_uniform)
	player.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	player.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/swat(src), slot_gloves)
	player.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)

	create_id(role_text, player)
	return 1
