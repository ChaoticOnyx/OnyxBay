/obj/effect/landmark/event
	icon_state = "landmark_event"
	delete_after = TRUE

/obj/effect/landmark/event/


/obj/effect/landmark/event/rift/spawn_point
	name = "bluespacerift"

/obj/effect/landmark/event/rift/spawn_point/New()
	..()
	GLOB.endgame_safespawns += loc

/obj/effect/landmark/event/rift/exit
	name = "endgame_exit"

/obj/effect/landmark/event/rift/exit/New()
	..()
	GLOB.endgame_exits += loc

// Admin prision
/obj/effect/landmark/event/prison/prisioner
	name = "prisonwarp"

/obj/effect/landmark/event/prison/prisioner/New()
	..()
	GLOB.prisonwarp += loc

/obj/effect/landmark/event/prison/security
	name = "prisonsecuritywarp"

/obj/effect/landmark/event/prison/security/New()
	..()
	GLOB.prisonsecuritywarp += loc

// TDome
/obj/effect/landmark/event/tdome/tdome1
	name = "tdome1"

/obj/effect/landmark/event/tdome/tdome1/New()
	..()
	GLOB.tdome1 += loc

/obj/effect/landmark/event/tdome/tdome2
	name = "tdome2"

/obj/effect/landmark/event/tdome/tdome2/New()
	..()
	GLOB.tdome2 += loc

/obj/effect/landmark/event/tdome/tdomeobserve
	name = "tdomeobserve"

/obj/effect/landmark/event/tdome/tdomeobserve/New()
	..()
	GLOB.tdomeobserve += loc

/obj/effect/landmark/event/tdome/tdomeadmin
	name = "tdomeadmin"

/obj/effect/landmark/event/tdome/tdomeadmin/New()
	..()
	GLOB.tdomeadmin += loc


/*
	//TODO: Clean up this mess.
	switch(name) // Some of these are probably obsolete.
		if("endgame_exit")
			endgame_safespawns += loc
			delete()
			return
		if("bluespacerift")

			delete()
			return
*/
