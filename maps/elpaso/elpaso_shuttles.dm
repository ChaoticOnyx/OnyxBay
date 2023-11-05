// emergency

/datum/shuttle/autodock/ferry/emergency/centcom_paso
	name = "Escape"
	location = 1
	warmup_time = 10
	shuttle_area = /area/elpaso/shuttle/escape/centcom
	dock_target = "escape_shuttle"
	landmark_transition = "nav_escape_transition"
	waypoint_offsite = "nav_centcom_dock"
	waypoint_station = "nav_escape_dock"

/obj/effect/shuttle_landmark/escape/centcom_paso
	name = "Centcom"
	landmark_tag = "nav_centcom_dock"
	docking_controller = "centcom_dock"
	autoset = 0

/obj/effect/shuttle_landmark/escape/internim_paso
	name = "In transit"
	landmark_tag = "nav_escape_transition"
	autoset = 1

/obj/effect/shuttle_landmark/escape/station_paso
	name = "Station"
	landmark_tag = "nav_escape_dock"
	docking_controller = "escape_dock_north_airlock;escape_dock_south_airlock"
	autoset = 1

// Syndi

/datum/shuttle/autodock/multi/antag/syndicate_paso
	name = "Syndicate"
	warmup_time = 10
	destination_tags = list(
		"nav_merc_start",
		"nav_merc_dock",
		"nav_merc_coupole",
		"nav_merc_minage",
		"nav_merc_residentiel",
		"nav_merc_south",
		"nav_merc_north",
		)
	shuttle_area = /area/elpaso/syndicate_station/start
	dock_target = "merc_shuttle"
	current_location = "nav_merc_start"
	landmark_transition = "nav_merc_transition"
	home_waypoint = "nav_merc_start"
	cloaked = 0
	move_time = 120
	arrival_announce = /datum/announce/nukeops_arrival
	departure_announce = /datum/announce/nukeops_departure

/obj/effect/shuttle_landmark/syndi/start_paso
	name = "Syndicate Base"
	landmark_tag = "nav_merc_start"
	docking_controller = "merc_base"

/obj/effect/shuttle_landmark/syndi/internim_paso
	name = "In transit"
	landmark_tag = "nav_merc_transition"
	autoset = 1

/obj/effect/shuttle_landmark/syndi/north_paso
	name = "North"
	landmark_tag = "nav_merc_north"
	autoset = 1

/obj/effect/shuttle_landmark/syndi/south_paso
	name = "South"
	landmark_tag = "nav_merc_south"
	autoset = 1

//Emergency Response Team Shuttle

/datum/shuttle/autodock/multi/antag/rescue_paso
	name = "Rescue"
	warmup_time = 10
	destination_tags = list(
		"nav_rescue_start",
		"nav_rescue_station",
		"nav_rescue_dock",
		"nav_rescue_coupole",
		"nav_rescue_minage",
		"nav_rescue_residentiel",
		"nav_rescue_southeast",
		"nav_rescue_northeast",
		)
	shuttle_area = /area/elpaso/rescue_base/start
	dock_target = "rescue_shuttle"
	current_location = "nav_rescue_start"
	landmark_transition = "nav_rescue_transition"
	home_waypoint = "nav_rescue_start"
	move_time = 120

/obj/effect/shuttle_landmark/rescue/start_paso
	name = "Rescue Base"
	landmark_tag = "nav_rescue_start"
	docking_controller = "rescue_base"
	base_area = /area/rescue_base/base
	base_turf = /turf/simulated/open

/obj/effect/shuttle_landmark/rescue/internim_paso
	name = "In transit"
	landmark_tag = "nav_rescue_transition"
	autoset = 1

/obj/effect/shuttle_landmark/rescue/station_paso
	name = "Station Dock"
	landmark_tag = "nav_rescue_station"
	autoset = 1
	docking_controller = "rescue_shuttle_dock_airlock"

// deathsquad

/datum/shuttle/autodock/ferry/deathsquad_paso
	name = "Deathsquad"
	warmup_time = 10
	location = 0
	shuttle_area = /area/elpaso/shuttle/deathsquad/centcom
	dock_target = "deathsquad_shuttle_port"
	landmark_transition = "nav_deathsquad_transition"
	waypoint_station = "nav_deathsquad_centcom"
	waypoint_offsite = "nav_deathsquad_station"
	move_time = 120

/obj/effect/shuttle_landmark/deathsquad/centcom_paso
	name = "Centcom"
	landmark_tag = "nav_deathsquad_centcom"
	docking_controller = "deathsquad_centcom_dock"
	autoset = 0

/obj/effect/shuttle_landmark/deathsquad/internim_paso
	name = "In transit"
	landmark_tag = "nav_deathsquad_transition"
	autoset = 1

/obj/effect/shuttle_landmark/deathsquad/station_paso
	name = "Station"
	landmark_tag = "nav_deathsquad_station"
	docking_controller = "deathsquad_shuttle_dock_airlock"
	autoset = 1

//Skipjack

/datum/shuttle/autodock/multi/antag/skipjack_paso
	name = "Skipjack"
	warmup_time = 10
	destination_tags = list(
		"nav_skipjack_start",
		"nav_skipjack_nw",
		"nav_skipjack_sw",
		"nav_skipjack_se",
		"nav_skipjack_ne",
		)
	shuttle_area = /area/skipjack_station/start
	dock_target = "skipjack_shuttle"
	current_location = "nav_skipjack_start"
	landmark_transition = "nav_skipjack_transition"
	home_waypoint = "nav_skipjack_start"
	cloaked = 1
	move_time = 120
	arrival_announce = /datum/announce/skipjack_arrival
	departure_announce = /datum/announce/skipjack_departure

/obj/effect/shuttle_landmark/skipjack/start_paso
	name = "Raider Base"
	landmark_tag = "nav_skipjack_start"
	docking_controller = "skipjack_base"

/obj/effect/shuttle_landmark/skipjack/internim_paso
	name = "In transit"
	landmark_tag = "nav_skipjack_transition"
	autoset = 1

/obj/effect/shuttle_landmark/skipjack/northwest_paso
	name = "North West"
	landmark_tag = "nav_skipjack_nw"
	autoset = 1

/obj/effect/shuttle_landmark/skipjack/southwest
	name = "South West"
	landmark_tag = "nav_skipjack_sw"
	autoset = 1

/obj/effect/shuttle_landmark/skipjack/southeast_paso
	name = "South East"
	landmark_tag = "nav_skipjack_se"
	autoset = 1

/obj/effect/shuttle_landmark/skipjack/northeast
	name = "North East"
	landmark_tag = "nav_skipjack_ne"
	autoset = 1
