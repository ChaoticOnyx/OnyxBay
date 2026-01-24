/obj/item/organ_module/active/simple/lighter
	name = "integrated lighter"
	desc = "A compact internal lighter for a quick flame whenever you need it."
	icon_state = "lighter-aug"
	action_button_name = "Deploy lighter"
	holding_type = /obj/item/flame/lighter/zippo
	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 1
	w_class = 1
	cpu_load = 0
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
