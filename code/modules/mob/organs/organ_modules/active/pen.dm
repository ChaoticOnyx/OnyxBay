/obj/item/organ_module/active/simple/pen
	name = "retractable pen"
	desc = "A discreet pen integrated into your hand for quick notes and signatures."
	icon_state = "augment"
	action_button_name = "Deploy Pen"
	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	holding_type = /obj/item/pen
	loadout_cost = 1
	available_in_charsetup = TRUE
	w_class = 1
	cpu_load = 0
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	slot_flags = SLOT_DENYPOCKET
