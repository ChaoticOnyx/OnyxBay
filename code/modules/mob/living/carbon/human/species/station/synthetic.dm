/datum/species/synth
	name = SPECIES_SYNTH
	name_plural = "Cyborgs"
	organic_type_species = SPECIES_HUMAN
	hair_key = SPECIES_HUMAN
	facial_hair_key = SPECIES_HUMAN
	var/tail_slim
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

	spawn_flags = SPECIES_IS_FBP | SPECIES_NOT_CHOOSEABLE
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR

/datum/species/synth/generate_synth_species(species_name, company)
	switch(species_name)
		if(SPECIES_TAJARA)
			tail = "tajtail"
			tail_slim = "tajtail_slim"
			tail_animation = 'icons/mob/species/tajaran/tail.dmi'
			default_h_style = "Ears"
			hair_key = SPECIES_TAJARA
			facial_hair_key = SPECIES_TAJARA
			unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws)
			secondary_langs = list(LANGUAGE_SIIK_MAAS)
			additional_langs = list(LANGUAGE_SIIK_TAJR)
			name_language = LANGUAGE_SIIK_MAAS
			body_builds = list(
				new /datum/body_build/tajaran,
				new /datum/body_build/slim/alt/tajaran,
				new /datum/body_build/tajaran/fat
			)
			move_trail = /obj/effect/decal/cleanable/blood/tracks/paw
			species_appearance_flags |= HAS_SKIN_COLOR

		if(SPECIES_UNATHI)
			tail = "sogtail"
			tail_animation = 'icons/mob/species/unathi/tail.dmi'
			hair_key = SPECIES_UNATHI
			unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/tail, /datum/unarmed_attack/claws)
			move_trail = /obj/effect/decal/cleanable/blood/tracks/claw
			secondary_langs = list(LANGUAGE_UNATHI)
			name_language = LANGUAGE_UNATHI
			body_builds = list(
				new /datum/body_build/unathi
			)
			species_appearance_flags |= HAS_SKIN_COLOR

		if(SPECIES_SKRELL)
			hair_key = SPECIES_SKRELL
			facial_hair_key = null
			unarmed_types = list(/datum/unarmed_attack/punch)
			secondary_langs = list(LANGUAGE_SKRELLIAN)
			name_language = LANGUAGE_SKRELLIAN
			troublesome_sexual_dimorphism = TRUE
			species_appearance_flags |= HAS_SKIN_COLOR

		if(SPECIES_SWINE)
			default_h_style = "Bald"
			hair_key = SPECIES_SWINE
			facial_hair_key = SPECIES_SWINE
			body_builds = list(
				new /datum/body_build/fat
			)

	organic_type_species = species_name

/datum/species/synth/get_tail(mob/living/carbon/human/H)
	if(istype(H.body_build, /datum/body_build/slim/alt/tajaran))
		return tail_slim
	return ..()

/datum/species/synth/equip_survival_gear(mob/living/carbon/human/H)
	..()
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H),slot_shoes)
