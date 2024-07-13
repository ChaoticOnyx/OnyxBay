/obj/item/organ_module/active/enhanced_vision
	name = "vision enhanced retinas"
	desc = "Zeng Hu implants given to EMTs to assist with finding the injured. These eye implants allow one to see further than you normally could."
	icon_state = "adaptive_binoculars"
	var/viewsize = 8
	allowed_organs = list(BP_EYES)
	cpu_load = 0
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 8

/obj/item/organ_module/active/enhanced_vision/activate(obj/item/organ/E, mob/living/carbon/human/user)
	if(!toggled)
		user.client.view_size.set_both(viewsize, viewsize)
		toggled = TRUE
	else
		user.client.view_size.reset_to_default()
		toggled = FALSE

	user.visible_message(
		toggled ? "<b>[user]</b>'s pupils narrow..." : "<b>[user]</b>'s pupils return to normal.",
		range = 3
	)

/obj/item/organ_module/active/enhanced_vision/emp_act(severity)
	. = ..()

	var/obj/item/organ/internal/eyes/E = loc
	if(!istype(E))
		return

	E.take_general_damage(5)
