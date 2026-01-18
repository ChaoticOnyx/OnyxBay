/obj/item/organ_module/active/simple/armshield
	name = "embedded shield"
	desc = "An embedded shield designed to be inserted into an arm."
	action_button_name = "Deploy embedded shield"
	icon_state = "armshield"
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 5)
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/shield/energy
	available_in_charsetup = FALSE
	origin_tech = list(TECH_COMBAT = 4, TECH_POWER = 3)
