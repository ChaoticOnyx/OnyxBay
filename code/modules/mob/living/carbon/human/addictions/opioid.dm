/datum/addiction/opioid
	name = "Opioid"
	cause_reagent = list(
		/datum/reagent/painkiller/opium,
		/datum/reagent/painkiller/tramadol/oxycodone,
		/datum/reagent/painkiller/tramadol,
		/datum/reagent/painkiller/opium/tarine
	)
	antagonist_reagent = list(
		// Core detox/support
		/datum/reagent/dylovene,
		/datum/reagent/tricordrazine,
		/datum/reagent/inaprovaline,
		// Symptom support
		/datum/reagent/bicaridine,
		/datum/reagent/synaptizine,
		/datum/reagent/citalopram,
		/datum/reagent/noexcutite,
		/datum/reagent/kelotane
	)

	// Withdrawal for opioids should be impactful, but not a spammy stun-lock.
	// These defaults are tuned for SSmobs.wait = 2 SECONDS (tick every ~2s).
	detox_time_required = 15 MINUTES

/datum/addiction/opioid/on_relapse(mob/living/carbon/human/H)
	to_chat(H, SPAN_THOUGHT("[pick(
		"Warmth blooms through your body — everything stops hurting.",\
		"Relief. Pure, quiet relief.",\
		"Your muscles unclench and the world finally makes sense again.",\
		"The craving goes silent. You feel safe, for a moment."\
	)]"))

/datum/addiction/opioid/on_cured(mob/living/carbon/human/H)
	to_chat(H, SPAN_THOUGHT("You feel... present again. The need for opiates no longer rules your thoughts."))

/datum/addiction/opioid/proc/_ready(mob/living/carbon/human/H)
	if(!H.addiction_next_msg) H.addiction_next_msg = list()
	if(!H.addiction_next_symptom) H.addiction_next_symptom = list()
	if(!H.addiction_next_pain) H.addiction_next_pain = list()
	if(!H.addiction_withdrawal_relief) H.addiction_withdrawal_relief = list()

/datum/addiction/opioid/tick(mob/living/carbon/human/H)
	_ready(H)

	var/satisfaction_diff = ..(H)
	var/satisfaction = H.addictions[type]

	// "Reward" feelgood lines after dosing: rate-limited, not every tick.
	if(satisfaction_diff > 0.1)
		var/next_good = H.addiction_next_symptom[type]
		if(isnull(next_good) || world.time >= next_good)
			H.addiction_next_symptom[type] = world.time + rand(45 SECONDS, 75 SECONDS)
			if(prob(60))
				if(satisfaction < -10)
					to_chat(H, SPAN_THOUGHT("You feel [FONT_LARGE(pick(
						"unbelievably happy",\
						"like living your best life",\
						"blissful",\
						"blessed",\
						"unearthly tranquility"\
					))]."))
				else
					to_chat(H, SPAN_THOUGHT("You feel [pick("happy", "joyful", "relaxed", "tranquility")]."))

	// No withdrawal when satisfied
	if(satisfaction >= 0)
		return

	var/P = abs(satisfaction)

	// Relief is computed in _addictions.dm from antagonist reagents (0..~0.65 by default)
	var/relief = H.addiction_withdrawal_relief[type]
	if(isnull(relief)) relief = 0

	// Effective severity for symptoms; keep in same "minutes" unit (deciseconds)
	var/effectiveP = P * (1 - relief * 0.7)

	// --- Craving messages (rare, not spam) ---
	var/next_msg = H.addiction_next_msg[type]
	if(isnull(next_msg) || world.time >= next_msg)
		H.addiction_next_msg[type] = world.time + rand(50 SECONDS, 185 SECONDS)
		switch(effectiveP)
			if(0 to (3 MINUTES))
				to_chat(H, SPAN_THOUGHT("[pick(
					"You want something to take the edge off.",\
					"You think about opiates more than you should.",\
					"A quiet craving curls in your chest."\
				)]"))
			if((3 MINUTES) to (8 MINUTES))
				to_chat(H, SPAN_WARNING("[pick(
					"You really want opiates.",\
					"Your body feels wrong without a dose.",\
					"You keep imagining that first warm wave of relief."\
				)]"))
			if((8 MINUTES) to INFINITY)
				to_chat(H, SPAN_DANGER("[pick(
					"You need opiates — withdrawal is clawing at you.",\
					"Your nerves scream for relief.",\
					"You feel frantic without a dose."\
				)]"))

	// --- Pain / nausea (rate-limited and capped) ---
	var/next_pain = H.addiction_next_pain[type]
	if(!isnull(next_pain) && world.time < next_pain)
		return

	H.addiction_next_pain[type] = world.time + rand(50 SECONDS, 185 SECONDS)

	// Not guaranteed every window (prevents predictable spam)
	if(!prob(round(65 - relief * 25)))
		return

	var/pain_organ = pick(H.external_organs)

	// Step-based pain with hard cap (prevents instant stunlock at large P values)
	var/pain_amt
	var/pain_text

	if(effectiveP < (2 MINUTES))
		pain_amt = rand(20, 25)
		pain_text = "Your body stings slightly."
	else if(effectiveP < (5 MINUTES))
		pain_amt = rand(25, 40)
		pain_text = "Your body stings."
	else if(effectiveP < (10 MINUTES))
		pain_amt = rand(40, 55)
		pain_text = "Your body aches."
	else
		pain_amt = rand(55, 70)
		pain_text = pick("Your body aches all over.", "Your body hurts everywhere, it's driving you mad.", "Pain flares across your body.")

	// Antagonists reduce, but never remove, discomfort
	pain_amt = round(pain_amt * (1 - relief * 0.6))
	pain_amt = clamp(pain_amt, 20, 70)

	H.custom_pain(pain_text, pain_amt, 0, pain_organ, FALSE)

	// Nausea/vomit: still possible, but not constant; reduced by relief
	var/vomit_chance
	if(effectiveP < (2 MINUTES))
		vomit_chance = 0
	else if(effectiveP < (5 MINUTES))
		vomit_chance = 8
	else if(effectiveP < (10 MINUTES))
		vomit_chance = 16
	else
		vomit_chance = 28

	vomit_chance = round(vomit_chance * (1 - relief))
	if(vomit_chance > 0 && prob(vomit_chance))
		to_chat(H, SPAN_WARNING(pick("You feel nauseous...", "Your stomach turns...", "You feel like you're about to throw up...")))
		spawn()
			H.vomit()
