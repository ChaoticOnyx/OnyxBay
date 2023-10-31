//Severe traumas, when your brain gets abused way too much.
//These range from very annoying to completely debilitating.
//They cannot be cured with chemicals, and require brain surgery to solve.

/datum/brain_trauma/severe
	abstract_type = /datum/brain_trauma/severe
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/brain_trauma/severe/mute
	name = "Mutism"
	desc = "Patient is completely unable to speak."
	scan_desc = "extensive damage to the brain's speech center"
	gain_text = SPAN_WARNING("You forget how to speak!")
	lose_text = SPAN_NOTICE("You suddenly remember how to speak.")

/datum/brain_trauma/severe/mute/on_gain()
	ADD_TRAIT(owner, TRAIT_MUTE)
	..()

/datum/brain_trauma/severe/mute/on_lose()
	REMOVE_TRAIT(owner, TRAIT_MUTE)
	..()

/datum/brain_trauma/severe/aphasia
	name = "Aphasia"
	desc = "Patient is unable to speak or understand any language."
	scan_desc = "extensive damage to the brain's language center"
	gain_text = SPAN_WARNING("You have trouble forming words in your head...")
	lose_text = SPAN_NOTICE("You suddenly remember how languages work.")

/datum/brain_trauma/severe/aphasia/on_gain()
	owner.add_blocked_language(subtypesof(/datum/language) - /datum/language/aphasia, LANGUAGE_APHASIA)
	owner.grant_language(/datum/language/aphasia, source = LANGUAGE_APHASIA)
	..()

/datum/brain_trauma/severe/aphasia/on_lose()
	if(!QDELING(owner))
		owner.remove_blocked_language(subtypesof(/datum/language), LANGUAGE_APHASIA)
		owner.remove_language(/datum/language/aphasia, source = LANGUAGE_APHASIA)

	..()

/datum/brain_trauma/severe/blindness
	name = "Cerebral Blindness"
	desc = "Patient's brain is no longer connected to its eyes."
	scan_desc = "extensive damage to the brain's occipital lobe"
	gain_text = SPAN_WARNING("You can't see!")
	lose_text = SPAN_NOTICE("Your vision returns.")

/datum/brain_trauma/severe/blindness/on_gain()
	owner.become_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/blindness/on_lose()
	owner.cure_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/paralysis
	name = "Paralysis"
	desc = "Patient's brain can no longer control part of its motor functions."
	scan_desc = "cerebral paralysis"
	gain_text = ""
	lose_text = ""
	var/paralysis_type
	var/list/paralysis_traits = list()
	//for descriptions

/datum/brain_trauma/severe/paralysis/New(specific_type)
	if(specific_type)
		paralysis_type = specific_type
	if(!paralysis_type)
		paralysis_type = pick("full","left","right","arms","legs","r_arm","l_arm","r_leg","l_leg")
	var/subject
	switch(paralysis_type)
		if("full")
			subject = "your body"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("left")
			subject = "the left side of your body"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_L_LEG)
		if("right")
			subject = "the right side of your body"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_R_LEG)
		if("arms")
			subject = "your arms"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM)
		if("legs")
			subject = "your legs"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("r_arm")
			subject = "your right arm"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM)
		if("l_arm")
			subject = "your left arm"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM)
		if("r_leg")
			subject = "your right leg"
			paralysis_traits = list(TRAIT_PARALYSIS_R_LEG)
		if("l_leg")
			subject = "your left leg"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG)

	gain_text = SPAN_WARNING("You can't feel [subject] anymore!")
	lose_text = SPAN_NOTICE("You can feel [subject] again!")

/datum/brain_trauma/severe/paralysis/on_gain()
	..()
	for(var/X in paralysis_traits)
		ADD_TRAIT(owner, X)


/datum/brain_trauma/severe/paralysis/on_lose()
	..()
	for(var/X in paralysis_traits)
		REMOVE_TRAIT(owner, X)


/datum/brain_trauma/severe/paralysis/paraplegic
	random_gain = FALSE
	paralysis_type = "legs"
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/paralysis/hemiplegic
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/paralysis/hemiplegic/left
	paralysis_type = "left"

/datum/brain_trauma/severe/paralysis/hemiplegic/right
	paralysis_type = "right"

