/datum/addiction/nicotine
	name = "Nicotine"
	cause_reagent = list(/datum/reagent/nicotine)

/datum/addiction/nicotine/tick(mob/living/carbon/human/H)
	. = ..(H)
	var/satisfaction = H.addictions[type]

	if(satisfaction >= 0)
		return

	var/P = abs(satisfaction)
	if(prob(3))
		switch(P)
			if(0 to (1 MINUTE))
				to_chat(H, SPAN_THOUGHT("You wanna smoke."))
			if((1 MINUTE) to (5 MINUTES))
				to_chat(H, SPAN_WARNING("You really wanna smoke."))
			if((5 MINUTES) to INFINITY)
				to_chat(H, SPAN_DANGER("You need to smoke right now, it's driving you mad."))
