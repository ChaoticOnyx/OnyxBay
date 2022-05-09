// /obj/effect/shuttle_landmark/train/evac/station
// 	name = "Station"
// 	landmark_tag = "nav_train_evac_station"
// 	autoset = 0
// 	base_area =

// /obj/effect/shuttle_landmark/train/evac/tcom
// 	name = "TCOM"
// 	landmark_tag = "nav_train_evac_tcom"
// 	autoset = 1

// Cargo shuttle

/datum/shuttle/autodock/ferry/supply/polar_drone
	name = "Supply"
	location = 1
	warmup_time = 10
	shuttle_area = /area/polarplanet/supply/dock
	dock_target = "supply_shuttle"
	waypoint_offsite = "nav_cargo_start"
	waypoint_station = "nav_cargo_station"

// Emergency

/datum/shuttle/autodock/ferry/emergency/centcom
	name = "Escape"
	location = 1
	warmup_time = 10
	shuttle_area = /area/shuttle/escape/centcom
	dock_target = "escape_shuttle"
	landmark_transition = "nav_escape_transition"
	waypoint_offsite = "nav_centcom_dock"
	waypoint_station = "nav_escape_dock"

//Merchant

/datum/shuttle/autodock/multi/antag/merchant_polar
	name = "Merchant"
	warmup_time = 10
	destination_tags = list(
		"nav_merchant_start",
		"nav_merchant_shop"
	)

	shuttle_area = /area/polarplanet/shuttle/merchant/home
	landmark_transition = "nav_merchant_transition"
	current_location = "nav_merchant_start"
	dock_target = "merchant_ship_dock"
	home_waypoint = "nav_merchant_start"
	cloaked = 1
	move_time = 60
	announcer = "Planet Sensor Array"
	arrival_message = "Attention, you have an unarmed cargo vessel, which appears to be a merchant ship, approaching the surface."
