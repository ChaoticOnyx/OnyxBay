/// TGUI backend for the Character Setup interface.
/// Replaces the legacy HTML preferences browser with a modern TGUI window.
/// Inspired by The Sims 4 Create-a-Sim: large central preview + category panels.

/// Lightweight shim that provides is_FBP()/get_FBP_type() for trait validation,
/// since the TGUI datum is not a /datum/category_item/player_setup_item.
/datum/tgui_trait_validator
	var/datum/preferences/pref

/datum/tgui_trait_validator/New(datum/preferences/P)
	pref = P

/datum/tgui_trait_validator/proc/is_FBP()
	if(!pref.organ_data || pref.organ_data[BP_CHEST] != "cyborg")
		return FALSE
	return TRUE

/datum/tgui_trait_validator/proc/get_FBP_type()
	if(!is_FBP())
		return 0
	var/result = "cyborg"
	if(BP_BRAIN in pref.organ_data)
		switch(pref.organ_data[BP_BRAIN])
			if("assisted")
				result = "cyborg"
			if("mechanical")
				result = "posi"
			if("digital")
				result = "software"
	return result

/datum/character_setup
	var/datum/preferences/pref
	var/preview_dir = SOUTH
	var/list/slot_previews  // Cached character slot appearance data (generated on demand)
	// Loadout state
	var/selected_gear_hash
	var/list/selected_tweaks = list()
	var/hide_unavailable_gear = FALSE
	var/hide_donate_gear = FALSE
	var/slot_filter
	// Augmentation state
	var/selected_organ = BP_CHEST
	// Undo stack — list of assoc lists (character snapshots), most recent last
	var/list/undo_stack = list()

/datum/character_setup/New(datum/preferences/P)
	pref = P

/datum/character_setup/Destroy()
	pref = null
	return ..()

/datum/character_setup/proc/push_undo_state()
	if(undo_stack.len >= 20)
		undo_stack.Cut(1, 2)
	undo_stack += list(pref.snapshot_character())


/datum/character_setup/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/character_setup/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "CharacterSetup", "Character Setup")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/character_setup/tgui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/directories/tgui_sprites)
	)

