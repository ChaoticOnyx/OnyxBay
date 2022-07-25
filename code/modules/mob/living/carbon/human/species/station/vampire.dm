/datum/species/vampire
	name = SPECIES_VAMPIRE
	name_plural = "Vampires"
	max_age = INFINITY
	blurb = "Vampire is an alpha-predator"
	gluttonous = null
	hunger_factor = 0
	breath_type = null
	spawn_flags = null
	reagent_tag = IS_VAMPIRE
	blood_color = "#6e0202"
	has_organ = list(        
		BP_HEART =    /obj/item/organ/internal/heart/vampiric_heart,
		BP_STOMACH =  /obj/item/organ/internal/stomach/vampiric_stomach,
		BP_LUNGS =    /obj/item/organ/internal/lungs/vampiric_lungs,
		BP_LIVER =    /obj/item/organ/internal/liver/vampiric_liver,
		BP_KIDNEYS =  /obj/item/organ/internal/kidneys/vampiric_kidneys,
		BP_BRAIN =    /obj/item/organ/internal/brain/vampiric_brain,
		BP_APPENDIX = /obj/item/organ/internal/appendix/vampiric_appendix,
		BP_EYES =     /obj/item/organ/internal/eyes/vampiric_eyes
		)
	burn_mod = 1.3
	oxy_mod = 0.0
	brute_mod = 0.7
	body_temperature = null
	cold_level_1 = 220 //Default 260 - Lower is better
	cold_level_2 = 120 //Default 200
	cold_level_3 = 80 //Default 120
	heat_level_1 = 460 //Default 400 - Higher is better //186.85C lol
	heat_level_2 = 650 //Default 500
	heat_level_3 = 1100 //Default 1000
	blood_volume = 1000
	cold_discomfort_level = 240 //16.85C, not more because they will have a constant messages
	heat_discomfort_level = 375 //101.85C    
	species_flags = SPECIES_FLAG_NO_POISON 
	spawn_flags = SPECIES_IS_RESTRICTED	
	
	var/species/vampire_origin_species = SPECIES_HUMAN	
	primitive_form = "Human"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite)
	num_alternate_languages = 2
	secondary_langs = list(LANGUAGE_SOL_COMMON)
	name_language = null // Use the first-name last-name generator rather than a language scrambler
	body_builds = list(
		new /datum/body_build,
		new /datum/body_build/slim,
		new /datum/body_build/slim/alt,
		new /datum/body_build/slim/male,
		new /datum/body_build/fat
		)
	appearance_flags = HAS_HAIR_COLOR | HAS_SKIN_TONE_NORMAL | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR
	sexybits_location = BP_GROIN
