/obj/item/organ_module/muscle
	name = "mechanical muscles"
	desc = "A set of mechanical muscles designed to be implanted into legs."
	allowed_organs = list(BP_R_LEG, BP_L_LEG)
	icon_state = "muscle"
	organ_tally = -0.1
	available_in_charsetup = TRUE
	augment_cost = 1
	cpu_load = 1
	w_class = 2
	origin_tech = list(TECH_COMBAT = 6, TECH_ENGINEERING = 6, TECH_BIO = 6)
	matter = list(
		MATERIAL_GOLD = 1000,
		MATERIAL_PLASTEEL = 3000,
		MATERIAL_SILVER = 100
	)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL | OM_FLAG_MECHANICAL
/// later will be used for jumps
