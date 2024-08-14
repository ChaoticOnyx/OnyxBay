/datum/species/arenahuman
	name = "Arenahuman"
	hair_key = SPECIES_HUMAN
	facial_hair_key = SPECIES_HUMAN
	language = "Sol Common"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch)
	species_flags = SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_ANTAG_TARGET
	spawn_flags = SPECIES_IS_RESTRICTED
	siemens_coefficient = 0
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_SKIN_COLOR | HAS_EYE_COLOR |  HAS_A_SKIN_TONE

	breath_type = null
	poison_type = null

	has_organ = list(
		BP_BRAIN = /obj/item/organ/internal/cerebrum/arenacerebrum,
		BP_STOMACH = /obj/item/organ/internal/stomach,
		BP_HEART = /obj/item/organ/internal/heart
		)

	death_message = "becomes completely motionless..."

	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/unbreakable),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/unbreakable),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/unbreakable),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/unbreakable),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/unbreakable),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/unbreakable),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/unbreakable),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/unbreakable),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/unbreakable),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/unbreakable),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/unbreakable)
		)

	xenomorph_type = null

/datum/species/arenahuman/is_eligible_for_antag_spawn(antag_id)
	return FALSE

/obj/item/organ/internal/cerebrum/arenacerebrum
	vital = FALSE
