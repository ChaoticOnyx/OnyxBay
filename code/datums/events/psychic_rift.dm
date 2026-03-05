/datum/event/psychic_rift
	id = "psychic rift"
	name = "Psychic Rift"
	description = "A psychic rift will appear somewhere at the station"

	mtth = 4 HOURS
	difficulty = 60

/datum/event/psychic_rift/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (6 MINUTES))
	. = max(1 HOUR, .)

/datum/event/psychic_rift/on_fire()
	set waitfor = FALSE

	var/list/affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)
	var/list/pick_turfs = list()

	for(var/z in affecting_z)
		for(var/turf/simulated/floor/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			if(turf_contains_dense_objects(T))
				continue
			pick_turfs.Add(weakref(T))

	for(var/t in pick_turfs)
		var/turf/T = safepick(pick_turfs)?.resolve()
		if(istype(T))
			var/obj/structure/psychic_rift/PR = new(T)
			log_debug("A psychic rift has been spawned at: x = [PR.x], y = [PR.y], z = [PR.z].")
			break
