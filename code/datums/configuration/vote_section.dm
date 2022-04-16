/datum/configuration_section/vote
	name = "vote"

	var/allow_vote_restart = TRUE
	var/allow_vote_mode = TRUE
	var/allow_extra_antags = FALSE
	var/vote_delay = 6000
	var/vote_period = 600
	var/vote_autotransfer_initial = 108000
	var/vote_autotransfer_interval = 36000
	var/vote_autogamemode_timeleft = 100
	var/no_dead_vote = FALSE
	var/default_no_vote = TRUE

/datum/configuration_section/vote/load_data(list/data)
	CONFIG_LOAD_BOOL(allow_vote_restart, data["allow_vote_restart"])
	CONFIG_LOAD_BOOL(allow_vote_mode, data["allow_vote_mode"])
	CONFIG_LOAD_BOOL(allow_extra_antags, data["allow_extra_antags"])
	CONFIG_LOAD_NUM(vote_delay, data["vote_delay"])
	CONFIG_LOAD_NUM(vote_period, data["vote_period"])
	CONFIG_LOAD_NUM(vote_autotransfer_initial, data["vote_autotransfer_initial"])
	CONFIG_LOAD_NUM(vote_autotransfer_interval, data["vote_autotransfer_interval"])
	CONFIG_LOAD_NUM(vote_autogamemode_timeleft, data["vote_autogamemode_timeleft"])
	CONFIG_LOAD_BOOL(no_dead_vote, data["no_dead_vote"])
	CONFIG_LOAD_BOOL(default_no_vote, data["default_no_vote"])
