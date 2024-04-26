GLOBAL_DATUM_INIT(actor, /datum/antagonist/actor, new)

/datum/antagonist/actor
	id = MODE_ACTOR
	role_text = "NanoTrasen Actor"
	role_text_plural = "NanoTrasen Actors"
	welcome_text = "You've been hired to entertain people through the power of television!"
	landmark_id = "Actor"
	id_type = /obj/item/card/id/syndicate

	flags = ANTAG_OVERRIDE_JOB | ANTAG_SET_APPEARANCE | ANTAG_CHOOSE_NAME | ANTAG_RANDOM_EXCEPTED

	hard_cap = 7
	hard_cap_round = 10
	initial_spawn_req = 1
	initial_spawn_target = 1
	show_objectives_on_creation = 0 //actors are not antagonists and do not need the antagonist greet text

	station_crew_involved = FALSE

/datum/antagonist/actor/Initialize()
	. = ..()
	if(config.game.actor_min_age)
		min_player_age = config.game.actor_min_age

/datum/antagonist/actor/greet(datum/mind/player)
	if(!..())
		return

	player.current.show_message("You work for [GLOB.using_map.company_name], tasked with the production and broadcasting of entertainment to all of its assets.")
	player.current.show_message("Entertain the crew! Try not to disrupt them from their work too much and remind them how great [GLOB.using_map.company_name] is!")

/datum/antagonist/actor/equip(mob/living/carbon/human/player)
	player.equip_to_slot_or_del(new /obj/item/clothing/under/chameleon(src), slot_w_uniform)
	player.equip_to_slot_or_del(new /obj/item/clothing/shoes/chameleon(src), slot_shoes)
	player.equip_to_slot_or_del(new /obj/item/device/radio/headset/entertainment(src), slot_l_ear)
	var/obj/item/card/id/centcom/ERT/C = new(player.loc)
	C.assignment = "Actor"
	player.set_id_info(C)
	player.equip_to_slot_or_del(C,slot_wear_id)

	return 1

/mob/proc/join_as_actor()
	set category = "OOC"
	set name = "Join as Actor"
	set desc = "Join as an Actor to entertain the crew through television!"

	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(src, SPAN_WARNING("Please wait for round start."))
		return

	if(jobban_isbanned(src, MODE_ACTOR))
		to_chat(src, SPAN_WARNING("You are jobbanned from the actor role."))
		return

	if(!MayRespawn(TRUE) || !GLOB.actor.can_become_antag(mind, TRUE))
		return

	if(alert("Are you sure you'd like to join as an actor?", "Confirmation", "Yes", "No") == "No")
		return

	if(!SSeams.CheckForAccess(client))
		return

	if(isghost(src) || isnewplayer(src))
		if(GLOB.actor.current_antagonists.len >= GLOB.actor.hard_cap)
			to_chat(src, SPAN_WARNING("No more actors may spawn at the current time."))
			return
		GLOB.actor.create_default(src)
	else
		to_chat(src, SPAN_WARNING("You must be observing or be a new player to spawn as an actor."))
