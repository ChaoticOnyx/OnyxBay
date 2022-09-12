
/datum/map/example
	name = "Example"
	full_name = "The Example"
	path = "example"

	lobby_icon = 'maps/example/example_lobby.dmi'

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/example
	)

	map_levels = list(
		new /datum/space_level/example_1,
		new /datum/space_level/example_2,
		new /datum/space_level/example_3,
		new /datum/space_level/example_4
	)

	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
		/area/shuttle/escape_pod1,
		/area/shuttle/escape_pod2,
		/area/shuttle/escape_pod3,
		/area/shuttle/escape_pod5,
	)

	allowed_spawns = list("Arrivals Shuttle")

	shuttle_docked_message = "The shuttle has docked."
	shuttle_leaving_dock = "The shuttle has departed from home dock."
	shuttle_called_message = "A scheduled transfer shuttle has been sent."
	shuttle_recall_message = "The shuttle has been recalled"
	emergency_shuttle_docked_message = "The emergency escape shuttle has docked."
	emergency_shuttle_leaving_dock = "The emergency escape shuttle has departed from %dock_name%."
	emergency_shuttle_called_message = "An emergency escape shuttle has been sent."
	emergency_shuttle_recall_message = "The emergency shuttle has been recalled"
