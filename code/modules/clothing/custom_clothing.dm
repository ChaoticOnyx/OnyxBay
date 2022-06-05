/////////////////////////////////////////////////////////////////////////
// Some SPECIAL clothes for the exceptionally important onyx residents //
/////////////////////////////////////////////////////////////////////////

// HentaiStorm
/obj/item/clothing/suit/storage/toggle/det_trench/gilded
	name = "detective gilded trenchcoat"
	desc = "A gilded trenchcoat sewn for especially distinguished detectives."
	icon_state  = "detectivegold_open"
	item_state  = "detectivegold_open"
	icon_open   = "detectivegold_open"
	icon_closed = "detectivegold"
	matter = list(MATERIAL_GOLD = 2000)

// Schutze88
/obj/item/clothing/suit/armor/hos/jensen/fieldcoat
	name = "military trenchcoat"
	desc = "A military trenchcoat with a leather belt and long, custom collar. Looks kinda old, but is kept in a good shape."
	icon_state = "dalek_coat"
	item_state = "dalek_coat"
	armor = list(melee = 45, bullet = 35, laser = 35, energy = 10, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/hos/jensen/fieldcoat/mob_can_equip(mob/user)
	.=..()
	if(user.gender == FEMALE)
		to_chat(user, SPAN("warning", "You aren't sure you'll fit in this fascist cloth..."))
		return 0

// TaTarin
/obj/item/clothing/head/helmet/police
	name = "police helmet"
	desc = "It's a helmet specifically designed for police use. Comfortable and robust."
	icon_state = "helmet_police"
	valid_accessory_slots = null
	body_parts_covered = HEAD|FACE|EYES //face shield
	armor = list(melee = 55, bullet = 55, laser = 55, energy = 25, bomb = 35, bio = 5, rad = 0)
	siemens_coefficient = 0.6
	action_button_name = "Toggle Visor"

/obj/item/clothing/head/helmet/police/attack_self(mob/user)
	togglevisor(user)

/obj/item/clothing/suit/storage/vest/police
	name = " police armored vest"
	desc = "A synthetic armor vest with a large webbing and additional ballistic plates. Has a name badge on the frontal plate, that reads 'Sgt. Bauer'"
	icon_state = "policevest"
	item_state = "policevest"
	armor = list(melee = 40, bullet = 40, laser = 45, energy = 15, bomb = 30, bio = 0, rad = 0)
	allowed = list(
		/obj/item/gun/energy,
		/obj/item/device/radio,
		/obj/item/device/flashlight,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/gun/projectile,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/handcuffs,
		/obj/item/gun/magnetic,
		/obj/item/grenade,
		)

//Terror

/obj/item/clothing/head/helmet/german
	name = "stahlhelm"
	desc = "A simple yet menacing looking steel helmet. Protects the head from bullets."
	icon_state = "wehrhelm"
	valid_accessory_slots = null
	body_parts_covered = HEAD
	armor = list(melee = 45, bullet = 60, laser = 45,energy = 10, bomb = 40, bio = 2, rad = 10)
	siemens_coefficient = 1
	has_visor = 0

//Schutze88

/obj/item/clothing/head/HoS/german
	name = "ancient cap"
	desc = "An ancient cap, how did it survived to these days?"
	icon_state = "capger"
	armor = list(melee = 25, bullet = 10, laser = 10,energy = 10, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/hos/german
	name = "ancient trenchcoat"
	desc = "An ancient trenchcoat, how did it survived to these days? There's a label on the neck that reads 'Hergestellt von Hugo Boss'"
	icon_state = "trenchcoatger"
	item_state = "trenchcoatger"
	armor = list(melee = 35, bullet = 15, laser = 15, energy = 10, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/hos/german/mob_can_equip(mob/user)
	.=..()
	if(user.gender == FEMALE)
		to_chat(user, SPAN("warning", "You aren't sure you'll fit in this men's cloth..."))
		return 0

// Item below belong to i-dont-fucking-know-who
// Please, sign it ASAP

/obj/item/clothing/suit/storage/toggle/forensics/customred
	name = "red jacket"
	desc = "A nice red forensics technician jacket."
	icon_state = "custom_forensics_red_long"
	item_state = "custom_forensics_red_long"

//NeinAnimas

/obj/item/clothing/suit/armor/hos/jensen/custom
	name = "stylish trenchcoat"
	desc = "A loose, unbelted trenchcoat of military style. Has a \"MILITA\" writen on chest."
	icon_state = "hostrench"
	item_state = "hostrench"
	armor = list(melee = 15, bullet = 10, laser = 10, energy = 10, bomb = 10, bio = 0, rad = 0)

// Item below belong to i-dont-fucking-know-who
// Please, sign it ASAP

/obj/item/clothing/suit/storage/toggle/det_trench/warfare
    name = "comfy greatcoat"
    desc = "A greatcoat that is holding small pieces of dirt and such. It feels underarmored, yet you're absolutely sure that it will keep out the cold."
    icon_state = "redcoat"
    armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/toggle/det_trench/warfare/mob_can_equip(mob/user)
	.=..()
	if(user.gender == FEMALE)
		to_chat(user, SPAN("warning", "You aren't sure you'll fit in this men's cloth..."))
		return 0

// AmiClerick

/obj/item/clothing/suit/storage/toggle/labcoat/amired
	name = "fancy labcoat"
	desc = "A suit that protects against minor chemical spills. This one looks especially special. Perhaps, its owner survived a fireaxey medbay massacre? Or just put it into a washing machine with some red cloth."
	icon_state = "amicoat"

/obj/item/clothing/suit/storage/toggle/labcoat/amired/toggle()
	set name = "Toggle Coat Buttons"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return 0

	to_chat(usr, "The buttonholes appear to be purely decorative. Oh.")

// Gremy4uu
/obj/item/clothing/suit/storage/vest/police_dark
	name = "police armored vest"
	desc = "A synthetic armor vest with a large webbing and additional ballistic plates. Instead of a label, there's a small picture of a bearded man beating someone down in a maintenance area."
	icon_state = "policevest_dark"
	item_state = "policevest_dark"
	armor = list(melee = 40, bullet = 40, laser = 45, energy = 15, bomb = 30, bio = 0, rad = 0)
	allowed = list(
		/obj/item/gun/energy,
		/obj/item/device/radio,
		/obj/item/device/flashlight,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/gun/projectile,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/handcuffs,
		/obj/item/gun/magnetic,
		/obj/item/grenade
		)

// NoTips
/obj/item/clothing/suit/fire/firefighter/atmos
	name = "atmospherics firesuit"
	desc = "A suit that protects you against your mistakes in the engineering."
	icon_state = "firesuit_atmos"

/obj/item/clothing/head/hardhat/atmos
	icon_state = "hardhat0_fireatmos"
	name = "atmospherics firesuit helmet"

/obj/item/device/modkit/fire_atmos
	name = "atmospherics firesuit modkit"
	desc = "A kit containing all the needed tools and parts to modify an firesuit into an atmospherics firesuit."
	icon_state = "modkit"

/obj/item/device/modkit/fire_atmos/New()
	..()
	parts = new /list(2)
	original = new /list(2)
	finished = new /list(2)

	parts[1] =	1
	original[1] = /obj/item/clothing/head/hardhat/red
	finished[1] = /obj/item/clothing/head/hardhat/atmos
	parts[2] =	1
	original[2] = /obj/item/clothing/suit/fire/firefighter
	finished[2] = /obj/item/clothing/suit/fire/firefighter/atmos
