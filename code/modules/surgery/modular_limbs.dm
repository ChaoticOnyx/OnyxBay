/obj/item/organ/external/proc/get_modular_limb_category()
	. = MODULAR_BODYPART_INVALID
	if(status == ORGAN_ROBOTIC && model)
		var/datum/robolimb/manufacturer = all_robolimbs[model]
		if(!isnull(manufacturer?.modular_bodyparts))
			. = manufacturer.modular_bodyparts

/obj/item/organ/external/proc/can_remove_modular_limb(mob/living/carbon/human/user)
	var/bodypart_cat = get_modular_limb_category()
	if(bodypart_cat == MODULAR_BODYPART_CYBERNETIC)
		if(!parent_organ)
			return FALSE
		var/obj/item/organ/external/parent = user?.get_organ(parent_organ)
		if(!parent || parent.get_modular_limb_category(user) < MODULAR_BODYPART_CYBERNETIC)
			return FALSE
	. = (bodypart_cat != MODULAR_BODYPART_INVALID)

/obj/item/organ/external/proc/can_attach_modular_limb(mob/living/carbon/human/user)
	var/list/limb_data = user?.species?.has_limbs[organ_tag]
	if(islist(limb_data) && limb_data["has_children"] > 0)
		. = (length(children) < limb_data["has_children"])

/obj/item/organ/external/proc/can_be_attached_modular_limb(mob/living/carbon/human/user)
	var/bodypart_cat = get_modular_limb_category()
	if(bodypart_cat == MODULAR_BODYPART_INVALID)
		return FALSE
	if(!parent_organ)
		return FALSE
	var/obj/item/organ/external/parent = user?.get_organ(parent_organ)
	if(!parent)
		return FALSE
	if(!parent.can_attach_modular_limb(user))
		return FALSE
	if(bodypart_cat == MODULAR_BODYPART_CYBERNETIC && parent.get_modular_limb_category(src) < MODULAR_BODYPART_CYBERNETIC)
		return FALSE
	return TRUE

/obj/item/organ/external/proc/check_modular_limb_damage(mob/living/carbon/human/user)
	. =  damage >= min_broken_damage || (status & ORGAN_BROKEN) || is_stump()

/mob/living/carbon/human/proc/get_modular_limbs(return_first_found = FALSE, validate_proc)
	for(var/bp in organs)
		var/obj/item/organ/external/E = bp
		if(!validate_proc || call(E, validate_proc)(src) > MODULAR_BODYPART_INVALID)
			LAZYADD(., E)
			if(return_first_found)
				return

	for(var/bp in .)
		var/obj/item/organ/external/E = bp
		if(length(E.children))
			. -= E.children

/mob/living/carbon/human/proc/refresh_modular_limb_verbs()
	if(length(get_modular_limbs(return_first_found = TRUE, validate_proc = /obj/item/organ/external/proc/can_attach_modular_limb)))
		verbs |= .proc/attach_limb_verb
	else
		verbs -= .proc/attach_limb_verb
	if(length(get_modular_limbs(return_first_found = TRUE, validate_proc = /obj/item/organ/external/proc/can_remove_modular_limb)))
		verbs |= .proc/detach_limb_verb
	else
		verbs -= .proc/detach_limb_verb