// ============================================================
// STATIC DATA — sent once, cached on the client
// Contains all reference data: species, hair styles, etc.
// ============================================================
/datum/character_setup/tgui_static_data(mob/user)
	var/list/data = list()

	// Species list with full metadata
	var/list/species_data = list()
	for(var/species_name in playable_species)
		var/datum/species/S = all_species[species_name]
		if(!S)
			continue
		var/list/builds_by_gender = list()
		for(var/G in S.genders)
			builds_by_gender[G] = S.get_body_build_list(G)

		species_data += list(list(
			"name" = S.name,
			"blurb" = S.blurb,
			"genders" = S.genders,
			"min_age" = S.min_age,
			"max_age" = S.max_age,
			"appearance_flags" = S.species_appearance_flags,
			"body_builds" = builds_by_gender,
			"default_h_style" = S.default_h_style,
			"default_f_style" = S.default_f_style,
			"max_skin_tone" = S.max_skin_tone(),
			"no_lace" = !!(S.spawn_flags & SPECIES_NO_LACE),
			"icobase" = "[S.icobase]",
			"hair_key" = S.hair_key
		))
	data["species_list"] = species_data

	// Hair styles
	var/list/hair_data = list()
	for(var/style_name in GLOB.hair_styles_list)
		var/datum/sprite_accessory/hair/H = GLOB.hair_styles_list[style_name]
		hair_data += list(list(
			"name" = H.name,
			"icon_state" = H.icon_state,
			"gender" = H.gender,
			"species_allowed" = H.species_allowed,
			"has_secondary" = H.has_secondary
		))
	data["hair_styles"] = hair_data

	// Facial hair styles
	var/list/facial_data = list()
	for(var/style_name in GLOB.facial_hair_styles_list)
		var/datum/sprite_accessory/facial_hair/F = GLOB.facial_hair_styles_list[style_name]
		facial_data += list(list(
			"name" = F.name,
			"icon_state" = F.icon_state,
			"gender" = F.gender,
			"species_allowed" = F.species_allowed
		))
	data["facial_hair_styles"] = facial_data

	// Hair icon DMI mappings — needed for client-side sprite compositor
	// Maps build category ("default"/"slim") -> species hair_key -> DMI path
	var/list/hair_icons_data = list()
	for(var/build_cat in GLOB.hair_icons)
		var/list/species_map = list()
		for(var/species_key in GLOB.hair_icons[build_cat])
			species_map[species_key] = "[GLOB.hair_icons[build_cat][species_key]]"
		hair_icons_data[build_cat] = species_map
	data["hair_icons"] = hair_icons_data

	var/list/facial_icons_data = list()
	for(var/build_cat in GLOB.facial_hair_icons)
		var/list/species_map = list()
		for(var/species_key in GLOB.facial_hair_icons[build_cat])
			species_map[species_key] = "[GLOB.facial_hair_icons[build_cat][species_key]]"
		facial_icons_data[build_cat] = species_map
	data["facial_hair_icons"] = facial_icons_data

	// Body build render data — maps build name to index suffix and clothing DMI paths
	// Collect from all playable species body builds
	var/list/build_render_data = list()
	for(var/species_name in playable_species)
		var/datum/species/S = all_species[species_name]
		if(!S)
			continue
		for(var/datum/body_build/BB in S.body_builds)
			if(BB.name in build_render_data)
				continue
			var/list/clothing_paths = list()
			for(var/slot in BB.clothing_icons)
				clothing_paths[slot] = "[BB.clothing_icons[slot]]"
			build_render_data[BB.name] = list(
				"index" = BB.index,
				"clothing_icons" = clothing_paths
			)
	data["body_build_render"] = build_render_data

	// Blood types
	data["blood_types"] = valid_bloodtypes

	// Spawnpoints
	var/list/spawn_names = list()
	for(var/sp in spawntypes())
		spawn_names += sp
	data["spawnpoints"] = spawn_names

	// Body heights with display names
	var/list/height_data = list()
	for(var/h in body_heights)
		height_data += list(list(
			"value" = h,
			"label" = human_height_text(h)
		))
	data["body_heights"] = height_data

	// Body markings
	var/list/marking_data = list()
	for(var/marking_name in GLOB.body_marking_styles_list)
		var/datum/sprite_accessory/marking/M = GLOB.body_marking_styles_list[marking_name]
		marking_data += list(list(
			"name" = M.name,
			"species_allowed" = M.species_allowed
		))
	data["body_markings_available"] = marking_data

	// Underwear categories + items
	var/list/uw_cats = list()
	for(var/datum/category_group/underwear/UWC in GLOB.underwear.categories)
		var/list/items = list()
		var/list/colorable = list()
		for(var/datum/category_item/underwear/UWI in UWC.items)
			items += UWI.name
			if(UWI.has_color)
				colorable += UWI.name
		uw_cats += list(list(
			"name" = UWC.name,
			"items" = items,
			"colorable" = colorable
		))
	data["underwear_categories"] = uw_cats

	// Backpack types
	var/list/bp_list = list()
	var/bos = decls_repository.get_decls_of_subtype(/decl/backpack_outfit)
	for(var/bo in bos)
		var/decl/backpack_outfit/B = bos[bo]
		bp_list += B.name
	data["backpack_types"] = bp_list

	// Preview background options
	data["bgstate_options"] = pref.bgstate_options

	// Config flags
	data["config"] = list(
		"allow_metadata" = config.character_setup.allow_metadata,
		"use_cortical_stacks" = config.revival.use_cortical_stacks,
		"max_name_len" = MAX_NAME_LEN,
		"loadout_slots" = config.character_setup.loadout_slots,
		"character_slots" = config.character_setup.character_slots
	)

	// === LOADOUT DATA ===
	var/list/loadout_cats = list()
	for(var/cat_name in loadout_categories)
		var/datum/loadout_category/LC = loadout_categories[cat_name]
		var/list/items = list()
		for(var/gear_name in LC.gear)
			var/datum/gear/G = LC.gear[gear_name]
			if(!G.path && !length(G.gear_tweaks))
				continue
			items += list(build_gear_entry(G, user))
		loadout_cats += list(list(
			"name" = cat_name,
			"items" = items
		))
	data["loadout_categories"] = loadout_cats

	// Slot types for loadout
	data["loadout_slot_types"] = list(
		list("slotId" = slot_head, "name" = "Head"),
		list("slotId" = slot_glasses, "name" = "Eyes"),
		list("slotId" = slot_wear_mask, "name" = "Mask"),
		list("slotId" = slot_l_ear, "name" = "Left Ear"),
		list("slotId" = slot_r_ear, "name" = "Right Ear"),
		list("slotId" = slot_w_uniform, "name" = "Uniform"),
		list("slotId" = slot_wear_suit, "name" = "Suit"),
		list("slotId" = slot_gloves, "name" = "Gloves"),
		list("slotId" = slot_belt, "name" = "Belt"),
		list("slotId" = slot_back, "name" = "Back"),
		list("slotId" = slot_shoes, "name" = "Shoes"),
		list("slotId" = slot_wear_id, "name" = "ID"),
		list("slotId" = slot_tie, "name" = "Accessory")
	)

	// === AUGMENTATION DATA ===
	// Robolimb brands
	var/list/robolimb_data = list()
	for(var/company in GLOB.chargen_robolimbs)
		var/datum/robolimb/R = GLOB.chargen_robolimbs[company]
		// Resolve icon path — use racial_icons if species has one, else default
		var/rlimb_icon = "[R.icon]"
		if(R.racial_icons && R.racial_icons[pref.species])
			rlimb_icon = "[R.racial_icons[pref.species]]"
		robolimb_data += list(list(
			"company" = R.company,
			"desc" = R.desc,
			"icon" = rlimb_icon,
			"species_cannot_use" = R.species_cannot_use,
			"restricted_to" = R.restricted_to,
			"applies_to_part" = R.applies_to_part
		))
	data["robolimb_brands"] = robolimb_data

	// Organ modules available at chargen — cached to avoid repeated instantiation
	var/static/list/cached_module_data
	if(!cached_module_data)
		cached_module_data = list()
		for(var/mod_type in subtypesof(/obj/item/organ_module))
			var/obj/item/organ_module/M = mod_type
			if(!initial(M.available_in_charsetup))
				continue
			if(!initial(M.name))
				continue
			var/obj/item/organ_module/mod = new mod_type(null)
			var/list/role_names = list()
			var/list/roles = mod.allowed_roles
			if(!length(roles))
				roles = mod.allowed_jobs
			if(islist(roles))
				for(var/role_type in roles)
					if(ispath(role_type, /datum/job) && job_master)
						var/datum/job/J = job_master.occupations_by_type[role_type]
						if(J)
							role_names += J.title
			cached_module_data += list(list(
				"path" = "[mod_type]",
				"name" = mod.name,
				"desc" = mod.desc,
				"allowed_organs" = mod.allowed_organs.Copy(),
				"module_type" = mod.module_type,
				"module_flags" = mod.module_flags,
				"augment_cost" = mod.augment_cost,
				"loadout_cost" = mod.loadout_cost,
				"cpu_power" = mod.cpu_power,
				"cpu_load" = mod.cpu_load,
				"w_class" = mod.w_class,
				"allowed_roles" = role_names
			))
			qdel(mod)
	data["organ_modules_available"] = cached_module_data

	// Body part info for the augmentation UI
	data["body_parts"] = list(
		list("tag" = BP_HEAD, "name" = "Head", "type" = "external"),
		list("tag" = BP_CHEST, "name" = "Chest", "type" = "external"),
		list("tag" = BP_GROIN, "name" = "Groin", "type" = "external"),
		list("tag" = BP_L_ARM, "name" = "Left Arm", "type" = "external"),
		list("tag" = BP_R_ARM, "name" = "Right Arm", "type" = "external"),
		list("tag" = BP_L_HAND, "name" = "Left Hand", "type" = "external"),
		list("tag" = BP_R_HAND, "name" = "Right Hand", "type" = "external"),
		list("tag" = BP_L_LEG, "name" = "Left Leg", "type" = "external"),
		list("tag" = BP_R_LEG, "name" = "Right Leg", "type" = "external"),
		list("tag" = BP_L_FOOT, "name" = "Left Foot", "type" = "external"),
		list("tag" = BP_R_FOOT, "name" = "Right Foot", "type" = "external"),
		list("tag" = BP_HEART, "name" = "Heart", "type" = "internal"),
		list("tag" = BP_EYES, "name" = "Eyes", "type" = "internal"),
		list("tag" = BP_LUNGS, "name" = "Lungs", "type" = "internal"),
		list("tag" = BP_LIVER, "name" = "Liver", "type" = "internal"),
		list("tag" = BP_KIDNEYS, "name" = "Kidneys", "type" = "internal"),
		list("tag" = BP_BRAIN, "name" = "Brain", "type" = "internal")
	)

	// === CAREER DATA ===
	if(job_master)
		var/list/job_list = list()
		var/datum/species/pref_species = all_species[pref.species ? pref.species : SPECIES_HUMAN]
		for(var/datum/job/J in job_master.occupations)
			if(!J.show_in_setup)
				continue
			var/list/job_entry = list(
				"title" = J.title,
				"department" = J.department,
				"color" = J.selection_color,
				"head" = J.head_position,
				"minimum_character_age" = J.minimum_character_age
			)
			if(J.alt_titles)
				var/list/alt_names = list()
				for(var/alt_name in J.alt_titles)
					alt_names += alt_name
				job_entry["alt_titles"] = alt_names
			var/banned = jobban_isbanned(user, J.title)
			if(banned == "Whitelisted Job")
				job_entry["status"] = "whitelist"
			else if(banned)
				job_entry["status"] = "banned"
			else if(J.total_positions == 0 && J.spawn_positions == 0)
				job_entry["status"] = "unavailable"
			else if(!J.player_old_enough(user.client))
				job_entry["status"] = "too_young_player"
				job_entry["available_in_days"] = J.available_in_days(user.client)
			else if(J.minimum_character_age && pref.age < J.minimum_character_age)
				job_entry["status"] = "too_young_char"
			else if(pref_species && !J.is_species_allowed(pref_species))
				job_entry["status"] = "species_restricted"
			else if(J.faction_restricted && pref.background != GLOB.using_map.company_name)
				job_entry["status"] = "faction_restricted"
			else
				job_entry["status"] = "available"
			job_list += list(job_entry)
		data["job_list"] = job_list

	// Fallback options
	data["fallback_options"] = list(
		list("value" = GET_RANDOM_JOB, "label" = "Get random job"),
		list("value" = BE_ASSISTANT, "label" = "Be assistant"),
		list("value" = RETURN_TO_LOBBY, "label" = "Return to lobby")
	)

	// === PERSONALITY DATA ===
	// Trait definitions
	var/list/trait_list = list()
	for(var/trait_name in trait_datums)
		var/datum/trait/T = trait_datums[trait_name]
		var/list/exclusions = list()
		for(var/excl_type in T.mutually_exclusive)
			if(excl_type in trait_type_to_ref)
				var/datum/trait/ET = trait_type_to_ref[excl_type]
				exclusions += ET.name
		trait_list += list(list(
			"name" = T.name,
			"desc" = T.desc,
			"category" = T.category,
			"mutually_exclusive" = exclusions
		))
	data["trait_list"] = trait_list
	data["trait_categories"] = trait_categories

	// Antagonist roles
	var/list/antag_roles = list()
	for(var/antag_type in GLOB.all_antag_types_)
		var/datum/antagonist/A = GLOB.all_antag_types_[antag_type]
		var/banned = jobban_isbanned(user, A.id)
		antag_roles += list(list(
			"id" = A.id,
			"name" = A.role_text,
			"status" = banned ? (banned == "Whitelisted Job" ? "whitelist" : "banned") : "available"
		))
	data["antag_roles"] = antag_roles

	// Ghost roles
	var/list/ghost_role_list = list()
	var/list/ghost_traps = get_ghost_traps()
	for(var/ghost_trap_key in ghost_traps)
		var/datum/ghosttrap/GT = ghost_traps[ghost_trap_key]
		if(!GT.list_as_special_role)
			continue
		var/banned = FALSE
		for(var/ban_type in GT.ban_checks)
			if(jobban_isbanned(user, ban_type))
				banned = TRUE
				break
		ghost_role_list += list(list(
			"id" = GT.pref_check,
			"name" = GT.ghost_trap_role,
			"status" = banned ? "banned" : "available"
		))
	data["ghost_roles"] = ghost_role_list

	// Uplink sources
	var/list/uplink_list = list()
	var/bos_ul = decls_repository.get_decls_of_subtype(/decl/uplink_source)
	for(var/ul_type in bos_ul)
		var/decl/uplink_source/US = bos_ul[ul_type]
		uplink_list += list(list(
			"name" = US.name,
			"desc" = US.desc
		))
	data["uplink_sources_available"] = uplink_list

	// === BACKGROUND DATA ===
	// Company alignments
	data["company_alignments"] = COMPANY_ALIGNMENTS
	data["company_name"] = GLOB.using_map.company_name

	// Home systems
	var/list/home_systems = GLOB.using_map.home_system_choices.Copy()
	home_systems.Insert(1, "Unset")
	home_systems += "Other"
	data["home_systems"] = home_systems

	// Backgrounds/factions
	var/list/backgrounds = GLOB.using_map.background_choices.Copy()
	backgrounds.Insert(1, "Unset")
	backgrounds += "Other"
	data["backgrounds"] = backgrounds

	// Religions
	var/list/religions = GLOB.using_map.religion_choices.Copy()
	religions.Insert(1, "None")
	religions += "Other"
	data["religions"] = religions

	// Bank security options
	data["bank_security_options"] = list(
		list("value" = BANK_SECURITY_MINIMUM, "label" = "Minimum", "desc" = "Auto-identify from worn ID, require only account number"),
		list("value" = BANK_SECURITY_MODERATE, "label" = "Moderate", "desc" = "Require manual login/account number and PIN"),
		list("value" = BANK_SECURITY_MAXIMUM, "label" = "Maximum", "desc" = "Require card and manual login")
	)

	// Flavor text body parts
	data["flavor_text_parts"] = list("general", "head", "face", "eyes", "torso", "arms", "hands", "legs", "feet", "action")

	// Robot module types for robot flavor
	data["robot_module_types"] = GLOB.robot_module_types

	// Language data: species-specific, send for each species
	var/list/species_languages = list()
	for(var/species_name in playable_species)
		var/datum/species/S = all_species[species_name]
		if(!S)
			continue
		var/list/available_langs = list()
		for(var/L in S.secondary_langs)
			available_langs += L
		for(var/L in all_languages)
			var/datum/language/lang = all_languages[L]
			if(lang && !(lang.language_flags & RESTRICTED))
				available_langs |= L
		available_langs -= S.language
		available_langs -= S.default_language
		species_languages[species_name] = list(
			"native" = S.language,
			"default" = S.default_language,
			"max_alternates" = S.num_alternate_languages,
			"available" = available_langs
		)
	data["species_languages"] = species_languages

	// Relation types
	var/list/relation_types_list = list()
	for(var/T in subtypesof(/datum/relation))
		var/datum/relation/R = T
		if(!initial(R.name))
			continue
		relation_types_list += list(list(
			"name" = initial(R.name),
			"desc" = initial(R.desc)
		))
	data["relation_types"] = relation_types_list

	// Records banned check (use owner mob)
	data["records_banned"] = !!jobban_isbanned(user, "Records")

	// === SETTINGS DATA ===
	// Client preferences grouped by category
	var/list/pref_categories = list()
	var/mob/pref_mob = user
	for(var/cp in get_client_preferences())
		var/datum/client_preference/client_pref = cp
		if(!client_pref.may_set(pref_mob.client))
			continue
		var/cat = client_pref.category
		if(!(cat in pref_categories))
			pref_categories[cat] = list()
		var/list/cat_list = pref_categories[cat]
		cat_list += list(list(
			"key" = client_pref.key,
			"description" = client_pref.description,
			"options" = client_pref.get_options(pref_mob.client),
			"category" = cat
		))
	data["client_preference_categories"] = pref_categories

	// UI theme list
	var/list/theme_list = list()
	for(var/style in GLOB.all_ui_styles)
		theme_list += style
	data["ui_themes"] = theme_list

	// Keybinding definitions grouped by category
	var/list/kb_categories = list()
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(!(kb.category in kb_categories))
			kb_categories[kb.category] = list()
		var/list/cat_list = kb_categories[kb.category]
		cat_list += list(list(
			"name" = kb.name,
			"full_name" = kb.full_name,
			"description" = kb.description,
			"category" = kb.category,
			"default_keys" = kb.hotkey_keys
		))
	data["keybinding_categories"] = kb_categories

	return data

