/obj/item/clothing/head/helmet/space/rig/syndi
	light_overlay = "helmet_light_dual_green"
	camera = /obj/machinery/camera/network/syndicate

/obj/item/rig/syndi
	name = "crimson powersuit control module"
	desc = "A blood-red powersuit featuring some fairly illegal technology."
	icon_state = "merc_rig"
	suit_type = "crimson powersuit"
	armor = list(melee = 80, bullet = 65, laser = 65, energy = 15, bomb = 80, bio = 100, rad = 60)
	online_slowdown = 1
	offline_slowdown = 3
	offline_vision_restriction = TINT_HEAVY

	helm_type = /obj/item/clothing/head/helmet/space/rig/syndi
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword,/obj/item/handcuffs)

	initial_modules = list(
		/obj/item/rig_module/mounted,
		/obj/item/rig_module/vision/thermal,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/chem_dispenser/combat,
		/obj/item/rig_module/fabricator/energy_net
		)

//Has most of the modules removed
/obj/item/rig/syndi/empty
	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/electrowarfare_suite, //might as well
		)

/obj/item/rig/syndi/heavy
	name = "heavy crimson powersuit control module"
	desc = "A blood-red powersuit featuring some fairly illegal technology and real curves."
	icon_state = "merc_rig_heavy"
	suit_type = "heavy crimson powersuit"
	armor = list(melee = 90, bullet = 80, laser = 80, energy = 25, bomb = 90, bio = 100, rad = 70)
	offline_slowdown = 4
	online_slowdown = 2

/obj/item/rig/syndi/heavy/empty
	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/electrowarfare_suite, //might as well
		)