/datum/spell/toggled/thermal
	name = "Thermal"
	desc = "You're are able to see in the dark."
	invocation = "none"
	invocation_type = SPI_NONE
	need_target = FALSE
	icon_state = "vamp_darksight_off"

/datum/spell/toggled/thermal/New()

/datum/spell/toggled/thermal/activate()
	if(!..())
		return
	icon_state = "vamp_darksight_on"
	var/mob/living/H = holder
	H.seeThermal = TRUE

/datum/spell/toggled/thermal/deactivate(no_message = TRUE)
	if(!..())
		return
	icon_state = "vamp_darksight_off"
	var/mob/living/H = holder
	H.seeThermal = FALSE
