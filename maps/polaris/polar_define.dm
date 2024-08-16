
/datum/map/polar
	name = "Pathos-I"
	full_name = "Pathos-I"
	path = "polar"

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/supply/drone/polar,
		/datum/shuttle/autodock/multi/antag/rescue/polar,
		/datum/shuttle/autodock/ferry/emergency/centcom/polar,
		/datum/shuttle/autodock/ferry/administration/polar,
		/datum/shuttle/autodock/multi/antag/syndicate/polar,
		/datum/shuttle/autodock/multi/antag/elite_syndicate/polar,
		/datum/shuttle/autodock/ferry/deathsquad/polar,
		/datum/shuttle/autodock/multi/antag/merchant/polar,
		/datum/shuttle/autodock/multi/antag/skipjack/polar,
		/datum/shuttle/autodock/ferry/train
	)

	map_levels = list(
		new /datum/space_level/polar_1,
		new /datum/space_level/polar_2,
		new /datum/space_level/polar_3,
		new /datum/space_level/polar_4,
		new /datum/space_level/polar_5
	)

	station_name  = "Pathos-I"
	station_short = "Pathos-I"
	dock_name     = "Pathos-I - Landing Zone"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "Nanotrasen"
	company_short = "NT"
	system_name   = "Nyx"

	evac_controller_type = /datum/evacuation_controller/shuttle

	base_floor_type = /turf/simulated/floor/natural/frozenground/cave
	base_floor_area = /area/polarplanet/street

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

/datum/map/polar
	post_round_safe_areas = list (
		/area/polarplanet/centcom,
		/area/polarplanet/shuttle/escape/centcom,
		/area/polarplanet/shuttle/escape_pod1,
		/area/polarplanet/shuttle/escape_pod2,
		/area/polarplanet/shuttle/escape_pod3,
		/area/polarplanet/shuttle/escape_pod5,
		/area/polarplanet/shuttle/administration,
		/area/polarplanet/shuttle/specops/centcom,
	)
