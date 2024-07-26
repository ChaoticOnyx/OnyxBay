/mob/living/carbon/human/add_grab(obj/item/grab/grab, defer_hand = FALSE, use_pull_slot = FALSE)
	if(use_pull_slot)
		return ..()
	else if(defer_hand)
		. = put_in_hands(grab)
	else
		. = put_in_active_hand(grab)

/mob/living/carbon/human/can_be_grabbed(mob/grabber, target_zone, defer_hand = FALSE)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/external/organ = organs_by_name[check_zone(target_zone)]
	if(!istype(organ))
		to_chat(grabber, SPAN_WARNING("\The [src] is missing that body part!"))
		return FALSE

	if(grabber == src)
		var/using_slot = defer_hand ? get_inactive_hand() : get_active_hand()
		if(!using_slot)
			to_chat(src, SPAN_WARNING("You cannot grab yourself without a usable hand!"))
			return FALSE

		var/list/bad_parts = list(organ.organ_tag) | organ.parent_organ
		for(var/obj/item/organ/external/child in organ.children)
			bad_parts |= child.organ_tag
		if(using_slot in bad_parts)
			to_chat(src, SPAN_WARNING("You can't grab your own [organ.name] with itself!"))
			return FALSE

	if(pull_damage())
		to_chat(grabber, SPAN_DANGER("Pulling \the [src] in their current condition would probably be a bad idea."))
	var/obj/item/clothing/C = get_covering_equipped_item(target_zone)
	if(istype(C))
		C.add_fingerprint(grabber)

/mob/living/carbon/human/make_grab(atom/movable/target, grab_tag = /datum/grab/simple, defer_hand = FALSE, force_grab_tag = FALSE, use_pull_slot = FALSE)
	. = ..()
	if(!.)
		return

	remove_cloaking_source(species)
