/datum/map/elpaso
	name = "Elpaso"
	full_name = "Town Of El Paso"
	path = "elpaso"

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/supply/drone,
		/datum/shuttle/autodock/ferry/emergency/centcom_paso,
		/datum/shuttle/autodock/multi/antag/syndicate_paso,
		/datum/shuttle/autodock/multi/antag/rescue_paso,
		/datum/shuttle/autodock/multi/antag/elite_syndicate,
		/datum/shuttle/autodock/ferry/deathsquad_paso,
		/datum/shuttle/autodock/multi/antag/merchant,
		/datum/shuttle/autodock/multi/antag/skipjack_paso
	)

	map_levels = list(
		new /datum/space_level/elpaso_1,
		new /datum/space_level/elpaso_2,
		new /datum/space_level/elpaso_3,
		new /datum/space_level/elpaso_4,
		new /datum/space_level/null_space,
		new /datum/space_level/telecomms,
		new /datum/space_level/construction_site,
	)

	station_name  = "Town Of El Paso"
	station_short = "El Paso"
	dock_name     = "Colony Ship"
	boss_name     = "Train Station"
	boss_short    = "Centcomm"
	company_name  = "Nanotrasen"
	company_short = "NT"
	system_name   = "New Gibson"

	evac_controller_type = /datum/evacuation_controller/shuttle

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
		NETWORK_MINE,
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
		NETWORK_MASTER
	)

	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
		/area/shuttle/escape_pod1,
		/area/shuttle/escape_pod2,
		/area/shuttle/escape_pod3,
		/area/shuttle/escape_pod5,
		/area/shuttle/transport/centcom,
		/area/shuttle/administration/,
		/area/shuttle/specops/centcom,
	)
