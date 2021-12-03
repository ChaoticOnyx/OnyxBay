


/////////////////
// /mob/ PROCS //
/////////////////

// Transfers mind from wherewher we are into atom/A, moves biostructure in process
/mob/proc/changeling_transfer_mind(atom/A)
	var/obj/item/organ/internal/biostructure/BIO
	if(istype(src, /mob/living/carbon/brain))
		BIO = loc
	else
		BIO = locate() in contents

	if(!BIO)
		return FALSE

	var/mob/M = A
	if(!M)
		return FALSE

	BIO.change_host(M) // Biostructure object gets moved here
	mind.changeling.update_my_mob(M)

	if(mind) // It SHOULD exist, but we cannot be completely sure when it comes to changelings code
		if(!istype(M, /mob/living/carbon/brain))
			mind.transfer_to(M) // Moving mind into a mob
		else
			BIO.mind_into_biostructure(src) // Moving mind into a biostructure
	else
		M.key = key // Cringe happened, using hard transfer by key and praying for things to still be repairable

	var/mob/living/carbon/human/H = M
	if(istype(H))
		if(H.stat == DEAD) // Resurrects dead bodies, yet doesn't heal damage
			H.setBrainLoss(0)
			H.SetParalysis(0)
			H.SetStunned(0)
			H.SetWeakened(0)
			H.shock_stage = 0
			H.timeofdeath = 0
			H.switch_from_dead_to_living_mob_list()
			var/obj/item/organ/internal/heart/heart = H.internal_organs_by_name[BP_HEART]
			heart.pulse = 1
			H.set_stat(CONSCIOUS)
			H.failed_last_breath = 0 // So mobs that died of oxyloss don't revive and have perpetual out of breath.
			H.reload_fullscreen()

	return TRUE

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
