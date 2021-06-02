
/mob/proc/changeling_toggle_darksight()
	set category = "Changeling"
	set name = "Toggle Darkvision"
	set desc = "We are able to see in the dark."

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)
		return FALSE

	var/mob/living/carbon/C = src
	C.seeDarkness = !C.seeDarkness
	if(C.seeDarkness)
		to_chat(C, SPAN("changeling", "We no longer need light to see."))
	else
		to_chat(C, SPAN("changeling", "We allow the shadows to return."))
	return TRUE
