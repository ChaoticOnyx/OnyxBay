
/datum/map/exodus/sunset
	name = "Sunset"
	full_name = "NSS Sunset"
	path = "exodus/sunset"

	station_levels = list(1,2,3)
	admin_levels = list(4)
	contact_levels = list(1,2,3,4)
	player_levels = list(1,2,3,4)
	sealed_levels = list(4)
	dynamic_z_levels = list(
		'sunset-1.dmm',
		'sunset-2.dmm',
		'sunset-3.dmm',
		'sunset-4.dmm'
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
