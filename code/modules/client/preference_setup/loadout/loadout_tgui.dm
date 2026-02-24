/// TGUI backend for the Loadout Manager interface.
/// Replaces the legacy HTML loadout UI with a modern TGUI window.

/datum/loadout_tgui
	var/datum/preferences/pref
	var/mob/owner
	var/selected_gear_hash
	var/list/selected_tweaks = list()
	var/current_category
	var/hide_unavailable_gear = FALSE
	var/hide_donate_gear = FALSE
	var/slot_filter  // If set, only show gear for this slot

/datum/loadout_tgui/New(datum/preferences/P, mob/user)
	pref = P
	owner = user
	if(length(loadout_categories))
		current_category = loadout_categories[1]

/datum/loadout_tgui/Destroy()
	pref = null
	owner = null
	return ..()

/datum/loadout_tgui/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/loadout_tgui/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "LoadoutManager", "Loadout Manager")
		ui.open()

/datum/loadout_tgui/tgui_static_data(mob/user)
	var/list/categories = list()
	for(var/cat_name in loadout_categories)
		var/datum/loadout_category/LC = loadout_categories[cat_name]
		var/list/items = list()
		for(var/gear_name in LC.gear)
			var/datum/gear/G = LC.gear[gear_name]
			if(!G.path && !length(G.gear_tweaks))
				continue
			if(!G.is_allowed_to_display(user))
				continue
			items += list(build_gear_entry(G, user))
		categories += list(list(
			"name" = cat_name,
			"items" = items
		))

	// Build slot type list for the mannequin overlay
	var/list/slot_types = list()
	var/list/slot_ids = list(
		list("id" = slot_head, "name" = "Head"),
		list("id" = slot_glasses, "name" = "Eyes"),
		list("id" = slot_wear_mask, "name" = "Mask"),
		list("id" = slot_l_ear, "name" = "Left Ear"),
		list("id" = slot_r_ear, "name" = "Right Ear"),
		list("id" = slot_w_uniform, "name" = "Uniform"),
		list("id" = slot_wear_suit, "name" = "Suit"),
		list("id" = slot_gloves, "name" = "Gloves"),
		list("id" = slot_belt, "name" = "Belt"),
		list("id" = slot_back, "name" = "Back"),
		list("id" = slot_shoes, "name" = "Shoes"),
		list("id" = slot_wear_id, "name" = "ID"),
		list("id" = slot_tie, "name" = "Accessory"),
	)
	for(var/list/slot_info in slot_ids)
		slot_types += list(list(
			"slotId" = slot_info["id"],
			"name" = slot_info["name"]
		))

	return list(
		"categories" = categories,
		"allSlotTypes" = slot_types,
		"maxSlots" = config.character_setup.loadout_slots
	)

/datum/loadout_tgui/tgui_data(mob/user)
	var/list/equipped = list()
	var/list/gear_items = pref.gear_list[pref.gear_slot]
	for(var/gear_name in gear_items)
		var/datum/gear/G = gear_datums[gear_name]
		if(G)
			equipped[G.gear_hash] = TRUE

	// Build filled slots info
	var/list/filled_slots = list()
	for(var/gear_name in gear_items)
		var/datum/gear/G = gear_datums[gear_name]
		if(G && G.slot)
			filled_slots += list(list(
				"slotId" = G.slot,
				"name" = slot_to_description(G.slot),
				"equippedName" = G.display_name,
				"equippedIcon" = G.path ? icon2base64html(G.path) : null
			))

	// Selected item detail
	var/list/selected_detail = null
	var/list/selected_tweak_defs = list()
	if(selected_gear_hash)
		var/datum/gear/SG = hash_to_gear[selected_gear_hash]
		if(SG)
			selected_detail = build_gear_detail(SG, user)
			selected_tweak_defs = build_tweak_defs(SG)

	// Calculate total cost
	var/total_cost = 0
	for(var/gear_name in gear_items)
		var/datum/gear/G = gear_datums[gear_name]
		if(G)
			total_cost += G.cost

	// Mannequin preview
	var/mannequin_icon = get_mannequin_preview(user)

	// Patron info
	var/patron_tier = user.client?.donator_info?.get_full_patron_tier()
	var/current_opyxes = user.client?.donator_info ? round(user.client.donator_info.opyxes) : 0

	return list(
		"equippedGear" = equipped,
		"selectedHash" = selected_gear_hash,
		"selectedItemDetail" = selected_detail,
		"selectedTweaks" = selected_tweak_defs,
		"mannequinIcon" = mannequin_icon,
		"currentSlot" = pref.gear_slot,
		"usedPoints" = total_cost,
		"maxPoints" = pref.max_loadout_points,
		"filledSlots" = filled_slots,
		"isTryingOn" = !!pref.trying_on_gear,
		"hideUnavailable" = hide_unavailable_gear,
		"hideDonate" = hide_donate_gear,
		"slotFilter" = slot_filter,
		"patronTier" = patron_tier,
		"currentOpyxes" = current_opyxes
	)

