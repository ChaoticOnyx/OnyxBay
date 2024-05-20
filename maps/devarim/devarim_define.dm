/datum/map/devarim
	name = "Devarim"
	full_name = "NCS Devarim"
	path = "example"
	station_short = "Ex"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "Nanotrasen"
	company_short = "NT"
	system_name   = "Nyx"

	overmap_type = /obj/structure/overmap/example_ship

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/example
	)

	map_levels = list(
		new /datum/space_level/devarim_1,
		new /datum/space_level/devarim_2,
	)

	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
	)

	allowed_spawns = list("Arrivals Shuttle")
	can_be_voted = FALSE

	welcome_sound = 'sound/signals/start2.ogg'
