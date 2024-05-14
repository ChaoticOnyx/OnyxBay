//Actually pods

/datum/shuttle/autodock/ferry/escape_pod/escape_pod1
	shuttle_area = /area/shuttle/escape_pod1/station
	number = 1
/obj/effect/shuttle_landmark/escape_pod/start/pod1
	number = 1
/obj/effect/shuttle_landmark/escape_pod/out/pod1
	number = 1
/obj/effect/shuttle_landmark/escape_pod/transit/pod1
	number = 1

/obj/effect/shuttle_landmark/transport/start
	name = "Centcomm"
	landmark_tag = "nav_transport_start"
	docking_controller = "transport_centcom_dock"
	autoset = 0

/obj/effect/shuttle_landmark/transport/internim
	name = "In transit"
	landmark_tag = "nav_transport_transition"
	autoset = 1

/obj/effect/shuttle_landmark/transport/station
	name = "To station"
	landmark_tag = "nav_transport_station"
	docking_controller = "transport_shuttle_dock_airlock"
	autoset = 1

//Cargo shuttle

/datum/shuttle/autodock/ferry/supply/drone
	name = "Supply"
	location = 1
	warmup_time = 10
	shuttle_area = /area/supply/dock
	dock_target = "supply_shuttle"
	waypoint_offsite = "nav_cargo_start"
	waypoint_station = "nav_cargo_station"

/obj/effect/shuttle_landmark/supply/centcom
	name = "Centcom"
	landmark_tag = "nav_cargo_start"
	autoset = 0

/obj/effect/shuttle_landmark/supply/station
	name = "Dock Station"
	landmark_tag = "nav_cargo_station"
	docking_controller = "cargo_bay"
	autoset = 1

//Engineer Shuttle

/datum/shuttle/autodock/ferry/engie
	name = "Engineering"
	warmup_time = 10
	move_time = 10
	location = 0
	shuttle_area = /area/shuttle/constructionsite
	dock_target = "engineering_shuttle"
	waypoint_station = "nav_engie_station"
	waypoint_offsite = "nav_engie_outpost"
	landmark_transition = "nav_engie_transition"

/obj/effect/shuttle_landmark/engie/station
	name = "Station"
	landmark_tag = "nav_engie_station"
	docking_controller = "edock_airlock"
	autoset = 0

/obj/effect/shuttle_landmark/engie/asteroid
	name = "Asteroid Outpost"
	landmark_tag = "nav_engie_outpost"
	docking_controller = "engineering_dock_airlock"
	autoset = 1

/obj/effect/shuttle_landmark/engie/internim
	name = "In transit"
	landmark_tag = "nav_engie_transition"
	autoset = 1

//Emergency Response Team Shuttle

/datum/shuttle/autodock/multi/antag/rescue
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
	shuttle_area = /area/rescue_base/start
	dock_target = "rescue_shuttle"
	current_location = "nav_rescue_start"
	landmark_transition = "nav_rescue_transition"
	home_waypoint = "nav_rescue_start"
	move_time = 120

/obj/effect/shuttle_landmark/rescue/start
	name = "Rescue Base"
	landmark_tag = "nav_rescue_start"
	docking_controller = "rescue_base"
	base_area = /area/rescue_base/base
	base_turf = /turf/simulated/open

/obj/effect/shuttle_landmark/rescue/internim
	name = "In transit"
	landmark_tag = "nav_rescue_transition"
	autoset = 1

/obj/effect/shuttle_landmark/rescue/station
	name = "Station Dock"
	landmark_tag = "nav_rescue_station"
	autoset = 1
	docking_controller = "rescue_shuttle_dock_airlock"

/obj/effect/shuttle_landmark/rescue/dock
	name = "North West"
	landmark_tag = "nav_rescue_dock"
	autoset = 1

/obj/effect/shuttle_landmark/rescue/northeast
	name = "North East"
	landmark_tag = "nav_rescue_northeast"
	autoset = 1

/obj/effect/shuttle_landmark/rescue/coupole
	name = "South"
	landmark_tag = "nav_rescue_coupole"
	autoset = 1

/obj/effect/shuttle_landmark/rescue/minage
	name = "South West"
	landmark_tag = "nav_rescue_minage"
	autoset = 1

/obj/effect/shuttle_landmark/rescue/residentiel
	name = "North"
	landmark_tag = "nav_rescue_residentiel"
	autoset = 1

/obj/effect/shuttle_landmark/rescue/southeast
	name = "South East"
	landmark_tag = "nav_rescue_southeast"
	autoset = 1

// emergency

