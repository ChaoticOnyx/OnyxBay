
// Fake Voice
/mob/proc/changeling_mimicvoice()
	set category = "Changeling"
	set name = "Mimic Voice"
	set desc = "Shape our vocal glands to form a voice of someone we choose. We cannot regenerate chemicals when mimicing."

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)
		return

	if(changeling.mimicing)
		changeling.mimicing = ""
		to_chat(src, SPAN("changeling", "We return our vocal glands to their original form."))
		return

	var/mimic_voice = sanitize(input(usr, "Enter a name to mimic.", "Mimic Voice", null), MAX_NAME_LEN)
	if(!mimic_voice)
		return

	changeling.mimicing = mimic_voice

	to_chat(src, SPAN("changeling", "We shape our glands to take the voice of <b>[mimic_voice]</b>, this will stop us from regenerating chemicals while active.\nUse this power again to return to our original voice and reproduce chemicals again."))
	feedback_add_details("changeling_powers","MV")

	spawn(0)
		while(src?.mind?.changeling?.mimicing && !is_regenerating())
			mind.changeling.chem_charges = max(mind.changeling.chem_charges - 1, 0)
			sleep(40)
		if(src?.mind?.changeling)
			mind.changeling.mimicing = ""
