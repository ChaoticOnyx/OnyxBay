/datum/event2/wormholes
	id = "wormholes"
	name = "Wormholes"
	description = "Womrholes will appear throughout the station"

	mtth = 4 HOURS

	var/list/pick_turfs = list()
	var/list/wormholes = list()
	var/shift_frequency = 3
	var/number_of_wormholes = 400

/datum/event2/wormholes/get_conditions_description()
	. = "<em>Wormholes</em> should not be <em>running</em>.<br>"

/datum/event2/wormholes/check_conditions()
	. = SSevents.evars["wormholes_running"] != TRUE

/datum/event2/wormholes/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (6 MINUTES))
	. = max(1 HOUR, .)

/datum/event2/wormholes/on_fire()
	SSevents.evars["wormholes_running"] = TRUE
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

	addtimer(CALLBACK(src, .proc/announce), rand(0, 5) SECONDS)
	addtimer(CALLBACK(src, .proc/end), rand(1, 3) MINUTES)

	set_next_think(world.time)

/datum/event2/wormholes/think()
	for(var/obj/effect/portal/wormhole/O in wormholes)
		var/turf/T = pick(pick_turfs).resolve()
		if(T)
			O.forceMove(T)

	set_next_think(world.time + 3 SECONDS)

/datum/event2/wormholes/proc/announce()
	GLOB.using_map.space_time_anomaly_detected_annoncement()

/datum/event2/wormholes/proc/end()
	SSevents.evars["wormholes_running"] = FALSE
	set_next_think(0)
	QDEL_NULL_LIST(wormholes)

/proc/create_wormhole(turf/enter, turf/exit)
	if(!enter || !exit)
		return
	var/obj/effect/portal/wormhole/W = new (enter)
	W.target = exit
	return W
