/datum/configuration_section/multiaccount
	name = "multiaccount"

	var/panic_bunker
	var/panic_server_address
	var/panic_server_name
	var/eams
	var/eams_blocks_ooc

/datum/configuration_section/multiaccount/load_data(list/data)
	CONFIG_LOAD_BOOL(panic_bunker, data["panic_bunker"])
	CONFIG_LOAD_STR(panic_server_address, data["panic_server_address"])
	CONFIG_LOAD_STR(panic_server_name, data["panic_server_name"])
	CONFIG_LOAD_BOOL(eams, data["eams"])
	CONFIG_LOAD_BOOL(eams_blocks_ooc, data["eams_blocks_ooc"])
