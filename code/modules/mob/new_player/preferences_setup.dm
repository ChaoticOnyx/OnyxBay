#define ASSIGN_LIST_TO_COLORS(L, R, G, B) if(L) { R = L[1]; G = L[2]; B = L[3]; }

/datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
	proc/randomize_appearance_and_body_for(mob/living/carbon/human/H)
		var/datum/species/current_species = all_species[species]
		if(!current_species) current_species = all_species[SPECIES_HUMAN]

		gender = pick(current_species.genders)
		var/list/available_body_builds = new()
		for(var/datum/body_build/build in current_species.body_builds)
			if (gender in build.genders)
				available_body_builds += build
		body = pick(available_body_builds).name
		body_height = pick(body_heights)

		h_style = random_hair_style(gender, species)
		f_style = random_facial_hair_style(gender, species)
		if(current_species)
			if(current_species.species_appearance_flags & HAS_A_SKIN_TONE)
				s_tone = current_species.get_random_skin_tone() || s_tone
			if(current_species.species_appearance_flags & HAS_EYE_COLOR)
				ASSIGN_LIST_TO_COLORS(current_species.get_random_eye_color(), r_eyes, g_eyes, b_eyes)
			else
				r_eyes = hex2num(copytext(current_species.default_eye_color, 2, 4))
				g_eyes = hex2num(copytext(current_species.default_eye_color, 4, 6))
				b_eyes = hex2num(copytext(current_species.default_eye_color, 6, 8))
			if(current_species.species_appearance_flags & HAS_SKIN_COLOR)
				ASSIGN_LIST_TO_COLORS(current_species.get_random_skin_color(), r_skin, g_skin, b_skin)
			if(current_species.species_appearance_flags & HAS_HAIR_COLOR)
				var/hair_colors = current_species.get_random_hair_color()
				if(hair_colors)
					ASSIGN_LIST_TO_COLORS(hair_colors, r_hair, g_hair, b_hair)

					if(prob(75))
						r_facial = r_hair
						g_facial = g_hair
						b_facial = b_hair
					else
						ASSIGN_LIST_TO_COLORS(current_species.get_random_facial_hair_color(), r_facial, g_facial, b_facial)

				hair_colors = current_species.get_random_hair_color()
				if(hair_colors)
					ASSIGN_LIST_TO_COLORS(hair_colors, r_s_hair, g_s_hair, b_s_hair)

		if(current_species.species_appearance_flags & HAS_UNDERWEAR)
			all_underwear.Cut()
			for(var/datum/category_group/underwear/WRC in GLOB.underwear.categories)
				var/datum/category_item/underwear/WRI = pick(WRC.items)
				all_underwear[WRC.name] = WRI.name

		backpack = decls_repository.get_decl(pick(subtypesof(/decl/backpack_outfit)))
		age = rand(current_species.min_age, current_species.max_age)
		b_type = RANDOM_BLOOD_TYPE
		if(H)
			copy_to(H)

#undef ASSIGN_LIST_TO_COLORS

/datum/preferences/proc/dress_preview_mob(mob/living/carbon/human/mannequin)
	copy_to(mannequin, TRUE)

	if(!equip_preview_mob)
		return

	var/update_icon = FALSE
	mannequin.update_icon = TRUE

	var/datum/job/previewJob
	if(equip_preview_mob && job_master)
		// Determine what job is marked as 'High' priority, and dress them up as such.
		if("Assistant" in job_low)
			previewJob = job_master.GetJob("Assistant")
		else
			for(var/datum/job/job in job_master.occupations)
				if(job.title == job_high)
					previewJob = job
					break
	else
		return

	if(!previewJob && mannequin.icon)
		update_icon = TRUE // So we don't end up stuck with a borg/AI icon after setting their priority to non-high
	else if((equip_preview_mob & EQUIP_PREVIEW_JOB) && previewJob)
		mannequin.job = previewJob.title
		previewJob.equip_preview(mannequin, player_alt_titles[previewJob.title])
		if(!previewJob.preview_override)
			update_icon = TRUE

	if((equip_preview_mob & EQUIP_PREVIEW_LOADOUT) && !previewJob?.preview_override)
		// Equip custom gear loadout, replacing any job items
		var/wrist_underwear_equipped = FALSE
		var/list/loadout_taken_slots = list()
		var/list/accessories = list()

		var/list/gears = Gear().Copy()
		if(trying_on_gear)
			gears[trying_on_gear] = trying_on_tweaks.Copy()

		for(var/thing in gears)
			var/datum/gear/G = gear_datums[thing]
			if(G)
				var/permitted = 0
				if(G.allowed_roles && G.allowed_roles.len)
					if(previewJob)
						for(var/job_type in G.allowed_roles)
							if(previewJob.type == job_type)
								permitted = 1
				else
					permitted = 1

				if(G.whitelisted && (G.whitelisted != mannequin.species.name))
					permitted = 0

				if(!permitted)
					continue

				if(G.slot == slot_tie)
					accessories.Add(G)
					continue

				if(ispath(G.path, /obj/item/underwear/wrist) && !wrist_underwear_equipped)
					G.spawn_on_mob(mannequin, gears[G.display_name])
					wrist_underwear_equipped = TRUE
					update_icon = TRUE

				if(G.slot && !(G.slot in loadout_taken_slots) && G.spawn_on_mob(mannequin, gears[G.display_name]))
					loadout_taken_slots.Add(G.slot)
					update_icon = TRUE

		// equip accessories after other slots so they don't attach to a suit which will be replaced
		for(var/datum/gear/G in accessories)
			G.spawn_as_accessory_on_mob(mannequin, gears[G.display_name])

		if(accessories.len)
			update_icon = TRUE


	if(update_icon)
		mannequin.update_icons()

/datum/preferences/proc/update_preview_icon()
	var/mob/living/carbon/human/dummy/mannequin/mannequin = get_mannequin(client_ckey)
	if(!mannequin)
		return
	mannequin.delete_inventory(TRUE)
	dress_preview_mob(mannequin)
	mannequin.ImmediateOverlayUpdate()

	var/mutable_appearance/MA = new /mutable_appearance(mannequin)
	MA.appearance_flags = PIXEL_SCALE
	update_character_previews(MA)
