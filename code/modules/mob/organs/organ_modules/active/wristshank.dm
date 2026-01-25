/obj/item/melee/implant/armblade/wristshank
	name = "wristshank"
	desc = "A stubby blade deployed from your wrist. Get shanking."
	icon = 'icons/obj/implants.dmi'
	icon_state = "wristshank"
	item_state = "wristshank"
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("shanked", "slashed", "gored")
	edge = TRUE
	sharp = TRUE
	force = 11
	mod_weight = 0.6
	mod_reach = 0.6
	mod_handy = 1.2
	armor_penetration = 20

/obj/item/organ_module/active/simple/wristshank
	name = "embedded wristshank"
	desc = "A stubby blade designed to be inserted into a wrist. It gives you a nice advantage in a brawl."
	action_button_name = "Deploy wristshank"
	icon_state = "wristshank"
	matter = list(
		MATERIAL_STEEL = 2000,
		MATERIAL_PLASTIC = 3000,
		MATERIAL_GLASS = 1000
	)
	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	holding_type = /obj/item/melee/implant/armblade/wristshank
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	available_in_charsetup = FALSE
	origin_tech = list(TECH_COMBAT = 2, TECH_BIO = 3, TECH_MATERIAL = 2)
	loadout_cost = 0
	augment_cost = 5
	cpu_load = 1
	w_class = 1
