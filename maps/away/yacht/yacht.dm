#include "yacht_areas.dm"

/datum/map_template/ruin/away_site/yacht
	name = "Yacht"
	id = "awaysite_yach"
	description = "Tiny movable ship with spiders."
	suffixes = list("yacht/yacht.dmm")
	cost = 0.5

/obj/effect/shuttle_landmark/nav_yacht/nav1
	name = "Small Yacht Navpoint #1"
	landmark_tag = "nav_yacht_1"

/obj/effect/shuttle_landmark/nav_yacht/nav2
	name = "Small Yacht Navpoint #2"
	landmark_tag = "nav_yacht_2"

/obj/effect/shuttle_landmark/nav_yacht/nav3
	name = "Small Yacht Navpoint #3"
	landmark_tag = "nav_yacht_3"

/obj/effect/shuttle_landmark/nav_yacht/nav4
	name = "Small Yacht Navpoint #4"
	landmark_tag = "nav_yacht_antag"
