/datum/game_mode/derelict
	name = "derelict"
	config_tag = "derelict"

/datum/game_mode/derelict/announce()
	world << "<B>The current game mode is - Derelict!</B>"
	world << "<B>Salvage all the parts you can!</B>"

/datum/game_mode/derelict/pre_setup()

	world << "\red <B> Derelict takes time to load, please wait</B>"

	wreakstation()




	config.allow_ai = 0
	return 1
/datum/game_mode/derelict/post_setup()
	for(var/mob/living/carbon/human/player in world)
		equip_scavenger(player)

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


/datum/game_mode/derelict/proc/equip_scavenger(var/mob/living/carbon/human/player)
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

	player.wear_suit = new /obj/item/clothing/suit/fire(player)
	player.wear_suit.layer = 40


	player.w_uniform = new /obj/item/clothing/under/color/black(player)
	player.w_uniform.layer = 40
	player.wear_id = new /obj/item/weapon/card/id(player)
	player.wear_id.registered = player.real_name
	player.wear_id.assignment = "Scavenger"
	player.wear_id.name = "[player.real_name]'s Scavenger ID"
	player.wear_id.layer = 40
	player.shoes = new /obj/item/clothing/shoes/black(player)
	player.shoes.layer = 40
	player.belt = new /obj/item/weapon/storage/utilitybelt(player)
	player.belt.layer = 40
	if(prob(50))
		player.r_hand = new /obj/item/weapon/storage/toolbox/mechanical(player)
	else
		player.r_hand = new /obj/item/weapon/storage/toolbox/electrical(player)
	player.r_hand.layer = 40
	if(prob(15))
		player.r_store = new /obj/item/device/multitool(player)
		player.r_store.layer = 40
	if(prob(30))
		player.gloves = new /obj/item/clothing/gloves/yellow(player)
		player.gloves.layer = 40
	var/obj/item/weapon/storage/backpack/bp = new /obj/item/weapon/storage/backpack(player)
	player.back = bp
	player.back.layer = 40
	new /obj/item/weapon/circuitry(player.back)
	new /obj/item/weapon/circuitry(player.back)
/*		var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/under/w_uniform = null
//	var/obj/item/device/radio/w_radio = null
	var/obj/item/clothing/shoes/shoes = null
	var/obj/item/weapon/belt = null
	var/obj/item/clothing/gloves/gloves = null
	var/obj/item/clothing/glasses/glasses = null
	var/obj/item/clothing/head/head = null
	var/obj/item/clothing/ears/ears = null
	var/obj/item/weapon/card/id/wear_id = null
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null*/

/datum/game_mode/derelict/latespawn(var/mob/living/carbon/human/player)
	equip_scavenger(player)

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