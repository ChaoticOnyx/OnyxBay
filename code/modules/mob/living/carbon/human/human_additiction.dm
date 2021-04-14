/datum/additiction
	var/name
	var/power
	var/time
	var/chronic = FALSE
	var/max_power

	var/safe_time
	var/safe_period

	var/critical_period
	var/to_chronical_period

	var/withdrawal_period

	var/withdrawal_increase_period

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

		if(!(A.time < A.safe_time + A.safe_period))
			A.tick()
			++A.withdrawal_period
		++A.time

		if(!A.chronic)
			A.power -= lerp(1, 0.1, A.time / (A.critical_period * 30))

		if(A.time > A.to_chronical_period * 30 || A.chronic)
			A.power = A.max_power
			A.chronic = TRUE

		if(A.withdrawal_period > A.withdrawal_increase_period * 30 && !(CE_MIND in chem_effects))
			A.power += 0.1
			A.max_power += 0.1



/datum/additiction/opioid
	name = "Opioid"
	critical_period = 6
	to_chronical_period = 9
	withdrawal_increase_period = 3

/datum/additiction/opioid/update(var/mob/living/carbon/human/H)
	for(var/R in H.reagents.reagent_list)
		if(istype(R, /datum/reagent/tramadol))
			var/datum/reagent/tramadol/T = R
			power = lerp(power, max(power, T.pain_power / 20. + H.chem_doses[R] * 0.5), 0.01)
			max_power = max(power, max_power)

			// Period without opioid withdrawal
			safe_time = lerp(safe_time, time, (T.pain_power * 5) / safe_period)
			safe_period = max(safe_period, T.pain_power * 5)

/datum/additiction/opioid/tick(mob/living/carbon/human/H)
	if(H.life_tick % lerp(15, 3, power / 60) == 0)
		if(prob(25))
			H.custom_pain("You really need painkillers.", rand(power), 0, null, 0)

		switch(power)
			if(0 to 6)
				H.custom_pain("Your body burns.", 20 + power * 2, 0, null, 0)
			if(6 to 13)
				H.custom_pain("Your body burns strongly.", 30 + power * 1.5, 0, null, 0)
			if(13 to 30)
				H.custom_pain("Your body burns all over.", 40 + power * 2, 0, null, 0)
			if(30 to INFINITY)
				H.custom_pain("Your body burns all over, it's driving you mad.", 50 + power * 3, 0, null, 0)

	if(withdrawal_period > 3 * 30 && !(/datum/disease/selfharm in H.diseases))
		var/datum/disease/selfharm/D = new
		D.period = 3
		H.add_disease(D)

	if(withdrawal_period > 16 * 30 && !(/datum/disease/suicide in H.diseases))
		var/datum/disease/suicide/D = new
		D.period = 1.5
		H.add_disease(D)

/datum/additiction/alcohol
	name = "Alcohol"
	critical_period = 12
	to_chronical_period = 21
	withdrawal_increase_period = 20

/datum/additiction/alcohol/update(var/mob/living/carbon/human/H)
	for(var/datum/reagent/ethanol/booz in H.reagents.reagent_list | H.get_ingested_reagents())
		safe_time = lerp(safe_time, time, ((100-booz.strength) * 5) / safe_period)
		safe_period = max(safe_period, ((100-booz.strength) * 5))

/datum/additiction/alcohol/tick(var/mob/living/carbon/human/H)
	if(H.life_tick % 10 == 0 && withdrawal_period > 15 * 30)
		switch(power)
			if(6 to 13)
				H.make_jittery(5, 5)
			if(13 to 30)
				H.make_dizzy(2, 2)
				H.make_jittery(10, 10)
			if(30 to INFINITY)
				H.make_dizzy(3, 3)
				H.make_jittery(20, 20)