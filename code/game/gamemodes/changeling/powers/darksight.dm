
// Makes us able to see in the dark.
/datum/changeling_power/toggled/darksight
	name = "Darkvision"
	desc = "Makes us able to see in the dark."
	icon_state = "ling_darksight"
	power_processing = FALSE

	text_activate = "We no longer need light to see."
	text_deactivate = "We allow the shadows to return."

/datum/changeling_power/toggled/darksight/activate()
	if(!..())
		return
	var/mob/living/carbon/C = my_mob
	C.seeDarkness = TRUE
	to_chat(C, SPAN("changeling", text_activate))

/datum/changeling_power/toggled/darksight/deactivate()
	if(!..())
		return
	var/mob/living/carbon/C = my_mob
	C.seeDarkness = FALSE
	to_chat(C, SPAN("changeling", text_deactivate))
