
/datum/map/entrepot
	name = "Entrepot"
	full_name = "NTS Entrepot-17"
	path = "entrepot"

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/emergency/centcom,
		/datum/shuttle/autodock/multi/antag/syndicate,
		/datum/shuttle/autodock/multi/antag/skipjack,
	)

	map_levels = list(
		new /datum/space_level/entrepot_1,
		new /datum/space_level/entrepot_2,
		new /datum/space_level/entrepot_3, // Exodus-shaped CentCom
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
		NETWORK_EXODUS,
		NETWORK_TELECOM,
		NETWORK_MASTER
	)

	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom
	)
