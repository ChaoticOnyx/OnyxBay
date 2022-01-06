/obj/item/rig/combat
	name = "combat powersuit control module"
	desc = "A sleek and dangerous powersuit for active combat."
	icon_state = "security_rig"
	suit_type = "combat powersuit"
	armor = list(melee = 80, bullet = 65, laser = 55, energy = 15, bomb = 80, bio = 100, rad = 60)
	online_slowdown = 1
	offline_slowdown = 3
	offline_vision_restriction = TINT_HEAVY
	allowed = list(/obj/item/device/flashlight, /obj/item/tank,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/handcuffs,/obj/item/device/t_scanner, /obj/item/rcd, /obj/item/crowbar, \
	/obj/item/screwdriver, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/wrench, /obj/item/device/multitool, \
	/obj/item/device/radio, /obj/item/device/analyzer,/obj/item/storage/briefcase/inflatable, /obj/item/melee/baton, /obj/item/gun, \
	/obj/item/storage/firstaid, /obj/item/reagent_containers/hypospray, /obj/item/roller, /obj/item/device/suit_cooling_unit)

	chest_type = /obj/item/clothing/suit/space/rig/combat
	helm_type = /obj/item/clothing/head/helmet/space/rig/combat
	boot_type = /obj/item/clothing/shoes/magboots/rig/combat
	glove_type = /obj/item/clothing/gloves/rig/combat

/obj/item/clothing/head/helmet/space/rig/combat
	light_overlay = "helmet_light_dual_green"
	species_restricted = list(SPECIES_HUMAN, SPECIES_UNATHI)

/obj/item/clothing/suit/space/rig/combat
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/combat
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/combat
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI)

/obj/item/rig/combat/equipped
	initial_modules = list(
		/obj/item/rig_module/mounted/egun,
		/obj/item/rig_module/vision/thermal,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/chem_dispenser/combat,
		/obj/item/rig_module/cooling_unit
		)

//Extremely OP, hardly standard issue equipment
//Now a little less OP
/obj/item/rig/military
	name = "military powersuit control module"
	desc = "An austere powersuit used by paramilitary groups and real soldiers alike."
	icon_state = "military_rig"
	suit_type = "military powersuit"
	armor = list(melee = 80, bullet = 75, laser = 60, energy = 15, bomb = 80, bio = 100, rad = 30)
	online_slowdown = 1
	offline_slowdown = 3
	offline_vision_restriction = TINT_HEAVY
	allowed = list(/obj/item/device/flashlight, /obj/item/tank,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/handcuffs,/obj/item/device/t_scanner, /obj/item/rcd, /obj/item/crowbar, \
	/obj/item/screwdriver, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/wrench, /obj/item/device/multitool, \
	/obj/item/device/radio, /obj/item/device/analyzer,/obj/item/storage/briefcase/inflatable, /obj/item/melee/baton, /obj/item/gun, \
	/obj/item/storage/firstaid, /obj/item/reagent_containers/hypospray, /obj/item/roller, /obj/item/device/suit_cooling_unit)

	chest_type = /obj/item/clothing/suit/space/rig/military
	helm_type = /obj/item/clothing/head/helmet/space/rig/military
	boot_type = /obj/item/clothing/shoes/magboots/rig/military
	glove_type = /obj/item/clothing/gloves/rig/military

/obj/item/clothing/head/helmet/space/rig/military
	light_overlay = "helmet_light_dual_green"
	species_restricted = list(SPECIES_HUMAN)

/obj/item/clothing/suit/space/rig/military
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI)

/obj/item/clothing/shoes/magboots/rig/military
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI)

/obj/item/clothing/gloves/rig/military
	species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI)

/obj/item/rig/military/equipped
	initial_modules = list(
		/obj/item/rig_module/mounted/egun,
		/obj/item/rig_module/vision/multi,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/chem_dispenser/injector,
		/obj/item/rig_module/cooling_unit
		)
