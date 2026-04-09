
// Normal
/obj/item/clothing/head/helmet/space/void/engineering
	name = "engineering voidhelmet"
	desc = "A sturdy looking voidsuit helmet rated to protect against radiation."
	icon_state = "eng_helm"
	item_state = "eng_helm"
	siemens_coefficient = 0.3
	armor_values = alist(melee = 60, bullet = 50, laser = 60, energy = 45, bomb = 35, bio = 100)
	rad_resist_type = /datum/rad_resist/void_engi_salvage

/obj/item/clothing/suit/space/void/engineering
	name = "engineering voidsuit"
	desc = "A run-of-the-mill service voidsuit with all the plating and radiation protection required for industrial work in vacuum."
	icon_state = "eng_voidsuit"
	item_state = "eng_voidsuit"
	siemens_coefficient = 0.3
	armor_values = alist(melee = 60, bullet = 50, laser = 60, energy = 45, bomb = 35, bio = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/construction/rcd)
	rad_resist_type = /datum/rad_resist/void_engi_salvage

/obj/item/clothing/suit/space/void/engineering/New()
	..()
	A_LAZYSET(slowdown_per_slot, slot_wear_suit, 1)

/obj/item/clothing/suit/space/void/engineering/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering
	boots = /obj/item/clothing/shoes/magboots

// Advanced
/obj/item/clothing/head/helmet/space/void/engineering/alt
	name = "engineering hardsuit helmet"
	desc = "A heavy, radiation-shielded voidsuit helmet with a surprisingly comfortable interior."
	icon_state = "engalt_helm"
	item_state = "engalt_helm"
	armor_values = alist(melee = 80, bullet = 70, laser = 60, energy = 65, bomb = 35, bio = 100)
	light_overlay = "helmet_light_dual_low"
	rad_resist_type = /datum/rad_resist/suit_radiation

/obj/item/clothing/suit/space/void/engineering/alt
	name = "engineering hardsuit"
	desc = "A bulky industrial voidsuit. It's a few generations old, but a reliable design and radiation shielding make up for the lack of climate control."
	icon_state = "engalt_voidsuit"
	item_state = "engalt_voidsuit"
	armor_values = alist(melee = 80, bullet = 70, laser = 60, energy = 65, bomb = 35, bio = 100)
	rad_resist_type = /datum/rad_resist/suit_radiation

/obj/item/clothing/suit/space/void/engineering/alt/New()
	..()
	A_LAZYSET(slowdown_per_slot, slot_wear_suit, 2)

/obj/item/clothing/suit/space/void/engineering/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering/alt
	boots = /obj/item/clothing/shoes/magboots

// For putting out reactor core fires
/obj/item/clothing/head/helmet/space/void/engineering/meltdown
	name = "meltdown voidhelmet"
	desc = "A massive looking voidsuit helmet rated to protect against extreme heat and radiation."
	icon_state = "rad_helm"
	item_state = "rad_helm"
	siemens_coefficient = 0.15
	armor_values = alist(melee = 55, bullet = 45, laser = 130, energy = 65, bomb = 65, bio = 100)
	rad_resist_type = /datum/rad_resist/suit_radiation
	max_heat_protection_temperature = ATMOS_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/void/engineering/meltdown
	name = "meltdown voidsuit"
	desc = "A heavy-duty service voidsuit designed to be worn while dealing during *major* emergencies involving plasteel-melting heat and extreme radiation levels. Even though it's massive, the plating is quite soft and brittle, hence does not provide much defense against brute force."
	icon_state = "rad_voidsuit"
	item_state = "rad_voidsuit"
	siemens_coefficient = 0.15
	armor_values = alist(melee = 55, bullet = 45, laser = 130, energy = 65, bomb = 65, bio = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/construction/rcd, /obj/item/device/geiger)
	rad_resist_type = /datum/rad_resist/suit_radiation
	max_heat_protection_temperature = ATMOS_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/void/engineering/meltdown/New()
	..()
	A_LAZYSET(slowdown_per_slot, slot_wear_suit, 3)

/obj/item/clothing/suit/space/void/engineering/meltdown/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/engineering/meltdown
	boots = /obj/item/clothing/shoes/magboots
