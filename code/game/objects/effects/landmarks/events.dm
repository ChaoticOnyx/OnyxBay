/obj/effect/landmark/event
	icon_state = "landmark_event"
	should_be_added = TRUE

/obj/effect/landmark/event/other
	should_be_added = TRUE

/obj/effect/landmark/event/other/lightsout
	name = "lightsout"

/obj/effect/landmark/event/other/tripai
	name = "Triple AI"
	icon_state = "landmark_ai"

/obj/effect/landmark/event/other/drones
	name = "Drone Swarm"
	icon_state = "landmark_drone"

/obj/effect/landmark/event/other/carps
	name = "Carp Pack"
	icon_state = "landmark_carp"

/obj/effect/landmark/event/other/holodeck/atmos
	name = "Atmospheric Test Start"

/obj/effect/landmark/event/other/holodeck/carps
	name = "Holocarp Spawn"

/obj/effect/landmark/event/other/holodeck/randcarps
	name ="Holocarp Spawn Random"

// Centcom teleports
/obj/effect/landmark/event/centcom/enter
	name = "Marauder Entry"

/obj/effect/landmark/event/centcom/exit
	name = "Marauder Exit"

// Nuke
/obj/effect/landmark/event/nuke
	icon_state = "landmark_nuke"

/obj/effect/landmark/event/nuke/bomb
	name = "Nuclear Bomb"

/obj/effect/landmark/event/nuke/code
	name = "Nuclear Code"

// Bluespace rift
/obj/effect/landmark/event/rift
	delete_after = TRUE
	should_be_added = FALSE

/obj/effect/landmark/event/rift/spawn_point
	name = "bluespacerift"

/obj/effect/landmark/event/rift/spawn_point/New()
	GLOB.endgame_safespawns += loc
	return ..()

/obj/effect/landmark/event/rift/exit
	name = "endgame_exit"

/obj/effect/landmark/event/rift/exit/New()
	GLOB.endgame_exits += loc
	return ..()

// Admin prison
/obj/effect/landmark/event/prison
	delete_after = TRUE
	should_be_added = FALSE

/obj/effect/landmark/event/prison/prisioner
	name = "prisonwarp"

/obj/effect/landmark/event/prison/prisioner/New()
	GLOB.prisonwarp += loc
	return ..()

/obj/effect/landmark/event/prison/security
	name = "prisonsecuritywarp"

/obj/effect/landmark/event/prison/security/New()
	GLOB.prisonsecuritywarp += loc
	return ..()

// Thunderdome
/obj/effect/landmark/event/tdome
	should_be_added = FALSE

/obj/effect/landmark/event/tdome/tdome1
	name = "tdome1"

/obj/effect/landmark/event/tdome/tdome1/New()
	GLOB.tdome1 += loc
	return ..()

/obj/effect/landmark/event/tdome/tdome2
	name = "tdome2"

/obj/effect/landmark/event/tdome/tdome2/New()
	GLOB.tdome2 += loc
	return ..()

/obj/effect/landmark/event/tdome/tdomeobserve
	name = "tdomeobserve"

/obj/effect/landmark/event/tdome/tdomeobserve/New()
	GLOB.tdomeobserve += loc
	return ..()

/obj/effect/landmark/event/tdome/tdomeadmin
	name = "tdomeadmin"

/obj/effect/landmark/event/tdome/tdomeadmin/New()
	GLOB.tdomeadmin += loc
	return ..()
