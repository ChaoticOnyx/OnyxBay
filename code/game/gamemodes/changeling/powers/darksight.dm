
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
		to_chat(C, "<span class='notice'>We no longer need light to see.</span>")
	else
		to_chat(C, "<span class='notice'>We allow the shadows to return.</span>")
	return TRUE
