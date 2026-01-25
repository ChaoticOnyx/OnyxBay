/datum/addiction/alcohol
	name = "Alcohol"
	cause_reagent = list(/datum/reagent/ethanol)
	antagonist_reagent = list(
		/datum/reagent/dylovene,
		/datum/reagent/tricordrazine,
		/datum/reagent/inaprovaline,
		/datum/reagent/bicaridine,
		/datum/reagent/synaptizine,
		/datum/reagent/citalopram,
		/datum/reagent/methylphenidate,
		/datum/reagent/ethylredoxrazine
	)
	detox_time_required = 15 MINUTES

/datum/addiction/alcohol/on_relapse(mob/living/carbon/human/H)
	to_chat(H, SPAN_THOUGHT("[pick(
		"That first sip hits and your worries melt away.",\
		"Warmth spreads through you — you feel normal again.",\
		"The edge disappears. You could drink like this forever."\
	)]"))

/datum/addiction/alcohol/on_cured(mob/living/carbon/human/H)
	to_chat(H, SPAN_THOUGHT("You realize you haven't craved a drink in a while."))

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

	if(!H.addiction_next_symptom) H.addiction_next_symptom = list()
	if(!H.addiction_next_msg) H.addiction_next_msg = list()
	if(!H.addiction_withdrawal_relief) H.addiction_withdrawal_relief = list()

	// Pleasant buzz lines (rate-limited; SSmobs.wait=2s)
	if(power_diff >= 0 && (is_boozed(H) > 0))
		var/next_buzz = H.addiction_next_symptom[type]
		if(isnull(next_buzz) || world.time >= next_buzz)
			H.addiction_next_symptom[type] = world.time + rand(50 SECONDS, 120 SECONDS)
			if(prob(55))
				if(prob(50))
					to_chat(H, SPAN_THOUGHT("You feel [pick("relaxed", "blissful", "warm", "pleasantly loose")]."))
				else
					to_chat(H, SPAN_THOUGHT("You feel [pick("decent", "relaxed", "tranquil", "comfortably buzzed")]."))

	if(satisfaction >= 0)
		return

	var/P = abs(satisfaction)
	var/relief = H.addiction_withdrawal_relief[type]
	if(isnull(relief)) relief = 0
	var/effectiveP = P * (1 - relief * 0.7)

	// Craving lines (rare)
	var/next_msg = H.addiction_next_msg[type]
	if(!isnull(next_msg) && world.time < next_msg)
		return
	H.addiction_next_msg[type] = world.time + rand(75 SECONDS, 150 SECONDS)

	switch(effectiveP)
		if(0 to (3 MINUTES))
			to_chat(H, SPAN_THOUGHT("[pick(
				"You could go for a drink.",\
				"You miss the taste of alcohol.",\
				"You think about a cold beer."\
			)]"))
		if((3 MINUTES) to (10 MINUTES))
			to_chat(H, SPAN_WARNING("[pick(
				"You really want a drink.",\
				"Your hands feel a little restless without alcohol.",\
				"You keep imagining that first sip."\
			)]"))
		if((10 MINUTES) to INFINITY)
			to_chat(H, SPAN_DANGER("[pick(
				"You need a drink — it's getting under your skin.",\
				"Your thoughts keep circling back to alcohol.",\
				"You feel on edge without a drink."\
			)]"))

	// Mild withdrawal side-effects (very rare; reduced by relief)
	if(prob(round(2 * (1 - relief))))
		H.adjustToxLoss(max(1, effectiveP / 4000))
