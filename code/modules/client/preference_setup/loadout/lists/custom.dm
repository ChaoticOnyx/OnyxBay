/datum/gear/custom_item
	sort_category = "Custom Items"
	var/ckey // assigned ckey of custom item owner
	var/required_access
	var/datum/custom_item/current_data

/datum/gear/custom_item/New(key, item_path, datum/custom_item/data)
	var/atom/A = item_path
	display_name = data.name ? data.name : initial(A.name)
	if(data.item_desc)
		description = data.item_desc
	ckey = key
	path = item_path
	var/list/job_types = list()
	for(var/tittle in data.req_titles)
		job_types.Add(job_master.occupations_by_title[tittle])
	allowed_roles = job_types
	required_access = data.req_access
	current_data = data
	..()
	gear_tweaks += new /datum/gear_tweak/custom(current_data)

/datum/gear/custom_item/is_allowed_to_display(mob/user)
	return user.ckey == ckey

/datum/gear/custom_item/is_allowed_to_equip(mob/user)
	. = ..()
	if(. && ishuman(user))
		var/mob/living/carbon/human/M = user
		var/obj/item/weapon/card/id/current_id = M.wear_id
		if(required_access && required_access > 0)
			if(!(istype(current_id) && (required_access in current_id.access)))
				return FALSE

/datum/gear/custom_item/spawn_item(location, metadata)
	var/obj/item/item = ..()
	current_data.apply_to_item(item)
	return item
