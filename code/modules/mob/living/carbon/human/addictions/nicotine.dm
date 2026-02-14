/datum/addiction/nicotine
	name = "Nicotine"
	cause_reagent = list(/datum/reagent/nicotine)
	antagonist_reagent = list(
		/datum/reagent/noexcutite,
		/datum/reagent/inaprovaline,
		/datum/reagent/citalopram,
		/datum/reagent/methylphenidate,
		/datum/reagent/synaptizine
	)

	/// Chem doses with value lower than this will not be considered.
	min_chem_dose_required = 0.45

/datum/addiction/nicotine/on_relapse(mob/living/carbon/human/H)
	to_chat(H, SPAN_THOUGHT("[pick(
		"The first drag settles your nerves instantly.",\
		"Your fingers stop itching. You feel centered again.",\
		"That familiar calm returns with the nicotine."\
	)]"))

/datum/addiction/nicotine/on_cured(mob/living/carbon/human/H)
	to_chat(H, SPAN_THOUGHT("You notice your cravings for nicotine have faded."))

/datum/addiction/nicotine/tick(mob/living/carbon/human/H)
	var/diff = ..(H)
	var/satisfaction = H.addictions[type]

	if(!H.addiction_next_symptom) H.addiction_next_symptom = list()
	if(!H.addiction_next_msg) H.addiction_next_msg = list()
	if(!H.addiction_withdrawal_relief) H.addiction_withdrawal_relief = list()

	// After dosing: small "steady" lines, rate-limited
	if(diff > 0.1)
		var/next_good = H.addiction_next_symptom[type]
		if(isnull(next_good) || world.time >= next_good)
			H.addiction_next_symptom[type] = world.time + rand(48 SECONDS, 138 SECONDS)
			if(prob(50))
				to_chat(H, SPAN_THOUGHT(pick(
					"You feel steadier.",\
					"Your nerves calm down a little.",\
					"You feel more focused."\
				)))

	if(satisfaction >= 0)
		return

	var/P = abs(satisfaction)
	var/relief = H.addiction_withdrawal_relief[type]
	if(isnull(relief)) relief = 0
	var/effectiveP = P * (1 - relief * 0.7)

	// Craving lines (rare)
	var/next_msg = H.addiction_next_msg[type]
	if(isnull(next_msg) || world.time >= next_msg)
		H.addiction_next_msg[type] = world.time + rand(55 SECONDS, 165 SECONDS)
		switch(effectiveP)
			if(0 to (3 MINUTES))
				to_chat(H, SPAN_THOUGHT(pick(
					"You want a cigarette.",\
					"You miss the familiar nicotine buzz.",\
					"You feel like taking a quick smoke break."\
				)))
			if((3 MINUTES) to (10 MINUTES))
				to_chat(H, SPAN_WARNING(pick(
					"You really want nicotine.",\
					"You feel irritable without a smoke.",\
					"Your fingers feel restless — you want a drag."\
				)))
			if((10 MINUTES) to INFINITY)
				to_chat(H, SPAN_DANGER(pick(
					"You need nicotine — your nerves are screaming.",\
					"You can't stop thinking about smoking.",\
					"You're on edge. You need a cigarette."\
				)))

	// Light symptoms (not disabling), rate-limited separately
	var/sym_key = "[type]_sym"
	var/next_sym = H.addiction_next_symptom[sym_key]
	if(isnull(next_sym) || world.time >= next_sym)
		H.addiction_next_symptom[sym_key] = world.time + rand(30 SECONDS, 120 SECONDS)
		if(prob(round(8 * (1 - relief))))
			H.make_jittery(15 SECONDS)
			if(prob(25))
				H.confused = 10
				H.stuttering = 20
