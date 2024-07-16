/datum/configuration_section/watchdog
	name = "watchdog"
	protection_state = PROTECTION_PRIVATE

	var/enabled
	var/timeout
	var/webhook_url
	var/message

/datum/configuration_section/watchdog/load_data(list/data)
	CONFIG_LOAD_BOOL(enabled, data["enabled"])
	CONFIG_LOAD_NUM(timeout, data["timeout"])
	CONFIG_LOAD_STR(webhook_url, data["webhook_url"])
	CONFIG_LOAD_STR(message, data["message"])
