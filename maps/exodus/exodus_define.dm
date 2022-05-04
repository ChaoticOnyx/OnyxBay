
/datum/map/exodus
	name = "Exodus"
	full_name = "NSS Exodus"
	path = "exodus"

	lobby_icon = 'maps/exodus/exodus_lobby.dmi'

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod1,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod2,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod3,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod5,
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
	load_legacy_saves = TRUE
	station_levels = list(1,2)
	admin_levels = list(4)
	contact_levels = list(1,2,4,6)
	player_levels = list(1,2,3,5,6,7,8,9,10,11,12,13,14,15,16)
	sealed_levels = list(12)
	accessible_z_levels = list(
		"1" = 5,
		"2" = 5,
		"3" = 10,
		"5" = 15,
		"6" = 30,
		"7" = 15,
		"8" = 5,
		"9" = 5,
		"10" = 5,
		"11" = 5,
		"13" = 3,
		"14" = 5,
		"15" = 3,
		"16" = 3
	)
	dynamic_z_levels = list(
		'exodus-1.dmm',
		'exodus-2.dmm',
		'exodus-3.dmm',
		// CC
		'exodus-4.dmm',
		'maps/telecomms.dmm',
		'maps/null-space.dmm',
		'maps/derelicts/construction_site.dmm',
		'maps/derelicts/snowasteroid.dmm',
		'maps/derelicts/original/derelict.dmm',
		'maps/derelicts/bearcat/bearcat-1.dmm',
		'maps/derelicts/bearcat/bearcat-2.dmm',
		'maps/derelicts/jungleplanet/jungle_planet.dmm',
		'maps/derelicts/old_restaurant/old_restaurant.dmm',
		'maps/derelicts/sensor_array/sensor_array.dmm',
		'maps/derelicts/science_ship/science_ship-1.dmm',
		'maps/derelicts/science_ship/science_ship-2.dmm'
	)

	station_name  = "NSS Exodus"
	station_short = "Exodus"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Nyx"

	shuttle_docked_message = "The scheduled Crew Transfer Shuttle to %Dock_name% has docked with the station. It will depart in approximately %ETD%"
	shuttle_leaving_dock = "The Crew Transfer Shuttle has left the station. Estimate %ETA% until the shuttle docks at %dock_name%."
	shuttle_called_message = "A crew transfer to %Dock_name% has been scheduled. The shuttle has been called. It will arrive in approximately %ETA%"
	shuttle_recall_message = "The scheduled crew transfer has been cancelled."

	evac_controller_type = /datum/evacuation_controller/shuttle

/datum/map/exodus/perform_map_generation()
	new /datum/random_map/automata/cave_system(null, 1, 1, 6, 255, 255) // Create the mining Z-level.
	new /datum/random_map/noise/ore(null, 1, 1, 6, 255, 255)         // Create the mining ore distribution map.
	return 1
