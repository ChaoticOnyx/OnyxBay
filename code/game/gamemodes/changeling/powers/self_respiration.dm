
// No breathing required.
/datum/changeling_power/toggled/self_respiration
	name = "Self Respiration"
	desc = "We choose whether or not to breathe."
	icon_state = "ling_respiration"
	power_processing = FALSE
	max_stat = UNCONSCIOUS

	text_activate = "We stop breathing, as we no longer need to."
	text_deactivate = "We resume breathing, as we now need to again."

/datum/changeling_power/toggled/self_respiration/activate()
	if(!..())
		return
	var/mob/living/carbon/C = my_mob
	C.does_not_breathe = TRUE

/datum/changeling_power/toggled/self_respiration/deactivate(no_message = TRUE)
	if(!..())
		return
	var/mob/living/carbon/C = my_mob
	C.does_not_breathe = FALSE
