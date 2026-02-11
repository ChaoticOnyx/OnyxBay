/datum/species/synth
	name = SPECIES_SYNTH
	name_plural = "Cyborgs"
	organic_type_species = SPECIES_HUMAN
	hair_key = SPECIES_HUMAN
	facial_hair_key = SPECIES_HUMAN
	xenomorph_type = null
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch)
	blurb = "Humanity originated in the Sol system, and over the last five centuries has spread \
	colonies across a wide swathe of space. They hold a wide range of forms and creeds.<br/><br/> \
	While the central Sol government maintains control of its far-flung people, powerful corporate \
	interests, rampant cyber and bio-augmentation and secretive factions make life on most human \
	worlds tumultous at best."
	secondary_langs = list(LANGUAGE_SOL_COMMON)
	num_alternate_languages = 2
	name_language = null
	min_age = 18
	max_age = 200

	body_builds = list(
		new /datum/body_build,
		new /datum/body_build/slim,
		new /datum/body_build/slim/alt,
		new /datum/body_build/slim/flat,
		new /datum/body_build/slim/male,
		new /datum/body_build/fat
	)

	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/robotic),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/robotic),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/robotic),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/robotic),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/robotic),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/robotic),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/robotic),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/robotic),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/robotic),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/robotic),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/robotic)
		)

	death_message = "gives one shrill beep before falling lifeless."
	knockout_message = "encounters a hardware fault and suddenly reboots!"
	halloss_message = "slumps over, too weak to continue fighting..."
	halloss_message_self = "The pain is too severe for you to keep going..."
	show_ssd = "flashing a 'system offline' glyph on their monitor"

	virus_immune = TRUE
	vision_organ = BP_OPTICS
	coagulation = COAGULATION_NONE
	flesh_color = SYNTH_FLESH_COLOUR
	blood_color = SYNTH_BLOOD_COLOUR
	base_color = SYNTH_FLESH_COLOUR
	species_flags = SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_PAIN

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	has_organ = list(
		BP_CELL =		/obj/item/organ/internal/cell,
		BP_VOICE =		/obj/item/organ/internal/voicebox,
		BP_OPTICS =		/obj/item/organ/internal/eyes/optics,
		)

	spawn_flags = SPECIES_IS_FBP
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR

/datum/species/synth/tajaran
	name = SPECIES_SYNTH_TAJARA
	organic_type_species = SPECIES_TAJARA
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	tail = "tajtail"
	var/tail_slim = "tajtail_slim"
	tail_animation = 'icons/mob/species/tajaran/tail.dmi'
	default_h_style = "Ears"
	hair_key = SPECIES_TAJARA
	facial_hair_key = SPECIES_TAJARA
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws)
	generic_attack_mod = 2.0
	darksight_range = 8
	darksight_tint = DARKTINT_GOOD
	num_alternate_languages = 2
	secondary_langs = list(LANGUAGE_SIIK_MAAS)
	additional_langs = list(LANGUAGE_SIIK_TAJR)
	name_language = LANGUAGE_SIIK_MAAS

	generic_attack_mod = 2.0
	darksight_range = 8
	darksight_tint = DARKTINT_GOOD
	movespeed_modifier = /datum/movespeed_modifier/tajaran
	brute_mod = 1.15
	burn_mod =  1.15

	body_builds = list(
		new /datum/body_build/tajaran,
		new /datum/body_build/slim/alt/tajaran,
		new /datum/body_build/tajaran/fat
	)

	move_trail = /obj/effect/decal/cleanable/blood/tracks/paw
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR | HAS_SKIN_COLOR

/datum/species/synth/tajaran/get_tail(mob/living/carbon/human/H)
	if(istype(H.body_build, /datum/body_build/slim/alt/tajaran))
		return tail_slim
	return ..()

/datum/species/synth/unathi
	name = SPECIES_SYNTH_UNATHI
	organic_type_species = SPECIES_UNATHI
	icobase = 'icons/mob/human_races/r_lizard.dmi'

	tail = "sogtail"
	tail_animation = 'icons/mob/species/unathi/tail.dmi'
	hair_key = SPECIES_UNATHI

	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/tail, /datum/unarmed_attack/claws)
	generic_attack_mod = 2.0
	darksight_range = 3
	darksight_tint = DARKTINT_MODERATE
	strength = STR_HIGH
	movespeed_modifier = /datum/movespeed_modifier/unathi
	brute_mod = 0.8
	blood_volume = 8 LITERS
	secondary_langs = list(LANGUAGE_UNATHI)
	name_language = LANGUAGE_UNATHI

	move_trail = /obj/effect/decal/cleanable/blood/tracks/claw

	blurb = "A heavily reptillian species, Unathi (or 'Sinta as they call themselves) hail from the \
	Uuosa-Eso system, which roughly translates to 'burning mother'.<br/><br/>Coming from a harsh, radioactive \
	desert planet, they mostly hold ideals of honesty, virtue, martial combat and bravery above all \
	else, frequently even their own lives. They prefer warmer temperatures than most species and \
	their native tongue is a heavy hissing laungage called Sinta'Unathi."

	body_builds = list(
		new /datum/body_build/unathi
	)
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR | HAS_SKIN_COLOR

/datum/species/synth/equip_survival_gear(mob/living/carbon/human/H)
	..()
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H),slot_shoes)

/datum/species/synth/skrell
	name = SPECIES_SYNTH_SKRELL
	organic_type_species = SPECIES_SKRELL
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	hair_key = SPECIES_SKRELL
	facial_hair_key = null
	unarmed_types = list(/datum/unarmed_attack/punch)
	blurb = "An amphibious species, Skrell come from the star system known as Qerr'Vallis, which translates to 'Star of \
	the royals' or 'Light of the Crown'.<br/><br/>Skrell are a highly advanced and logical race who live under the rule \
	of the Qerr'Katish, a caste within their society which keeps the empire of the Skrell running smoothly. Skrell are \
	herbivores on the whole and tend to be co-operative with the other species of the galaxy, although they rarely reveal \
	the secrets of their empire to their allies."
	num_alternate_languages = 2
	secondary_langs = list(LANGUAGE_SKRELLIAN)
	name_language = LANGUAGE_SKRELLIAN
	troublesome_sexual_dimorphism = TRUE

	burn_mod = 0.9
	darksight_range = 4
	darksight_tint = DARKTINT_MODERATE

	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR | HAS_SKIN_COLOR

/datum/species/synth/swine
	name = SPECIES_SYNTH_SWINE
	organic_type_species = SPECIES_SWINE
	icobase = 'icons/mob/human_races/r_swine.dmi'
	default_h_style = "Bald"
	hair_key = SPECIES_SWINE
	facial_hair_key = SPECIES_SWINE

	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR

	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/punch)
	blood_volume = 8 LITERS
	strength = STR_HIGH
	brute_mod = 0.8
	burn_mod =  0.8
	name_language = null

	blurb = "Human-pig hybrids, Trottines were initially created for organ-harvesting \
	operations by a long-gone corporation, before bioprinting became such a wide-spread technology. \
	They found success in their attempt to merge human DNA with that of a pig - to make easier transplantable \
	organs such as hearts and lungs - creating a more humanlike being than anticipated."

	body_builds = list(
		new /datum/body_build/fat
	)
