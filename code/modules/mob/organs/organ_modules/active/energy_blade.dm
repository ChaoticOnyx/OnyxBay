/obj/item/organ_module/active/simple/armblade/energy_blade
	name = "energy armblade"
	desc = "An energy blade projector designed to be inserted into an arm. Gives you one hell of an advantage in a brawl."
	action_button_name = "Deploy energy blade"
	icon_state = "energyblade"
	mod_overlay = "installer_armblade"
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_MECHANICAL | OM_FLAG_BIOLOGICAL
	origin_tech = list(TECH_COMBAT = 4, TECH_POWER = 3)
	holding_type = /obj/item/melee/energy/armblade
	available_in_charsetup = FALSE
	cpu_load = 2
	w_class = 1

/obj/item/organ_module/active/simple/armblade/energy_blade/syndie
	holding_type = /obj/item/melee/energy/armblade/syndie

/obj/item/organ_module/active/simple/armblade/energy_blade/nt
	name = "prototype energy armblade"
	desc = "A prototype energy blade projector designed to be inserted into an arm. Gives you a nice advantage in a brawl."
	holding_type = /obj/item/melee/energy/armblade/nt

/obj/item/organ_module/active/simple/armblade/energy_blade/deploy(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	var/obj/item/melee/energy/armblade/S = holding
	if(!istype(S) || S.loc == src)
		return

	S.activate(H)
	if(E.organ_tag in list(BP_L_ARM, BP_L_HAND))
		H.update_inv_l_hand()
	else if(E.organ_tag in list(BP_R_ARM, BP_R_HAND))
		H.update_inv_r_hand()

/obj/item/organ_module/active/simple/armblade/energy_blade/retract(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	var/obj/item/melee/energy/armblade/S = holding
	if(!istype(S))
		return

	S.deactivate(H)

/obj/item/melee/energy/armblade
	name = "energy armblade"
	desc = "A lovely omni-blade that cuts through both cakes and limbs with ease."
	atom_flags = ATOM_FLAG_NO_BLOOD
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	anchored = TRUE    // Never spawned outside of inventory, should be fine.
	canremove = FALSE
	force_drop = TRUE

	sharp = FALSE
	edge = TRUE
	active_force = 45
	mod_weight = 0.5
	mod_reach = 0.3
	mod_handy = 1.0
	mod_shield = 1.0
	mod_weight_a = 1.25
	mod_reach_a = 1.25
	mod_handy_a = 1.5
	mod_shield_a = 2.5
	block_tier_a = BLOCK_TIER_MELEE
	hitsound = 'sound/effects/fighting/energy1.ogg'

	active_max_bright = 0.75
	brightness_color = "#ff5959"

	var/blade_color = "red"

/obj/item/melee/energy/armblade/syndie
	desc = "An ominous omni-blade that cuts through both cakes and NT employees with ease."
	brightness_color = "#68ff4d"
	blade_color = "green"

/obj/item/melee/energy/armblade/nt
	desc = "An bright-orange omni-blade that cuts through both cakes and criminals with ease."
	brightness_color = "#ff8c27"
	blade_color = "orange" // The same as security energy shields, low-tier reverse-engineered energy weapons or something.
	active_force = 35 // A bit worse than the COOL ones

/obj/item/melee/energy/armblade/activate(mob/living/user)
	..()
	set_light(l_max_bright = active_max_bright, l_outer_range = active_outer_range, l_color = brightness_color)

/obj/item/melee/energy/armblade/deactivate(mob/living/user)
	..()
	set_light(0)

/obj/item/melee/energy/armblade/attack_self(mob/user)
	return

/obj/item/melee/energy/armblade/think()
	return

/obj/item/melee/energy/armblade/on_update_icon()
	..()
	icon_state = "eblade[blade_color]"
	item_state = icon_state
	A_LAZYSET(item_state_slots, slot_l_hand_str, icon_state)
	A_LAZYSET(item_state_slots, slot_r_hand_str, icon_state)
