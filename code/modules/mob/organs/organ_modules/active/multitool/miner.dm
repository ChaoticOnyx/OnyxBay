/obj/item/organ_module/active/multitool/miner
	name = "embedded mining multitool"
	desc = "A specialized mining multitool frequently purchased by the guild, it allows a miner to free up the space taken by some of their bulkier equipment. Includes an emergency radio, just in case."
	action_button_name = "Deploy mining tool"
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	items = list(
		/obj/item/wrench,
		/obj/item/device/depth_scanner,
		/obj/item/shovel,
		/obj/item/device/radio/off,
		/obj/item/screwdriver
	)
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 3
	cpu_load = 1
	w_class = 3
	allowed_roles = list(/datum/job/mining)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_MECHANICAL
