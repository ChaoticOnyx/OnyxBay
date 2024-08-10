/datum/addiction
	var/name

// NEG - withdrawal
// POS - addictive
	var/power = 0
	var/time = 0
	var/time_start = 0
	var/chronic = FALSE
	var/max_power = 0

/datum/addiction/proc/update(mob/living/carbon/human/H)
	pass()

/datum/addiction/proc/tick(mob/living/carbon/human/H)
	pass()

/datum/addiction/proc/can_gone(mob/living/carbon/human/H)
	return TRUE

/mob/living/carbon/human/var/list/datum/addiction/addictions = list()

/mob/living/carbon/human/proc/add_addiction(datum/addiction/A)
	A.time_start = world.time
	addictions[A.name] = A

/mob/living/carbon/human/proc/handle_addictions()
	for(var/T in subtypesof(/datum/addiction))
		var/datum/addiction/A = new T
		if(A.name in addictions)
			continue

		A.update(src)
		A.time_start = world.time
		if(A.power > 0)
			add_addiction(A)

	for(var/N in addictions)
		var/datum/addiction/A = addictions[N]
		A.tick(src)
		A.time = world.time - A.time_start
		A.update(src)

		if(A.can_gone(src))
			addictions -= A.name

/datum/addiction/opioid
	name = "Opioid"

/datum/addiction/opioid/can_gone(mob/living/carbon/human/H)
	return chronic ? FALSE : power <= (-max_power * 1.5)

/datum/addiction/opioid/update(mob/living/carbon/human/H)
	var/power_diff = 0
	for(var/datum/reagent/painkiller/tramadol/T in (H.reagents.reagent_list | H.get_ingested_reagents().reagent_list))
		if(power < T.pain_power / 5)
			power_diff += (T.pain_power / 20 * H.chem_doses[T.type] * 0.05)
	if(power < 0)
		power_diff *= 10
	power += power_diff
	if(power_diff < 0.1)
		if(power >= 0)
			power -= max(0.01, power * (chronic ? 0.008 : 0.01))
		else if(abs(power) < (max_power * 0.8))
			power -= 0.1

	//if(/datum/reagent/naloxone in H.chem_doses)
	//	if(power_diff > 0)
	//		power_diff *= 0.8
	//	else
	//		power_diff *= 1.2

	if(power_diff > 0.1 && prob(7) && max_power > 30)
		if(power < -10)
			to_chat(H, SPAN_NOTICE("You feel <big>[pick("unbeliveably happy", "like living your best life", "blissful", "blessed", "unearthly tranquility")]</big>"))
		else if(power >= -10)
			to_chat(H, SPAN_NOTICE("You feel [pick("happy", "joyful", "relaxed", "tranquility")]"))

	if(power < (-max_power * chronic ? 2 : 1.5))
		power = (-max_power * chronic ? 2 : 1.5)
	max_power = max(power, max_power)

/datum/addiction/opioid/tick(mob/living/carbon/human/H)
	H.add_chemical_effect(CE_PAINKILLER, max_power * 0.5)
	if(power >= 0)
		return
	var/P = abs(power)
	//if(/datum/reagent/naloxone in H.chem_doses)
	//	P *= CLAMP01(1 - H.chem_doses[/datum/reagent/naloxone])
	if(prob(10))
		H.take_overall_damage(P * 0.25, used_weapon = "Opioid addiction")
		switch(P)
			if(0 to 6)
				H.custom_pain("Your body stings slightly.", P * 2, 0, null, 0)
			if(6 to 13)
				H.custom_pain("Your body stings.", P * 1.5, 0, null, 0)
				if(prob(20))
					spawn()
						H.vomit()
			if(13 to 30)
				H.custom_pain("Your body stings strongly.", P * 2, 0, null, 0)
				if(prob(30))
					spawn()
						H.vomit()
			if(30 to INFINITY)
				if(chronic && power > 60)
					H.custom_pain("Your body crushes all over.", P * 3.5, 0, null, 0)
				else
					H.custom_pain("Your body aches all over, it's driving you mad.", P * 3, 0, null, 0)
				if(prob(60))
					spawn()
						H.vomit()
		if(prob(10))
			switch(P)
				if(0 to 6)
					to_chat(H, SPAN_NOTICE("You want opiates."))
				if(6 to 13)
					to_chat(H, SPAN_WARNING("You really want opiates."))
				if(13 to 30)
					to_chat(H, SPAN_DANGER("You need opiates."))
				if(30 to 60)
					to_chat(H, SPAN_DANGER("<big>You need opiates.</big>"))
				if(60 to INFINITY)
					to_chat(H, SPAN_DANGER("<big>OH GOD! You cannot live without opiates.</big>"))

		H.adjustToxLoss(P / 40)

