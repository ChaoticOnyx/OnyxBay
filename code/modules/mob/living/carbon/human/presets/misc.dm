
/mob/living/carbon/human/simple
	snowflake_organs = ORGAN_SNOWFLAKE_SIMPLE

/mob/living/carbon/human/simplest
	snowflake_organs = ORGAN_SNOWFLAKE_SIMPLEST

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	virtual_mob = null

/mob/living/carbon/human/dummy/mannequin/Initialize()
	. = ..()
	STOP_PROCESSING(SSmobs, src)
	GLOB.human_mob_list -= src
	delete_inventory()

/mob/living/carbon/human/dummy/mannequin/add_to_living_mob_list()
	return FALSE

/mob/living/carbon/human/dummy/mannequin/add_to_dead_mob_list()
	return FALSE

/mob/living/carbon/human/dummy/mannequin/update_deformities()
	return // There's simply no need in extra processing

/mob/living/carbon/human/dummy/mannequin/fully_replace_character_name(new_name)
	..("[new_name] (mannequin)", FALSE)

/mob/living/carbon/human/dummy/mannequin/InitializeHud()
	return	// Mannequins don't get HUDs

/mob/living/carbon/human/dummy/mannequin/should_have_organ()
	return FALSE // Mannequins are great no organs required

/mob/living/carbon/human/dummy/mannequin/Life()
	return // Because we never know

/mob/living/carbon/human/dummy/mannequin/check_shadow()
	return
