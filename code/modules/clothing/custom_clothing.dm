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
	armor = list(melee = 45, bullet = 35, laser = 35, energy = 10, bomb = 10, bio = 0)

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
	visor_body_parts_covered = FACE|EYES
	armor = list(melee = 55, bullet = 55, laser = 55, energy = 25, bomb = 35, bio = 5)
	siemens_coefficient = 0.6
	action_button_name = "Toggle Visor"

/obj/item/clothing/head/helmet/police/attack_self(mob/user)
	togglevisor(user)

/obj/item/clothing/suit/storage/vest/police
	name = " police armored vest"
	desc = "A synthetic armor vest with a large webbing and additional ballistic plates. Has a name badge on the frontal plate, that reads 'Sgt. Bauer'"
	icon_state = "policevest"
	item_state = "policevest"
	armor = list(melee = 40, bullet = 40, laser = 45, energy = 15, bomb = 30, bio = 0)
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
	visor_body_parts_covered = NO_BODYPARTS
	armor = list(melee = 45, bullet = 60, laser = 45,energy = 10, bomb = 40, bio = 2)
	siemens_coefficient = 1

//Schutze88

/obj/item/clothing/head/HoS/german
	name = "ancient cap"
	desc = "An ancient cap, how did it survived to these days?"
	icon_state = "capger"
	armor = list(melee = 25, bullet = 10, laser = 10,energy = 10, bomb = 10, bio = 0)

/obj/item/clothing/suit/armor/hos/german
	name = "ancient trenchcoat"
	desc = "An ancient trenchcoat, how did it survived to these days? There's a label on the neck that reads 'Hergestellt von Hugo Boss'"
	icon_state = "trenchcoatger"
	item_state = "trenchcoatger"
	armor = list(melee = 35, bullet = 15, laser = 15, energy = 10, bomb = 10, bio = 0)

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
	armor = list(melee = 15, bullet = 10, laser = 10, energy = 10, bomb = 10, bio = 0)

// Item below belong to i-dont-fucking-know-who
// Please, sign it ASAP

/obj/item/clothing/suit/storage/toggle/det_trench/warfare
    name = "comfy greatcoat"
    desc = "A greatcoat that is holding small pieces of dirt and such. It feels underarmored, yet you're absolutely sure that it will keep out the cold."
    icon_state = "redcoat"
    armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

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
	armor = list(melee = 40, bullet = 40, laser = 45, energy = 15, bomb = 30, bio = 0)
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

// AnimeshkaTvar
/obj/item/clothing/head/helmet/space/void/syndi/clown_syndie
	name = "strange clown helmet"
	desc = "A strange helmet with a clown face on it. It looks like it was made by an unknown party."
	icon_state = "clown_syndie"
	item_state = "clown_syndie"
	item_state_slots = list(
		slot_l_hand_str = "syndie_clown",
		slot_r_hand_str = "syndie_clown",
	)

/obj/item/clothing/suit/space/void/syndi/clown_syndie
	name = "Syndicate “Honk” voidsuit"
	desc = "A suit that protects you against the void. It has a clown face on it."
	icon_state = "rig-syndie-clown"
	item_state = "rig-syndie-clown"
	item_state_slots = list(
		slot_l_hand_str = "syndie_clown",
		slot_r_hand_str = "syndie_clown",
	)

/obj/item/device/modkit/clown_syndie
	name = "clown syndie voidsuit modkit"
	desc = "A kit containing all the needed tools and parts to modify a voidsuit into a clown syndie voidsuit."
	icon_state = "modkit"

/obj/item/device/modkit/clown_syndie/New()
	..()
	parts = new /list(2)
	original = new /list(2)
	finished = new /list(2)

	parts[1] =	1
	original[1] =  /obj/item/clothing/head/helmet/space/void/syndi
	finished[1] = /obj/item/clothing/head/helmet/space/void/syndi/clown_syndie
	parts[2] =	1
	original[2] = /obj/item/clothing/suit/space/void/syndi
	finished[2] = /obj/item/clothing/suit/space/void/syndi/clown_syndie

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

/obj/item/clothing/head/dragon_skull
	name = "dragon skull"
	desc = "A skull of a fallen one. It's a bit heavy. And plasticy."
	icon_state = "dragon_skull"

