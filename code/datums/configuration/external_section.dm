/datum/configuration_section/external
	name = "external"
	protection_state = PROTECTION_PRIVATE

	var/comms_password
	var/ban_comms_password
	var/server
	var/server_url
	var/login_export_addr

/datum/configuration_section/external/load_data(list/data)
	CONFIG_LOAD_STR(comms_password, data["comms_password"])
	CONFIG_LOAD_STR(ban_comms_password, data["ban_comms_password"])
	CONFIG_LOAD_STR(server, data["server"])
	CONFIG_LOAD_STR(server_url, data["server_url"])
	CONFIG_LOAD_STR(login_export_addr, data["login_export_addr"])
