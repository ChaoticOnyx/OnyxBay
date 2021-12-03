
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


/*
// Using in: /mob/living/carbon/human/proc/changeling_rapidregen()
/datum/rapidregen
	var/heals = 10
	var/mob/living/carbon/human/H = null
	var/datum/changeling/C = null

/datum/rapidregen/New(mob/_M)
	H = _M
	C = _M.mind.changeling
	START_PROCESSING(SSprocessing, src)

/datum/rapidregen/Destroy()
	H = null
	C = null
	return ..()

/datum/rapidregen/Process()
	if(QDELETED(H))
		qdel(src)
		return
	if(heals)
		H.adjustBruteLoss(-5)
		H.adjustToxLoss(-5)
		H.adjustOxyLoss(-5)
		H.adjustFireLoss(-5)
		--heals
	else
		C?.rapidregen_active = FALSE
		qdel(src)*/
