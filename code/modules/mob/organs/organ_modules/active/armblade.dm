/obj/item/melee/implant/armblade
	name = "armblade"
	desc = "A mechanical blade deployed from your arm. The favourite hidden weapon of many criminal types."
	icon = 'icons/obj/implants.dmi'
	icon_state = "armblade"
	item_state = "armblade"
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("stabbed", "chopped", "cut")
	mod_weight = 0.75
	mod_reach = 1
	mod_handy = 1.25
	armor_penetration = 25
	sharp = TRUE
	edge = TRUE
	force = 25

/obj/item/organ_module/active/simple/armblade
	name = "embedded armblade"
	desc = "A mechanical blade designed to be inserted into an arm. Gives you a nice advantage in a brawl."
	action_button_name = "Deploy armblade"
	icon_state = "armblade"
	matter = list(MATERIAL_STEEL = 30)
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/melee/implant/armblade
	available_in_charsetup = TRUE