/datum/loadout_tgui/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("selectGear")
			var/hash = params["hash"]
			var/datum/gear/G = hash_to_gear[hash]
			if(!G)
				return FALSE
			selected_gear_hash = hash
			selected_tweaks = pref.gear_list[pref.gear_slot][G.display_name]
			if(!selected_tweaks)
				selected_tweaks = list()
				for(var/datum/gear_tweak/tweak in G.gear_tweaks)
					selected_tweaks["[tweak]"] = tweak.get_default()
			pref.trying_on_gear = null
			pref.trying_on_tweaks.Cut()
			update_preview()
			return TRUE

		if("toggleGear")
			var/hash = params["hash"]
			var/datum/gear/TG = hash_to_gear[hash]
			if(!TG)
				return FALSE
			if(!gear_allowed_to_equip(TG, owner))
				return FALSE
			if(TG.display_name in pref.gear_list[pref.gear_slot])
				pref.gear_list[pref.gear_slot] -= TG.display_name
			else
				var/total_cost = 0
				for(var/gear_name in pref.gear_list[pref.gear_slot])
					var/datum/gear/G = gear_datums[gear_name]
					if(istype(G))
						total_cost += G.cost
				if((total_cost + TG.cost) <= pref.max_loadout_points)
					pref.gear_list[pref.gear_slot][TG.display_name] = selected_tweaks.Copy()
			update_preview()
			return TRUE

		if("setTweak")
			var/tweak_index = params["tweakIndex"]
			var/datum/gear/SG = hash_to_gear[selected_gear_hash]
			if(!SG || !tweak_index || tweak_index < 1 || tweak_index > length(SG.gear_tweaks))
				return FALSE
			var/datum/gear_tweak/tweak = SG.gear_tweaks[tweak_index]

			var/new_value
			if(params["value"])
				// Direct value from frontend (path selection, color palette, etc.)
				new_value = params["value"]
			else
				// Server-side input dialog (free color picker, etc.)
				new_value = tweak.get_metadata(owner, selected_tweaks["[tweak]"], params["subtype"])

			if(!new_value)
				return FALSE

			selected_tweaks["[tweak]"] = new_value

			// If gear is currently equipped, update saved tweaks too
			if(SG.display_name in pref.gear_list[pref.gear_slot])
				var/list/gear_items = pref.gear_list[pref.gear_slot]
				var/list/metadata = gear_items[SG.display_name]
				if(!islist(metadata))
					metadata = list()
					gear_items[SG.display_name] = metadata
				metadata["[tweak]"] = new_value

			// If trying on, update try-on tweaks
			if(SG.display_name == pref.trying_on_gear)
				pref.trying_on_tweaks["[tweak]"] = new_value

			update_preview()
			return TRUE

		if("setSlot")
			var/new_slot = params["slot"]
			if(!isnum(new_slot) || new_slot < 1 || new_slot > config.character_setup.loadout_slots)
				return FALSE
			pref.gear_slot = new_slot
			selected_gear_hash = null
			selected_tweaks = list()
			pref.trying_on_gear = null
			pref.trying_on_tweaks.Cut()
			update_preview()
			return TRUE

		if("clearLoadout")
			var/list/gear = pref.gear_list[pref.gear_slot]
			gear.Cut()
			selected_gear_hash = null
			selected_tweaks = list()
			pref.trying_on_gear = null
			pref.trying_on_tweaks.Cut()
			update_preview()
			return TRUE

		if("randomizeLoadout")
			randomize_loadout()
			update_preview()
			return TRUE

		if("tryOn")
			if(!selected_gear_hash)
				return FALSE
			var/datum/gear/SG = hash_to_gear[selected_gear_hash]
			if(!SG)
				return FALSE
			if(SG.display_name == pref.trying_on_gear)
				pref.trying_on_gear = null
				pref.trying_on_tweaks.Cut()
			else
				pref.trying_on_gear = SG.display_name
				pref.trying_on_tweaks = selected_tweaks.Copy()
			update_preview()
			return TRUE

		if("buyGear")
			var/hash = params["hash"]
			var/datum/gear/G = hash_to_gear[hash]
			if(!G || !G.price)
				return FALSE
			if(owner.client.donator_info.has_item(G.type))
				return FALSE
			var/adjusted_price = G.discount ? G.price * G.discount : G.price
			var/comment = "Donation store purchase: [G.type]"
			var/transaction = SSdonations.create_transaction(owner.client, -adjusted_price, DONATIONS_TRANSACTION_TYPE_PURCHASE, comment)
			if(transaction)
				if(SSdonations.give_item(owner.client, G.type, transaction))
					pref.trying_on_gear = null
					pref.trying_on_tweaks.Cut()
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
				slot_filter = null  // Toggle off
			else
				slot_filter = new_filter
			return TRUE

	return FALSE

