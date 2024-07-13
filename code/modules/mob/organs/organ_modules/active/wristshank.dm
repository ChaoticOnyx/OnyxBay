/obj/item/melee/implant/armblade/wristshank
	name = "wristshank"
	desc = "A stubby blade deployed from your wrist. Get shanking."
	icon = 'icons/obj/implants.dmi'
	icon_state = "wristshank"
	item_state = null
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("shanked", "slashed", "gored")
	edge = TRUE
	sharp = TRUE
	force = 11
	mod_weight = 0.6
	mod_reach = 0.6
	mod_handy = 1.2
	armor_penetration = 50

/obj/item/organ_module/active/simple/wristshank
	name = "embedded wristshank"
	desc = "A stubby blade designed to be inserted into a wrist. Gives you a nice advantage in a brawl."
	verb_name = "Deploy wristshank"
	icon_state = "wristshank"
	matter = list(MATERIAL_STEEL = 20)
	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	holding_type = /obj/item/melee/implant/armblade/wristshank
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	available_in_charsetup = FALSE
	allowed_jobs = list(/datum/job/hos, /datum/job/captain)
	available_in_charsetup = FALSE
	origin_tech = list(TECH_COMBAT = 4, TECH_POWER = 3)
