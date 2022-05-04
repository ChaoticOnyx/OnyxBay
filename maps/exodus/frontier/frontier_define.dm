
/datum/map/exodus/frontier
	name = "Frontier"
	full_name = "NSS Frontier"
	path = "exodus/frontier"

	station_levels = list(1)
	admin_levels = list(2)
	contact_levels = list(1,4)
	player_levels = list(1,3,4,5,6,7,8,9,10,11,12)
	sealed_levels = list(8)
	empty_levels = list(3)
	accessible_z_levels = list(
		"1" = 10,
		"3" = 15,
		"4" = 30,
		"5" = 15,
		"6" = 5,
		"7" = 5,
		"8" = 5,
		"9" = 5,
		"10" = 3,
		"11" = 3,
		"12" = 3
	)

	dynamic_z_levels = list(
		'frontier-1.dmm',
		// CC
		'frontier-2.dmm',
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

	station_name  = "NSS Frontier"
	station_short = "Frontier"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Arcturus"

/datum/map/exodus/frontier/perform_map_generation()
	new /datum/random_map/automata/cave_system(null, 1, 1, 1, 300, 300) // Create the mining Z-level.
	new /datum/random_map/noise/ore(null, 1, 1, 1, 300, 300)         // Create the mining ore distribution map.
	return 1