/// Build a gear entry for static data (sent once).
/datum/loadout_tgui/proc/build_gear_entry(datum/gear/G, mob/user)
	var/list/entry = list(
		"name" = G.display_name,
		"hash" = G.gear_hash,
		"icon" = G.path ? icon2base64html(G.path) : null,
		"slot" = G.slot,
		"slotName" = G.slot ? slot_to_description(G.slot) : "",
		"subgroup" = G.subgroup || "",
		"cost" = G.cost,
		"price" = G.price || 0,
		"discount" = G.discount || 0,
		"patronTier" = G.patron_tier,
		"description" = G.description || "",
		"allowed" = gear_allowed_to_see(G),
		"canEquip" = gear_allowed_to_equip(G, user)
	)

	// Allowed roles info
	if(length(G.allowed_roles))
		var/list/role_names = list()
		for(var/allowed_type in G.allowed_roles)
			if(ispath(allowed_type, /datum/job))
				var/datum/job/J = job_master ? job_master.occupations_by_type[allowed_type] : new allowed_type
				role_names += J.title
		entry["allowedRoles"] = role_names

	// Species restrictions
	if(G.whitelisted)
		var/list/species_list = islist(G.whitelisted) ? G.whitelisted : list(G.whitelisted)
		entry["whitelisted"] = species_list

	// Tweak info (for the item browser - just types and option counts)
	var/list/tweaks = list()
	var/tweak_index = 0
	for(var/datum/gear_tweak/tweak in G.gear_tweaks)
		tweak_index++
		var/list/tweak_info = list(
			"index" = tweak_index,
			"type" = get_tweak_type_name(tweak)
		)
		// For path tweaks, include options
		if(istype(tweak, /datum/gear_tweak/path))
			var/datum/gear_tweak/path/pt = tweak
			var/list/option_names = list()
			for(var/name in pt.valid_paths)
				option_names += name
			tweak_info["options"] = option_names
		// For color tweaks with valid_colors, include palette
		if(istype(tweak, /datum/gear_tweak/color))
			var/datum/gear_tweak/color/ct = tweak
			if(ct.valid_colors)
				tweak_info["validColors"] = ct.valid_colors
		// For contents tweaks, include options per slot
		if(istype(tweak, /datum/gear_tweak/contents))
			var/datum/gear_tweak/contents/cnt = tweak
			var/list/content_options = list()
			for(var/i = 1 to length(cnt.valid_contents))
				var/list/slot_options = list("Random", "None")
				for(var/name in cnt.valid_contents[i])
					slot_options += name
				content_options += list(slot_options)
			tweak_info["contentOptions"] = content_options
		// For reagent tweaks, include reagent names
		if(istype(tweak, /datum/gear_tweak/reagents))
			var/datum/gear_tweak/reagents/rt = tweak
			var/list/reagent_names = list("Random", "None")
			for(var/name in rt.valid_reagents)
				reagent_names += name
			tweak_info["reagentOptions"] = reagent_names

		tweaks += list(tweak_info)
	entry["tweaks"] = tweaks

	return entry

/// Build detailed info for the selected gear item.
/datum/loadout_tgui/proc/build_gear_detail(datum/gear/G, mob/user)
	// Create virtual item with tweaks applied for the icon
	var/tweaked_icon = null
	if(G.path)
		var/datum/gear_data/gd = new(G.path)
		for(var/datum/gear_tweak/gt in G.gear_tweaks)
			gt.tweak_gear_data(selected_tweaks["[gt]"], gd)
		var/atom/movable/gear_virtual_item = new gd.path
		for(var/datum/gear_tweak/gt in G.gear_tweaks)
			gt.tweak_item(gear_virtual_item, selected_tweaks["[gt]"])
		var/icon/I = icon(gear_virtual_item.icon, gear_virtual_item.icon_state)
		if(gear_virtual_item.color)
			if(islist(gear_virtual_item.color))
				I.MapColors(arglist(gear_virtual_item.color))
			else
				I.Blend(gear_virtual_item.color, ICON_MULTIPLY)
		I.Scale(I.Width() * 2, I.Height() * 2)
		QDEL_NULL(gear_virtual_item)
		tweaked_icon = icon2base64html(I)

	var/desc = G.get_description(selected_tweaks)

	return list(
		"name" = G.display_name,
		"hash" = G.gear_hash,
		"tweakedIcon" = tweaked_icon,
		"description" = desc || "",
		"slot" = G.slot,
		"slotName" = G.slot ? slot_to_description(G.slot) : "",
		"cost" = G.cost,
		"price" = G.price || 0,
		"discount" = G.discount || 0,
		"patronTier" = G.patron_tier,
		"canEquip" = gear_allowed_to_equip(G, user),
		"allowed" = gear_allowed_to_see(G),
		"equipped" = (G.display_name in pref.gear_list[pref.gear_slot])
	)

