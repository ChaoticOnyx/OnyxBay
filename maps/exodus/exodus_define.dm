
/datum/map/exodus
	name = "Exodus"
	full_name = "NSS Exodus"
	path = "exodus"

	lobby_icon = 'maps/exodus/exodus_lobby.dmi'

	load_legacy_saves = TRUE
	station_levels = list(1, 2)
	admin_levels = list(3)
	contact_levels = list(1,2,4,6)
	player_levels = list(1,2,4,5,6,7,8,9,10,11,12)
	sealed_levels = list(12)
	empty_levels = list(6)
	accessible_z_levels = list("1" = 5, "2" = 5, "4" = 10, "5" = 15, "6" = 15, "7" = 30, "8" = 5, "9" = 5, "10" = 5, "11" = 5)
	dynamic_z_levels = list("1" = 'exodus-1.dmm', "2" = 'exodus-2.dmm', "3" = 'exodus-3.dmm', "6" = 'exodus-6.dmm')

	station_name  = "NSS Exodus"
	station_short = "Exodus"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Nyx"

	shuttle_docked_message_l = L10N_ANNOUNCE_SHUTTLE_DOCKED_EXODUS
	shuttle_leaving_dock_l = L10N_ANNOUNCE_SHUTTLE_LEAVING_DOCK_EXODUS
	shuttle_called_message_l = L10N_ANNOUNCE_SHUTTLE_CALLED_EXODUS
	shuttle_recall_message_l = L10N_ANNOUNCE_SHUTTLE_RECALL_EXODUS

	evac_controller_type = /datum/evacuation_controller/shuttle

/datum/map/exodus/perform_map_generation()
	new /datum/random_map/automata/cave_system(null, 1, 1, 6, 255, 255) // Create the mining Z-level.
	new /datum/random_map/noise/ore(null, 1, 1, 6, 255, 255)         // Create the mining ore distribution map.
	return 1
