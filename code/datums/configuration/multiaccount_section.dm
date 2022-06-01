/datum/configuration_section/multiaccount
	name = "multiaccount"

	var/panic_bunker = FALSE
	var/panic_server_address = null
	var/panic_server_name = null
	var/eams = FALSE
	var/eams_blocks_ooc = FALSE

/datum/configuration_section/multiaccount/load_data(list/data)
	CONFIG_LOAD_BOOL(panic_bunker, data["panic_bunker"])
	CONFIG_LOAD_STR(panic_server_address, data["panic_server_address"])
	CONFIG_LOAD_STR(panic_server_name, data["panic_server_name"])
	CONFIG_LOAD_BOOL(eams, data["eams"])
	CONFIG_LOAD_BOOL(eams_blocks_ooc, data["eams_blocks_ooc"])
