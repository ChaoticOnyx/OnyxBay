
/obj/item/melee/implant/claws
	name = "claws"
	desc = "A set of claws deployed from the tips of your fingers. Great for cutting people into ribbons."
	icon_state = "wolverine"
	icon = 'icons/obj/implants.dmi'

/obj/item/organ_module/active/simple/wolverine
	name = "embedded claws"
	desc = "A variant on the popular armblade, these claws allow for a more traditional unarmed brawl style while still mantaining your advantage."
	action_button_name = "Deploy embedded claws"
	icon_state = "wolverine"
	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	holding_type = /obj/item/melee/implant/claws
	matter = list(MATERIAL_STEEL = 40)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	available_in_charsetup = FALSE
	origin_tech = list(TECH_COMBAT = 4, TECH_POWER = 3)