/mob/living/carbon/human/proc/check_can_attach_modular_limb(obj/item/organ/external/E)
	THROTTLE(last_special, 8)
	if(!last_special || get_active_hand() != E)
		return FALSE
	if(incapacitated() || restrained())
		to_chat(src, SPAN_WARNING("You can't do that in your current state!"))
		return FALSE
	if(QDELETED(E) || !istype(E))
		to_chat(src, SPAN_WARNING("You are not holding a compatible limb to attach."))
		return FALSE
	if(!E.can_be_attached_modular_limb(src))
		to_chat(src, SPAN_WARNING("\The [E] cannot be attached to your current body."))
		return FALSE
	if(E.get_modular_limb_category() <= MODULAR_BODYPART_INVALID)
		to_chat(src, SPAN_WARNING("\The [E] cannot be attached by your own hand."))
		return FALSE
	var/install_to_zone = E.organ_tag
	if(!isnull(get_organ(install_to_zone)))
		to_chat(src, SPAN_WARNING("There is already a limb attached at that part of your body."))
		return FALSE
	if(E.check_modular_limb_damage(src))
		to_chat(src, SPAN_WARNING("\The [E] is too damaged to be attached."))
		return FALSE
	var/obj/item/organ/external/parent = E.parent_organ && get_organ(E.parent_organ)
	if(!parent)
		to_chat(src, SPAN_WARNING("\The [E] needs an existing limb to be attached to."))
		return FALSE
	if(parent.check_modular_limb_damage(src))
		to_chat(src, SPAN_WARNING("Your [parent.name] is too damaged to have anything attached."))
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/check_can_detach_modular_limb(obj/item/organ/external/E)
	THROTTLE(last_special, 8)
	if(!last_special)
		return FALSE
	if(incapacitated() || restrained())
		to_chat(src, SPAN_WARNING("You can't do that in your current state!"))
		return FALSE
	if(!istype(E) || QDELETED(src) || QDELETED(E) || E.owner != src || E.loc != src)
		return FALSE
	if(E.check_modular_limb_damage(src))
		to_chat(src, SPAN_WARNING("That limb is too damaged to be removed!"))
		return FALSE
	var/obj/item/organ/external/parent = E.parent_organ && get_organ(E.parent_organ)
	if(!parent)
		return FALSE
	if(parent.check_modular_limb_damage(src))
		to_chat(src, SPAN_WARNING("Your [parent.name] is too damaged to detach anything from it."))
		return FALSE
	return (E in get_modular_limbs(return_first_found = FALSE, validate_proc = /obj/item/organ/external/proc/can_remove_modular_limb))

/mob/living/carbon/human/proc/attach_limb_verb()
	set name = "Attach Limb"
	set category = "Object"
	set desc = "Attach a replacement limb."

	var/obj/item/organ/external/E = get_active_hand()
	if(!check_can_attach_modular_limb(E))
		return FALSE
	if(!do_after(src, 2 SECONDS, src))
		return FALSE
	if(!check_can_attach_modular_limb(E))
		return FALSE

	last_special = world.time
	drop_from_inventory(E)
	E.replaced(src)

	E.status &= ~ORGAN_CUT_AWAY
	for(var/obj/item/organ/external/child in E.children)
		child.status &= ~ORGAN_CUT_AWAY

	var/datum/gender/G = gender_datums[gender]
	visible_message(
		SPAN_NOTICE("\The [src] attaches \the [E] to [G.his] body!"),
		SPAN_NOTICE("You attach \the [E] to your body!"))
	regenerate_icons()
	return TRUE

/mob/living/carbon/human/proc/detach_limb_verb()
	set name = "Remove Limb"
	set category = "Object"
	set desc = "Detach one of your limbs."

	var/list/detachable_limbs = get_modular_limbs(return_first_found = FALSE, validate_proc = /obj/item/organ/external/proc/can_remove_modular_limb)
	if(!length(detachable_limbs))
		to_chat(src, SPAN_WARNING("You have no detachable limbs."))
		return FALSE
	var/obj/item/organ/external/E = input(usr, "Which limb do you wish to detach?", "Limb Removal") as null|anything in detachable_limbs
	if(!check_can_detach_modular_limb(E))
		return FALSE
	if(!do_after(src, 2 SECONDS, src))
		return FALSE
	if(!check_can_detach_modular_limb(E))
		return FALSE

	last_special = world.time
	E.removed(src)
	E.clean_blood()
	E.dropInto(loc)
	put_in_hands(E)
	var/datum/gender/G = gender_datums[gender]
	visible_message(
		SPAN_NOTICE("\The [src] detaches [G.his] [E.name]!"),
		SPAN_NOTICE("You detach your [E.name]!"))
	return TRUE
