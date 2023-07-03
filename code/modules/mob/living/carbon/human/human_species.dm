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
	h_style = "Bald"
	..(new_loc, SPECIES_SWINE)

/mob/living/carbon/human/vox/New(new_loc)
	h_style = "Long Vox Quills"
	..(new_loc, SPECIES_VOX)

/mob/living/carbon/human/diona/New(new_loc)
	..(new_loc, SPECIES_DIONA)

/mob/living/carbon/human/machine/New(new_loc)
	..(new_loc, SPECIES_IPC)

/mob/living/carbon/human/nabber/New(new_loc)
	pulling_punches = 1
	..(new_loc, SPECIES_NABBER)

/mob/living/carbon/human/monkey/New(new_loc)
	..(new_loc, "Monkey")

/mob/living/carbon/human/farwa/New(new_loc)
	..(new_loc, "Farwa")

/mob/living/carbon/human/neaera/New(new_loc)
	..(new_loc, "Neaera")

/mob/living/carbon/human/stok/New(new_loc)
	..(new_loc, "Stok")

/mob/living/carbon/human/vrhuman/New(new_loc)
	..(new_loc, "VR human")

/mob/living/carbon/human/vatgrown/fully_replace_character_name(new_name, in_depth)
	#define LTR ascii2text(rand(65,90))
	#define NUM ascii2text(rand(48,57))
	#define NAME capitalize(pick(gender == FEMALE ? GLOB.first_names_female : GLOB.first_names_male))
	switch(rand(1, 4))
		if(1) new_name = NAME
		if(2) new_name = "[LTR][LTR]-[NAME]"
		if(3) new_name = "[NAME]-[NUM][NUM][NUM]"
		if(4) new_name = "[LTR][LTR]-[NUM][NUM][NUM]"
	. = ..(new_name, in_depth)
	#undef LTR
	#undef NUM
	#undef NAME

/mob/living/carbon/human/vatgrown/New(new_loc)
	LAZYADD(mutations, MUTATION_VATGROWN)
	..(new_loc, SPECIES_HUMAN)

/mob/living/carbon/human/vatgrown/female/New(new_loc)
	gender = FEMALE
	..(new_loc, SPECIES_HUMAN)

/mob/living/carbon/human/abductor/New(new_loc)
	..(new_loc, SPECIES_ABDUCTOR)

/mob/living/carbon/human/promethean/New(new_loc)
	..(new_loc, SPECIES_PROMETHEAN)

/mob/living/carbon/human/slimeperson/New(new_loc)
	..(new_loc, SPECIES_SLIMEPERSON)

/mob/living/carbon/human/stargazer/New(new_loc)
	..(new_loc, SPECIES_STARGAZER)

/mob/living/carbon/human/luminescent/New(new_loc)
	..(new_loc, SPECIES_LUMINESCENT)
