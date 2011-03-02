/datum/game_mode/zombie
	name = "zombie"
	config_tag = "zombie"

/datum/game_mode/zombie/announce()
	world << "<B>The current game mode is - Zombie!</B>"

/datum/game_mode/zombie/pre_setup()
	config.allow_ai = 0
	power_failure()
	for(var/obj/machinery/light/Light in world) if(Light.z < 5)
		Light.broken()

	// remove fighting items to avoid too much fighting zombies
	// encourage running :)
	for(var/obj/item/weapon/gun/G in world) del G
	for(var/obj/item/weapon/scalpel/S in world) del S
	for(var/obj/item/weapon/circular_saw/C in world) del C

	// make the mode more scary by deleting all radios
	for(var/obj/item/device/radio/R in world) del R

	// add a charge to all cells to make it possible to power the station
	for(var/obj/item/weapon/cell/cell in world) cell.charge = 100

	return 1

/datum/game_mode/zombie/post_setup()
	for(var/mob/living/carbon/human/player in world)
		equip_zombie(player)


/datum/game_mode/zombie/proc/equip_zombie(var/mob/living/carbon/human/player)
	// remove the headset
	if(player.ears) del player.ears

/datum/game_mode/zombie/latespawn(var/mob/living/carbon/human/player)
	equip_zombie(player)