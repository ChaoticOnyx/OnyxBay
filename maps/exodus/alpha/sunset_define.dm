
/datum/map/exodus/sunset
	name = "Sunset"
	full_name = "NSS Sunset"
	path = "exodus/sunset"

	station_levels = list(1,2,3)
	admin_levels = list(4)
	contact_levels = list(1,2,3,5)
	player_levels = list(1,2,3,5,6,7)
	//sealed_levels = list(7)
	empty_levels = list(7)
	dynamic_z_levels = list("1" = 'sunset-1.dmm', "2" = 'sunset-2.dmm', "3" = 'sunset-3.dmm', "6" = 'sunset-4.dmm')
	accessible_z_levels = list("1" = 10, "2" = 10, "3" = 10, "5" = 10, "6" = 15, "7" = 60) //Percentage of chance to get on this or that Z level as you drift through space.

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