/datum/brain_trauma/severe/narcolepsy
	name = "Narcolepsy"
	desc = "Patient may involuntarily fall asleep during normal activities."
	scan_desc = "traumatic narcolepsy"
	gain_text = SPAN_WARNING("You have a constant feeling of drowsiness...")
	lose_text = SPAN_NOTICE("You feel awake and aware again.")

/datum/brain_trauma/severe/narcolepsy/on_life(seconds_per_tick, times_fired)
	if(owner.IsSleeping())
		return

	var/sleep_chance = 1
	var/drowsy = !!owner.has_status_effect(/datum/status_effect/drowsiness)
	if(owner.move_intent == MOVE_INTENT_RUN)
		sleep_chance += 2
	if(drowsy)
		sleep_chance += 3

	if(SPT_PROB(0.5 * sleep_chance, seconds_per_tick))
		to_chat(owner, SPAN_WARNING("You fall asleep."))
		owner.Sleeping(6 SECONDS)

	else if(!drowsy && SPT_PROB(sleep_chance, seconds_per_tick))
		to_chat(owner, SPAN_WARNING("You feel tired..."))
		owner.adjust_drowsiness(20 SECONDS)

/datum/brain_trauma/severe/monophobia
	name = "Monophobia"
	desc = "Patient feels sick and distressed when not around other people, leading to potentially lethal levels of stress."
	scan_desc = "monophobia"
	gain_text = ""
	lose_text = SPAN_NOTICE("You feel like you could be safe on your own.")
	var/stress = 0

/datum/brain_trauma/severe/monophobia/on_gain()
	..()
	if(check_alone())
		to_chat(owner, SPAN_WARNING("You feel really lonely..."))
	else
		to_chat(owner, SPAN_NOTICE("You feel safe, as long as you have people around you."))

/datum/brain_trauma/severe/monophobia/on_life(seconds_per_tick, times_fired)
	..()
	if(check_alone())
		stress = min(stress + 0.5, 100)
		if(stress > 10 && SPT_PROB(2.5, seconds_per_tick))
			stress_reaction()
	else
		stress = max(stress - (2 * seconds_per_tick), 0)

/datum/brain_trauma/severe/monophobia/proc/check_alone()
	var/check_radius = 7
	if(owner.is_blind())
		check_radius = 1
	for(var/mob/M in oview(owner, check_radius))
		if(!isliving(M)) //ghosts ain't people
			continue
		if(istype(M, /mob/living/simple_animal/pet) || istype(M, /mob/living/basic/pet) || M.ckey)
			return FALSE
	return TRUE

/datum/brain_trauma/severe/monophobia/proc/stress_reaction()
	if(owner.stat != CONSCIOUS)
		return

	var/high_stress = (stress > 60) //things get psychosomatic from here on
	switch(rand(1, 6))
		if(1)
			if(high_stress)
				to_chat(owner, SPAN_WARNING("You feel really sick at the thought of being alone!"))
			else
				to_chat(owner, SPAN_WARNING("You feel sick..."))
			addtimer(CALLBACK(owner, /mob/living/carbon/human/proc/vomit), high_stress, 50) //blood vomit if high stress
		if(2)
			if(high_stress)
				to_chat(owner, SPAN_WARNING("You feel weak and scared! If only you weren't alone..."))
				owner.adjustStaminaLoss(50)
			else
				to_chat(owner, SPAN_WARNING("You can't stop shaking..."))

			owner.adjust_dizzy(40 SECONDS)
			owner.adjust_confusion(20 SECONDS)
			owner.set_jitter_if_lower(40 SECONDS)

		if(3, 4)
			if(high_stress)
				to_chat(owner, SPAN_WARNING("You're going mad with loneliness!"))
				owner.adjust_hallucinations(60 SECONDS)
			else
				to_chat(owner, SPAN_WARNING("You feel really lonely..."))

		if(5)
			if(high_stress)
				if(prob(15) && ishuman(owner))
					var/mob/living/carbon/human/H = owner
					H.set_heartattack(TRUE)
					to_chat(H, span_userdanger("You feel a stabbing pain in your heart!"))
				else
					to_chat(owner, span_userdanger("You feel your heart lurching in your chest..."))
					owner.adjustOxyLoss(8)
			else
				to_chat(owner, SPAN_WARNING("Your heart skips a beat."))
				owner.adjustOxyLoss(8)

		else
			//No effect
			return

