/obj/item/organ_module/active
	var/verb_name = "Activate"
	var/verb_desc = "activate embedded module"
	var/datum/action/organ_action = null

/obj/item/organ_module/active/_on_install(obj/item/organ/external/E)
	. = ..()
	organ_action = new /datum/action/item_action/organ_module
	organ_action.target = src
	organ_action.Grant(E?.owner)

/obj/item/organ_module/active/_on_remove(obj/item/organ/external/E)
	QDEL_NULL(organ_action)

/obj/item/organ_module/active/proc/can_activate(obj/item/organ/E, mob/living/carbon/human/H)
	if(H?.incapacitated(INCAPACITATION_KNOCKOUT))
		show_splash_text(usr, "Can't do that!", SPAN_WARNING("You can't do that now!"))
		return

	return TRUE

/obj/item/organ_module/active/proc/activate(obj/item/organ/E, mob/living/carbon/human/H)
	pass()

/obj/item/organ_module/active/proc/deactivate(obj/item/organ/E, mob/living/carbon/human/H)
	pass()

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
