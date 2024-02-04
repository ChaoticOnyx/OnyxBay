/mob/living/carbon/human/proc/change_appearance(flags = APPEARANCE_ALL_HAIR, location = src, mob/user = src, check_species_whitelist = 1, list/species_whitelist = list(), list/species_blacklist = list(), datum/topic_state/state = GLOB.default_state)
	var/datum/nano_module/appearance_changer/AC = new(location, src, check_species_whitelist, species_whitelist, species_blacklist)
	AC.flags = flags
	AC.ui_interact(user, state = state)

/mob/living/carbon/human/proc/change_species(new_species)
	if(!new_species)
		return

	if(species == new_species)
		return

	if(!(new_species in all_species))
		return

	set_species(new_species)
	reset_hair()
	return 1

/mob/living/carbon/human/proc/change_gender(gender)
	if(src.gender == gender)
		return

	src.gender = gender
	reset_hair()
	update_body()
	update_dna()
	return 1

/mob/living/carbon/human/proc/randomize_gender()
	change_gender(pick(species.genders))

/mob/living/carbon/human/proc/sanitize_body()
	var/list/body_builds = src.species.get_body_build_datum_list(src.gender)
	if(!(body_build in body_builds))
		change_body_build(body_builds[1])
		regenerate_icons()

/// Use this proc to set body build or I will eat your liver
/mob/living/carbon/human/proc/change_body_build(body_build)
	if(src.body_build == body_build)
		return

	if(src.body_build?.movespeed_modifier)
		remove_movespeed_modifier(src.body_build.movespeed_modifier)

	src.body_build = body_build
	add_movespeed_modifier(src.body_build.movespeed_modifier)
	regenerate_icons()
	return 1

/mob/living/carbon/human/proc/change_hair(hair_style)
	if(!hair_style)
		return

	if(h_style == hair_style)
		return

	if(!(hair_style in GLOB.hair_styles_list))
		return

	h_style = hair_style

	update_hair()
	return 1

/mob/living/carbon/human/proc/change_facial_hair(facial_hair_style)
	if(!facial_hair_style)
		return

	if(f_style == facial_hair_style)
		return

	if(!(facial_hair_style in GLOB.facial_hair_styles_list))
		return

	f_style = facial_hair_style

	update_hair()
	return 1

/mob/living/carbon/human/proc/reset_hair()
	var/list/valid_hairstyles = generate_valid_hairstyles()
	var/list/valid_facial_hairstyles = generate_valid_facial_hairstyles()

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)
	else
		//this shouldn't happen
		h_style = "Bald"

	if(valid_facial_hairstyles.len)
		f_style = pick(valid_facial_hairstyles)
	else
		//this shouldn't happen
		f_style = "Shaved"

	update_hair()

/mob/living/carbon/human/proc/change_eye_color(red, green, blue)
	if(red == r_eyes && green == g_eyes && blue == b_eyes)
		return

	r_eyes = red
	g_eyes = green
	b_eyes = blue

	update_eyes()
	update_body()
	return 1

/mob/living/carbon/human/proc/change_hair_color(red, green, blue)
	if(red == r_hair && green == g_hair && blue == b_hair)
		return

	r_hair = red
	g_hair = green
	b_hair = blue

	force_update_limbs()
	update_body()
	update_hair()
	return 1

/mob/living/carbon/human/proc/change_s_hair_color(red, green, blue)
	if(red == r_eyes && green == g_eyes && blue == b_eyes)
		return

	r_s_hair = red
	g_s_hair = green
	b_s_hair = blue

	force_update_limbs()
	update_body()
	update_hair()
	return 1

/mob/living/carbon/human/proc/change_facial_hair_color(red, green, blue)
	if(red == r_facial && green == g_facial && blue == b_facial)
		return

	r_facial = red
	g_facial = green
	b_facial = blue

	update_hair()
	return 1

/mob/living/carbon/human/proc/change_skin_color(red, green, blue)
	if(red == r_skin && green == g_skin && blue == b_skin || !(species.appearance_flags & HAS_SKIN_COLOR))
		return

	r_skin = red
	g_skin = green
	b_skin = blue

	force_update_limbs()
	update_body()
	return 1

/mob/living/carbon/human/proc/change_skin_tone(tone)
	if(s_tone == tone || !(species.appearance_flags & HAS_A_SKIN_TONE))
		return

	s_tone = tone

	force_update_limbs()
	update_body()
	return 1

/mob/living/carbon/human/proc/update_dna()
	check_dna()
	dna.ready_dna(src)
	sync_organ_dna()

/mob/living/carbon/human/proc/generate_valid_species(check_whitelist = 1, list/whitelist = list(), list/blacklist = list())
	var/list/valid_species = new()
	for(var/current_species_name in all_species)
		var/datum/species/current_species = all_species[current_species_name]

		if(check_whitelist) //If we're using the whitelist, make sure to check it!
			if((current_species.spawn_flags & SPECIES_IS_RESTRICTED) && !check_rights(R_ADMIN, 0, src))
				continue
			if(!is_alien_whitelisted(src, current_species))
				continue
		if(whitelist.len && !(current_species_name in whitelist))
			continue
		if(blacklist.len && (current_species_name in blacklist))
			continue

		valid_species += current_species_name

	return valid_species

/mob/living/carbon/human/proc/generate_valid_hairstyles(check_gender = 1)
	. = list()
	var/list/hair_styles = species.get_hair_styles()
	for(var/hair_style in hair_styles)
		var/datum/sprite_accessory/S = hair_styles[hair_style]
		if(check_gender)
			if(gender == MALE && S.gender == FEMALE)
				continue
			if(gender == FEMALE && S.gender == MALE)
				continue
		.[hair_style] = S

/mob/living/carbon/human/proc/generate_valid_facial_hairstyles()
	return species.get_facial_hair_styles(gender)

/mob/living/carbon/human/proc/force_update_limbs()
	for(var/obj/item/organ/external/O in organs)
		O.sync_colour_to_human(src)
	update_body(0)
