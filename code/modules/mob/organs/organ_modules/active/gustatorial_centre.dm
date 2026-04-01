/obj/item/organ_module/active/gustatorial
	name = "gustatorial centre"
	desc = "Small taste and chemical analyser, hidden in your finger. Don't dip it too deep!"
	icon_state = "augment"
	action_button_name = "Activate Gustatorial Centre (hand)"
	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	cooldown = 1 SECOND
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 0
	available_in_charsetup = TRUE
	w_class = 1
	augment_cost = 3
	allowed_roles = list(/datum/job/cmo, /datum/job/doctor, /datum/job/chemist, /datum/job/detective)
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6)
	matter = list(
		MATERIAL_GOLD = 250,
		MATERIAL_SILVER = 250,
		MATERIAL_PLATINUM = 250,
		MATERIAL_PLASTIC = 250
	)

	var/action_verb = "sticks their finger in"
	var/self_action_verb = "stick your finger in"

/obj/item/organ_module/active/gustatorial/activate(obj/item/organ/E, mob/living/carbon/human/H)
	var/obj/item/reagent_containers/F = H.get_active_hand()
	if(istype(F))
		if(!F.is_open_container())
			to_chat(H, SPAN_WARNING("\The [F] is closed!"))
			return

		H.visible_message("<b>[H]</b> [action_verb] \the [F].", SPAN_NOTICE("You [self_action_verb] \the [F]."))
		to_chat(H, SPAN_NOTICE("\The [src] reports that \the [F] tastes like: [F.reagents.generate_taste_message(H, TASTE_NORMAL)]"))
		to_chat(H, SPAN_NOTICE("\The [src] detects: [F.reagents.get_reagents()]."))
	else
		to_chat(H, SPAN_NOTICE("\The [src] reports there is nothing in your hand to sample."))
