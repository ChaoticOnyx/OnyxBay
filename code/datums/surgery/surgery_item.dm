/obj/item/proc/do_surgery(mob/living/carbon/human/target, mob/user)
	if(!hasorgans(target))
		return FALSE

	if(user.a_intent == I_HURT)
		return FALSE

	if(!target.can_operate(user))
		return FALSE

	for(var/datum/surgery_step/S in GLOB.surgery_steps)
		var/status = S.do_step(user, target, src, user.zone_sel.selecting, user.rightclicked)
		if(status || status == SURGERY_FAILURE)
			return TRUE

	return FALSE
