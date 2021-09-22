#include "frontier-SCP_areas.dm"

/datum/map/exodus/Demeter
	name = "Demeter"
	full_name = "RnCC Demeter"
	path = "exodus/frontier-SCP"

	station_levels = list(1)
	admin_levels = list(3)
	contact_levels = list(1,4)
	player_levels = list(1,4,5,7)
	//sealed_levels = list(2)
	empty_levels = list()
	accessible_z_levels = list("1" = 10, "4" = 10, "5" = 15, "7" = 60)
	//base_turf_by_z = list("1" = /turf/simulated/floor/asteroid) // Moonbase
	dynamic_z_levels = list("1" = 'frontier-SCP-1.dmm',"3" = 'frontier-SCP-3.dmm')

	station_name  = "RnCC Demeter"
	station_short = "Demeter"
	dock_name     = "Overwatch HQ"
	boss_name     = "Overwatch"
	boss_short    = "Overwatch"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Arcturus"

	emergency_shuttle_docked_message = "The Emergency Shuttle to %Dock_name% has docked with the station. Evacuation is mandatory for all Foundation personnel. It will depart in %ETD%."
	emergency_shuttle_leaving_dock = "The Emergency Shuttle is departing from RnCC Demeter and will arrive in %ETA%. Please cooperate with Responders upon arrival."
	emergency_shuttle_called_message = "An emergency evacuation has been ordered for this facility. All authorized evacuees must proceed to the outbound Shuttle Zone within %ETA%."
	emergency_shuttle_recall_message = "The emergency evacuation has been cancelled. Return to your post."

/datum/map/exodus/Demeter/perform_map_generation()
	new /datum/random_map/automata/cave_system(null, 1, 1, 1, 300, 300) // Create the mining Z-level.
	new /datum/random_map/noise/ore(null, 1, 1, 1, 300, 300)         // Create the mining ore distribution map.
	return 1
