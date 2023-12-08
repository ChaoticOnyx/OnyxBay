/datum/event/wallrot
	id = "wallrot"
	name = "Wallrot"
	description = "Dangerous fungi will appear on some walls destroying the walls"

	mtth = 2 HOURS
	difficulty = 25

/datum/event/wallrot/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce)), 0)

/datum/event/wallrot/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Gardener"] * (15 MINUTES))
	. -= (SSevents.triggers.roles_count["Engineer"] * (15 MINUTES))
	. = max(1 HOUR, .)

/datum/event/wallrot/proc/announce()
	SSannounce.play_station_announce(/datum/announce/wallrot)

/datum/event/wallrot/on_fire()
	set_next_think_ctx("announce", world.time + (rand(2, 5) MINUTES))

	spawn()
		var/turf/simulated/wall/center = null

		// 100 attempts
		for(var/i = 0, i < 100, i++)
			var/turf/candidate = locate(rand(1, world.maxx), rand(1, world.maxy), pick(GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			if(istype(candidate, /turf/simulated/wall))
				center = candidate
				break

		if(center)
			// Make sure at least one piece of wall rots!
			center.rot()

			// Have a chance to rot lots of other walls.
			var/rotcount = 0
			var/actual_severity = rand(5, 10)
			for(var/turf/simulated/wall/W in range(5, center))
				if(prob(50))
					W.rot()
					rotcount++

				// Only rot up to severity walls
				if(rotcount >= actual_severity)
					break