// ============================================================
// DYNAMIC DATA — sent on every UI update
// Contains current preference values and preview
// ============================================================
/datum/character_setup/tgui_data(mob/user)
	var/list/data = list()

	// Preview direction — client-side compositor handles rendering
	// preview_icon is no longer sent; the TGUI client renders via SpriteCompositor
	data["preview_dir"] = preview_dir

	data["real_name"] = pref.real_name
	data["gender"] = pref.gender
	data["species"] = pref.species
	data["age"] = pref.age
	data["body"] = pref.body
	data["body_height"] = pref.body_height
	data["b_type"] = pref.b_type
	data["spawnpoint"] = pref.spawnpoint
	data["be_random_name"] = pref.be_random_name
	data["metadata"] = pref.metadata

	// Appearance — send as hex colors for efficient client-side rendering
	data["hair_color"] = rgb(pref.r_hair, pref.g_hair, pref.b_hair)
	data["s_hair_color"] = rgb(pref.r_s_hair, pref.g_s_hair, pref.b_s_hair)
	data["facial_color"] = rgb(pref.r_facial, pref.g_facial, pref.b_facial)
	data["skin_color"] = rgb(pref.r_skin, pref.g_skin, pref.b_skin)
	data["eye_color"] = rgb(pref.r_eyes, pref.g_eyes, pref.b_eyes)
	data["s_tone"] = pref.s_tone
	data["h_style"] = pref.h_style
	data["f_style"] = pref.f_style
	data["disabilities"] = pref.disabilities
	data["has_cortical_stack"] = pref.has_cortical_stack

	// Body markings as list of {name, color, icon, icon_state, body_parts}
	var/list/markings = list()
	for(var/marking_name in pref.body_markings)
		var/datum/sprite_accessory/marking/M = GLOB.body_marking_styles_list[marking_name]
		if(!M)
			continue
		markings += list(list(
			"name" = marking_name,
			"color" = pref.body_markings[marking_name],
			"icon" = "[M.icon]",
			"icon_state" = M.icon_state,
			"body_parts" = M.body_parts,
			"draw_target" = M.draw_target
		))
	data["body_markings"] = markings

	data["all_underwear"] = pref.all_underwear
	// Current underwear colors (category -> hex color, only for items with has_color)
	var/list/uw_color_map = list()
	if(islist(pref.all_underwear_metadata))
		for(var/uw_category in pref.all_underwear)
			var/datum/category_group/underwear/UWC2 = GLOB.underwear.categories_by_name[uw_category]
			if(!UWC2)
				continue
			var/uw_item_name2 = pref.all_underwear[uw_category]
			var/datum/category_item/underwear/UWD2 = UWC2.items_by_name[uw_item_name2]
			if(!UWD2 || !UWD2.has_color || !pref.all_underwear_metadata[uw_category])
				continue
			var/list/meta2 = pref.all_underwear_metadata[uw_category]
			for(var/datum/gear_tweak/gt2 in UWD2.tweaks)
				if(istype(gt2, /datum/gear_tweak/color))
					if(meta2["[gt2]"])
						uw_color_map[uw_category] = meta2["[gt2]"]
					break
	data["all_underwear_color"] = uw_color_map
	data["backpack"] = pref.backpack ? pref.backpack.name : "Nothing"
	// Backpack tweak options (e.g. pocketbook type selection)
	var/list/bp_tweaks
	if(pref.backpack && length(pref.backpack.tweaks))
		bp_tweaks = list()
		for(var/i = 1 to length(pref.backpack.tweaks))
			var/datum/backpack_tweak/selection/bt = pref.backpack.tweaks[i]
			if(!istype(bt))
				continue
			LAZYINITLIST(pref.backpack_metadata)
			var/list/meta = pref.backpack_metadata[pref.backpack.name]
			if(!islist(meta))
				meta = list()
				pref.backpack_metadata[pref.backpack.name] = meta
			var/current = meta["[bt]"] || bt.get_default_metadata()
			var/list/option_names = list()
			for(var/opt_name in bt.selections)
				option_names += opt_name
			bp_tweaks += list(list(
				"tweakIndex" = i,
				"options" = option_names,
				"current" = current
			))
	data["backpack_tweaks"] = length(bp_tweaks) ? bp_tweaks : null
	data["equip_preview_mob"] = pref.equip_preview_mob
	data["bgstate"] = pref.bgstate

	// Underwear render data — resolved icon_state + DMI path for client-side rendering
	var/list/underwear_render = list()
	var/datum/species/render_species = all_species[pref.species] || all_species[SPECIES_HUMAN]
	var/datum/body_build/render_build
	if(render_species)
		for(var/datum/body_build/BB in render_species.body_builds)
			if(BB.name == pref.body)
				render_build = BB
				break
		if(!render_build && length(render_species.body_builds))
			render_build = render_species.body_builds[1]
	for(var/uw_category in pref.all_underwear)
		var/datum/category_group/underwear/UWC = GLOB.underwear.categories_by_name[uw_category]
		if(!UWC)
			continue
		var/uw_item_name = pref.all_underwear[uw_category]
		var/datum/category_item/underwear/UWD = UWC.items_by_name[uw_item_name]
		if(!UWD || !UWD.icon_state)
			continue
		var/uw_dmi = render_build ? "[render_build.get_mob_icon(slot_hidden_str, UWD.icon_state)]" : "icons/inv_slots/hidden/mob.dmi"
		var/uw_color = null
		if(UWD.has_color && pref.all_underwear_metadata && pref.all_underwear_metadata[uw_category])
			var/list/meta = pref.all_underwear_metadata[uw_category]
			for(var/datum/gear_tweak/gt in UWD.tweaks)
				if(istype(gt, /datum/gear_tweak/color))
					uw_color = meta["[gt]"]
					break
		underwear_render += list(list(
			"state" = UWD.icon_state,
			"dmiFile" = uw_dmi,
			"color" = uw_color
		))
	data["underwear_render"] = underwear_render

	var/list/equip_result = generate_equipment_render_data()
	data["equipment_render"] = equip_result["equipment"]
	data["hide_hair"] = equip_result["hide_hair"]
	data["hide_facial_hair"] = equip_result["hide_facial_hair"]

	data["can_undo"] = undo_stack.len > 0
	data["default_slot"] = pref.default_slot
	data["is_guest"] = pref.is_guest
	data["load_failed"] = pref.load_failed
	var/list/slots_info = list()
	for(var/i = 1 to config.character_setup.character_slots)
		var/slot_key = pref.get_slot_key(i)
		var/slot_name = (pref.slot_names && pref.slot_names[slot_key]) || "Character [i]"
		slots_info += list(list("slot" = i, "name" = slot_name))
	data["character_slots_info"] = slots_info
	if(slot_previews)
		data["slot_previews"] = slot_previews

	// === LOADOUT DYNAMIC DATA ===
	var/list/equipped_gear = list()
	var/list/gear_items = pref.gear_list ? pref.gear_list[pref.gear_slot] : null
	if(islist(gear_items))
		for(var/gear_name in gear_items)
			var/datum/gear/G = gear_datums[gear_name]
			if(G)
				equipped_gear[G.gear_hash] = TRUE
	data["equippedGear"] = equipped_gear
	data["currentGearSlot"] = pref.gear_slot
	data["maxLoadoutPoints"] = pref.max_loadout_points

	var/used_lp = 0
	if(islist(gear_items))
		for(var/gear_name in gear_items)
			var/datum/gear/G = gear_datums[gear_name]
			if(G)
				used_lp += G.cost
	data["usedLoadoutPoints"] = used_lp

	data["selectedGearHash"] = selected_gear_hash
	if(selected_gear_hash)
		var/datum/gear/SG = hash_to_gear[selected_gear_hash]
		if(SG)
			data["selectedGearDetail"] = build_gear_detail(SG, user)
			data["selectedGearTweaks"] = build_tweak_defs(SG)

	data["hideUnavailable"] = hide_unavailable_gear
	data["hideDonate"] = hide_donate_gear
	data["slotFilter"] = slot_filter

	data["patronTier"] = user.client?.donator_info?.get_full_patron_tier()
	data["currentOpyxes"] = user.client?.donator_info ? round(user.client.donator_info.opyxes) : 0

	// === AUGMENTATION DYNAMIC DATA ===
	data["organ_data"] = pref.organ_data
	data["rlimb_data"] = pref.rlimb_data
	data["selected_organ"] = selected_organ

	var/list/installed_modules = list()
	if(islist(pref.organ_modules))
		for(var/organ_tag in pref.organ_modules)
			var/list/mods = pref.organ_modules[organ_tag]
			if(islist(mods))
				var/list/mod_paths = list()
				for(var/mod_path in mods)
					mod_paths += "[mod_path]"
				installed_modules[organ_tag] = mod_paths
	data["installed_modules"] = installed_modules

	// Augmentation points — ensure max is initialized and recalculate total
	if(!pref.max_augmentation_points)
		pref.max_augmentation_points = config.character_setup.max_augmentation_points
	pref.get_aug_cost()
	data["total_aug_points"] = pref.total_aug_points
	data["max_aug_points"] = pref.max_augmentation_points

	// === CAREER DYNAMIC DATA ===
	data["job_high"] = pref.job_high
	data["job_medium"] = pref.job_medium
	data["job_low"] = pref.job_low
	data["player_alt_titles"] = pref.player_alt_titles
	data["alternate_option"] = pref.alternate_option

	// === PERSONALITY DYNAMIC DATA ===
	data["traits"] = pref.traits
	data["be_special_role"] = pref.be_special_role
	data["may_be_special_role"] = pref.may_be_special_role

	var/list/uplink_order = list()
	if(islist(pref.uplink_sources))
		for(var/entry in pref.uplink_sources)
			var/decl/uplink_source/US = entry
			uplink_order += US.name
	data["uplink_source_order"] = uplink_order

	// === BACKGROUND DYNAMIC DATA ===
	data["nanotrasen_relation"] = pref.nanotrasen_relation
	data["home_system"] = pref.home_system
	data["background"] = pref.background
	data["religion"] = pref.religion
	data["bank_security"] = pref.bank_security
	data["bank_pin"] = pref.bank_pin
	data["med_record"] = pref.med_record
	data["gen_record"] = pref.gen_record
	data["sec_record"] = pref.sec_record
	data["exploit_record"] = pref.exploit_record
	data["memory"] = pref.memory
	data["flavor_texts"] = pref.flavor_texts
	data["flavour_texts_robot"] = pref.flavour_texts_robot
	data["alternate_languages"] = pref.alternate_languages
	data["relations"] = pref.relations
	data["relations_info"] = pref.relations_info

	// === SETTINGS DYNAMIC DATA ===
	data["preference_values"] = pref.preference_values
	data["ui_style"] = pref.UI_style
	data["ui_style_color"] = pref.UI_style_color
	data["ui_style_alpha"] = pref.UI_style_alpha
	// Keybindings: invert to binding_name -> list of keys
	var/list/user_binds = list()
	if(islist(pref.key_bindings))
		for(var/key in pref.key_bindings)
			for(var/kb_name in pref.key_bindings[key])
				if(!(kb_name in user_binds))
					user_binds[kb_name] = list()
				var/list/keys = user_binds[kb_name]
				keys += key
	data["user_keybindings"] = user_binds

	return data

// ============================================================
// PREVIEW — client-side rendering via SpriteCompositor
// Server only updates BYOND-side lobby screen preview
// ============================================================
/datum/character_setup/proc/mark_preview_dirty()
	// Updates the BYOND-side lobby screen preview separately from TGUI rendering
	pref.update_preview_icon()

/datum/character_setup/proc/is_valid_hex_color(hex_color)
	if(!istext(hex_color) || length(hex_color) != 7 || copytext(hex_color, 1, 2) != "#")
		return FALSE
	if(isnull(hex2num(copytext(hex_color, 2, 4))))
		return FALSE
	if(isnull(hex2num(copytext(hex_color, 4, 6))))
		return FALSE
	if(isnull(hex2num(copytext(hex_color, 6, 8))))
		return FALSE
	return TRUE

/datum/character_setup/proc/set_pref_color(key, hex_color)
	if(!is_valid_hex_color(hex_color))
		return
	var/r = hex2num(copytext(hex_color, 2, 4))
	var/g = hex2num(copytext(hex_color, 4, 6))
	var/b = hex2num(copytext(hex_color, 6, 8))
	pref.vars["r_[key]"] = r
	pref.vars["g_[key]"] = g
	pref.vars["b_[key]"] = b
	mark_preview_dirty()

