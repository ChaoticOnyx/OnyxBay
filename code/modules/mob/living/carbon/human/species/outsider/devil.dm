/datum/species/devil
	name = "Devil"
	name_plural = "devils"
	hair_key = SPECIES_HUMAN
	facial_hair_key = SPECIES_HUMAN
	language = "Sol Common"
	unarmed_types = list(/datum/unarmed_attack/claws/strong)
	generic_attack_mod = 2.0
	darksight_range = 7
	darksight_tint = DARKTINT_GOOD
	gluttonous = GLUT_ANYTHING
	strength = STR_HIGH
	blood_color = "#cccccc"
	flesh_color = "#aaaaaa"
	tail = "deviltail"
	secondary_langs = list(LANGUAGE_INFERNAL)
	name_language = LANGUAGE_INFERNAL
	min_age = 18
	max_age = 1000
	remains_type = /obj/effect/decal/cleanable/ash
	death_message = "dissolves into ash..."

	species_flags = SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NEED_DIRECT_ABSORB | SPECIES_FLAG_NO_ANTAG_TARGET | SPECIES_FLAG_NO_FIRE
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_SKIN_COLOR | HAS_EYE_COLOR
	spawn_flags = SPECIES_IS_RESTRICTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_NO_LACE

	body_builds = list(
		new /datum/body_build,
		new /datum/body_build/slim,
		new /datum/body_build/slim/alt,
		new /datum/body_build/slim/flat,
		new /datum/body_build/slim/male,
		new /datum/body_build/fat
	)

/datum/species/devil/handle_death(mob/living/carbon/human/H)
	H.dust()

/datum/species/devil/is_eligible_for_antag_spawn()
	return FALSE

/datum/species/devil/get_tail(mob/living/carbon/human/H)
	if(istype(H.body_build, /datum/body_build/slim) || \
		istype(H.body_build, /datum/body_build/slim/alt) || \
		istype(H.body_build, /datum/body_build/slim/flat) || \
		istype(H.body_build, /datum/body_build/slim/male))
		return "[tail]_slim"

	else
		return tail
