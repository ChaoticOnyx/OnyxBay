/datum/gear/custom_item
	sort_category = "Custom Items"
	var/ckey // assigned ckey of custom item owner
	var/datum/custom_item/item_data
	var/patreon_type
	var/static/list/gear_flag_names_to_flag = list(
		"GEAR_HAS_COLOR_SELECTION" = 1,
		"GEAR_HAS_TYPE_SELECTION" = 2,
		"GEAR_HAS_SUBTYPE_SELECTION" = 4,
	)

/datum/gear/custom_item/New(key, item_path, datum/custom_item/data)
	var/obj/item/A = item_path
	var/slot_flags = initial(A.slot_flags)
	for(var/slot_name in slot_flags_enumeration)
		var/slot_mask = slot_flags_enumeration[slot_name]
		if(slot_mask & slot_flags)
			slot = text2num(slot_name)
			break
	display_name = sanitize(initial(A.name))
	var/item_id = 0
	var/fixed_use_name = display_name
	while(gear_datums["[fixed_use_name] (Custom)"])
		fixed_use_name = "[display_name] [++item_id]"
	display_name = fixed_use_name
	display_name = "[display_name] (Custom)"
	ckey = key
	path = item_path
	var/list/job_types = list()
	for(var/job_datum in data.req_job)
		job_types.Add(text2path(job_datum))
	allowed_roles = job_types
	item_data = data
	if(length(data.flags))
		for(var/flag_name in data.flags)
			flags |= gear_flag_names_to_flag[flag_name]
	..()
	gear_tweaks += new /datum/gear_tweak/custom(item_data)

/datum/gear/custom_item/is_allowed_to_display(mob/user)
	var/list/patreon_all_tiers = PATREON_ALL_TIERS
	if(patreon_type && patreon_all_tiers.Find(user?.client?.donator_info.patron_type) < patreon_all_tiers.Find(patreon_type))
		return FALSE
	return user.ckey == ckey
