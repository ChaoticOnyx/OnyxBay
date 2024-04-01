
/datum/map/entrepot
	name = "Entrepot"
	full_name = "NTS Entrepot-17"
	path = "entrepot"

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod1,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod2,
		/datum/shuttle/autodock/ferry/supply/drone,
		/datum/shuttle/autodock/ferry/elevator,
		/datum/shuttle/autodock/multi/antag/mining,
		/datum/shuttle/autodock/ferry/research,
		/datum/shuttle/autodock/ferry/engie,
		/datum/shuttle/autodock/ferry/mining,
		/datum/shuttle/autodock/multi/antag/rescue,
		/datum/shuttle/autodock/ferry/emergency/centcom,
		/datum/shuttle/autodock/ferry/administration,
		/datum/shuttle/autodock/multi/antag/syndicate,
		/datum/shuttle/autodock/multi/antag/elite_syndicate,
		/datum/shuttle/autodock/ferry/deathsquad,
		/datum/shuttle/autodock/multi/antag/merchant,
		/datum/shuttle/autodock/multi/antag/skipjack,
	)

	map_levels = list(
		new /datum/space_level/entrepot_1, // Basement
		new /datum/space_level/entrepot_2, // Ground level
		new /datum/space_level/entrepot_3, // 2F
		new /datum/space_level/entrepot_4, // Exodus-shaped CentCom
		new /datum/space_level/null_space,
		new /datum/space_level/telecomms,
		new /datum/space_level/derelict
	)

	station_name  = "NTS Entrepot-17"
	station_short = "Entrepot-17"
	dock_name     = "NSS Exodus"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "Nanotrasen"
	company_short = "NT"
	system_name   = "Nyx"

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
		/area/shuttle/transport/centcom,
		/area/shuttle/administration/,
		/area/shuttle/specops/centcom,
	)
