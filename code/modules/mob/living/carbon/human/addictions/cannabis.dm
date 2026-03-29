/datum/addiction/cannabis
	name = "Cannabis"
	cause_reagent = list(/datum/reagent/thc)

	antagonist_reagent = list(
		/datum/reagent/inaprovaline,
		/datum/reagent/tricordrazine,
		/datum/reagent/dylovene,
		/datum/reagent/noexcutite,
		/datum/reagent/citalopram,
		/datum/reagent/methylphenidate
	)

/datum/addiction/cannabis/tick(mob/living/carbon/human/H)
	var/power_diff = ..(H)
	var/satisfaction = H.addictions[type]
	var/relief = H.addiction_withdrawal_relief?[type] || 0

	if(power_diff >= 0 && prob(2))
		to_chat(H, SPAN_THOUGHT("You feel [pick(
			"mellow and unbothered",\
			"calm, like the world slowed down",\
			"pleasantly hazy",\
			"softly detached from everything",\
			"warm and relaxed"\
		)]."))

	if(satisfaction >= 0)
		return

	var/P = abs(satisfaction)
	var/effectiveP = P * (1 - relief * 0.7)

	if(world.time >= (H.addiction_next_msg?[type] || 0))
		H.addiction_next_msg[type] = world.time + rand(120 SECONDS, 180 SECONDS)

		switch(P)
			if(0 to (3 MINUTES))
				to_chat(H, SPAN_THOUGHT(pick(
					"You miss the familiar calm of being high.",\
					"You find yourself thinking about smoking.",\
					"You want to relax — weed would help."\
				)))
			if((3 MINUTES) to (10 MINUTES))
				to_chat(H, SPAN_WARNING(pick(
					"You feel irritable and restless without weed.",\
					"Your mood is souring. A hit would calm you down.",\
					"You can't quite relax — something feels missing."\
				)))
			if((10 MINUTES) to INFINITY)
				to_chat(H, SPAN_DANGER(pick(
					"You feel wound up and on edge. You need to smoke.",\
					"You can't settle your thoughts without weed.",\
					"Everything feels tense. You crave that haze badly."\
				)))

	if(world.time >= (H.addiction_next_symptom?[type] || 0))
		H.addiction_next_symptom[type] = world.time + rand(80 SECONDS, 120 SECONDS)

		if(prob(4 * (1 - relief)))
			H.adjustToxLoss(max(1, effectiveP / 6000))

		if(prob(10 * (1 - relief)))
			H.confused += 1

	if(world.time >= (H.addiction_next_pain?[type] || 0))
		H.addiction_next_pain[type] = world.time + rand(150 SECONDS, 220 SECONDS)

		if(prob(10 * (1 - relief)))
			var/pain
			if(effectiveP < 120)
				pain = 15
			else if(effectiveP < 400)
				pain = 20
			else
				pain = 25

			var/pain_organ = pick(H.external_organs)
			var/pain_amt = round(rand(pain, 40) * (1 - relief * 0.6))
			H.custom_pain(pick(
				"A mild discomfort makes itself known.",\
				"A faint but noticeable pain appears.",\
				"You feel a light, irritating ache.",\
				"A brief wave of mild pain passes through you.",\
				"There is a dull, manageable pain.",\
				"A slight pain tugs at your body.",\
				"A low, nagging discomfort settles in.",\
				"A weak pain flares up, then fades."\
			), pain_amt, 0, pain_organ, FALSE)
