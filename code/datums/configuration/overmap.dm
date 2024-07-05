/datum/configuration_section/overmap
	name = "overmap"

	var/list/blacklisted_gammemodes
	var/return_system
	var/list/systems

/datum/configuration_section/overmap/load_data(list/data)
	CONFIG_LOAD_LIST(blacklisted_gammemodes, data["blacklisted_gammemodes"])
	CONFIG_LOAD_STR(return_system, data["return_system"])
	CONFIG_LOAD_LIST(systems, data["systems"])
