/datum/game_mode/traitoramongus
	name = "traitor among us"
	config_tag = "traitoramongus"
	var/datum/mind/chosentraitor

/datum/game_mode/traitoramongus/announce()
	world << "<B>The current game mode is - Traitor among us!</B>"
	world << "<B>Somebody is a traitor!</B>"

/datum/game_mode/traitoramongus/pre_setup()

	for(var/obj/machinery/power/apc/a in world)
		a.cell.charge = 0
	for(var/obj/machinery/power/smes/a in world)
		a.charge = 0
	for(var/obj/machinery/door/airlock/a in world)
		a.locked = 1
	for(var/obj/item/device/radio/intercom/a in world)
		a.broadcasting = 1

	var/datum/mind/traitor = pick(get_possible_traitors())
	traitor.special_role = "Hidden Killer"
	chosentraitor = traitor

	config.allow_ai = 0
	return 1
/datum/game_mode/traitoramongus/post_setup()
	for(var/mob/living/carbon/human/player in world)
		equip_player(player)

		var/list/L = list()
		for(var/area/shuttle/arrival/station/S in world)
			L += S
		var/A = pick(L)
		var/list/NL = list()
		for(var/turf/T in A)
			if(!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					NL += T
		player.loc = pick(NL)



/datum/game_mode/traitoramongus/latespawn(var/mob/living/carbon/human/player)
	equip_player(player)
	var/list/L = list()
	for(var/area/shuttle/arrival/station/S in world)
		L += S
	var/A = pick(L)
	var/list/NL = list()
	for(var/turf/T in A)
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				NL += T
	player.loc = pick(NL)


/datum/game_mode/traitoramongus/proc/equip_player(var/mob/living/carbon/human/player)
	del player.wear_id
	del player.shoes
	del player.belt
	del player.gloves
	del player.glasses
	del player.head
	del player.r_store
	del player.l_store
	del player.wear_suit
	del player.w_uniform
	del player.ears

	var/uniform = pick(/obj/item/clothing/under/color/black,/obj/item/clothing/under/color/blue,/obj/item/clothing/under/color/green,/obj/item/clothing/under/color/grey,/obj/item/clothing/under/color/orange,/obj/item/clothing/under/color/pink,/obj/item/clothing/under/color/red,/obj/item/clothing/under/color/white,/obj/item/clothing/under/color/yellow)

	player.equip_if_possible(new uniform(player),player.slot_w_uniform)

	player.equip_if_possible(new /obj/item/device/pda,player.slot_belt)
	player.belt:owner = player.name

/datum/game_mode/traitoramongus/proc/get_possible_traitors()
	var/list/candidates = list()
	for(var/mob/new_player/player in world)
		if (player.client && player.ready)
			if(player.preferences.be_syndicate)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				candidates += player.mind

	return candidates

/datum/game_mode/traitoramongus/check_win()
	var/mob/living/carbon/human/mob = chosentraitor.current
	if(mob.stat != 2)
		var/humansalive = 0
		for(var/mob/living/carbon/human/h in world)
			if(h.stat != 2 && h != mob)
				humansalive += 1
		if(humansalive == 0)
			return 1
	return 0

/datum/game_mode/traitoramongus/check_finished()
	return 0
	var/mob/living/carbon/human/mob = chosentraitor.current
	var/humansalive = 0
	for(var/mob/living/carbon/human/h in world)
		if(h.mind && h != mob && h.stat != 2)
			humansalive += 1
	if(humansalive > 0)
		return 1
	else
		return 0

/datum/game_mode/traitoramongus/declare_completion()
	var/traitor_name

	if(chosentraitor.current)
		traitor_name = "[chosentraitor.current.real_name] (played by [chosentraitor.key])"
	else
		traitor_name = "[chosentraitor.key] (character destroyed)"
	if(check_win())
		world << "<FONT size = 3><B>[traitor_name] has killed everyone else, and is the sole person alive on the station</B></FONT>"
	else
		world << "<FONT size = 3><B>[traitor_name] died before managing to become the sole person alive</B></FONT>"