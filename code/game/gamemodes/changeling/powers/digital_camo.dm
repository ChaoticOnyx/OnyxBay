
//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/mob/proc/changeling_digitalcamo()
	set category = "Changeling"
	set name = "Toggle Digital Camoflague"
	set desc = "The AI can no longer track us, but we will look different if examined. Has a constant cost while active."

	var/mob/living/carbon/human/C = src
	if(C.digitalcamo)
		to_chat(C, SPAN("changeling", "We return to normal."))
		C.digitalcamo = FALSE
		return

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)
		return

	to_chat(C, SPAN("changeling", "We distort our form to prevent AI-tracking."))
	C.digitalcamo = TRUE

	spawn(0)
		while(C && C.digitalcamo && C.mind?.changeling && !is_regenerating())
			C.mind.changeling.chem_charges = max(C.mind.changeling.chem_charges - 1, 0)
			sleep(40)

	verbs -= /mob/proc/changeling_digitalcamo
	spawn(5)
		verbs += /mob/proc/changeling_digitalcamo

	feedback_add_details("changeling_powers", "CAM")