/datum/brain_trauma/severe/discoordination
	name = "Discoordination"
	desc = "Patient is unable to use complex tools or machinery."
	scan_desc = "extreme discoordination"
	gain_text = SPAN_WARNING("You can barely control your hands!")
	lose_text = SPAN_NOTICE("You feel in control of your hands again.")

/datum/brain_trauma/severe/discoordination/on_gain()
	. = ..()
	owner.apply_status_effect(/datum/status_effect/discoordinated)

/datum/brain_trauma/severe/discoordination/on_lose()
	owner.remove_status_effect(/datum/status_effect/discoordinated)
	return ..()

/datum/brain_trauma/severe/pacifism
	name = "Traumatic Non-Violence"
	desc = "Patient is extremely unwilling to harm others in violent ways."
	scan_desc = "pacific syndrome"
	gain_text = SPAN_NOTICE("You feel oddly peaceful.")
	lose_text = SPAN_NOTICE("You no longer feel compelled to not harm.")

/datum/brain_trauma/severe/pacifism/on_gain()
	ADD_TRAIT(owner, TRAIT_PACIFISM)
	..()

/datum/brain_trauma/severe/pacifism/on_lose()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM)
	..()

/datum/brain_trauma/severe/hypnotic_stupor
	name = "Hypnotic Stupor"
	desc = "Patient is prone to episodes of extreme stupor that leaves them extremely suggestible."
	scan_desc = "oneiric feedback loop"
	gain_text = SPAN_WARNING("You feel somewhat dazed.")
	lose_text = SPAN_NOTICE("You feel like a fog was lifted from your mind.")

/datum/brain_trauma/severe/hypnotic_stupor/on_lose() //hypnosis must be cleared separately, but brain surgery should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_stupor/on_life(seconds_per_tick, times_fired)
	..()
	if(SPT_PROB(0.5, seconds_per_tick) && !owner.has_status_effect(/datum/status_effect/trance))
		owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)

/datum/brain_trauma/severe/hypnotic_trigger
	name = "Hypnotic Trigger"
	desc = "Patient has a trigger phrase set in their subconscious that will trigger a suggestible trance-like state."
	scan_desc = "oneiric feedback loop"
	gain_text = SPAN_WARNING("You feel odd, like you just forgot something important.")
	lose_text = SPAN_NOTICE("You feel like a weight was lifted from your mind.")
	random_gain = FALSE
	var/trigger_phrase = "Nanotrasen"

/datum/brain_trauma/severe/hypnotic_trigger/New(phrase)
	..()
	if(phrase)
		trigger_phrase = phrase

/datum/brain_trauma/severe/hypnotic_trigger/on_lose() //hypnosis must be cleared separately, but brain surgery should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_trigger/handle_hearing(datum/source, list/hearing_args)
	if(!owner.can_hear() || owner == hearing_args[HEARING_SPEAKER])
		return

	var/regex/reg = new("(\\b[REGEX_QUOTE(trigger_phrase)]\\b)","ig")

	if(findtext(hearing_args[HEARING_RAW_MESSAGE], reg))
		addtimer(CALLBACK(src, .proc/hypnotrigger), 10) //to react AFTER the chat message
		hearing_args[HEARING_RAW_MESSAGE] = reg.Replace(hearing_args[HEARING_RAW_MESSAGE], span_hypnophrase("*********"))

/datum/brain_trauma/severe/hypnotic_trigger/proc/hypnotrigger()
	to_chat(owner, SPAN_WARNING("The words trigger something deep within you, and you feel your consciousness slipping away..."))
	owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)

/datum/brain_trauma/severe/dyslexia
	name = "Dyslexia"
	desc = "Patient is unable to read or write."
	scan_desc = "dyslexia"
	gain_text = SPAN_WARNING("You have trouble reading or writing...")
	lose_text = SPAN_NOTICE("You suddenly remember how to read and write.")

/datum/brain_trauma/severe/dyslexia/on_gain()
	ADD_TRAIT(owner, TRAIT_ILLITERATE)
	..()

/datum/brain_trauma/severe/dyslexia/on_lose()
	REMOVE_TRAIT(owner, TRAIT_ILLITERATE)
	..()
