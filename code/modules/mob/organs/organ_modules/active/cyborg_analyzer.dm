/obj/item/organ_module/active/simple/cyborg_analyzer
	name = "retractable cyborg analyzer"
	desc = "A built-in cyborg analyzer for on-the-go diagnostics."
	icon_state = "augment-tool"
	action_button_name = "Deploy cyborg analyzer"
	allowed_organs = list(BP_R_HAND, BP_L_HAND)
	holding_type = /obj/item/device/robotanalyzer
	available_in_charsetup = TRUE
	cpu_load = 1
	w_class = 1
	augment_cost = 2
	origin_tech = list(TECH_ENGINEERING = 4, TECH_BIO = 2, TECH_MATERIAL = 4)
	matter = list(
		MATERIAL_STEEL = 2000,
		MATERIAL_PLASTIC = 3000,
		MATERIAL_GOLD = 50
	)
