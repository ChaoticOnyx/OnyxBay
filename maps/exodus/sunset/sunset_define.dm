
/datum/map/exodus/sunset
	name = "Sunset"
	full_name = "NSS Sunset"
	path = "exodus/sunset"

	station_levels = list(1,2,3)
	admin_levels = list(4)
	contact_levels = list(1,2,3,5)
	player_levels = list(1,2,3,5,6,7,8,9,10,11,12,13,14)
	sealed_levels = list(10)
	empty_levels = list(5)
	accessible_z_levels = list(
		"1" = 10,
		"2" = 10,
		"3" = 10,
		"5" = 30,
		"6" = 5,
		"7" = 5,
		"8" = 5,
		"9" = 5,
		"10" = 3,
		"11" = 5,
		"12" = 5,
		"13" = 3,
		"14" = 3
	)
	dynamic_z_levels = list(
		'sunset-1.dmm',
		'sunset-2.dmm',
		'sunset-3.dmm',
		// CC
		'sunset-4.dmm',
		'maps/null-space.dmm',
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

	station_name  = "NSS Sunset"
	station_short = "Sunset"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Pegasus"

/datum/map/exodus/sunset/perform_map_generation()
	new /datum/random_map/automata/cave_system(null, 1, 1, 1, 200, 200) // Create the mining Z-level.
	new /datum/random_map/noise/ore(null, 1, 1, 1, 64, 64)
	return 1
