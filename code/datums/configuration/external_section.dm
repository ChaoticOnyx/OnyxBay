/datum/configuration_section/external
	name = "external"

	var/sql_enabled = FALSE
	var/comms_password = null
	var/ban_comms_password = null
	var/webhook_address = null
	var/webhook_key = null
	var/server = null
	var/server_url = null
	var/login_export_addr = null
	var/use_irc_bot = FALSE
	var/irc_bot_host = null
	var/main_irc = null
	var/admin_irc = null
	var/announce_shuttle_dock_to_irc = FALSE

/datum/configuration_section/external/load_data(list/data)
	CONFIG_LOAD_BOOL(sql_enabled, data["sql_enabled"])
	CONFIG_LOAD_STR(comms_password, data["comms_password"])
	CONFIG_LOAD_STR(ban_comms_password, data["ban_comms_password"])
	CONFIG_LOAD_STR(webhook_address, data["webhook_address"])
	CONFIG_LOAD_STR(webhook_key, data["webhook_key"])
	CONFIG_LOAD_STR(server, data["server"])
	CONFIG_LOAD_STR(server_url, data["server_url"])
	CONFIG_LOAD_STR(login_export_addr, data["login_export_addr"])
	CONFIG_LOAD_BOOL(use_irc_bot, data["use_irc_bot"])
	CONFIG_LOAD_STR(irc_bot_host, data["irc_bot_host"])
	CONFIG_LOAD_STR(main_irc, data["main_irc"])
	CONFIG_LOAD_STR(admin_irc, data["admin_irc"])
	CONFIG_LOAD_BOOL(announce_shuttle_dock_to_irc, data["announce_shuttle_dock_to_irc"])
