
/mob/proc/changeling_no_pain()
	set category = "Changeling"
	set name = "Toggle feel pain (10)"
	set desc = "We cannot feel pain while this ability is active. Spends 3 chemicals every 4 seconds."

	var/datum/changeling/changeling = changeling_power(10, 0, 0, UNCONSCIOUS, TRUE)
	if(!changeling)
		return

	var/mob/living/carbon/human/C = src
	C.no_pain = !C.no_pain

	if(C.can_feel_pain())
		to_chat(C, SPAN("changeling", "We are able to feel pain now."))
	else
		to_chat(C, SPAN("changeling", "We are unable to feel pain anymore."))
		changeling.chem_charges -= 10

	spawn()
		while(C && !C.can_feel_pain() && C.mind && C.mind.changeling && !is_regenerating())
			C.mind.changeling.chem_charges = max(C.mind.changeling.chem_charges - 3, 0)
			if(C.mind.changeling.chem_charges == 0)
				C.no_pain = !C.no_pain
			sleep(40)