/// Generate equipment overlay render data for client-side rendering.
/// Dresses a mannequin with job/loadout items, then extracts icon + icon_state + layer
/// from the relevant overlays_standing slots.
/datum/character_setup/proc/generate_equipment_render_data()
	if(!pref.equip_preview_mob)
		return list("equipment" = list(), "hide_hair" = FALSE, "hide_facial_hair" = FALSE)

	var/mob/living/carbon/human/dummy/mannequin/M = get_mannequin(pref.client_ckey)
	if(!M)
		return list("equipment" = list(), "hide_hair" = FALSE, "hide_facial_hair" = FALSE)

	M.delete_inventory(TRUE)
	pref.dress_preview_mob(M)
	M.ImmediateOverlayUpdate()

	var/list/equipment = list()

	// Extract overlays from clothing-related HO_ layers
	var/list/clothing_layers = list(
		list(HO_UNIFORM_LAYER, "uniform"),
		list(HO_SHOES_LAYER, "shoes"),
		list(HO_GLOVES_LAYER, "gloves"),
		list(HO_BELT_LAYER, "belt"),
		list(HO_SUIT_LAYER, "suit"),
		list(HO_GLASSES_LAYER, "glasses"),
		list(HO_SUIT_STORE_LAYER, "suitstore"),
		list(HO_BACK_LAYER, "back"),
		list(HO_EARS_LAYER, "ears"),
		list(HO_FACEMASK_ALT_LAYER, "mask"),  // items with use_alt_layer=TRUE (scarves, sterile mask)
		list(HO_FACEMASK_LAYER, "mask"),
		list(HO_HEAD_LAYER, "head")
	)

	for(var/list/layer_info in clothing_layers)
		var/ho_layer = layer_info[1]
		var/overlay_data = M.overlays_standing[ho_layer]
		if(!overlay_data)
			continue
		var/list/overlays = islist(overlay_data) ? overlay_data : list(overlay_data)
		for(var/image/I in overlays)
			if(!I || !I.icon || !I.icon_state)
				continue
			equipment += list(list(
				"dmiFile" = "[I.icon]",
				"state" = I.icon_state,
				"color" = I.color,
				"layer" = ho_layer
			))
			// Also extract child overlays (e.g. accessories attached to uniforms)
			for(var/image/sub in I.overlays)
				if(!sub || !sub.icon || !sub.icon_state)
					continue
				equipment += list(list(
					"dmiFile" = "[sub.icon]",
					"state" = sub.icon_state,
					"color" = sub.color,
					"layer" = ho_layer
				))

	// Directly extract accessories from clothing items.
	// Accessories are attached to the uniform (or suit) but the sub-overlay
	// iteration above may miss them due to BYOND image.overlays quirks.
	var/list/clothing_to_check = list()
	if(istype(M.w_uniform, /obj/item/clothing))
		clothing_to_check += M.w_uniform
	if(istype(M.wear_suit, /obj/item/clothing))
		clothing_to_check += M.wear_suit

	for(var/obj/item/clothing/C in clothing_to_check)
		if(!LAZYLEN(C.accessories))
			continue
		for(var/obj/item/clothing/accessory/A in C.accessories)
			var/tmp_state = A.overlay_state ? A.overlay_state : A.icon_state
			var/sprite_sheet = M.body_build?.get_mob_icon(slot_tie_str, tmp_state)
			if(!sprite_sheet)
				continue
			equipment += list(list(
				"dmiFile" = "[sprite_sheet]",
				"state" = tmp_state,
				"color" = A.color,
				"layer" = HO_UNIFORM_LAYER
			))

	// Check if equipped head/mask items hide hair (matches update_hair/update_facial_hair)
	var/hide_hair = FALSE
	var/hide_facial_hair = FALSE
	if((M.head?.flags_inv & BLOCKHAIR) || (M.wear_mask?.flags_inv & BLOCKHAIR))
		hide_hair = TRUE
		hide_facial_hair = TRUE
	else if(M.head?.flags_inv & BLOCKHEADHAIR)
		hide_hair = TRUE

	return list("equipment" = equipment, "hide_hair" = hide_hair, "hide_facial_hair" = hide_facial_hair)

/// Generate slot preview data for all character slots.
/// Reads appearance fields directly from each slot's saved record —
/// the current pref state is never modified.
/datum/character_setup/proc/generate_slot_previews()
	var/list/previews = list()

	for(var/i = 1 to config.character_setup.character_slots)
		var/slot_key = pref.get_slot_key(i)
		var/slot_name = (pref.slot_names && pref.slot_names[slot_key]) || null
		var/list/appearance = null

		var/datum/pref_record_reader/R = pref.load_pref_record(slot_key)
		if(R)
			// Read appearance fields directly from the record — no pref modification
			var/r_species = R.read("species") || SPECIES_HUMAN
			var/r_gender  = R.read("gender")  || "male"
			var/r_body    = R.read("body")    || ""
			var/r_s_tone  = R.read("skin_tone") || 0

			if(!slot_name)
				slot_name = R.read("real_name") || "Character [i]"

			var/datum/species/S = all_species[r_species] || all_species[SPECIES_HUMAN]
			appearance = list(
				"species"          = r_species,
				"gender"           = r_gender,
				"body"             = r_body,
				"h_style"          = R.read("hair_style_name"),
				"f_style"          = R.read("facial_style_name"),
				"hair_color"       = rgb(R.read("hair_red") || 0, R.read("hair_green") || 0, R.read("hair_blue") || 0),
				"s_hair_color"     = rgb(R.read("s_hair_red") || 0, R.read("s_hair_green") || 0, R.read("s_hair_blue") || 0),
				"facial_color"     = rgb(R.read("facial_red") || 0, R.read("facial_green") || 0, R.read("facial_blue") || 0),
				"skin_color"       = rgb(R.read("skin_red") || 0, R.read("skin_green") || 0, R.read("skin_blue") || 0),
				"eye_color"        = rgb(R.read("eyes_red") || 0, R.read("eyes_green") || 0, R.read("eyes_blue") || 0),
				"s_tone"           = r_s_tone,
				"icobase"          = S ? "[S.icobase]" : null,
				"hair_key"         = S ? S.hair_key : "",
				"appearance_flags" = S ? S.species_appearance_flags : 0
			)

		if(!slot_name)
			slot_name = "Character [i]"

		previews += list(list("slot" = i, "name" = slot_name, "appearance" = appearance))

	slot_previews = previews
	return previews

