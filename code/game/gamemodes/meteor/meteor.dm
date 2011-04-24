/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/meteortime = 0

/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The ship has been stuck in a major meteor shower. You must escape from the ship or at least live.</B>"

/datum/game_mode/meteor/declare_completion()
	var/list/survivors = list()
	var/area/escape_zone = locate(/area/shuttle/escape/centcom)

	for(var/client/C)
		if (C.mob.stat != 2)
			var/turf/location = get_turf(C.mob.loc)
			if (location in escape_zone)
				survivors[C.mob.real_name] = "shuttle"
			else
				if (istype(C.mob.loc, /obj/machinery/vehicle/pod))
					survivors[C.mob.real_name] = "pod"
				else
					survivors[C.mob.real_name] = "alive"

	if (survivors.len)
		world << "\blue <B>The following survived the meteor attack!</B>"
		for(var/survivor in survivors)
			var/condition = survivors[survivor]
			switch(condition)
				if("shuttle")
					world << "\t <B><FONT size = 2>[survivor] escaped on the shuttle!</FONT></B>"
				if("pod")
					world << "\t <FONT size = 2>[survivor] escaped on an escape pod!</FONT>"
				if("alive")
					world << "\t <FONT size = 1>[survivor] stayed alive. Whereabouts unknown.</FONT>"
	else
		world << "\blue <B>No one survived the meteor attack!</B>"
	check_round()
	return 1

/datum/game_mode/meteor/process()
	if(meteortime <= 0)
		meteor_wave()
		meteortime = 5
	else
		meteortime -= 1

obj/meteor/proc/Target(var/mob/M in world)
	walk_towards(src,M,15)