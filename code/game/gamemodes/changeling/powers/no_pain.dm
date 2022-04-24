
// Makes us completely immune to pain.
/datum/changeling_power/toggled/no_pain
	name = "No Pain"
	desc = "We cannot feel pain while this ability is active."
	icon_state = "ling_no_pain"
	power_processing = TRUE
	max_stat = UNCONSCIOUS
	required_chems = 20
	chems_drain = 1

	text_activate = "We are unable to feel pain anymore."
	text_deactivate = "We are able to feel pain now."
	text_nochems = "We feel pain once again as we have no chemicals left."

/datum/changeling_power/toggled/no_pain/activate()
	if(!..())
		return
	var/mob/living/carbon/human/H = my_mob
	H.no_pain = TRUE
	use_chems()

/datum/changeling_power/toggled/no_pain/deactivate(no_message = TRUE)
	if(!..())
		return
	var/mob/living/carbon/human/H = my_mob
	H.no_pain = FALSE
