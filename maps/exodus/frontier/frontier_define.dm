
/datum/map/exodus/frontier
	name = "Frontier"
	full_name = "NSS Frontier"
	path = "exodus/frontier"

	station_levels = list(1)
	admin_levels = list()
	contact_levels = list(1)
	player_levels = list(1)
	sealed_levels = list()
	empty_levels = list()
	accessible_z_levels = list("1" = 10)
	base_turf_by_z = list("1" = /turf/simulated/floor/asteroid) // Moonbase
	dynamic_z_levels = list("1" = 'frontier-1.dmm')

	station_name  = "NSS Frontier"
	station_short = "Frontier"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Arcturus"