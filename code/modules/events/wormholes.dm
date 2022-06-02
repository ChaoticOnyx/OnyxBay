/datum/event/wormholes
	announceWhen = 10
	endWhen = 60

	var/list/pick_turfs = list()
	var/list/wormholes = list()
	var/shift_frequency = 3
	var/number_of_wormholes = 400

/datum/event/wormholes/setup()
	announceWhen = rand(0, 20)
	endWhen = rand(40, 80)

/datum/event/wormholes/start()
	var/list/areas = area_repository.get_areas_by_z_level()
	for(var/i in areas)
		var/area/A = areas[i]
		for(var/turf/simulated/floor/T in A)
			if(isAdminLevel(T.z))
				continue
			if(turf_contains_dense_objects(T))
				continue
			pick_turfs.Add(weakref(T))

	for(var/i in 1 to number_of_wormholes)
		var/turf/enter = pick(pick_turfs).resolve()
		var/turf/exit = pick(pick_turfs).resolve()
		if(!istype(enter) || !istype(exit))
			continue
		pick_turfs -= weakref(enter)
		pick_turfs -= weakref(exit)

		wormholes += create_wormhole(enter, exit)

/datum/event/wormholes/announce()
	GLOB.using_map.space_time_anomaly_detected_annoncement()

/datum/event/wormholes/tick()
	if(activeFor % shift_frequency == 0)
		for(var/obj/effect/portal/wormhole/O in wormholes)
			var/turf/T = pick(pick_turfs).resolve()
			if(T)
				O.forceMove(T)

/datum/event/wormholes/end()
	QDEL_NULL_LIST(wormholes)

/proc/create_wormhole(turf/enter, turf/exit)
	if(!enter || !exit)
		return
	var/obj/effect/portal/wormhole/W = new (enter)
	W.target = exit
	return W
