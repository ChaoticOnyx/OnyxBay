/obj/item/organ_module/active/gustatorial
	name = "gustatorial centre"
	icon_state = "augment"
	action_button_name = "Activate Gustatorial Centre (tongue)"
	allowed_organs = list(BP_HEAD)
	cooldown = 1 SECOND
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 10

	var/taste_sensitivity = TASTE_NORMAL
	var/action_verb = "samples"
	var/self_action_verb = "sample"

/obj/item/organ_module/active/gustatorial/activate(obj/item/organ/E, mob/living/carbon/human/H)
	var/obj/item/reagent_containers/F = H.get_active_hand()
	if(istype(F))
		if(!F.is_open_container())
			to_chat(H, SPAN_WARNING("\The [F] is closed!"))
			return

		H.visible_message("<b>[H]</b> [action_verb] \the [F].", SPAN_NOTICE("You [self_action_verb] \the [F]."))
		to_chat(H, SPAN_NOTICE("\The [src] reports that \the [F] tastes like: [F.reagents.generate_taste_message(H, taste_sensitivity)]"))
	else
		var/list/tastes = list("Hypersensitive" = TASTE_HYPERSENSITIVE, "Sensitive" = TASTE_SENSITIVE, "Normal" = TASTE_NORMAL, "Dull" = TASTE_DULL, "Numb" = TASTE_NUMB)
		var/taste_choice = input(H, "How well do you want to taste?", "Taste Sensitivity", "Normal") as null|anything in tastes
		if(taste_choice)
			to_chat(H, SPAN_NOTICE("\The [src] will now output taste as if you were <b>[taste_choice]</b>."))
			taste_sensitivity = tastes[taste_choice]

/obj/item/organ_module/active/gustatorial/hand
	action_button_name = "Activate Gustatorial Centre (hand)"

	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	action_verb = "sticks their finger in"
	self_action_verb = "stick your finger in"
