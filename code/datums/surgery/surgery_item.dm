/obj/item/proc/do_surgery(mob/living/carbon/target, mob/living/user)
	if (!istype(target))
		return FALSE

	if (user.a_intent == I_HURT)
		return FALSE

	var/zone = user.zone_sel.selecting
	if(zone in target.surgery_status.ongoing_steps)
		to_chat(user, SPAN("warning", "You can't operate on this area while surgery is already in progress."))
		return TRUE

	for(var/datum/surgery_step/S in GLOB.surgery_steps)
		if(S.do_step(user, target, src, zone))
			return TRUE

	return FALSE
