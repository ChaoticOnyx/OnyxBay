/obj/item/organ_module/active/simple/armsmg
	name = "embedded pistol"
	desc = "A pistol designed to be embedded into prosthetics. Gives you a nice advantage in a firefight"
	verb_name = "Deploy embedded pistol"
	icon_state = "armsmg"
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 5)
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/gun/projectile/pistol/holdout
