/obj/item/organ_module/active/memory_inhibitor
	name = "memory inhibitor"
	desc = "A Zeng Hu implant that allows one to have control over their memories, " \
		+ "allowing you to set a timer and remove any memories developed within it. " \
		+ "This is most popular in Zeng Hu labs within Eridani."
	action_button_name = "Wipe memory"
	icon_state = "memory_inhibitor"
	allowed_organs = list(BP_HEAD)
	cooldown = 5 MINUTES
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 10
	var/ready_to_erase = FALSE

/obj/item/organ_module/active/memory_inhibitor/activate(obj/item/organ/E, mob/living/carbon/human/H)
	if(!ready_to_erase)
		to_chat(
			H,
			SPAN_NOTICE("Your memories following this point will be deleted on the following activation.")
		)
		ready_to_erase = TRUE
	else
		to_chat(
			H,
			SPAN_WARNING("You do not recall the events since the last time you activated your memory inhibitor!")
		)
		ready_to_erase = FALSE

/obj/item/organ_module/active/memory_inhibitor/emp_act(severity)
	. = ..()

	if(prob(10))
		var/obj/item/organ/external/head = loc
		var/mob/living/carbon/human/H = head?.loc
		if(istype(H))
			to_chat(H, SPAN_WARNING("You forgot everything that happened today!"))
		return TRUE
