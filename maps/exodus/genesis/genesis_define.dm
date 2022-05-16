/datum/map/exodus/genesis
	name = "Genesis"
	full_name = "NSS Genesis"
	path = "exodus/genesis"
	legacy_mode = TRUE

	dynamic_z_levels = list(
		'genesis-1.dmm',
		'genesis-2.dmm',
		// CC
		'genesis-3.dmm',
		'genesis-4.dmm',
		'maps/telecomms.dmm'
	)

	station_name  = "NSS Genesis"
	station_short = "Genesis"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Nyx"
	
/datum/map/exodus/genesis/perform_map_generation()
	new /datum/random_map/automata/cave_system(null, 1, 1, 4, 255, 255) // Create the mining Z-level.
	new /datum/random_map/noise/ore(null, 1, 1, 4, 255, 255)         // Create the mining ore distribution map.
	return 1