// ============================================================
// ACTION HANDLERS
// ============================================================
/datum/character_setup/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/owner = usr
	var/datum/species/current_species = all_species[pref.species]
	if(!current_species)
		current_species = all_species[SPECIES_HUMAN]

	// Handle undo before pushing state
	if(action == "undo")
		if(undo_stack.len)
			var/list/snapshot = undo_stack[undo_stack.len]
			undo_stack.len--
			pref.restore_character_snapshot(snapshot)
			mark_preview_dirty()
			update_static_data(owner)
		return TRUE

	// Non-modifying actions (UI state only) — skip undo push
	var/static/list/no_undo_actions = list(
		"rotatePreview",
		"generateSlotPreviews",
		"togglePreviewFlag",
		"saveSlot",
		// Wardrobe UI state
		"selectGear",
		"setGearSlot",
		"toggleHideUnavailable",
		"toggleHideDonate",
		"setSlotFilter",
		// Augments UI state
		"selectOrgan",
		// Settings (client preferences, not character data)
		"setClientPreference",
		"setUiStyle",
		"pickUiColor",
		"setKeybinding",
		"clearKeybinding",
		"resetKeybinding",
		"resetAllKeybindings",
		"confirmResetSlot",
		// Yielding actions — undo pushed manually inside handler on success
		"pickColor",
		"pickMarkingColor",
		"setGearTweak",
		"editRecordFancy",
		"setHomeSystem",
		"setBackground",
		"setReligion"
	)
	if(!(action in no_undo_actions))
		push_undo_state()

	switch(action)
		// === PREVIEW ===
		if("rotatePreview")
			var/new_dir = text2num(params["dir"])
			if(new_dir in list(NORTH, SOUTH, EAST, WEST))
				preview_dir = new_dir
			return TRUE

		if("randomizeAppearance")
			pref.randomize_appearance_and_body_for()
			mark_preview_dirty()
			return TRUE

		// === IDENTITY ===
		if("setName")
			var/new_name = sanitize_name(params["name"], pref.species)
			if(new_name)
				pref.real_name = new_name
			return TRUE

		if("randomizeName")
			pref.real_name = random_name(pref.gender, pref.species)
			return TRUE

		if("toggleRandomName")
			pref.be_random_name = !pref.be_random_name
			return TRUE

		if("setGender")
			var/new_gender = params["gender"]
			if(new_gender in current_species.genders)
				pref.gender = new_gender
				if(!(pref.f_style in current_species.get_facial_hair_styles(pref.gender)))
					pref.f_style = current_species.default_f_style
				var/list/valid_builds = current_species.get_body_build_list(pref.gender)
				if(!(pref.body in valid_builds))
					pref.body = valid_builds[1]
				mark_preview_dirty()
			return TRUE

		if("setSpecies")
			var/new_species = params["species"]
			if(!(new_species in playable_species))
				return TRUE
			if(new_species == pref.species)
				return TRUE
			pref.species = new_species
			var/datum/species/S = all_species[pref.species]
			if(!(pref.gender in S.genders))
				pref.gender = S.genders[1]
			var/list/valid_builds = S.get_body_build_list(pref.gender)
			if(!(pref.body in valid_builds))
				pref.body = valid_builds[1]
			pref.h_style = S.default_h_style
			pref.f_style = S.default_f_style
			pref.r_hair = 0
			pref.g_hair = 0
			pref.b_hair = 0
			pref.r_facial = 0
			pref.g_facial = 0
			pref.b_facial = 0
			pref.s_tone = 0
			pref.r_skin = hex2num(copytext(S.flesh_color, 2, 4))
			pref.g_skin = hex2num(copytext(S.flesh_color, 4, 6))
			pref.b_skin = hex2num(copytext(S.flesh_color, 6, 8))
			pref.r_eyes = hex2num(copytext(S.default_eye_color, 2, 4))
			pref.g_eyes = hex2num(copytext(S.default_eye_color, 4, 6))
			pref.b_eyes = hex2num(copytext(S.default_eye_color, 6, 8))
			pref.age = clamp(pref.age, S.min_age, S.max_age)
			if(S.species_appearance_flags & SECONDARY_HAIR_IS_SKIN)
				pref.r_s_hair = pref.r_skin
				pref.g_s_hair = pref.g_skin
				pref.b_s_hair = pref.b_skin
			else
				pref.r_s_hair = 0
				pref.g_s_hair = 0
				pref.b_s_hair = 0
			pref.body_markings.Cut()
			mark_preview_dirty()
			update_static_data(owner)
			return TRUE

		if("setAge")
			var/new_age = text2num(params["age"])
			if(new_age)
				pref.age = clamp(round(new_age), current_species.min_age, current_species.max_age)
			return TRUE

		if("setBody")
			var/new_body = params["body"]
			var/list/valid_builds = current_species.get_body_build_list(pref.gender)
			if(new_body in valid_builds)
				pref.body = new_body
				mark_preview_dirty()
			return TRUE

		if("setHeight")
			var/new_height = text2num(params["height"])
			if(new_height in body_heights)
				pref.body_height = new_height
				mark_preview_dirty()
			return TRUE

		if("setBloodType")
			var/new_bt = params["blood_type"]
			if(new_bt in valid_bloodtypes)
				pref.b_type = new_bt
			return TRUE

		if("setSpawnpoint")
			var/new_sp = params["spawnpoint"]
			if(new_sp in spawntypes())
				pref.spawnpoint = new_sp
			return TRUE

		if("setHairColor")
			if(!(current_species.species_appearance_flags & HAS_HAIR_COLOR))
				return TRUE
			set_pref_color("hair", params["color"])
			return TRUE

		if("setSecondaryHairColor")
			if(!(current_species.species_appearance_flags & HAS_HAIR_COLOR))
				return TRUE
			if(current_species.species_appearance_flags & SECONDARY_HAIR_IS_SKIN)
				return TRUE
			set_pref_color("s_hair", params["color"])
			return TRUE

		if("setFacialColor")
			if(!(current_species.species_appearance_flags & HAS_HAIR_COLOR))
				return TRUE
			set_pref_color("facial", params["color"])
			return TRUE

		if("setEyeColor")
			if(!(current_species.species_appearance_flags & HAS_EYE_COLOR))
				return TRUE
			set_pref_color("eyes", params["color"])
			return TRUE

		if("setSkinColor")
			if(!(current_species.species_appearance_flags & HAS_SKIN_COLOR))
				return TRUE
			set_pref_color("skin", params["color"])
			return TRUE

		if("setSkinTone")
			if(!(current_species.species_appearance_flags & HAS_A_SKIN_TONE))
				return TRUE
			var/new_tone = text2num(params["tone"])
			if(!isnull(new_tone))
				pref.s_tone = clamp(round(new_tone), 35 - current_species.max_skin_tone(), 34)
				mark_preview_dirty()
			return TRUE

		if("toggleDisability")
			var/flag = text2num(params["flag"])
			if(flag)
				pref.disabilities ^= flag
			return TRUE

		if("toggleCorticalStack")
			if(current_species.spawn_flags & SPECIES_NO_LACE)
				return TRUE
			pref.has_cortical_stack = !pref.has_cortical_stack
			return TRUE

		if("addBodyMarking")
			var/marking_name = params["marking"]
			if((marking_name in GLOB.body_marking_styles_list) && !(marking_name in pref.body_markings))
				pref.body_markings[marking_name] = "#000000"
				mark_preview_dirty()
			return TRUE

		if("removeBodyMarking")
			var/marking_name = params["marking"]
			if(marking_name in pref.body_markings)
				pref.body_markings -= marking_name
				mark_preview_dirty()
			return TRUE

		if("setBodyMarkingColor")
			var/marking_name = params["marking"]
			var/new_color = params["color"]
			if((marking_name in pref.body_markings) && is_valid_hex_color(new_color))
				pref.body_markings[marking_name] = new_color
				mark_preview_dirty()
			return TRUE

		// === HAIR ===
		if("setHairStyle")
			var/new_style = params["style"]
			if(new_style in current_species.get_hair_styles())
				pref.h_style = new_style
				mark_preview_dirty()
			return TRUE

		if("setFacialStyle")
			var/new_style = params["style"]
			if(new_style in current_species.get_facial_hair_styles(pref.gender))
				pref.f_style = new_style
				mark_preview_dirty()
			return TRUE

		// === WARDROBE ===
		if("setUnderwear")
			var/category = params["category"]
			var/item_name = params["name"]
			var/datum/category_group/underwear/UWC = GLOB.underwear.categories_by_name[category]
			if(UWC && UWC.items_by_name[item_name])
				pref.all_underwear[category] = item_name
				mark_preview_dirty()
			return TRUE

		if("setUnderwearColor")
			var/uw_cat = params["category"]
			var/datum/category_group/underwear/UWG = GLOB.underwear.categories_by_name[uw_cat]
			if(!UWG)
				return TRUE
			var/uw_selected = pref.all_underwear[uw_cat]
			var/datum/category_item/underwear/UWD = uw_selected ? UWG.items_by_name[uw_selected] : null
			if(!UWD || !UWD.has_color)
				return TRUE
			for(var/datum/gear_tweak/gt in UWD.tweaks)
				if(istype(gt, /datum/gear_tweak/color))
					LAZYINITLIST(pref.all_underwear_metadata)
					var/list/uw_meta = pref.all_underwear_metadata[uw_cat]
					if(!uw_meta)
						uw_meta = list()
						pref.all_underwear_metadata[uw_cat] = uw_meta
					var/existing_color = uw_meta["[gt]"]
					if(!existing_color)
						existing_color = gt.get_default()
					var/new_color = gt.get_metadata(owner, existing_color)
					if(new_color)
						uw_meta["[gt]"] = new_color
						mark_preview_dirty()
					break
			return TRUE

		if("setBackpack")
			var/bp_name = params["name"]
			var/bos = decls_repository.get_decls_of_subtype(/decl/backpack_outfit)
			for(var/bo in bos)
				var/decl/backpack_outfit/B = bos[bo]
				if(B.name == bp_name)
					pref.backpack = B
					mark_preview_dirty()
					break
			return TRUE

		if("setBackpackTweak")
			if(!pref.backpack || !length(pref.backpack.tweaks))
				return TRUE
			var/tweak_index = text2num(params["tweakIndex"])
			var/new_value = params["value"]
			if(!tweak_index || tweak_index < 1 || tweak_index > length(pref.backpack.tweaks))
				return TRUE
			var/datum/backpack_tweak/selection/bt = pref.backpack.tweaks[tweak_index]
			if(!istype(bt) || !(new_value in bt.selections))
				return TRUE
			LAZYINITLIST(pref.backpack_metadata)
			var/list/meta = pref.backpack_metadata[pref.backpack.name]
			if(!islist(meta))
				meta = list()
				pref.backpack_metadata[pref.backpack.name] = meta
			meta["[bt]"] = new_value
			mark_preview_dirty()
			return TRUE

		if("togglePreviewFlag")
			var/flag = text2num(params["flag"])
			if(flag)
				pref.equip_preview_mob ^= flag
				mark_preview_dirty()
			return TRUE

		if("setBgState")
			var/new_bg = params["bgstate"]
			if(new_bg in pref.bgstate_options)
				pref.bgstate = new_bg
				mark_preview_dirty()
			return TRUE

		if("setMetadata")
			var/new_metadata = sanitize(params["metadata"])
			if(!isnull(new_metadata))
				pref.metadata = new_metadata
			return TRUE

		// === SAVE/LOAD ===
		if("saveSlot")
			pref.save_character()
			slot_previews = null  // Name may have changed
			return TRUE

		if("loadSlot")
			var/slot = text2num(params["slot"])
			if(slot && slot >= 1 && slot <= config.character_setup.character_slots)
				pref.load_character(slot)
				pref.sanitize_preferences()
				slot_previews = null  // Force re-generation on next picker open
				undo_stack.Cut()  // Slot change/reload clears undo history
				mark_preview_dirty()
				update_static_data(owner)
			return TRUE

		if("confirmResetSlot")
			var/confirm = tgui_alert(owner, "Are you sure you want to reset this character slot to default? This cannot be undone.", "Reset Character", list("Reset", "Cancel"))
			if(confirm != "Reset")
				return TRUE
			pref.load_character(SAVE_RESET)
			pref.sanitize_preferences()
			slot_previews = null
			undo_stack.Cut()  // Reset clears history
			mark_preview_dirty()
			update_static_data(owner)
			return TRUE

		if("generateSlotPreviews")
			generate_slot_previews()
			return TRUE

		// === COLOR PICKERS (DM-side modal) ===
		if("pickColor")
			var/which = params["which"]
			if(!(which in list("hair", "s_hair", "facial", "eyes", "skin")))
				return TRUE
			var/current_color = rgb(pref.vars["r_[which]"], pref.vars["g_[which]"], pref.vars["b_[which]"])
			var/new_color = tgui_color_picker(owner, "Choose color:", "Character Setup", current_color)
			if(!new_color)
				return TRUE
			// Re-validate species flags after yield — species may have changed
			var/datum/species/post_species = all_species[pref.species]
			if(!post_species)
				return TRUE
			var/flags = post_species.species_appearance_flags
			if(which in list("hair", "s_hair", "facial"))
				if(!(flags & HAS_HAIR_COLOR))
					return TRUE
			else if(which == "eyes")
				if(!(flags & HAS_EYE_COLOR))
					return TRUE
			else if(which == "skin")
				if(!(flags & HAS_SKIN_COLOR))
					return TRUE
			push_undo_state()
			set_pref_color(which, new_color)
			return TRUE

		if("pickMarkingColor")
			var/marking_name = params["marking"]
			if(!(marking_name in pref.body_markings))
				return TRUE
			var/current_color = pref.body_markings[marking_name]
			var/new_color = tgui_color_picker(owner, "Choose marking color:", "Character Setup", current_color)
			if(new_color && (marking_name in pref.body_markings))
				push_undo_state()
				pref.body_markings[marking_name] = new_color
				mark_preview_dirty()
			return TRUE

		// === LOADOUT ACTIONS ===
		if("selectGear")
			var/hash = params["hash"]
			if(!hash)
				selected_gear_hash = null
				pref.trying_on_gear = null
				pref.trying_on_tweaks.Cut()
				mark_preview_dirty()
				return TRUE
			var/datum/gear/G = hash_to_gear[hash]
			if(!G)
				return FALSE
			selected_gear_hash = hash
			var/list/gear_items = pref.gear_list[pref.gear_slot]
			selected_tweaks = islist(gear_items) ? gear_items[G.display_name] : null
			if(!islist(selected_tweaks))
				selected_tweaks = list()
				for(var/datum/gear_tweak/tweak in G.gear_tweaks)
					selected_tweaks["[tweak]"] = tweak.get_default()
			// Preview the selected item on the doll
			pref.trying_on_gear = G.display_name
			pref.trying_on_tweaks = selected_tweaks.Copy()
			mark_preview_dirty()
			return TRUE

		if("toggleGear")
			var/hash = params["hash"]
			var/datum/gear/TG = hash_to_gear[hash]
			if(!TG)
				return FALSE
			if(!TG.is_allowed_to_equip(owner))
				return FALSE
			var/list/gear_items = pref.gear_list[pref.gear_slot]
			if(!islist(gear_items))
				return FALSE
			if(TG.display_name in gear_items)
				gear_items -= TG.display_name
			else
				var/total_cost = 0
				for(var/gear_name in gear_items)
					var/datum/gear/G = gear_datums[gear_name]
					if(G)
						total_cost += G.cost
				if((total_cost + TG.cost) <= pref.max_loadout_points)
					gear_items[TG.display_name] = selected_tweaks.Copy()
			mark_preview_dirty()
			return TRUE

		if("setGearTweak")
			var/tweak_index = text2num(params["tweakIndex"])
			var/datum/gear/SG = hash_to_gear[selected_gear_hash]
			if(!SG || !tweak_index || tweak_index < 1 || tweak_index > length(SG.gear_tweaks))
				return FALSE
			var/datum/gear_tweak/tweak = SG.gear_tweaks[tweak_index]
			var/new_value
			if(!isnull(params["value"]))
				new_value = params["value"]
			else
				var/pre_hash = selected_gear_hash
				var/pre_slot = pref.gear_slot
				new_value = tweak.get_metadata(owner, selected_tweaks["[tweak]"], params["subtype"])
				// Re-validate after yield — gear selection or slot may have changed
				if(selected_gear_hash != pre_hash || pref.gear_slot != pre_slot)
					return FALSE
			if(isnull(new_value))
				return FALSE
			push_undo_state()
			selected_tweaks["[tweak]"] = new_value
			if(SG.display_name in pref.gear_list[pref.gear_slot])
				var/list/gear_items = pref.gear_list[pref.gear_slot]
				var/list/metadata = gear_items[SG.display_name]
				if(!islist(metadata))
					metadata = list()
					gear_items[SG.display_name] = metadata
				metadata["[tweak]"] = new_value
			// Update trying-on preview with new tweaks
			if(pref.trying_on_gear)
				pref.trying_on_tweaks = selected_tweaks.Copy()
			mark_preview_dirty()
			return TRUE

		if("setGearSlot")
			var/new_slot = text2num(params["slot"])
			if(!new_slot || new_slot < 1 || new_slot > config.character_setup.loadout_slots)
				return FALSE
			pref.gear_slot = new_slot
			selected_gear_hash = null
			selected_tweaks = list()
			pref.trying_on_gear = null
			pref.trying_on_tweaks.Cut()
			mark_preview_dirty()
			return TRUE

		if("clearLoadout")
			var/list/gear = pref.gear_list[pref.gear_slot]
			if(islist(gear))
				gear.Cut()
			selected_gear_hash = null
			selected_tweaks = list()
			mark_preview_dirty()
			return TRUE

		if("randomizeLoadout")
			randomize_loadout(owner)
			mark_preview_dirty()
			return TRUE

		if("buyGear")
			var/hash = params["hash"]
			var/datum/gear/G = hash_to_gear[hash]
			if(!G || !G.price)
				return FALSE
			if(!owner.client?.donator_info)
				return FALSE
			if(owner.client.donator_info.has_item(G.type))
				return FALSE
			var/adjusted_price = G.discount ? G.price * G.discount : G.price
			var/comment = "Donation store purchase: [G.type]"
			var/transaction = SSdonations.create_transaction(owner.client, -adjusted_price, DONATIONS_TRANSACTION_TYPE_PURCHASE, comment)
			if(transaction)
				if(SSdonations.give_item(owner.client, G.type, transaction))
					update_static_data(owner)
					return TRUE
				else
					SSdonations.remove_transaction(owner.client, transaction)
			return FALSE

		if("toggleHideUnavailable")
			hide_unavailable_gear = !hide_unavailable_gear
			return TRUE

		if("toggleHideDonate")
			hide_donate_gear = !hide_donate_gear
			return TRUE

		if("setSlotFilter")
			var/new_filter = params["slotId"]
			if(slot_filter == new_filter)
				slot_filter = null
			else
				slot_filter = new_filter
			return TRUE

		// === AUGMENTATION ACTIONS ===
		if("selectOrgan")
			var/organ = params["organ"]
			if(organ)
				selected_organ = organ
			return TRUE

		if("setOrganStatus")
			var/organ = params["organ"]
			var/organ_action = params["action"]
			if(!organ || !organ_action)
				return TRUE
			// External limbs
			if(organ in BP_ALL_LIMBS)
				update_external_organ(organ, organ_action)
			// Internal organs
			else if(organ in BP_INTERNAL_ORGANS)
				update_internal_organ(organ, organ_action)
			mark_preview_dirty()
			return TRUE

		if("toggleOrganModule")
			var/organ = params["organ"]
			var/mod_path_text = params["module"]
			if(!organ || !mod_path_text)
				return TRUE
			if(!((organ in BP_ALL_LIMBS) || (organ in BP_INTERNAL_ORGANS)))
				return TRUE
			var/mod_path = text2path(mod_path_text)
			if(!ispath(mod_path, /obj/item/organ_module))
				return TRUE
			LAZYINITLIST(pref.organ_modules)
			LAZYINITLIST(pref.organ_modules[organ])
			var/list/modules = pref.organ_modules[organ]
			if(mod_path in modules)
				modules -= mod_path
			else
				// Validate before adding
				var/obj/item/organ_module/M = mod_path

				// Validate module_flags vs organ state
				var/is_robotic = (pref.organ_data[organ] == "cyborg" || pref.organ_data[organ] == "mechanical")
				if(is_robotic)
					if(!(initial(M.module_flags) & OM_FLAG_MECHANICAL))
						return TRUE
				else
					if(!(initial(M.module_flags) & OM_FLAG_BIOLOGICAL))
						return TRUE

				// Validate module_type placement
				if(initial(M.module_type) == OM_TYPE_PROCESSOR && organ != BP_HEAD)
					return TRUE
				if(initial(M.module_type) == OM_TYPE_ACTUATOR)
					if(organ == BP_HEAD || pref.organ_data[organ] == "cyborg" || !(organ in list(BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND)))
						return TRUE

				// Eyes need to be mechanical
				if(organ == BP_EYES && pref.organ_data[BP_EYES] != "mechanical")
					return TRUE

				if(initial(M.augment_cost) > 0)
					// Check aug point budget
					var/current_cost = pref.get_aug_cost()
					if((current_cost + initial(M.augment_cost)) > pref.max_augmentation_points)
						return TRUE
				// Check module type exclusivity (one processor/actuator per organ)
				if(initial(M.module_type))
					for(var/existing in modules)
						var/obj/item/organ_module/E = existing
						if(initial(E.module_type) == initial(M.module_type))
							modules -= existing
							break
				modules += mod_path
			mark_preview_dirty()
			return TRUE

		// === CAREER ACTIONS ===
		if("switchJobPriority")
			if(!job_master)
				return TRUE
			var/role = params["job"]
			var/datum/job/job = job_master.GetJob(role)
			if(!job)
				return TRUE
			if(role == "Assistant")
				if(job.title in pref.job_low)
					pref.job_low -= job.title
				else
					pref.job_low |= job.title
				mark_preview_dirty()
				return TRUE
			// Cycle: Never -> Low -> Medium -> High -> Never
			if(job.title == pref.job_high)
				pref.job_high = null
			else if(job.title in pref.job_medium)
				// Bump the previous High down to Medium before taking the slot
				if(pref.job_high)
					pref.job_medium |= pref.job_high
				pref.job_high = job.title
				pref.job_medium -= job.title
			else if(job.title in pref.job_low)
				pref.job_medium |= job.title
				pref.job_low -= job.title
			else
				pref.job_low |= job.title
			mark_preview_dirty()
			return TRUE

		if("setJobPriority")
			if(!job_master)
				return TRUE
			var/role = params["job"]
			var/priority = text2num(params["priority"])
			var/datum/job/job = job_master.GetJob(role)
			if(!job)
				return TRUE
			// Remove from all lists first
			if(pref.job_high == job.title)
				pref.job_high = null
			pref.job_medium -= job.title
			pref.job_low -= job.title
			// Add to correct list
			switch(priority)
				if(1) // HIGH
					pref.job_high = job.title
				if(2) // MEDIUM
					pref.job_medium |= job.title
				if(3) // LOW
					pref.job_low |= job.title
				// else: NEVER (don't add anywhere)
			mark_preview_dirty()
			return TRUE

		if("setAltTitle")
			if(!job_master)
				return TRUE
			var/job_title = params["job"]
			var/new_title = params["title"]
			var/datum/job/job = job_master.GetJob(job_title)
			if(!job || !new_title)
				return TRUE
			if(new_title == job.title)
				pref.player_alt_titles -= job.title
			else if(new_title in job.alt_titles)
				pref.player_alt_titles[job.title] = new_title
			mark_preview_dirty()
			return TRUE

		if("setFallbackOption")
			var/new_option = text2num(params["option"])
			if(!isnull(new_option) && new_option >= 0 && new_option <= 2)
				pref.alternate_option = new_option
			return TRUE

		if("resetJobs")
			pref.job_high = null
			if(islist(pref.job_medium))
				pref.job_medium.Cut()
			if(islist(pref.job_low))
				pref.job_low.Cut()
			if(islist(pref.player_alt_titles))
				pref.player_alt_titles.Cut()
			mark_preview_dirty()
			return TRUE

		// === PERSONALITY ACTIONS ===
		if("toggleTrait")
			var/trait_name = params["trait"]
			var/datum/trait/T = trait_datums[trait_name]
			if(!T)
				return TRUE
			if(T.name in pref.traits)
				pref.traits -= T.name
			else
				// Validate using shim that provides is_FBP()/get_FBP_type()
				var/datum/tgui_trait_validator/validator = new(pref)
				var/invalidity = T.test_for_invalidity(validator)
				qdel(validator)
				if(invalidity)
					return TRUE
				var/conflicts = T.test_for_trait_conflict(pref.traits)
				if(conflicts)
					return TRUE
				pref.traits += T.name
			mark_preview_dirty()
			return TRUE

		if("setAntagPriority")
			var/role_id = params["role"]
			var/priority = params["priority"]
			if(!role_id || !priority)
				return TRUE
			switch(priority)
				if("high")
					pref.be_special_role |= role_id
					pref.may_be_special_role -= role_id
				if("low")
					pref.be_special_role -= role_id
					pref.may_be_special_role |= role_id
				if("never")
					pref.be_special_role -= role_id
					pref.may_be_special_role -= role_id
			return TRUE

		if("setAllAntagPriority")
			var/priority = params["priority"]
			if(!priority)
				return TRUE
			// Apply to all antag roles
			for(var/antag_type in GLOB.all_antag_types_)
				var/datum/antagonist/A = GLOB.all_antag_types_[antag_type]
				switch(priority)
					if("high")
						pref.be_special_role |= A.id
						pref.may_be_special_role -= A.id
					if("low")
						pref.be_special_role -= A.id
						pref.may_be_special_role |= A.id
					if("never")
						pref.be_special_role -= A.id
						pref.may_be_special_role -= A.id
			return TRUE

		if("addUplinkSource")
			var/source_name = params["name"]
			if(!source_name)
				return TRUE
			var/bos_ul = decls_repository.get_decls_of_subtype(/decl/uplink_source)
			for(var/ul_type in bos_ul)
				var/decl/uplink_source/US = bos_ul[ul_type]
				if(US.name == source_name)
					if(!(US in pref.uplink_sources))
						pref.uplink_sources += US
					break
			return TRUE

		if("removeUplinkSource")
			var/source_name = params["name"]
			if(!source_name)
				return TRUE
			for(var/entry in pref.uplink_sources)
				var/decl/uplink_source/US = entry
				if(US.name == source_name)
					pref.uplink_sources -= US
					break
			return TRUE

		if("moveUplinkSource")
			var/source_name = params["name"]
			var/direction = params["direction"]
			if(!source_name || !direction)
				return TRUE
			for(var/i in 1 to length(pref.uplink_sources))
				var/decl/uplink_source/US = pref.uplink_sources[i]
				if(US.name == source_name)
					if(direction == "up" && i > 1)
						pref.uplink_sources.Swap(i, i - 1)
					else if(direction == "down" && i < length(pref.uplink_sources))
						pref.uplink_sources.Swap(i, i + 1)
					break
			return TRUE

		// === BACKGROUND ACTIONS ===
		if("setRelation")
			var/new_relation = params["value"]
			if(new_relation in COMPANY_ALIGNMENTS)
				pref.nanotrasen_relation = new_relation
			return TRUE

		if("setHomeSystem")
			var/new_home = params["value"]
			if(!new_home)
				return TRUE
			if(new_home == "Other")
				var/custom = sanitize(tgui_input_text(owner, "Enter your home system:", "Home System", pref.home_system, MAX_NAME_LEN))
				if(custom)
					push_undo_state()
					pref.home_system = custom
			else
				push_undo_state()
				pref.home_system = new_home
			return TRUE

		if("setBackground")
			var/new_bg = params["value"]
			if(!new_bg)
				return TRUE
			if(new_bg == "Other")
				var/custom = sanitize(tgui_input_text(owner, "Enter your background:", "Background", pref.background, MAX_NAME_LEN))
				if(custom)
					push_undo_state()
					pref.background = custom
			else
				push_undo_state()
				pref.background = new_bg
			return TRUE

		if("setReligion")
			var/new_rel = params["value"]
			if(!new_rel)
				return TRUE
			if(new_rel == "Other")
				var/custom = sanitize(tgui_input_text(owner, "Enter your religion:", "Religion", pref.religion))
				if(custom)
					push_undo_state()
					pref.religion = custom
			else
				push_undo_state()
				pref.religion = new_rel
			return TRUE

		if("setBankSecurity")
			var/new_sec = text2num(params["value"])
			if(!isnull(new_sec) && new_sec >= BANK_SECURITY_MINIMUM && new_sec <= BANK_SECURITY_MAXIMUM)
				pref.bank_security = new_sec
			return TRUE

		if("setBankPin")
			var/new_pin = text2num(params["value"])
			if(!isnull(new_pin))
				if(new_pin == 0)
					pref.bank_pin = 0 // Random each round
				else
					pref.bank_pin = clamp(round(new_pin), 1111, 9999)
			return TRUE

		if("setRecord")
			var/record_type = params["type"]
			var/new_text = sanitize(params["text"])
			if(!record_type)
				return TRUE
			if(jobban_isbanned(owner, "Records") && record_type != "memory")
				return TRUE
			switch(record_type)
				if("medical")
					pref.med_record = new_text
				if("general")
					pref.gen_record = new_text
				if("security")
					pref.sec_record = new_text
				if("exploit")
					pref.exploit_record = new_text
				if("memory")
					pref.memory = new_text
			return TRUE

		if("editRecordFancy")
			var/record_type = params["type"]
			if(!record_type)
				return TRUE
			if(jobban_isbanned(owner, "Records") && record_type != "memory")
				return TRUE
			var/current_value
			switch(record_type)
				if("medical")
					current_value = pref.med_record
				if("general")
					current_value = pref.gen_record
				if("security")
					current_value = pref.sec_record
				if("exploit")
					current_value = pref.exploit_record
				if("memory")
					current_value = pref.memory
				else
					return TRUE
			var/new_text = tgui_input_pencode_editor(owner, "Edit your [record_type] record.", "[capitalize(record_type)] Record", current_value)
			if(isnull(new_text))
				return TRUE
			push_undo_state()
			new_text = sanitize(new_text)
			switch(record_type)
				if("medical")
					pref.med_record = new_text
				if("general")
					pref.gen_record = new_text
				if("security")
					pref.sec_record = new_text
				if("exploit")
					pref.exploit_record = new_text
				if("memory")
					pref.memory = new_text
			return TRUE

		if("setFlavorText")
			var/part = params["part"]
			var/new_text = sanitize(params["text"], extra = 0)
			if(!part)
				return TRUE
			if(part in list("general", "head", "face", "eyes", "torso", "arms", "hands", "legs", "feet", "action"))
				pref.flavor_texts[part] = new_text
			return TRUE

		if("setRobotFlavorText")
			var/module = params["module"]
			var/new_text = sanitize(params["text"], extra = 0)
			if(!module || (module != "Default" && !(module in GLOB.robot_module_types)))
				return TRUE
			pref.flavour_texts_robot[module] = new_text
			return TRUE

		if("addLanguage")
			var/lang_name = params["language"]
			if(!lang_name)
				return TRUE
			var/datum/language/lang = all_languages[lang_name]
			if(!lang)
				return TRUE
			if(!(lang_name in pref.alternate_languages))
				if(pref.alternate_languages.len < current_species.num_alternate_languages)
					pref.alternate_languages += lang_name
			return TRUE

		if("removeLanguage")
			var/lang_name = params["language"]
			if(lang_name && (lang_name in pref.alternate_languages))
				pref.alternate_languages -= lang_name
			return TRUE

		if("toggleRelation")
			var/relation_name = params["name"]
			if(!relation_name)
				return TRUE
			// Verify it's a valid relation type
			for(var/T in subtypesof(/datum/relation))
				var/datum/relation/R = T
				if(initial(R.name) == relation_name)
					if(relation_name in pref.relations)
						pref.relations -= relation_name
					else
						pref.relations += relation_name
					break
			return TRUE

		if("setRelationInfo")
			var/relation_name = params["name"]
			var/new_info = sanitize(params["text"])
			if(!relation_name || (relation_name != "general" && !matchmaker.relation_types.Find(relation_name)))
				return TRUE
			pref.relations_info[relation_name] = new_info
			return TRUE

		// === SETTINGS ACTIONS ===
		if("setClientPreference")
			var/pref_key = params["key"]
			var/new_value = params["value"]
			if(!pref_key || !new_value)
				return TRUE
			owner.set_preference(pref_key, new_value)
			SScharacter_setup.queue_preferences_save(pref)
			return TRUE

		if("setUiStyle")
			var/style = params["style"]
			var/alpha = text2num(params["alpha"])
			if(!style || !isnum(alpha))
				return TRUE
			if(!(style in GLOB.all_ui_styles))
				return TRUE
			pref.UI_style = style
			pref.UI_style_alpha = Clamp(alpha, 0, 255)
			if(owner.client)
				owner.client.update_ui()
			SScharacter_setup.queue_preferences_save(pref)
			return TRUE

		if("pickUiColor")
			var/new_color = tgui_color_picker(owner, "Choose HUD color:", "Character Setup", pref.UI_style_color)
			if(!new_color)
				return TRUE
			pref.UI_style_color = new_color
			if(owner.client)
				owner.client.update_ui()
			SScharacter_setup.queue_preferences_save(pref)
			return TRUE

		if("setKeybinding")
			var/kb_name = params["binding"]
			var/new_key = params["key"]
			var/old_key = params["old_key"]
			if(!kb_name)
				return TRUE
			if(!(kb_name in GLOB.keybindings_by_name))
				return TRUE
			// Clear from old key
			if(old_key && pref.key_bindings[old_key])
				pref.key_bindings[old_key] -= kb_name
				if(!length(pref.key_bindings[old_key]))
					pref.key_bindings -= old_key
			// If clearing (new_key is "None" or empty)
			if(!new_key || new_key == "None")
				LAZYADD(pref.key_bindings["None"], kb_name)
			else
				// Remove from "None" if it was there
				if(pref.key_bindings["None"])
					pref.key_bindings["None"] -= kb_name
					if(!length(pref.key_bindings["None"]))
						pref.key_bindings -= "None"
				// Add to new key
				LAZYADD(pref.key_bindings[new_key], kb_name)
				pref.key_bindings[new_key] = sortTim(pref.key_bindings[new_key], /proc/cmp_text_asc)
			owner.client?.set_macros()
			SScharacter_setup.queue_preferences_save(pref)
			return TRUE

		if("clearKeybinding")
			var/kb_name = params["binding"]
			var/old_key = params["old_key"]
			if(!kb_name || !old_key)
				return TRUE
			if(pref.key_bindings[old_key])
				pref.key_bindings[old_key] -= kb_name
				if(!length(pref.key_bindings[old_key]))
					pref.key_bindings -= old_key
			owner.client?.set_macros()
			SScharacter_setup.queue_preferences_save(pref)
			return TRUE

		if("resetKeybinding")
			var/kb_name = params["binding"]
			if(!kb_name)
				return TRUE
			var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
			if(!kb)
				return TRUE
			// Remove from all current keys
			for(var/key in pref.key_bindings)
				if(kb_name in pref.key_bindings[key])
					pref.key_bindings[key] -= kb_name
					if(!length(pref.key_bindings[key]))
						pref.key_bindings -= key
			// Re-add defaults
			for(var/key in kb.hotkey_keys)
				LAZYADD(pref.key_bindings[key], kb_name)
				pref.key_bindings[key] = sortTim(pref.key_bindings[key], /proc/cmp_text_asc)
			owner.client?.set_macros()
			SScharacter_setup.queue_preferences_save(pref)
			return TRUE

		if("resetAllKeybindings")
			pref.key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key)
			owner.client?.set_macros()
			SScharacter_setup.queue_preferences_save(pref)
			return TRUE

