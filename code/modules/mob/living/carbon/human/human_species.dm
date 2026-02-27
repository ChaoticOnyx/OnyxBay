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

/mob/living/carbon/human/gatecrasher/Initialize()
	. = ..()
	add_think_ctx("unposessed_death_check", CALLBACK(src, nameof(.proc/unpossessed_death_check)), world.time + 45 SECONDS)

/mob/living/carbon/human/gatecrasher/proc/unpossessed_death_check()
	if(ckey) // Possessed, no euthanasia required
		remove_think_ctx("unposessed_death_check")
		return

	adjustOxyLoss(maxHealth) // Cease life functions.
	setBrainLoss(maxHealth)

	var/obj/item/organ/internal/heart/my_heart = internal_organs_by_name[BP_HEART]
	my_heart?.pulse = PULSE_NONE
	remove_think_ctx("unposessed_death_check")

/mob/living/carbon/human/gatecrasher/on_ghost_possess()
	. = ..()
	var/role_notice = ""
	if(prob(65)) // Sorry no antagonizing today
		role_notice = "Given that you are not an antag,"
	else
		var/antag_poll = list(
			MODE_CHANGELING = 3,
			MODE_TRAITOR = 15,
			MODE_VAMPIRE = 3,
			MODE_CULTIST = 5,
			MODE_REVOLUTIONARY = 5
		)
		var/datum/antagonist/selected_antag = GLOB.all_antag_types_[util_pick_weight(antag_poll)]
		selected_antag?.add_antagonist(mind, TRUE, max_stat = UNCONSCIOUS)
		role_notice = "Even though you happen to be an antag,"

	spawn(1 SECOND) // Added a delay so that this should pop up at the bottom, since we can get a lot of other spam by possessing a human and becoming an antag.
		var/disclaimer = "*--------------------*\n<b>You're a gatecrasher!</b>\n"
		disclaimer += "How did you end up in a locker aboard the station? What are your goals? Who are you? You tell the world! Your past and your future are yours to craft.\n"
		disclaimer += "<b>[role_notice] remember that you're not above the rules.</b> You have a chance to make this shift unique and unforgettable, don't waste it by aimlessly wreaking havoc and succumbing to wanton carnage.\n"
		disclaimer += "Please, do your best to make it fun for the others, and have fun yourself!\n*--------------------*"
		to_chat(src, SPAN("notice", "[disclaimer]"))

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
