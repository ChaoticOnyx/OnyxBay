/obj/item/shield/buckler/arm
	name = "arm shield"
	desc = "An embedded shield adept at blocking objects from connecting with the torso of the shield wielder."
	icon_state = "eshield1"
	item_state = "eshield1"
	attack_verb = list("bashed")

/obj/item/organ_module/active/simple/armshield
	name = "embedded shield"
	desc = "An embedded shield designed to be inserted into an arm."
	verb_name = "Deploy embedded shield"
	icon_state = "armshield"
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 5)
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/shield/buckler/arm