// ============================================================
// LOADOUT HELPER PROCS
// ============================================================
/datum/character_setup/proc/build_gear_entry(datum/gear/G, mob/user)
	// Send icon path + icon_state for client-side atlas rendering.
	// Create a temporary instance to reliably get icon/icon_state
	// (initial() on type path vars can fail for inherited values).
	var/gear_icon = null
	var/gear_icon_state = null
	if(G.path)
		var/obj/item/temp = new G.path
		gear_icon = "[temp.icon]"
		gear_icon_state = temp.icon_state
		QDEL_NULL(temp)
	// If the path has no usable icon_state (e.g. selection items whose path is a generic parent),
	// fall back to the first concrete path offered by a path tweak.
	if(!gear_icon_state)
		for(var/datum/gear_tweak/tweak in G.gear_tweaks)
			if(istype(tweak, /datum/gear_tweak/path))
				var/datum/gear_tweak/path/path_tweak = tweak
				if(length(path_tweak.valid_paths))
					var/first_key = path_tweak.valid_paths[1]
					var/first_path = path_tweak.valid_paths[first_key]
					var/obj/item/temp2 = new first_path
					gear_icon = "[temp2.icon]"
					gear_icon_state = temp2.icon_state
					QDEL_NULL(temp2)
				break
	var/owned = G.price && user.client?.donator_info?.has_item(G.type)
	var/list/entry = list(
		"name" = G.display_name,
		"hash" = G.gear_hash,
		"icon" = gear_icon,
		"iconState" = gear_icon_state,
		"slot" = G.slot,
		"slotName" = G.slot ? slot_to_description(G.slot) : "",
		"subgroup" = G.subgroup || "",
		"cost" = G.cost,
		"price" = owned ? 0 : (G.price || 0),
		"discount" = owned ? 0 : (G.discount || 0),
		"patronTier" = G.patron_tier,
		"description" = G.description || "",
		"allowed" = gear_allowed_to_see(G, user),
		"canEquip" = G.is_allowed_to_equip(user)
	)
	if(length(G.allowed_roles))
		var/list/role_names = list()
		for(var/allowed_type in G.allowed_roles)
			if(ispath(allowed_type, /datum/job) && job_master)
				var/datum/job/J = job_master.occupations_by_type[allowed_type]
				if(J)
					role_names += J.title
		entry["allowedRoles"] = role_names
	if(G.whitelisted)
		entry["whitelisted"] = islist(G.whitelisted) ? G.whitelisted : list(G.whitelisted)
	var/list/tweaks = list()
	var/tweak_index = 0
	for(var/datum/gear_tweak/tweak in G.gear_tweaks)
		tweak_index++
		var/list/tweak_info = list(
			"index" = tweak_index,
			"type" = get_tweak_type_name(tweak)
		)
		if(istype(tweak, /datum/gear_tweak/path))
			var/datum/gear_tweak/path/pt = tweak
			var/list/option_names = list()
			for(var/name in pt.valid_paths)
				option_names += name
			tweak_info["options"] = option_names
		if(istype(tweak, /datum/gear_tweak/color))
			var/datum/gear_tweak/color/ct = tweak
			if(ct.valid_colors)
				tweak_info["validColors"] = ct.valid_colors
		tweaks += list(tweak_info)
	entry["tweaks"] = tweaks
	return entry

