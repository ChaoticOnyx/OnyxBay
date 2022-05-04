
/datum/map/exodus
	name = "Exodus"
	full_name = "NSS Exodus"
	path = "exodus"

	lobby_icon = 'maps/exodus/exodus_lobby.dmi'

	load_legacy_saves = TRUE
	station_levels = list(1, 2)
	admin_levels = list(3)
	contact_levels = list(1,2,4,6)
	player_levels = list(1,2,4,5,6,7,8,9,10,11,12,13)
	sealed_levels = list(12)
	accessible_z_levels = list(
		"1" = 5,
		"2" = 5,
		"4" = 10,
		"5" = 15,
		"6" = 15,
		"7" = 30,
		"8" = 5,
		"9" = 5,
		"10" = 5,
		"11" = 5,
		"13" = 3,
		"14" = 5
	)
	dynamic_z_levels = list(
		'exodus-1.dmm',
		'exodus-2.dmm',
		// CC
		'exodus-3.dmm',
		'exodus-4.dmm',
		'exodus-5.dmm',
		'exodus-6.dmm',
		'maps/null-space.dmm',
		'maps/derelicts/snowasteroid.dmm',
		'maps/derelicts/original/derelict.dmm',
		'maps/derelicts/bearcat/bearcat-1.dmm',
		'maps/derelicts/bearcat/bearcat-2.dmm',
		'maps/derelicts/jungleplanet/jungle_planet.dmm',
		'maps/derelicts/old_restaurant/old_restaurant.dmm',
		'maps/derelicts/sensor_array/sensor_array.dmm'
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
