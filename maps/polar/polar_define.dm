
/datum/map/polar
	name = "Polar"
	full_name = "Polar Colony"
	path = "polar"

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/supply/polar_drone,
		/datum/shuttle/autodock/multi/antag/rescue,
		/datum/shuttle/autodock/ferry/emergency/centcom,
		/datum/shuttle/autodock/ferry/administration,
		/datum/shuttle/autodock/multi/antag/syndicate,
		/datum/shuttle/autodock/multi/antag/elite_syndicate,
		/datum/shuttle/autodock/ferry/deathsquad,
		/datum/shuttle/autodock/multi/antag/merchant_polar,
		/datum/shuttle/autodock/multi/antag/skipjack,
	)
	station_levels = list(1,2,3,4)
	admin_levels = list(5)
	contact_levels = list(1,2,3,4)
	player_levels = list(1,2,3,4)
	sealed_levels = list(7)
	accessible_z_levels = list(
		"1" = 5,
		"2" = 5,
		"3" = 10,
		"4" = 15,
	)
	dynamic_z_levels = list(
		'polar-1.dmm',
		'polar-2.dmm',
		'polar-3.dmm',
		'polar-4.dmm',
		// CC
		'polar-5.dmm',
		'maps/null-frozen.dmm',
		'maps/derelicts/jungleplanet/jungle_planet.dmm'
	)

	station_name  = "Polar Colony"
	station_short = "Polar"
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

	base_floor_type = /turf/simulated/floor/natural/frozenground/cave
	base_floor_area = /area/polarplanet/street

/datum/map/polar/setup_map()
	. = ..()

	AddComponent(/datum/component/polar_weather)

/datum/map/polar/perform_map_generation()
	//1-z level
	new /datum/random_map/automata/cave_system(null, 1, 1, 1, 200, 200) // Create the mining Z-level.
	new /datum/random_map/noise/ore(null, 1, 1, 1, 255, 255)         // Create the mining ore distribution map.
	//2-z level
	new /datum/random_map/noise/ore(null, 1, 1, 2, 200, 200)         // Create the mining ore distribution map.
	return 1