/datum/character_setup/proc/build_gear_detail(datum/gear/G, mob/user)
	// Resolve tweaked icon info for client-side atlas rendering
	var/tweaked_icon_file = null
	var/tweaked_icon_state = null
	var/tweaked_color = null
	if(G.path)
		var/datum/gear_data/gd = new(G.path)
		for(var/datum/gear_tweak/gt in G.gear_tweaks)
			gt.tweak_gear_data(selected_tweaks["[gt]"], gd)
		var/resolved_path = gd.path
		qdel(gd)
		var/atom/movable/gear_virtual_item = new resolved_path
		for(var/datum/gear_tweak/gt in G.gear_tweaks)
			gt.tweak_item(gear_virtual_item, selected_tweaks["[gt]"])
		tweaked_icon_file = "[gear_virtual_item.icon]"
		tweaked_icon_state = gear_virtual_item.icon_state
		if(gear_virtual_item.color)
			if(!islist(gear_virtual_item.color))
				tweaked_color = gear_virtual_item.color
		QDEL_NULL(gear_virtual_item)
	var/detail_owned = G.price && user.client?.donator_info?.has_item(G.type)
	return list(
		"name" = G.display_name,
		"hash" = G.gear_hash,
		"tweakedIcon" = tweaked_icon_file,
		"tweakedIconState" = tweaked_icon_state,
		"tweakedColor" = tweaked_color,
		"description" = G.get_description(selected_tweaks),
		"slot" = G.slot,
		"slotName" = G.slot ? slot_to_description(G.slot) : "",
		"cost" = G.cost,
		"price" = detail_owned ? 0 : (G.price || 0),
		"discount" = detail_owned ? 0 : (G.discount || 0),
		"patronTier" = G.patron_tier,
		"canEquip" = G.is_allowed_to_equip(user),
		"equipped" = islist(pref.gear_list[pref.gear_slot]) && (G.display_name in pref.gear_list[pref.gear_slot])
	)

