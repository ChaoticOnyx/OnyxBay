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

	hard_cap = 4
	hard_cap_round = 6
	initial_spawn_req = 3
	initial_spawn_target = 4
	//we are not antagonists, we do not need the antagonist shpiel/objectives
	//If you still need THING above just enter on the next line: show_objectives_on_creation = 0

	station_crew_involved = FALSE

	var/prim_task_text = "You shouldn't see this"
	var/is_station_secure = TRUE

/datum/antagonist/ert/create_default(mob/source)
	var/mob/living/carbon/human/M = ..()
	if(istype(M)) M.age = rand(25,45)

/datum/antagonist/ert/Initialize()
	..()
	leader_welcome_text = "As leader of the Emergency Response Team, you answer only to [GLOB.using_map.boss_name], and have authority to override the Captain where it is necessary to achieve your mission goals. It is recommended that you attempt to cooperate with the captain where possible, however."
	prim_task_text = "Protect [GLOB.using_map.company_name]'s ass-ets on [station_name()]. Find the source of an emergency and deal with it."

/datum/antagonist/ert/create_global_objectives()
	if(!..())
		return 0
	global_objectives = list()
	var/datum/objective/ert_station_save/prim_task = new
	prim_task.explanation_text = prim_task_text
	global_objectives |= prim_task
	return 1

/datum/antagonist/ert/proc/add_global_objective(var/datum/objective/Mission)
	global_objectives |= Mission
	for(var/datum/mind/player in current_antagonists)
		player.objectives |= Mission

/datum/antagonist/ert/proc/remove_global_objective(var/datum/objective/Mission)
	global_objectives ^= Mission
	for(var/datum/mind/player in current_antagonists)
		player.objectives ^= Mission

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
