/obj/item/melee/implant/armblade
	icon_state = "armblade"
	item_state = null
	name = "armblade"
	desc = "A mechanical blade deployed from your arm. The favourite hidden weapon of many criminal types."
	icon = 'icons/obj/implants.dmi'
	icon_state = "armblade"
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("stabbed", "chopped", "cut")
	mod_weight = 1.3
	mod_reach = 1.5
	mod_handy = 1.75
	armor_penetration = 30
	sharp = TRUE
	edge = TRUE

/obj/item/organ_module/active/simple/armblade
	name = "embedded armblade"
	desc = "A mechanical blade designed to be inserted into an arm. Gives you a nice advantage in a brawl."
	verb_name = "Deploy armblade"
	icon_state = "armblade"
	matter = list(MATERIAL_STEEL = 30)
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/melee/implant/armblade

/obj/item/melee/implant/claws
	name = "claws"
	desc = "A set of claws deployed from the tips of your fingers. Great for cutting people into ribbons."
	icon_state = "wolverine"
	icon = 'icons/obj/implants.dmi'

/obj/item/organ_module/active/simple/wolverine
	name = "embedded claws"
	desc = "A variant on the popular armblade, these claws allow for a more traditional unarmed brawl style while still mantaining your advantage."
	verb_name = "Deploy embedded claws"
	icon_state = "wolverine"
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/melee/implant/claws
	matter = list(MATERIAL_STEEL = 40)

/obj/item/implanter/installer/disposable/energy_blade
	name = "disposable cybernetic installer (energy blade)"
	desc = "A energy blade designed to be inserted into an arm. Gives you a nice advantage in a brawl."
	mod = /obj/item/organ_module/active/simple/armblade/energy_blade

/obj/item/organ_module/active/simple/armblade/energy_blade
	name = "energy armblade"
	desc = "A energy blade designed to be inserted into an arm. Gives you a nice advantage in a brawl."
	verb_name = "Deploy energyblade"
	icon_state = "energyblade"
	mod_overlay = "installer_armblade"
	origin_tech = list(TECH_MAGNET = 3, TECH_COVERT = 4)
	holding_type = /obj/item/melee/energy/blade/organ_module

/obj/item/melee/energy/blade/organ_module
	force_drop = FALSE
	destroy_on_drop = FALSE

/obj/item/organ_module/active/simple/armblade/energy_blade/deploy(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	playsound(H.loc, 'sound/weapons/saberon.ogg', 50, 1)

/obj/item/organ_module/active/simple/armblade/energy_blade/retract(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	playsound(H.loc, 'sound/weapons/saberoff.ogg', 50, 1)

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
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/melee/implant/armblade/wristshank