/datum/shuttle/autodock/ferry/emergency/centcom
	name = "Escape"
	location = 1
	warmup_time = 10
	shuttle_area = /area/shuttle/escape/centcom
	dock_target = "escape_shuttle"
	landmark_transition = "nav_escape_transition"
	waypoint_offsite = "nav_centcom_dock"
	waypoint_station = "nav_escape_dock"

/obj/effect/shuttle_landmark/escape/centcom
	name = "Centcom"
	landmark_tag = "nav_centcom_dock"
	docking_controller = "centcom_dock"
	autoset = 0

/obj/effect/shuttle_landmark/escape/internim
	name = "In transit"
	landmark_tag = "nav_escape_transition"
	autoset = 1

/obj/effect/shuttle_landmark/escape/station
	name = "Station"
	landmark_tag = "nav_escape_dock"
	docking_controller = "escape_dock"
	autoset = 1

// Administration

/datum/shuttle/autodock/ferry/administration
	name = "Administration"
	location = 1
	warmup_time = 10
	shuttle_area = /area/shuttle/administration/centcom
	dock_target = "admin_shuttle"
	landmark_transition = "nav_admin_transition"
	waypoint_offsite = "nav_admin_centcom_dock"
	waypoint_station = "nav_admin_station_dock"

/obj/effect/shuttle_landmark/administration/centcom
	name = "Centcom"
	landmark_tag = "nav_admin_centcom_dock"
	docking_controller = "admin_shuttle_centcom_dock"
	autoset = 0

/obj/effect/shuttle_landmark/administration/internim
	name = "In transit"
	landmark_tag = "nav_admin_transition"
	autoset = 1

/obj/effect/shuttle_landmark/administration/station
	name = "Station"
	landmark_tag = "nav_admin_station_dock"
	docking_controller = "admin_shuttle_dock_airlock"
	autoset = 1

// deathsquad

/datum/shuttle/autodock/ferry/deathsquad
	name = "Deathsquad"
	warmup_time = 10
	location = 0
	shuttle_area = /area/shuttle/deathsquad/centcom
	dock_target = "deathsquad_shuttle_port"
	landmark_transition = "nav_deathsquad_transition"
	waypoint_station = "nav_deathsquad_centcom"
	waypoint_offsite = "nav_deathsquad_station"
	move_time = 20

/obj/effect/shuttle_landmark/deathsquad/centcom
	name = "Centcom"
	landmark_tag = "nav_deathsquad_centcom"
	docking_controller = "deathsquad_centcom_dock"
	autoset = 0

/obj/effect/shuttle_landmark/deathsquad/internim
	name = "In transit"
	landmark_tag = "nav_deathsquad_transition"
	autoset = 1

/obj/effect/shuttle_landmark/deathsquad/station
	name = "Station"
	landmark_tag = "nav_deathsquad_station"
	docking_controller = "deathsquad_shuttle_dock_airlock"
	autoset = 1

//Merchant

/datum/shuttle/autodock/multi/antag/merchant
	name = "Merchant"
	warmup_time = 10
	destination_tags = list(
		"nav_merchant_start",
		"nav_merchant_out",
		"nav_merchant_shop",
		"nav_merchant_space",
		"nav_merchant_outpost"
		)
	shuttle_area = /area/shuttle/merchant/home
	landmark_transition = "nav_merchant_transition"
	current_location = "nav_merchant_start"
	dock_target = "merchant_ship_dock"
	home_waypoint = "nav_merchant_start"
	cloaked = 1
	move_time = 60
	arrival_announce = /datum/announce/merchants_arrival

/obj/effect/shuttle_landmark/merchant/start
	name = "Merchant Base"
	landmark_tag = "nav_merchant_start"
	docking_controller = "merchant_station_dock"
	autoset = 0

/obj/effect/shuttle_landmark/merchant/internim
	name = "In transit"
	landmark_tag = "nav_merchant_transition"
	autoset = 1

/obj/effect/shuttle_landmark/merchant/out
	name = "Station Ghetto Dock"
	landmark_tag = "nav_merchant_out"
	docking_controller = "merchant_shuttle_station_dock"
	autoset = 1

/obj/effect/shuttle_landmark/merchant/shop
	name = "Station Docking Bay"
	landmark_tag = "nav_merchant_shop"
	docking_controller = "merchant_shuttle_station_shop"
	autoset = 1

/obj/effect/shuttle_landmark/merchant/space
	name = "Station North East"
	landmark_tag = "nav_merchant_space"
	autoset = 1

/obj/effect/shuttle_landmark/merchant/outpost
	name = "Outpost North East"
	landmark_tag = "nav_merchant_outpost"
	autoset = 1
