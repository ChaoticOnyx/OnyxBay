/datum/configuration_section/error_handling
	name = "error-handling"

	var/error_cooldown = 600
	var/error_limit = 50
	var/error_silence_time = 6000
	var/error_msg_delay = 50

/datum/configuration_section/error_handling/load_data(list/data)
	CONFIG_LOAD_NUM(error_cooldown, data["error_cooldown"])
	CONFIG_LOAD_NUM(error_limit, data["error_limit"])
	CONFIG_LOAD_NUM(error_silence_time, data["error_silence_time"])
	CONFIG_LOAD_NUM(error_msg_delay, data["error_msg_delay"])
