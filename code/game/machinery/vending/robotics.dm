
//This one's from bay12
/obj/machinery/vending/robotics
	name = "Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."

	icon_state = "robotics"

	req_access = list(access_robotics)

	vending_sound = SFX_VENDING_GENERIC

	component_types = list(
		/obj/item/vending_cartridge/robotics
		)

	legal = list(
		/obj/item/stack/cable_coil = 4,
		/obj/item/device/flash/synthetic = 4,
		/obj/item/cell = 4,
		/obj/item/device/healthanalyzer = 2,
		/obj/item/device/robotanalyzer = 2,
		/obj/item/scalpel = 1,
		/obj/item/circular_saw = 1,
		/obj/item/tank/anesthetic = 2,
		/obj/item/clothing/mask/breath/medical = 5,
		/obj/item/screwdriver = 2,
		/obj/item/crowbar = 2
		)

	illegal = list(
		/obj/item/device/flash = 2
		)

/obj/item/vending_cartridge/robotics
	icon_state = "refill_parts"
	build_path = /obj/machinery/vending/robotics
