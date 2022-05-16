/datum/configuration_section/error
	name = "error"

	var/cooldown = 600
	var/limit = 50
	var/silence_time = 6000
	var/msg_delay = 50

/datum/configuration_section/error/load_data(list/data)
	CONFIG_LOAD_NUM(cooldown, data["error_cooldown"])
	CONFIG_LOAD_NUM(limit, data["error_limit"])
	CONFIG_LOAD_NUM(silence_time, data["error_silence_time"])
	CONFIG_LOAD_NUM(msg_delay, data["error_msg_delay"])
