// Switch this out to use a database at some point. Each ckey is
// associated with a list of custom item datums. When the character
// spawns, the list is checked and all appropriate datums are spawned.

/datum/custom_item
	var/item_path
	var/patreon_type
	var/list/req_job
	var/list/flags = list()

/datum/custom_item/New(item_path, patreon_type, req_job, flags)
	src.item_path = item_path
	src.patreon_type = patreon_type
	src.req_job = req_job
	src.flags = flags

/datum/custom_item/proc/spawn_item(newloc)
	var/obj/item/citem = new item_path(newloc)
	apply_to_item(citem)
	return citem

/datum/custom_item/proc/apply_to_item(obj/item/item)
	return item

//this has to mirror the way update_inv_*_hand() selects the state
/datum/custom_item/proc/get_state(obj/item/item, slot_str, hand_str)
	var/t_state
	if(item.item_state_slots && item.item_state_slots[slot_str])
		t_state = item.item_state_slots[slot_str]
	else if(item.item_state)
		t_state = item.item_state
	else
		t_state = item.icon_state
	if(item.icon_override)
		t_state += hand_str
	return t_state

//this has to mirror the way update_inv_*_hand() selects the icon
/datum/custom_item/proc/get_icon(obj/item/item, slot_str, icon/hand_icon)
	var/icon/t_icon
	if(item.icon_override)
		t_icon = item.icon_override
	else if(item.item_icons && (slot_str in item.item_icons))
		t_icon = item.item_icons[slot_str]
	else
		t_icon = hand_icon
	return t_icon

// Parses the config file into the custom_items list.
/hook/startup/proc/load_custom_items()
	if(GLOB.using_map.loadout_blacklist && (/datum/gear/custom_item in GLOB.using_map.loadout_blacklist))
		return

	for(var/ckey in config.custom.items)
		var/list/items = config.custom.items[ckey]

		for(var/datum/custom_item/item in items)
			var/datum/gear/custom_item/G = new(ckey, item.item_path, item)
			G.patreon_type = item.patreon_type

			var/use_name = G.display_name
			var/use_category = G.sort_category

			if(!loadout_categories[use_category])
				loadout_categories[use_category] = new /datum/loadout_category(use_category)

			var/datum/loadout_category/LC = loadout_categories[use_category]

			gear_datums[use_name] = G
			hash_to_gear[G.gear_hash] = G

			LC.gear[use_name] = gear_datums[use_name]

	return TRUE

//gets the relevant list for the key from the listlist if it exists, check to make sure they are meant to have it and then calls the giving function
/proc/equip_custom_items(mob/living/carbon/human/M)
	var/list/key_list = config.custom.items[M.ckey]

	if(!length(key_list))
		return

	for(var/datum/custom_item/citem in key_list)
		// Check for required job title.
		if(length(citem.req_job))
			var/has_title
			var/current_title = M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role
			for(var/title in citem.req_job)
				if(title == current_title)
					has_title = 1
					break
			if(!has_title)
				continue

		// ID cards and PDAs are applied directly to the existing object rather than spawned fresh.
		var/obj/item/existing_item
		if(citem.item_path == /obj/item/card/id && istype(M.wear_id)) //Set earlier.
			existing_item = M.wear_id
		else if(citem.item_path == /obj/item/device/pda)
			existing_item = locate(/obj/item/device/pda) in M.contents

		// Spawn and equip the item.
		if(existing_item)
			citem.apply_to_item(existing_item)
		else
			place_custom_item(M,citem)

// Places the item on the target mob.
/proc/place_custom_item(mob/living/carbon/human/M, datum/custom_item/citem)

	if(!citem) return
	var/obj/item/newitem = citem.spawn_item(M.loc)

	if(M.equip_to_appropriate_slot(newitem))
		return newitem

	if(M.equip_to_storage(newitem))
		return newitem

	return newitem
