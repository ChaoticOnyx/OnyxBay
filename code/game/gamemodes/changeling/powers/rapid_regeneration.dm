
//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/mob/living/carbon/human/proc/changeling_rapidregen()
	set category = "Changeling"
	set name = "Rapid Regeneration (30)"
	set desc = "We rapidly regenerate in a short amount of time. Does not affect stuns or chemicals."

	var/datum/changeling/changeling = changeling_power(30, 0, 100, UNCONSCIOUS)
	if(!changeling)
		return

	if(changeling.rapidregen_active)
		to_chat(src, SPAN("changeling", "We are already actively regenerating!"))
		return

	changeling.rapidregen_active = TRUE
	mind.changeling.chem_charges -= 30
	new /datum/rapidregen(src)

	feedback_add_details("changeling_powers", "RR")
