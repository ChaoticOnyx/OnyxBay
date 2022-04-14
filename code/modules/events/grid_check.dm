/datum/event/grid_check	//NOTE: Times are measured in master controller ticks!
	announceWhen		= 5

/datum/event/grid_check/start()
	power_failure(0, severity, affecting_z)

/datum/event/grid_check/announce()
	command_announcement.AnnounceLocalizeable(
		TR_DATA(GLOB.using_map.grid_check_message_l, null, list("station_name" = station_name())),
		TR_DATA(L10N_ANNOUNCE_GRID_CHECK_TITLE, null, null),
		new_sound = GLOB.using_map.grid_check_sound,
		zlevels = affecting_z
	)
