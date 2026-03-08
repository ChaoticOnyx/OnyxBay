#define PREF_SER_VERSION 1

/datum/preferences/proc/get_path(ckey, record_key, extension = "json")
	return "data/players/[ckey]/[record_key].[extension]"

// Returns null if there's no record file. Crashes on other error conditions.
/datum/preferences/proc/load_pref_record(record_key)
	var/path = get_path(client_ckey, record_key)
	if(!fexists(path))
		return null
	var/text = file2text(path)
	if(text == null)
		CRASH("failed to read [path]")
	var/list/data = json_decode(text)
	if(!istype(data))
		CRASH("failed to decode JSON from [path]")
	return new /datum/pref_record_reader/json_list(data)

/datum/preferences/proc/save_pref_record(record_key, list/data)
	var/path = get_path(client_ckey, record_key)
	var/text = json_encode(data)
	if(text == null)
		CRASH("failed to encode JSON for [path]")

	// Why this dance? If text2file fails, we want to leave the record as it was.

	var/tmp_path = "[path].tmp"
	// If we crashed at the end previously, we'll have a junk tmpfile, which text2file would append to.
	if(fexists(tmp_path))
		if(!fdel(tmp_path))
			CRASH("failed to remove junk existing tmpfile at [tmp_path]")
	if(!text2file(text,tmp_path))
		CRASH("failed to write record to tmpfile at [tmp_path]")
	if(!fcopy(tmp_path, path))
		CRASH("failed to copy tmpfile at [tmp_path] to [path]")
	if(!fdel(tmp_path))
		CRASH("failed to remove tmpfile at [tmp_path]")

/datum/preferences/proc/load_preferences()
	var/datum/pref_record_reader/R = load_pref_record("client_preferences")
	if(!R)
		R = new /datum/pref_record_reader/null_reader(PREF_SER_VERSION)
	player_setup.load_preferences(R)

/datum/preferences/proc/save_preferences()
	var/datum/pref_record_writer/json_list/W = new(PREF_SER_VERSION)
	player_setup.save_preferences(W)
	save_pref_record("client_preferences", W.data)

/datum/preferences/proc/get_slot_key(slot)
	return "character_[GLOB.using_map.preferences_key()]_[slot]"

/datum/preferences/proc/load_character(slot)
	if(!slot)
		slot = default_slot

	if(slot != SAVE_RESET) // SAVE_RESET will reset the slot as though it does not exist, but keep the current slot for saving purposes.
		slot = sanitize_integer(slot, 1, config.character_setup.character_slots, initial(default_slot))
		if(slot != default_slot)
			default_slot = slot
			SScharacter_setup.queue_preferences_save(src)

	if(slot == SAVE_RESET)
		// If we're resetting, set everything to null. Sanitization will clean it up
		var/datum/pref_record_reader/null_reader/R = new(PREF_SER_VERSION)
		player_setup.load_character(R)
	else
		var/datum/pref_record_reader/R = load_pref_record(get_slot_key(slot))
		if(!R)
			R = new /datum/pref_record_reader/null_reader(PREF_SER_VERSION)
		player_setup.load_character(R)

	clear_character_previews() // Recalculate them on next show

// Returns a deep copy of the character data as an assoc list (no disk write).
/datum/preferences/proc/snapshot_character()
	var/datum/pref_record_writer/json_list/W = new(PREF_SER_VERSION)
	player_setup.save_character(W)
	return deep_copy_assoc(W.data)

// Recursively deep-copies a list including both indexed and associated values.
/datum/preferences/proc/deep_copy_assoc(list/L)
	if(!islist(L))
		return L
	var/list/copy = L.Copy()
	// Deep-copy indexed values (handles numeric-indexed lists like gear_list)
	for(var/i = 1 to copy.len)
		if(islist(copy[i]))
			copy[i] = deep_copy_assoc(copy[i])
	// Deep-copy associated values (handles assoc lists like data["gear_list"])
	for(var/key in copy)
		if(istext(key) && islist(copy[key]))
			copy[key] = deep_copy_assoc(copy[key])
	return copy

// Restores character data from a snapshot produced by snapshot_character().
/datum/preferences/proc/restore_character_snapshot(list/snapshot)
	var/datum/pref_record_reader/json_list/R = new /datum/pref_record_reader/json_list(snapshot)
	player_setup.load_character(R)
	sanitize_preferences()

/datum/preferences/proc/save_character(override_key = null)
	var/datum/pref_record_writer/json_list/W = new(PREF_SER_VERSION)
	player_setup.save_character(W)

	var/record_key = override_key || get_slot_key(default_slot)
	save_pref_record(record_key, W.data)

	// Cache the character's name for listing
	LAZYSET(slot_names, record_key, W.data["real_name"])
	SScharacter_setup.queue_preferences_save(src)

/datum/preferences/proc/sanitize_preferences()
	player_setup.sanitize_setup()
	return 1

/datum/preferences/proc/get_lp_cost()
	total_lpoints_cost = player_setup.get_lp_cost()
	return total_lpoints_cost

/datum/preferences/proc/get_loadout_points_cost()
	return player_setup.get_loadout_points_cost()

/datum/preferences/proc/is_default_module(organ_tag, module_path)
	if(!organ_tag || !module_path)
		return FALSE
	var/datum/robolimb/R = GLOB.all_robolimbs[rlimb_data[organ_tag]]
	if(!R || !R.default_modules)
		return FALSE
	return (module_path in R.default_modules)

/datum/preferences/proc/get_aug_cost()
	total_aug_points = 0
	for(var/organ_tag in BP_ALL_LIMBS + BP_INTERNAL_ORGANS)
		for(var/obj/item/organ_module/mod as anything in organ_modules[organ_tag])
			if(initial(mod.module_type) == OM_TYPE_ACTUATOR)
				continue
			if(is_default_module(organ_tag, mod))
				continue
			if(initial(mod.augment_cost) <= 0)
				continue
			total_aug_points += initial(mod.augment_cost)
	return total_aug_points

#undef PREF_SER_VERSION
