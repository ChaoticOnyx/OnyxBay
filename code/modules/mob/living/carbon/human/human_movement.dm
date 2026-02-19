
/mob/living/carbon/human/can_slip(magboots_only = FALSE)
	. = ..()
	if(!.)
		return

	if(species?.check_no_slip(src, magboots_only))
		return FALSE

	return TRUE

/mob/living/carbon/human/get_jetpack()
	if(!back)
		return null

	if(istype(back, /obj/item/tank/jetpack))
		return back

	if(istype(back, /obj/item/rig))
		var/obj/item/rig/rig = back
		for(var/obj/item/rig_module/maneuvering_jets/module in rig.installed_modules)
			return module.jets

	return null

/mob/living/carbon/human/get_eva_slip_prob(prob_slip = 10)
	// General slip check.
	if((has_gravity() || has_magnetised_footing()) && get_solid_footing())
		return 0
	if(!l_hand)
		prob_slip -= 2
	else if(l_hand.w_class <= ITEM_SIZE_SMALL)
		prob_slip -= 1
	if(!r_hand)
		prob_slip -= 2
	else if(r_hand.w_class <= ITEM_SIZE_SMALL)
		prob_slip -= 1
	if(m_intent != M_RUN)
		prob_slip *= 0.5
	return max(prob_slip, 0)
