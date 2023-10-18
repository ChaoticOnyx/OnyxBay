/obj/item/proc/do_surgery(mob/living/carbon/target, mob/living/user)
	if(!hasorgans(target))
		return FALSE

	if(user.a_intent == I_HURT)
		return FALSE

	for(var/datum/surgery_step/S in GLOB.surgery_steps)
		if(S.do_step(user, target, src, user.zone_sel.selecting))
			return TRUE

	return FALSE
