/datum/moniker
	var/list/names = list()
	var/list/descriptors = list()
	var/list/hash = list()

/datum/moniker/proc/get(key)
	var/result = hash[key]

	if(!result)
		var/new_moniker = "[pick(descriptors)]-[pick(names)][rand(0, length(key))]"
		hash[key] = result = new_moniker

	return result

GLOBAL_DATUM_INIT(moniker, /datum/moniker/animals, new())
