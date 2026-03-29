/obj/item/organ_module/active
	var/verb_name = "Activate"
	var/verb_desc = "activate embedded module"
	var/datum/action/organ_action = null

/obj/item/organ_module/active/Destroy()
	QDEL_NULL(organ_action)
	return ..()

/obj/item/organ_module/active/_on_install(obj/item/organ/external/E)
	. = ..()
	organ_action = new /datum/action/item_action/organ_module
	organ_action.target = src
	var/action_name = implant_action_name || action_button_name
	organ_action.name = action_name ? action_name : "Activate [src.name]"
	if(E?.owner)
		var/mob/living/carbon/human/H = E.owner
		if(istype(H) && has_processor(H))
			organ_action.Grant(H)

/obj/item/organ_module/active/_on_remove(obj/item/organ/external/E)
	QDEL_NULL(organ_action)

/obj/item/organ_module/active/organ_removed(obj/item/organ/E, mob/living/carbon/human/owner)
	if(organ_action && owner)
		organ_action.Remove(owner)

/obj/item/organ_module/active/organ_installed(obj/item/organ/E, mob/living/carbon/human/owner)
	if(organ_action && owner)
		if(has_processor(owner))
			organ_action.Grant(owner)

/obj/item/organ_module/active/proc/can_activate(obj/item/organ/E, mob/living/carbon/human/H)
	if(H?.incapacitated(INCAPACITATION_KNOCKOUT))
		show_splash_text(usr, "Can't do that!", SPAN_WARNING("You can't do that now!"))
		return

	if(istype(E, /obj/item/organ/external))
		var/obj/item/organ/external/external = E
		if(!external.is_robotic_usable())
			var/cpu_name = "CPU"
			var/obj/item/organ/external/head/head = H?.external_organs_by_name[BP_HEAD]
			if(istype(head))
				for(var/obj/item/organ_module/module in head.organ_modules)
					if(initial(module.module_type) == OM_TYPE_PROCESSOR)
						cpu_name = module.name
						break
			to_chat(H, SPAN_WARNING("Your [cpu_name] send a signal to [src.name] but [external.name] actuator dont respond."))
			return

	return TRUE

/obj/item/organ_module/active/proc/has_processor(mob/living/carbon/human/H)
	var/obj/item/organ/external/head/head = H?.external_organs_by_name[BP_HEAD]
	if(!istype(head))
		return FALSE
	for(var/obj/item/organ_module/module in head.organ_modules)
		if(initial(module.module_type) == OM_TYPE_PROCESSOR)
			return TRUE
	return FALSE

/obj/item/organ_module/active/proc/activate(obj/item/organ/E, mob/living/carbon/human/H)
	return

/obj/item/organ_module/active/proc/deactivate(obj/item/organ/E, mob/living/carbon/human/H)
	return

/obj/item/organ_module/active/proc/is_cpu_active(mob/living/carbon/human/H)
	return FALSE

/datum/action/item_action/organ_module
	name = "Activate Organ Module"
	check_flags = AB_CHECK_ALIVE

/datum/action/item_action/organ_module/CheckRemoval(mob/living/user)
	var/obj/item/organ_module/active/A = target
	if(!istype(A))
		return TRUE

	var/obj/item/organ/O = A.loc
	if(!istype(O))
		return TRUE

	if(!ishuman(O.loc))
		return TRUE

	return FALSE

/obj/item/organ_module/active/ui_action_click()
	var/obj/item/organ/O = loc
	if(!istype(O))
		return

	if(!can_activate(O, usr))
		return

	THROTTLE(activate_cd, cooldown)
	if(!activate_cd)
		return

	activate(O, O?.owner)
