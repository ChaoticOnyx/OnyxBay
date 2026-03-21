/datum/map/lager
	name = "Lager"
	full_name = "Lager"
	path = "Lager"

	map_levels = list(
		new /datum/space_level/lager_1,
		new /datum/space_level/lager_2,
		new /datum/space_level/lager_3
	)

	station_name  = "Lager"
	station_short = "Lager"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "USSR"
	company_short = "USSR"

	station_networks = list(
		NETWORK_CIVILIAN_EAST,
		NETWORK_CIVILIAN_WEST,
		NETWORK_COMMAND,
		NETWORK_ENGINE,
		NETWORK_ENGINEERING,
		NETWORK_ENGINEERING_OUTPOST,
		NETWORK_EXODUS,
		NETWORK_MAINTENANCE,
		NETWORK_MEDICAL,
		NETWORK_RESEARCH,
		NETWORK_RESEARCH_OUTPOST,
		NETWORK_ROBOTS,
		NETWORK_PRISON,
		NETWORK_SECURITY,
		NETWORK_ALARM_ATMOS,
		NETWORK_ALARM_CAMERA,
		NETWORK_ALARM_FIRE,
		NETWORK_ALARM_MOTION,
		NETWORK_ALARM_POWER,
		NETWORK_THUNDER,
		NETWORK_TELECOM,
		NETWORK_MASTER,
		NETWORK_APPARAT_VORON
	)
