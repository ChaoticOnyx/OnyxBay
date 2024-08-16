/datum/configuration_section/whitelist
	name = "whitelist"

	var/enable
	var/list/ckeys
	var/enable_alien_whitelist

/datum/configuration_section/whitelist/load_data(list/data)
	CONFIG_LOAD_BOOL(enable, data["enable"])
	CONFIG_LOAD_LIST(ckeys, data["ckeys"])
	CONFIG_LOAD_BOOL(enable_alien_whitelist, data["enable_alien_whitelist"])
