
// Makes us almost transparent, using chemicals in process.
/datum/changeling_power/toggled/mimic_voice
	name = "Mimic Voice"
	desc = "Shape our vocal glands to form a voice of someone we choose. We cannot regenerate chemicals when mimicing."
	icon_state = "ling_mimic_voice"
	required_chems = 20
	chems_drain = 0.5
	power_processing = TRUE
	max_stat = UNCONSCIOUS

	text_activate = "We begin reshaping our vocal glands..."
	text_deactivate = "We return our vocal glands to their original form."
	text_nochems = "Our vocal glands suddenly return to their original form."

/datum/changeling_power/toggled/mimic_voice/activate()
	if(!..())
		return

	var/mimic_voice = sanitize(input(usr, "Enter a name to mimic.", "Mimic Voice", null), MAX_NAME_LEN)
	if(!mimic_voice)
		deactivate()
		return

	changeling.mimicing = mimic_voice
	use_chems()
	to_chat(my_mob, SPAN("changeling", "We sound like <b>[mimic_voice]</b> now."))
	feedback_add_details("changeling_powers","MV")

/datum/changeling_power/toggled/mimic_voice/deactivate(no_message = TRUE)
	if(!..())
		return
	changeling.mimicing = ""
