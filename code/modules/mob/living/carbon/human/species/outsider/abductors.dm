/datum/species/abductor
	name = "Abductor"
	name_plural = "Abductors"
	breath_type = null
	has_fine_manipulation = 1
	species_flags = SPECIES_FLAG_NO_BLOOD
	spawn_flags = SPECIES_IS_RESTRICTED
	default_language = LANGUAGE_ABDUCTOR
	num_alternate_languages = 1
	language = LANGUAGE_GALCOM
	icobase = 'icons/mob/human_races/r_abductor.dmi'
	deform = 'icons/mob/human_races/r_abductor.dmi'

	blood_color = "#972ab3"
	flesh_color = "#707070"

/datum/species/abductor/handle_vision(mob/living/carbon/human/H)
	. = ..()
	process_gland_hud()
