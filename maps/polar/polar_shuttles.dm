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

/datum/shuttle/autodock/ferry/supply/drone/polar
	shuttle_area = /area/polarplanet/supply/dock

// Emergency

/datum/shuttle/autodock/ferry/emergency/centcom/polar
	shuttle_area = /area/polarplanet/shuttle/escape/centcom

//Merchant

/datum/shuttle/autodock/multi/antag/merchant/polar
	destination_tags = list(
		"nav_merchant_start",
		"nav_merchant_shop"
	)

	shuttle_area = /area/polarplanet/shuttle/merchant/home

// Emergency Response Team Shuttle

/datum/shuttle/autodock/multi/antag/rescue/polar
	destination_tags = list(
		"nav_rescue_start",
		"nav_rescue_station",
		"nav_rescue_dock",
		"nav_rescue_southeast",
		"nav_rescue_northeast",
	)
	shuttle_area = /area/polarplanet/rescue_base/start

// Administration

/datum/shuttle/autodock/ferry/administration/polar
	shuttle_area = /area/polarplanet/shuttle/administration/centcom

// Syndi

/datum/shuttle/autodock/multi/antag/syndicate/polar
	destination_tags = list(
		"nav_merc_start",
		"nav_merc_dock",
		"nav_merc_coupole",
		"nav_merc_minage",
		"nav_merc_residentiel",
	)
	shuttle_area = /area/polarplanet/syndicate_station/start

// Elite syndi

/datum/shuttle/autodock/multi/antag/elite_syndicate/polar
	shuttle_area = /area/polarplanet/shuttle/syndicate_elite/mothership

// Deathsquad
/datum/shuttle/autodock/ferry/deathsquad/polar
	shuttle_area = /area/polarplanet/shuttle/deathsquad/centcom

//Skipjack

/datum/shuttle/autodock/multi/antag/skipjack/polar
	shuttle_area = /area/polarplanet/skipjack_station/start
