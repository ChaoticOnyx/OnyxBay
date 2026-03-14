
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
	if(m_intent == M_WALK && !l_hand && !r_hand)
		return 0
	if((has_gravity() || has_magnetised_footing()) && get_solid_footing())
		return 0
	var/obj/item/tank/jetpack/thrust = get_jetpack()
	if(thrust && thrust.on && thrust.stabilization_on)
		return 0 // Otherwise we are unable to slip in outer space, but still may slip while crawling along the hull.
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
