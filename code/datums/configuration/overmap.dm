/datum/configuration_section/overmap
	name = "overmap"

	var/list/blacklisted_gammemodes
	var/starmap_path
	var/return_system

/datum/configuration_section/overmap/load_data(list/data)
	CONFIG_LOAD_LIST(blacklisted_gammemodes, data["blacklisted_gammemodes"])
	CONFIG_LOAD_STR(starmap_path, data["starmap_path"])
	CONFIG_LOAD_STR(return_system, data["return_system"])
