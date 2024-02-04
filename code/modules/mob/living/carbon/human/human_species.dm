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

/mob/living/carbon/human/skrell/New(new_loc)
	h_style = "Skrell Male Tentacles"
	..(new_loc, SPECIES_SKRELL)

/mob/living/carbon/human/tajaran/New(new_loc)
	h_style = "Ears"
	..(new_loc, SPECIES_TAJARA)

/mob/living/carbon/human/unathi/New(new_loc)
	h_style = "Horns"
	..(new_loc, SPECIES_UNATHI)

/mob/living/carbon/human/swine/New(new_loc)
	h_style = pick("Bald", "Floppy Ears", "Pointy Ears")
	..(new_loc, SPECIES_SWINE)

/mob/living/carbon/human/vox/New(new_loc)
	h_style = "Long Vox Quills"
	..(new_loc, SPECIES_VOX)

/mob/living/carbon/human/diona/New(new_loc)
	..(new_loc, SPECIES_DIONA)

/mob/living/carbon/human/monkey/New(new_loc)
	..(new_loc, "Monkey")

/mob/living/carbon/human/farwa/New(new_loc)
	..(new_loc, "Farwa")

/mob/living/carbon/human/neaera/New(new_loc)
	..(new_loc, "Neaera")

/mob/living/carbon/human/stok/New(new_loc)
	..(new_loc, "Stok")

/mob/living/carbon/human/gravworlder/New(new_loc)
	..(new_loc, SPECIES_GRAVWORLDER)

/mob/living/carbon/human/spacer/New(new_loc)
	..(new_loc, SPECIES_SPACER)

/mob/living/carbon/human/vatgrown/New(new_loc)
	..(new_loc, SPECIES_VATGROWN)

/mob/living/carbon/human/vatgrown/female/New(new_loc)
	..(new_loc, SPECIES_VATGROWN)
	gender = "female"
	regenerate_icons()

/mob/living/carbon/human/promethean/New(new_loc)
	..(new_loc, SPECIES_PROMETHEAN)

/mob/living/carbon/human/slimeperson/New(new_loc)
	..(new_loc, SPECIES_SLIMEPERSON)

/mob/living/carbon/human/stargazer/New(new_loc)
	..(new_loc, SPECIES_STARGAZER)

/mob/living/carbon/human/luminescent/New(new_loc)
	..(new_loc, SPECIES_LUMINESCENT)
