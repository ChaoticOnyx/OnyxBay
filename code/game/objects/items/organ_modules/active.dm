/obj/item/organ_module/active
	var/verb_name = "Activate"
	var/verb_desc = "activate embedded module"
	var/datum/action/organ_action = null

/obj/item/organ_module/active/onInstall(obj/item/organ/external/E)
	organ_action = new /datum/action/item_action/organ_module
	organ_action.target = src
	organ_action.Grant(E?.owner)

/obj/item/organ_module/active/onRemove(obj/item/organ/external/E)
	QDEL_NULL(organ_action)

/obj/item/organ_module/active/organ_removed(obj/item/organ/external/E, mob/living/carbon/human/H)
	onRemove(E)

/obj/item/organ_module/active/organ_installed(obj/item/organ/external/E, mob/living/carbon/human/H)
	onInstall(E)

/obj/item/organ_module/active/proc/can_activate(mob/living/carbon/human/H, obj/item/organ/external/E)
	if(H.incapacitated(INCAPACITATION_KNOCKOUT))
		show_splash_text(usr, "Can't do that!", SPAN_WARNING("You can't do that now!"))
		return

	return TRUE

/obj/item/organ_module/active/proc/activate(mob/living/carbon/human/H, obj/item/organ/external/E)
	pass()

/obj/item/organ_module/active/proc/deactivate(mob/living/carbon/human/H, obj/item/organ/external/E)
	pass()

/datum/action/item_action/organ_module
	name = "Activate Organ Module"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_LYING | AB_CHECK_ALIVE

/datum/action/item_action/organ_module/CheckRemoval(mob/living/user)
	var/obj/item/organ_module/active/A = target
	if(!istype(A))
		return TRUE

	if(!isorgan(A.loc))
		return TRUE

	return FALSE

/obj/item/organ_module/active/ui_action_click()
	var/obj/item/organ/external/E = loc
	if(!istype(E))
		return

	activate(E?.owner, E)