// Animusin
/obj/item/clothing/suit/storage/toggle/heart_jacket
	name = "heart jacket"
	desc = "A black leather jacket with heart."
	icon_state = "heart_jacket"
	item_state = "heart_jacket"
	icon_open = "heart_jacket_open"
	icon_closed = "heart_jacket"
	body_parts_covered = UPPER_TORSO|ARMS
	initial_closed = TRUE

// Popky_dau
/obj/item/clothing/under/soviet/tcc
	name = "TCC uniform"
	desc = "For Magnitka!"
	icon_state = "soviet_tcc"

/obj/item/clothing/head/helmet/tcc
	name = "TCC army helmet"
	desc = "For Magnitka! Protects the head from Gaian sentiments."
	icon_state = "tcchelm"
	valid_accessory_slots = null
	body_parts_covered = HEAD
	visor_body_parts_covered = NO_BODYPARTS

/obj/item/device/modkit/helmet_tcc
	name = "TCC army helmet modkit"
	desc = "A kit containing all the needed tools and parts to modify a helmet into a TCC army helmet."
	icon_state = "modkit"

/obj/item/device/modkit/helmet_tcc/New()
	..()
	parts = new /list(1)
	original = new /list(1)
	finished = new /list(1)

	parts[1] =	1
	original[1] =  /obj/item/clothing/head/helmet
	finished[1] = /obj/item/clothing/head/helmet/tcc

// Sans andertale
/obj/item/clothing/suit/armor/vest/hazardcoat
	name = "ranger's coat"
	desc = "An armored coat with desert camo pattern."
	icon_state = "hazardcoat"
	//item_state = "armor"
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 25, bomb = 40, bio = 10)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS


/obj/item/device/modkit/hazardcoat
	name = "ranger coat modkit"
	desc = "A green coat with some kevlar inside it. Made specificly for warden's jacket."
	icon_state = "modkit"

/obj/item/device/modkit/hazardcoat/New()
	..()
	parts = new /list(1)
	original = new /list(1)
	finished = new /list(1)

	parts[1] =	1
	original[1] =  /obj/item/clothing/suit/armor/vest/warden
	finished[1] = /obj/item/clothing/suit/armor/vest/hazardcoat

/obj/item/gun/projectile/revolver/remington
	name = "sweet revenge"
	desc = "A very old revolver, based on the remington 1858. Uses .44 magnum rounds. There are 7 notches on this revolver."
	icon = 'icons/obj/guns/sr.dmi'
	icon_state = "remington"
	item_state = "webley"
	max_shells = 6
	caliber = ".44"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/c44

/obj/item/device/modkit/remington
	name = "remington 1858 modkit"
	desc = "Tools necessary to turn a .357 revolver into a remington."
	icon_state = "modkit"

/obj/item/device/modkit/remington/New()
	..()
	parts = new /list(1)
	original = new /list(1)
	finished = new /list(1)

	parts[1] =	1
	original[1] =  /obj/item/gun/projectile/revolver
	finished[1] = /obj/item/gun/projectile/revolver/remington

// TheUnknownOneBYND
/obj/item/clothing/under/color/odaycel
	name = "O-S jumpsuit"
	desc = "A seemingly custom-tailored brown jumpsuit. It's marked \"#O-S\" and has a serial number on its chest."
	color = "#663300"

/obj/item/clothing/under/color/odaycel/New()
	..()
	name = "O-S jumpsuit #[rand(1, 9999)]"


// Sekonda

/obj/item/clothing/suit/poncho/dominiancape
	name = "Award cape"
	desc = "A red silk cloak embroidered with gold threads"
	icon_state = "dominiancape"
	item_state = "dominiancape"

// Deimosen
/obj/item/clothing/suit/armor/fieldcoat_light
	name = "military trenchcoat"
	desc = "A military trenchcoat with a leather belt and long, custom collar. This one's armor was striped away."

	icon_state = "fieldcoat_light"
	item_state = "fieldcoat_light"

	body_parts_covered = UPPER_TORSO | LOWER_TORSO | ARMS | LEGS
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 5, bio = 0)
