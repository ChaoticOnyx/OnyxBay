
// Checks if we have any bodypart not covered with thick clothing.
/mob/living/carbon/human/proc/has_any_exposed_bodyparts()
	var/p_head  = FALSE
	var/p_face  = FALSE
	var/p_eyes  = FALSE
	var/p_chest = FALSE
	var/p_groin = FALSE
	var/p_arms  = FALSE
	var/p_hands = FALSE
	var/p_legs  = FALSE
	var/p_feet  = FALSE

	for(var/obj/item/clothing/C in list(head, wear_mask, wear_suit, w_uniform, gloves, shoes))
		if(!C)
			continue
		if((C.body_parts_covered & HEAD) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_head = TRUE
		if((C.body_parts_covered & FACE) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_face = TRUE
		if((C.body_parts_covered & EYES) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_eyes = TRUE
		if((C.body_parts_covered & UPPER_TORSO) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_chest = TRUE
		if((C.body_parts_covered & LOWER_TORSO) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_groin = TRUE
		if((C.body_parts_covered & ARMS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_arms = TRUE
		if((C.body_parts_covered & HANDS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_hands = TRUE
		if((C.body_parts_covered & LEGS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_legs = TRUE
		if((C.body_parts_covered & FEET) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_feet = TRUE

	return !(p_head && p_face && p_eyes && p_chest && p_groin && p_arms && p_hands && p_legs && p_feet)

/mob/living/carbon/human/proc/remove_nearsighted()
	sdisabilities &= ~NEARSIGHTED

/mob/living/carbon/human/proc/remove_deaf()
	sdisabilities &= ~DEAF

/mob/living/carbon/human/proc/delayed_hallucinations()
	hallucination(400, 80)
