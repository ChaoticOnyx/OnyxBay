/datum/configuration_section/overmap
	name = "overmap"

	var/list/blacklisted_gammemodes = list()
	var/starmap_path = "config/names/starmap_default.json"
	var/return_system = "Outpost 45"

/datum/configuration_section/overmap/load_data(list/data)
	CONFIG_LOAD_LIST(blacklisted_gammemodes, data["blacklisted_gammemodes"])
