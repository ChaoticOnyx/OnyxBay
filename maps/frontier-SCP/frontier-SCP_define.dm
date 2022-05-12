#include "frontier-SCP_areas.dm"

/datum/map/demeter
	name = "Demeter"
	full_name = "RnCC Demeter"
	path = "frontier-SCP"

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod1,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod2,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod3,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod5,
		/datum/shuttle/autodock/ferry/supply/drone,
		/datum/shuttle/autodock/ferry/elevator,
		/datum/shuttle/autodock/multi/antag/mining,
		/datum/shuttle/autodock/ferry/research,
		/datum/shuttle/autodock/ferry/engie,
		/datum/shuttle/autodock/ferry/mining,
		/datum/shuttle/autodock/multi/antag/rescue,
		/datum/shuttle/autodock/ferry/emergency/centcom,
		/datum/shuttle/autodock/ferry/administration,
		/datum/shuttle/autodock/multi/antag/syndicate,
		/datum/shuttle/autodock/multi/antag/elite_syndicate,
		/datum/shuttle/autodock/ferry/deathsquad,
		/datum/shuttle/autodock/multi/antag/merchant,
		/datum/shuttle/autodock/multi/antag/skipjack,
	)

	map_levels = list(
		new /datum/space_level/frontier_SCP_1,
		new /datum/space_level/frontier_SCP_2,
		new /datum/space_level/null_space
	)

	station_name  = "RnCC Demeter"
	station_short = "Demeter"
	dock_name     = "Overwatch HQ"
	boss_name     = "Overwatch"
	boss_short    = "Overwatch"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Arcturus"

	emergency_shuttle_docked_message = "The Emergency Request for RnCC Demeter Was successfully approved Evacuation is mandatory for all Foundation personnel. Shuttles will depart in %ETD%."
	emergency_shuttle_leaving_dock = "The Emergency Shuttles is departing from RnCC Demeter and will arrive in %ETA%. Please cooperate with Responders upon arrival."
	emergency_shuttle_called_message = "An Emergency Request has been ordered for this facility. All authorized evacuees must proceed to the outbound Evacuation Zone within %ETA%."
	emergency_shuttle_recall_message = "An Emergency Request has been declined by Overwatch. Return to your post."

	evac_controller_type = /datum/evacuation_controller/shuttle