/datum/character_setup/proc/build_tweak_defs(datum/gear/G)
	// Ensure departmental tweaks have job context
	if(G.is_departmental())
		var/datum/job/preview_job
		var/list/selected_jobs = list()
		if(job_master)
			if(pref.job_high)
				preview_job = job_master.occupations_by_title[pref.job_high]
			var/list/all_titles = list()
			if(pref.job_high)
				all_titles += pref.job_high
			all_titles |= pref.job_medium
			all_titles |= pref.job_low
			for(var/title in all_titles)
				var/datum/job/J = job_master.occupations_by_title[title]
				if(J)
					selected_jobs += J
		G.set_selected_jobs(preview_job, selected_jobs)

	var/list/defs = list()
	var/tweak_index = 0
	for(var/datum/gear_tweak/tweak in G.gear_tweaks)
		tweak_index++
		var/current_val = selected_tweaks["[tweak]"]
		if(isnull(current_val))
			current_val = tweak.get_default()
		var/list/def = list(
			"index" = tweak_index,
			"type" = get_tweak_type_name(tweak),
			"currentValue" = islist(current_val) ? json_encode(current_val) : "[current_val]"
		)
		if(istype(tweak, /datum/gear_tweak/path))
			var/datum/gear_tweak/path/pt = tweak
			var/list/option_names = list()
			for(var/name in pt.valid_paths)
				option_names += name
			def["options"] = option_names
		if(istype(tweak, /datum/gear_tweak/color))
			var/datum/gear_tweak/color/ct = tweak
			if(ct.valid_colors)
				def["validColors"] = ct.valid_colors
		if(istype(tweak, /datum/gear_tweak/departmental))
			var/datum/gear_tweak/departmental/dt = tweak
			var/list/contents = dt.get_contents(selected_tweaks["[tweak]"])
			var/list/dept_entries = list()
			for(var/label in contents)
				dept_entries += list(list("label" = label, "subtype" = "[contents[label]]"))
			def["deptEntries"] = dept_entries
		defs += list(def)
	return defs

/datum/character_setup/proc/get_tweak_type_name(datum/gear_tweak/tweak)
	if(istype(tweak, /datum/gear_tweak/color))
		return "color"
	if(istype(tweak, /datum/gear_tweak/path))
		return "path"
	if(istype(tweak, /datum/gear_tweak/departmental))
		return "departmental"
	if(istype(tweak, /datum/gear_tweak/contents))
		return "contents"
	if(istype(tweak, /datum/gear_tweak/reagents))
		return "reagents"
	if(istype(tweak, /datum/gear_tweak/custom))
		return "custom"
	return "unknown"

/datum/character_setup/proc/gear_allowed_to_see(datum/gear/G, mob/user)
	if(!G.path)
		return FALSE
	if(!G.is_allowed_to_display(user))
		return FALSE
	if(length(G.allowed_roles) && job_master)
		var/list/jobs = list()
		for(var/job_title in (pref.job_medium|pref.job_low|pref.job_high))
			if(job_master.occupations_by_title[job_title])
				jobs += job_master.occupations_by_title[job_title]
		if(!length(jobs))
			return FALSE
		var/job_ok = FALSE
		for(var/datum/job/J in jobs)
			if(J.type in G.allowed_roles)
				job_ok = TRUE
				break
		if(!job_ok)
			return FALSE
	if(G.whitelisted && !(pref.species in G.whitelisted))
		return FALSE
	return TRUE

// ============================================================
// AUGMENTATION HELPER PROCS
// ============================================================
/datum/character_setup/proc/update_internal_organ(organ, action)
	LAZYINITLIST(pref.organ_data)
	switch(action)
		if("nothing")
			pref.organ_data[organ] = null
			if(organ == BP_EYES)
				LAZYINITLIST(pref.organ_modules)
				pref.organ_modules[organ] = null
		if("assisted")
			pref.organ_data[organ] = "assisted"
			if(organ == BP_EYES)
				LAZYINITLIST(pref.organ_modules)
				pref.organ_modules[organ] = null
		if("mechanical")
			pref.organ_data[organ] = "mechanical"

/datum/character_setup/proc/update_external_organ(organ, action)
	LAZYINITLIST(pref.organ_data)
	LAZYINITLIST(pref.rlimb_data)
	switch(action)
		if("nothing")
			pref.organ_data[organ] = null
			pref.rlimb_data[organ] = null
			// Cascade: arm ↔ hand, leg ↔ foot
			switch(organ)
				if(BP_L_ARM)
					pref.organ_data[BP_L_HAND] = null
					pref.rlimb_data[BP_L_HAND] = null
				if(BP_R_ARM)
					pref.organ_data[BP_R_HAND] = null
					pref.rlimb_data[BP_R_HAND] = null
				if(BP_L_LEG)
					pref.organ_data[BP_L_FOOT] = null
					pref.rlimb_data[BP_L_FOOT] = null
				if(BP_R_LEG)
					pref.organ_data[BP_R_FOOT] = null
					pref.rlimb_data[BP_R_FOOT] = null
				if(BP_CHEST, BP_HEAD, BP_GROIN)
					// Full-body reset
					for(var/limb in BP_ALL_LIMBS)
						pref.organ_data[limb] = null
						pref.rlimb_data[limb] = null
					for(var/internal in BP_INTERNAL_ORGANS)
						pref.organ_data[internal] = null
		if("amputated")
			if(organ in list(BP_CHEST, BP_HEAD, BP_GROIN))
				return // Can't amputate chest, head or groin
			pref.organ_data[organ] = "amputated"
			pref.rlimb_data[organ] = null
			// Cascade amputation
			switch(organ)
				if(BP_L_ARM)
					pref.organ_data[BP_L_HAND] = "amputated"
					pref.rlimb_data[BP_L_HAND] = null
				if(BP_R_ARM)
					pref.organ_data[BP_R_HAND] = "amputated"
					pref.rlimb_data[BP_R_HAND] = null
				if(BP_L_LEG)
					pref.organ_data[BP_L_FOOT] = "amputated"
					pref.rlimb_data[BP_L_FOOT] = null
				if(BP_R_LEG)
					pref.organ_data[BP_R_FOOT] = "amputated"
					pref.rlimb_data[BP_R_FOOT] = null
		else
			// Robolimb brand assignment
			if(!(action in GLOB.chargen_robolimbs))
				return
			var/datum/robolimb/R = GLOB.chargen_robolimbs[action]
			if(pref.species in R.species_cannot_use)
				return
			if(length(R.restricted_to) && !(pref.species in R.restricted_to))
				return
			if(length(R.applies_to_part) && !(organ in R.applies_to_part))
				return
			pref.organ_data[organ] = "cyborg"
			pref.rlimb_data[organ] = action
			// Cascade for paired limbs
			switch(organ)
				if(BP_L_ARM)
					pref.organ_data[BP_L_HAND] = "cyborg"
					pref.rlimb_data[BP_L_HAND] = action
				if(BP_R_ARM)
					pref.organ_data[BP_R_HAND] = "cyborg"
					pref.rlimb_data[BP_R_HAND] = action
				if(BP_L_LEG)
					pref.organ_data[BP_L_FOOT] = "cyborg"
					pref.rlimb_data[BP_L_FOOT] = action
				if(BP_R_LEG)
					pref.organ_data[BP_R_FOOT] = "cyborg"
					pref.rlimb_data[BP_R_FOOT] = action
				if(BP_CHEST, BP_HEAD, BP_GROIN)
					// Full-body prosthetic
					for(var/limb in BP_ALL_LIMBS)
						pref.organ_data[limb] = "cyborg"
						pref.rlimb_data[limb] = action
					if(!pref.organ_data[BP_BRAIN])
						pref.organ_data[BP_BRAIN] = "assisted"
					for(var/internal in list(BP_HEART, BP_EYES, BP_LUNGS, BP_LIVER, BP_KIDNEYS))
						pref.organ_data[internal] = "mechanical"

// ============================================================
// LOADOUT HELPERS
// ============================================================
/datum/character_setup/proc/randomize_loadout(mob/owner)
	var/list/gear = pref.gear_list[pref.gear_slot]
	if(!islist(gear))
		gear = list()
		pref.gear_list[pref.gear_slot] = gear
	else
		gear.Cut()
	pref.trying_on_gear = null
	if(islist(pref.trying_on_tweaks))
		pref.trying_on_tweaks.Cut()
	selected_gear_hash = null
	selected_tweaks = list()

	var/list/pool = list()
	for(var/gear_name in gear_datums)
		var/datum/gear/G = gear_datums[gear_name]
		if(gear_allowed_to_see(G, owner) && G.is_allowed_to_equip(owner) && G.cost <= pref.max_loadout_points)
			pool += G
	var/points_left = pref.max_loadout_points
	while(points_left > 0 && length(pool))
		var/datum/gear/chosen = pick(pool)
		var/list/chosen_tweaks = list()
		for(var/datum/gear_tweak/tweak in chosen.gear_tweaks)
			chosen_tweaks["[tweak]"] = tweak.get_random()
		gear[chosen.display_name] = chosen_tweaks.Copy()
		points_left -= chosen.cost
		for(var/datum/gear/G in pool)
			if(G.cost > points_left || (G.slot && G.slot == chosen.slot))
				pool -= G
