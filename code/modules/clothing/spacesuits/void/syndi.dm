//Syndicate rig
/obj/item/clothing/head/helmet/space/void/syndi
	name = "blood-red voidsuit helmet"
	desc = "An advanced helmet designed for work in special operations. Property of Gorlex Marauders."
	icon_state = "rig0-syndie"
	item_state = "syndie_helm"
	armor = list(melee = 80, bullet = 100, laser = 120, energy = 35, bomb = 30, bio = 100)
	siemens_coefficient = 0.3
	species_restricted = list(SPECIES_HUMAN)
	camera = /obj/machinery/camera/network/syndicate
	light_overlay = "helmet_light_green" //todo: species-specific light overlays
	rad_resist_type = /datum/rad_resist/void_syndi

/obj/item/clothing/suit/space/void/syndi
	icon_state = "rig-syndie"
	name = "blood-red voidsuit"
	desc = "An advanced suit that protects against injuries during special operations. Property of Gorlex Marauders."
	item_state_slots = list(
		slot_l_hand_str = "syndie_voidsuit",
		slot_r_hand_str = "syndie_voidsuit",
	)
	w_class = ITEM_SIZE_LARGE //normally voidsuits are bulky but the syndi voidsuit is 'advanced' or something
	armor = list(melee = 80, bullet = 100, laser = 120, energy = 35, bomb = 30, bio = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/one_hand,/obj/item/handcuffs)
	siemens_coefficient = 0.3
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL)
	rad_resist_type = /datum/rad_resist/void_syndi

/datum/rad_resist/void_syndi
	alpha_particle_resist = 59.4 MEGA ELECTRONVOLT
	beta_particle_resist = 13.2 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/suit/space/void/syndi/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 0

/obj/item/clothing/suit/space/void/syndi/prepared/New()
	..()

/obj/item/clothing/suit/space/void/syndi/prepared/Initialize()
	helmet = /obj/item/clothing/head/helmet/space/void/syndi
	. = ..()
