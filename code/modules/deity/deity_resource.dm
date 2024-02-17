/datum/god_form
	var/list/resources = list()

/datum/god_form/New()
	for(var/path in resources)
		resources.Remove(path)
		resources.Add(new path(src))
	return ..()

/datum/god_form/Destroy()
	QDEL_NULL_LIST(resources)
	return ..()

/datum/god_form/proc/get_resource(path)
	for(var/r in resources)
		if(istype(r, path))
			return r

	return null

/datum/god_form/proc/has_enough_resource(path, amt)
	if(amt == 0)
		return TRUE

	var/datum/deity_resource/resource = get_resource(path)
	if(resource)
		return resource.has_amount(amt)

	return FALSE

/datum/god_form/proc/use_resource(path, amt)
	if(amt == 0)
		return TRUE

	var/datum/deity_resource/resource = get_resource(path)
	if(resource)
		var/r = resource.use_amount(amt)
		return r

	return FALSE

/datum/god_form/proc/add_to_resource(path, amt)
	if(amt == 0)
		return TRUE

	var/datum/deity_resource/resource = get_resource(path)
	if(resource)
		var/r = resource.add_amount(amt)
		return r

	return FALSE
