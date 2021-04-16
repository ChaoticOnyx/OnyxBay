
/datum/map/exodus/frontier
	name = "Frontier"
	full_name = "NSS Frontier"
	path = "exodus/frontier"

	station_levels = list(1)
	admin_levels = list(3)
	contact_levels = list(1,4)
	player_levels = list(1,4,5,7)
	//sealed_levels = list(2)
	empty_levels = list()
	accessible_z_levels = list("1" = 10, "4" = 10, "5" = 15, "7" = 60)
	//base_turf_by_z = list("1" = /turf/simulated/floor/asteroid) // Moonbase
	dynamic_z_levels = list("1" = 'frontier-1.dmm',"3" = 'frontier-3.dmm')

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
