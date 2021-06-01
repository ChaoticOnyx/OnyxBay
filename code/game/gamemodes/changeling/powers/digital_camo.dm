
//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/mob/proc/changeling_digitalcamo()
	set category = "Changeling"
	set name = "Toggle Digital Camoflague"
	set desc = "The AI can no longer track us, but we will look different if examined.  Has a constant cost while active."

	if(is_regenerating())
		return 0

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)
		return 0

	var/mob/living/carbon/human/C = src
	if(C.digitalcamo)
		to_chat(C, "<span class='notice'>We return to normal.</span>")
	else
		to_chat(C, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
	C.digitalcamo = !C.digitalcamo

	spawn(0)
		while(C && C.digitalcamo && C.mind && C.mind.changeling && !is_regenerating())
			C.mind.changeling.chem_charges = max(C.mind.changeling.chem_charges - 1, 0)
			sleep(40)

	src.verbs -= /mob/proc/changeling_digitalcamo
	spawn(5)	src.verbs += /mob/proc/changeling_digitalcamo
	feedback_add_details("changeling_powers","CAM")
	return 1
