/datum/configuration_section/vote
	name = "vote"

	var/allow_vote_restart
	var/allow_vote_mode
	var/allow_extra_antags
	var/delay
	var/period
	var/autotransfer_initial
	var/autotransfer_interval
	var/autogamemode_timeleft
	var/no_dead_vote
	var/default_no_vote

/datum/configuration_section/vote/load_data(list/data)
	CONFIG_LOAD_BOOL(allow_vote_restart, data["allow_vote_restart"])
	CONFIG_LOAD_BOOL(allow_vote_mode, data["allow_vote_mode"])
	CONFIG_LOAD_BOOL(allow_extra_antags, data["allow_extra_antags"])
	CONFIG_LOAD_NUM(delay, data["delay"])
	CONFIG_LOAD_NUM(period, data["period"])
	CONFIG_LOAD_NUM(autotransfer_initial, data["autotransfer_initial"])
	CONFIG_LOAD_NUM(autotransfer_interval, data["autotransfer_interval"])
	CONFIG_LOAD_NUM(autogamemode_timeleft, data["autogamemode_timeleft"])
	CONFIG_LOAD_BOOL(no_dead_vote, data["no_dead_vote"])
	CONFIG_LOAD_BOOL(default_no_vote, data["default_no_vote"])
