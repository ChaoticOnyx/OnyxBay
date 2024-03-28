/datum/species/swine
	name = SPECIES_SWINE
	name_plural = "Trottines"
	icobase = 'icons/mob/human_races/r_swine.dmi'
	default_h_style = "Bald"
	hair_key = SPECIES_SWINE
	facial_hair_key = SPECIES_SWINE

	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/punch)
	gluttonous = GLUT_TINY | GLUT_SMALLER | GLUT_ITEM_ANYTHING
	strength = STR_HIGH
	brute_mod = 0.8
	burn_mod =  0.8
	toxins_mod = 0.7
	siemens_coefficient = 0.7
	warning_low_pressure = WARNING_LOW_PRESSURE * 0.8
	hazard_low_pressure = HAZARD_LOW_PRESSURE * 0.8
	warning_high_pressure = WARNING_HIGH_PRESSURE * 1.2
	hazard_high_pressure = HAZARD_HIGH_PRESSURE * 1.2
	blood_volume = 800
	num_alternate_languages = 2
	name_language = null
	hunger_factor = DEFAULT_HUNGER_FACTOR * 3
	meat_type = /obj/item/reagent_containers/food/meat/pork

	min_age = 18
	max_age = 80

	blurb = "Human-pig hybrids, Trottines were initially created for organ-harvesting \
	operations by a long-gone corporation, before bioprinting became such a wide-spread technology. \
	They found success in their attempt to merge human DNA with that of a pig - to make easier transplantable \
	organs such as hearts and lungs - creating a more humanlike being than anticipated."

	body_builds = list(
		new /datum/body_build/fat
	)

	cold_level_1 = 240 //Default 260 - Lower is better
	cold_level_2 = 180 //Default 200
	cold_level_3 = 100 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000

	spawn_flags = SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR | HAS_SKIN_TONE_SPCR | SECONDARY_HAIR_IS_SKIN

	sexybits_location = BP_GROIN

	heat_discomfort_level = 305
	heat_discomfort_strings = list(
		"You feel sweat drip down your neck.",
		"You feel uncomfortably warm.",
		"Your skin prickles in the heat.",
		"You feel warm enough to take a nap."
		)

	cold_discomfort_level = 260
	cold_discomfort_strings = list(
		"You feel chilly.",
		"You shiver suddenly.",
		"Your chilly flesh stands out in goosebumps."
		)

/datum/species/swine/handle_environment_special(mob/living/carbon/human/H)
	if(H.InStasis() || H.is_ic_dead() || isundead(H))
		return
	if(H.nutrition < 50)
		H.adjustToxLoss(2, 0)
		return
