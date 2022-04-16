/datum/configuration_section/time
	name = "time"

	var/pregame_timeleft = 1800
	var/restart_timeout = 600

/datum/configuration_section/time/load_data(list/data)
	CONFIG_LOAD_NUM(pregame_timeleft, data["pregame_timeleft"])
	CONFIG_LOAD_NUM(restart_timeout, data["restart_timeout"])
