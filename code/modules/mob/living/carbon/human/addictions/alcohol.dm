/datum/addiction/alcohol
	name = "Alcohol"
	cause_reagent = list(/datum/reagent/ethanol)

/datum/addiction/alcohol/proc/is_boozed(mob/living/carbon/human/H)
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

/datum/addiction/alcohol/tick(mob/living/carbon/human/H)
	var/power_diff = ..(H)
	var/satisfaction = H.addictions[type]

	if(power_diff >= 0 && prob(3) && (is_boozed(H) > 0))
		if(prob(50))
			to_chat(H, SPAN_THOUGHT("You feel [pick("relaxed", "blissful")]"))
		else
			to_chat(H, SPAN_THOUGHT("You feel [pick("decent", "relaxed", "tranquility")]"))

	if(satisfaction >= 0)
		return

	var/P = abs(satisfaction)
	if(prob(3))
		switch(P)
			if(0 to (3 MINUTES))
				to_chat(H, SPAN_THOUGHT("You wanna drink."))
			if((3 MINUTES) to (10 MINUTES))
				to_chat(H, SPAN_WARNING("You really wanna drink."))
			if((10 MINUTES) to INFINITY)
				to_chat(H, SPAN_DANGER("You need to drink right now, it's driving you mad."))

		H.adjustToxLoss(P / 100)
