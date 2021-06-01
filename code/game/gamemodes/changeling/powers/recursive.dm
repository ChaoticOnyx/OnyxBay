
//Increases macimum chemical storage
/mob/proc/changeling_recursive_enhancement()
	set category = "Changeling"
	set name = "Recursive Enhancement"
	set desc = "Empowers our abilities."
	var/datum/changeling/changeling = changeling_power()
	if(!changeling)
		return 0
	if(src.mind.changeling.recursive_enhancement)
		to_chat(src, "<span class='warning'>We will no longer empower our abilities.</span>")
		src.mind.changeling.recursive_enhancement = 0
		return 0
	else
		to_chat(src, "<span class='notice'>We empower ourselves. Our abilities will now be extra potent.</span>")
		src.mind.changeling.recursive_enhancement = 1
	feedback_add_details("changeling_powers","RE")
	return 1