/// Build tweak definitions with current values for the selected item.
/datum/loadout_tgui/proc/build_tweak_defs(datum/gear/G)
	// Ensure departmental tweaks have job context
	if(G.is_departmental())
		var/datum/job/preview_job = get_preview_job()
		var/list/selected_jobs = get_selected_jobs()
		G.set_selected_jobs(preview_job, selected_jobs)

	var/list/defs = list()
	var/tweak_index = 0
	for(var/datum/gear_tweak/tweak in G.gear_tweaks)
		tweak_index++
		var/current_val = selected_tweaks["[tweak]"]
		if(!current_val)
			current_val = tweak.get_default()
		var/list/def = list(
			"index" = tweak_index,
			"type" = get_tweak_type_name(tweak),
			"currentValue" = "[current_val]"
		)
		// Include options for path tweaks
		if(istype(tweak, /datum/gear_tweak/path))
			var/datum/gear_tweak/path/pt = tweak
			var/list/option_names = list()
			for(var/name in pt.valid_paths)
				option_names += name
			def["options"] = option_names
		// Include color palette
		if(istype(tweak, /datum/gear_tweak/color))
			var/datum/gear_tweak/color/ct = tweak
			if(ct.valid_colors)
				def["validColors"] = ct.valid_colors
		// Include departmental contents (job -> item choices)
		if(istype(tweak, /datum/gear_tweak/departmental))
			var/datum/gear_tweak/departmental/dt = tweak
			var/list/contents = dt.get_contents(selected_tweaks["[tweak]"])
			var/list/dept_entries = list()
			for(var/label in contents)
				dept_entries += list(list("label" = label, "subtype" = "[contents[label]]"))
			def["deptEntries"] = dept_entries
		defs += list(def)
	return defs

/// Get the high-priority job datum for the current preferences.
/datum/loadout_tgui/proc/get_preview_job()
	if(!job_master)
		return null
	if(pref.job_high)
		return job_master.occupations_by_title[pref.job_high]
	return null

/// Get the list of all selected job datums.
/datum/loadout_tgui/proc/get_selected_jobs()
	if(!job_master)
		return list()
	var/list/jobs = list()
	var/list/all_titles = list()
	if(pref.job_high)
		all_titles += pref.job_high
	all_titles |= pref.job_medium
	all_titles |= pref.job_low
	for(var/title in all_titles)
		var/datum/job/J = job_master.occupations_by_title[title]
		if(J)
			jobs += J
	return jobs

/// Get a string type name for a gear tweak.
/datum/loadout_tgui/proc/get_tweak_type_name(datum/gear_tweak/tweak)
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

/// Get mannequin preview as base64 HTML icon.
/datum/loadout_tgui/proc/get_mannequin_preview(mob/user)
	if(!user?.ckey)
		return null
	var/mob/living/carbon/human/dummy/mannequin/M = get_mannequin(user.ckey)
	if(!M)
		return null
	M.delete_inventory(TRUE)
	pref.dress_preview_mob(M)
	M.ImmediateOverlayUpdate()
	var/icon/preview = M.generate_preview()
	if(!preview)
		return null
	preview.Scale(preview.Width() * 3, preview.Height() * 3)
	return icon2base64html(preview)

/// Update the character preview in the preferences window.
/datum/loadout_tgui/proc/update_preview()
	pref.update_preview_icon()

/// Check if a gear is allowed to be seen by the current user.
/datum/loadout_tgui/proc/gear_allowed_to_see(datum/gear/G)
	if(!G.path)
		return FALSE
	if(!G.is_allowed_to_display(owner))
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

/// Check if a gear is allowed to be equipped by the user.
/datum/loadout_tgui/proc/gear_allowed_to_equip(datum/gear/G, mob/user)
	return G.is_allowed_to_equip(user)

/// Randomize the current loadout slot.
/datum/loadout_tgui/proc/randomize_loadout()
	var/list/gear = pref.gear_list[pref.gear_slot]
	gear.Cut()
	pref.trying_on_gear = null
	pref.trying_on_tweaks.Cut()
	selected_gear_hash = null
	selected_tweaks = list()

	var/list/pool = list()
	for(var/gear_name in gear_datums)
		var/datum/gear/G = gear_datums[gear_name]
		if(gear_allowed_to_see(G) && gear_allowed_to_equip(G, owner) && G.cost <= pref.max_loadout_points)
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
