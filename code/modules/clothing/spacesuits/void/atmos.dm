
// Normal
/obj/item/clothing/head/helmet/space/void/atmos
	name = "atmospherics voidhelmet"
	desc = "A flame-retardant voidsuit helmet with a self-repairing visor and light anti-radiation shielding."
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	item_state_slots = list(
		slot_l_hand_str = "atmos_helm",
		slot_r_hand_str = "atmos_helm",
		)
	armor = list(melee = 50, bullet = 45, laser = 70, energy = 45, bomb = 35, bio = 100)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual_low"
	rad_resist_type = /datum/rad_resist/void_med

/obj/item/clothing/suit/space/void/atmos
	name = "atmos voidsuit"
	desc = "A durable voidsuit with advanced temperature-regulation systems as well as minor radiation protection. Well worth the price."
	icon_state = "rig-atmos"
	item_state_slots = list(
		slot_l_hand_str = "atmos_voidsuit",
		slot_r_hand_str = "atmos_voidsuit",
	)
	armor = list(melee = 50, bullet = 45, laser = 70, energy = 45, bomb = 35, bio = 100)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/construction/rcd)
	rad_resist_type = /datum/rad_resist/void_med

/obj/item/clothing/suit/space/void/atmos/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/atmos
	boots = /obj/item/clothing/shoes/magboots

// Advanced
/obj/item/clothing/head/helmet/space/void/atmos/alt
	name = "atmos hardsuit helmet"
	desc = "A voidsuit helmet plated with an expensive heat and radiation resistant ceramic."
	icon_state = "rig0-atmosalt"
	item_state = "atmosalt_helm"
	armor = list(melee = 50, bullet = 45, laser = 90, energy = 45, bomb = 45, bio = 100)
	max_heat_protection_temperature = ATMOS_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light"

/obj/item/clothing/suit/space/void/atmos/alt
	desc = "An expensive NanoTrasen voidsuit, rated to withstand extreme heat and even minor radiation without exceeding room temperature within."
	icon_state = "rig-atmosalt"
	name = "atmos hardsuit"
	armor = list(melee = 50, bullet = 45, laser = 90, energy = 45, bomb = 45, bio = 100)
	max_heat_protection_temperature = ATMOS_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/void/atmos/alt/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/atmos/alt
	boots = /obj/item/clothing/shoes/magboots
