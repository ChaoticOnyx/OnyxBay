
// Makes us able to see in the dark.
/datum/vampire_power/toggled/darkvision
	name = "Darkvision"
	desc = "You're are able to see in the dark."
	icon_state = "vamp_darksight_off"
	power_processing = FALSE
	max_stat = UNCONSCIOUS

	text_activate = "You no longer need light to see."
	text_deactivate = "You allow the shadows to return."

/datum/vampire_power/toggled/darkvision/activate()
	if(!..())
		return
	icon_state = "vamp_darksight_on"
	my_mob.seeDarkness = TRUE

/datum/vampire_power/toggled/darkvision/deactivate(no_message = TRUE)
	if(!..())
		return
	icon_state = "vamp_darksight_off"
	my_mob.seeDarkness = FALSE
