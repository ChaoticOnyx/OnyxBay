
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
	empty_levels = list(6)

	dynamic_z_levels = list(
		'exodus-1.dmm',
		'exodus-2.dmm',
		'exodus-3.dmm',
		'exodus-4.dmm',
		'exodus-5.dmm',
		'exodus-6.dmm'
	)

	derelict_levels = list(
		'derelicts/snowasteroid.dmm' = 80,
		'derelicts/original/derelict.dmm' = 70,
		list('derelicts/bearcat/bearcat-1.dmm', 'derelicts/bearcat/bearcat-2.dmm') = 75,
		'derelicts/jungleplanet/jungle_planet.dmm' = 80,
		'derelicts/old_restaurant/old_restaurant.dmm' = 75
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
