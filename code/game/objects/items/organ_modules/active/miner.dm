GLOBAL_LIST_INIT(om_multitool_items, list(
	/obj/item/screwdriver,
	/obj/item/wrench,
	/obj/item/weldingtool,
	/obj/item/crowbar,
	/obj/item/wirecutters,
	/obj/item/device/analyzer
))

/obj/item/organ_module/active/multitool/miner
	name = "embedded mining multitool"
	desc = "A specialized mining multitool frequently purchased by the guild, it allows a miner to free up the space taken by some of their bulkier equipment. Includes an emergency radio, just in case."
	verb_name = "Deploy mining tool"
	items = list(
		/obj/item/wrench,
		/obj/item/pickaxe/drill,
		/obj/item/device/depth_scanner,
		/obj/item/shovel,
		/obj/item/device/radio/off,
		/obj/item/screwdriver
	)
