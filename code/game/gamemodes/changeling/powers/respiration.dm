
//No breathing required
/mob/proc/changeling_self_respiration()
	set category = "Changeling"
	set name = "Toggle Breathing"
	set desc = "We choose whether or not to breathe."

	var/datum/changeling/changeling = changeling_power(max_stat = UNCONSCIOUS)
	if(!changeling)
		return

	var/mob/living/carbon/C = src
	if(C.does_not_breathe == FALSE)
		C.does_not_breathe = TRUE
		to_chat(src, SPAN("changeling", "We stop breathing, as we no longer need to."))
	else
		C.does_not_breathe = FALSE
		to_chat(src, SPAN("changeling", "We resume breathing, as we now need to again."))
