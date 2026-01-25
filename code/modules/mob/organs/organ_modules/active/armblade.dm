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
	matter = list(
		MATERIAL_PLASTIC = 2000,
		MATERIAL_PLATINUM = 3000,
		MATERIAL_GOLD = 1500,
		MATERIAL_PLASTEEL = 2000
	)
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_MECHANICAL | OM_FLAG_BIOLOGICAL
	holding_type = /obj/item/melee/implant/armblade
	available_in_charsetup = FALSE
	w_class = 2
	cpu_load = 2
	origin_tech = list(TECH_COMBAT = 4, TECH_ENGINEERING = 3)
