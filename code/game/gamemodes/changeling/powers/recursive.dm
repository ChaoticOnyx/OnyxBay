
//Increases macimum chemical storage
/mob/proc/changeling_recursive_enhancement()
	set category = "Changeling"
	set name = "Recursive Enhancement"
	set desc = "Empowers our abilities."

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)
		return

	if(mind.changeling.recursive_enhancement)
		to_chat(src, SPAN("changeling", "We will no longer empower our abilities."))
		mind.changeling.recursive_enhancement = FALSE
		return
	else
		to_chat(src, SPAN("changeling", "We empower ourselves. Our abilities will now be extra potent."))
		mind.changeling.recursive_enhancement = TRUE

	feedback_add_details("changeling_powers", "RE")
