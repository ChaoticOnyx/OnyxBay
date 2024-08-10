/datum/addiction/opioid
	name = "Opioid"
	cause_reagent = list(
		/datum/reagent/painkiller/opium,
		/datum/reagent/painkiller/tramadol/oxycodone,
		/datum/reagent/painkiller/tramadol,
	)

/datum/addiction/opioid/tick(mob/living/carbon/human/H)
	var/satisfaction_diff = ..(H)
	var/satisfaction = H.addictions[type]

	if(satisfaction_diff > 0.1 && prob(7))
		if(satisfaction < -10)
			to_chat(H, SPAN_THOUGHT("You feel <big>[pick("unbeliveably happy", "like living your best life", "blissful", "blessed", "unearthly tranquility")]</big>"))
		else if(satisfaction >= -10)
			to_chat(H, SPAN_THOUGHT("You feel [pick("happy", "joyful", "relaxed", "tranquility")]"))

	if(satisfaction >= 0)
		return

	var/P = abs(satisfaction)
	if(prob(10))
		H.take_overall_damage(P * 0.25, used_weapon = "Opioid addiction")
		switch(P)
			if(0 to (2 MINUTES))
				H.custom_pain("Your body stings slightly.", P * 2, 0, null, 0)
			if((3 MINUTES) to (5 MINUTES))
				H.custom_pain("Your body stings.", P * 1.5, 0, null, 0)
				if(prob(20))
					spawn()
						H.vomit()
			if((5 MINUTES) to (10 MINUTES))
				H.custom_pain("Your body stings strongly.", P * 2, 0, null, 0)
				if(prob(30))
					spawn()
						H.vomit()
			if((10 MINUTES) to INFINITY)
				if(prob(50))
					H.custom_pain("Your body crushes all over.", P * 3.5, 0, null, 0)
				else
					H.custom_pain("Your body aches all over, it's driving you mad.", P * 3, 0, null, 0)
				if(prob(60))
					spawn()
						H.vomit()
		if(prob(10))
			switch(P)
				if(0 to 6)
					to_chat(H, SPAN_THOUGHT("You want opiates."))
				if(6 to 13)
					to_chat(H, SPAN_WARNING("You really want opiates."))
				if(13 to 30)
					to_chat(H, SPAN_DANGER("You need opiates."))
				if(30 to 60)
					to_chat(H, SPAN_DANGER("<big>You need opiates.</big>"))
				if(60 to INFINITY)
					to_chat(H, SPAN_DANGER("<big>OH GOD! You cannot live without opiates.</big>"))

		H.adjustToxLoss(P / 40)
