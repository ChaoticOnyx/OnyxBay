
/mob/proc/changeling_no_pain()
	set category = "Changeling"
	set name = "Toggle feel pain (10)"
	set desc = "We choose whether or not to fell pain."

	if(is_regenerating())
		return

	var/datum/changeling/changeling = changeling_power(10, 0, 0, UNCONSCIOUS)
	if(!changeling)
		return FALSE

	var/mob/living/carbon/human/C = src
	C.no_pain = !C.no_pain

	if(C.can_feel_pain())
		to_chat(C, "<span class='notice'>We are able to feel pain now.</span>")
	else
		to_chat(C, "<span class='notice'>We are unable to feel pain anymore.</span>")

	spawn()
		while(C && !C.can_feel_pain() && C.mind && C.mind.changeling && !is_regenerating())
			C.mind.changeling.chem_charges = max(C.mind.changeling.chem_charges - 3, 0)
			if(C.mind.changeling.chem_charges == 0)
				C.no_pain = !C.no_pain
			sleep(40)
	return TRUE