/datum/addiction/alcohol
	name = "Alcohol"

/datum/addiction/alcohol/can_gone(mob/living/carbon/human/H)
	return chronic ? FALSE : power < -max_power

/datum/addiction/alcohol/proc/isboozed(mob/living/carbon/human/H)
	. = 0
	var/datum/reagents/ingested = H.get_ingested_reagents()
	if(ingested)
		var/list/pool = H.reagents.reagent_list | ingested.reagent_list
		for(var/datum/reagent/ethanol/booze in pool)
			if(H.chem_doses[booze.type] < 2)
				continue
			. = 1
			if(booze.strength < 40)
				return 2

/datum/addiction/alcohol/update(mob/living/carbon/human/H)
	var/power_diff = isboozed(H)
	if(power < 0)
		power_diff *= 10
	power += power_diff / 10

	power -= 0.025
	//if(/datum/reagent/naloxone in H.chem_doses)
	//	if(power_diff > 0)
	//		power_diff *= 0.8
	//	else
	//		power_diff *= 1.2

	if(power_diff >= 1 && prob(3) && max_power > 30)
		if(power < -10)
			to_chat(H, SPAN_NOTICE("You feel [pick("relaxed", "blissful")]"))
		else if(power >= -10)
			to_chat(H, SPAN_NOTICE("You feel [pick("decent", "relaxed", "tranquility")]"))

	max_power = max(power, max_power)

/datum/addiction/alcohol/tick(mob/living/carbon/human/H)
	if(power >= 0)
		return
	var/P = abs(power)
	//if(/datum/reagent/naloxone in H.chem_doses)
	//	P *= CLAMP01(1 - H.chem_doses[/datum/reagent/naloxone])
	if(prob(3))
		switch(P)
			if(0 to 12)
				to_chat(H, SPAN_NOTICE("You wanna drink."))
			if(12 to 30)
				to_chat(H, SPAN_WARNING("You really wanna drink."))
			if(30 to INFINITY)
				to_chat(H, SPAN_DANGER("You need to drink right now, it's driving you mad."))

		H.adjustToxLoss(P / 100)

/datum/addiction/nicotine
	name = "Nicotine"

/datum/addiction/nicotine/can_gone(mob/living/carbon/human/H)
	return chronic ? FALSE : power < -max_power

/datum/addiction/nicotine/update(mob/living/carbon/human/H)
	var/power_diff = H.chem_doses[/datum/reagent/nicotine] || 0
	if(power < 0)
		power_diff *= 200
	power += power_diff / 10
	power -= 0.1
	//if(/datum/reagent/naloxone in H.chem_doses)
	//	power += 0.2
	max_power = max(power, max_power)

/datum/addiction/nicotine/tick(mob/living/carbon/human/H)
	if(power >= 0)
		return
	var/P = abs(power)
	//if(/datum/reagent/naloxone in H.chem_doses)
	//	P *= CLAMP01(1 - H.chem_doses[/datum/reagent/naloxone])
	if(prob(3))
		switch(P)
			if(0 to 12)
				to_chat(H, SPAN_NOTICE("You wanna smoke."))
			if(12 to 30)
				to_chat(H, SPAN_WARNING("You really wanna smoke."))
			if(30 to INFINITY)
				to_chat(H, SPAN_DANGER("You need to smoke right now, it's driving you mad."))
