/obj/item/organ_module/active/simple/armblade/energy_blade
	name = "energy armblade"
	desc = "A energy blade designed to be inserted into an arm. Gives you a nice advantage in a brawl."
	action_button_name = "Deploy energyblade"
	icon_state = "energyblade"
	mod_overlay = "installer_armblade"
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_MECHANICAL | OM_FLAG_BIOLOGICAL
	origin_tech = list(TECH_COMBAT = 4, TECH_POWER = 3)
	holding_type = /obj/item/melee/energy/sword/one_hand/organ_module
	available_in_charsetup = FALSE
	cpu_load = 2
	w_class = 1

/obj/item/melee/energy/sword/one_hand/organ_module
	force_drop = FALSE

/obj/item/melee/energy/sword/one_hand/organ_module/attack_self(mob/user)
	return

/obj/item/melee/energy/sword/one_hand/organ_module/think()
	return

/obj/item/melee/energy/sword/one_hand/organ_module/on_update_icon()
	..()
	item_state = icon_state
	item_state_slots[slot_l_hand_str] = icon_state
	item_state_slots[slot_r_hand_str] = icon_state

/obj/item/organ_module/active/simple/armblade/energy_blade/deploy(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	var/obj/item/melee/energy/sword/one_hand/organ_module/S = holding
	if(!S || S.loc == src)
		return
	if(istype(S))
		S.activate(H)
		S.update_icon()
		if(E.organ_tag in list(BP_L_ARM, BP_L_HAND))
			H.update_inv_l_hand()
		else if(E.organ_tag in list(BP_R_ARM, BP_R_HAND))
			H.update_inv_r_hand()
	playsound(H.loc, 'sound/weapons/saberon.ogg', 50, 1)

/obj/item/organ_module/active/simple/armblade/energy_blade/retract(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	var/obj/item/melee/energy/sword/one_hand/organ_module/S = holding
	if(istype(S))
		S.deactivate(H)
	playsound(H.loc, 'sound/weapons/saberoff.ogg', 50, 1)
