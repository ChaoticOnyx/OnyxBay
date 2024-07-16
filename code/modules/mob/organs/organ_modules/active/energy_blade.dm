/obj/item/organ_module/active/simple/armblade/energy_blade
	name = "energy armblade"
	desc = "A energy blade designed to be inserted into an arm. Gives you a nice advantage in a brawl."
	action_button_name = "Deploy energyblade"
	icon_state = "energyblade"
	mod_overlay = "installer_armblade"
	origin_tech = list(TECH_COMBAT = 4, TECH_POWER = 3)
	holding_type = /obj/item/melee/energy/blade/organ_module
	available_in_charsetup = FALSE

/obj/item/melee/energy/blade/organ_module
	force_drop = FALSE
	destroy_on_drop = FALSE

/obj/item/organ_module/active/simple/armblade/energy_blade/deploy(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	playsound(H.loc, 'sound/weapons/saberon.ogg', 50, 1)

/obj/item/organ_module/active/simple/armblade/energy_blade/retract(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	playsound(H.loc, 'sound/weapons/saberoff.ogg', 50, 1)
