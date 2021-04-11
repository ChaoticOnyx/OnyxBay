/datum/additiction
	var/name
	var/power
	var/time
	var/chronic = FALSE
	var/max_power

/datum/additiction/proc/update(var/mob/living/carbon/human/H)
	return

/datum/additiction/proc/tick(var/mob/living/carbon/human/H)
	return

/mob/living/carbon/human/var/list/datum/additiction/additictions = list()

/mob/living/carbon/human/proc/add_additiction(datum/additiction/A)
	if(A in additictions)
		var/datum/additiction/B = additictions[A.name]
		B.power = max(A.power, B.power)
		return
	else
		additictions[A.name] = A

/mob/living/carbon/human/proc/handle_additictions()
	var/list/L = typesof(/datum/additiction) - /datum/additiction
	for(var/T in L)
		var/datum/additiction/A = new T
		A.update(src)
		if(A.power > 0)
			add_additiction(A)

	for(var/datum/additiction/A in additictions)
		A.update()
		A.tick()
		++A.time



/datum/additiction/opioid
	name = "Opioid"

/datum/additiction/opioid/update(var/mob/living/carbon/human/H)
	for(var/R in H.reagents.reagent_list)
		if(istype(R, /datum/reagent/tramadol))
			var/datum/reagent/tramadol/T = R
			power = lerp(power, max(power, T.pain_power / 20. + H.chem_doses[R] * 0.5), 0.01)
			max_power = max(power, max_power)

	if(!chronic)
		power -= lerp(1, 0.1, time / (3 * TICKS_IN_SECOND * 60))
	if(time > 8 * TICKS_IN_SECOND * 60 || chronic)
		power = max_power

/datum/additiction/opioid/tick(var/mob/living/carbon/human/H)
	if(H.life_tick % 15)
		H.take_overall_damage(brute = power * 0.25, "Opioid additiction")
		switch(power)
			if(0 to 6)
				H.custom_pain("Your body stings slightly.", power * 2, 0, null, 0)
			if(6 to 13)
				H.custom_pain("Your body stings.", power * 1.5, 0, null, 0)
			if(13 to 30)
				H.custom_pain("Your body stings strongly.", power * 2, 0, null, 0)
			if(30 to INFINITY)
				H.custom_pain("Your body aches all over, it's driving you mad.", power * 3, 0, null, 0)
