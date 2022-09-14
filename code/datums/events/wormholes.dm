/datum/event/wormholes
	id = "wormholes"
	name = "Wormholes"
	description = "Womrholes will appear throughout the station"

	mtth = 4 HOURS

	var/list/pick_turfs = list()
	var/list/wormholes = list()
	var/shift_frequency = 3
	var/number_of_wormholes = 400

/datum/event/wormholes/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, .proc/announce), 0)
	add_think_ctx("end", CALLBACK(src, .proc/end), 0)

/datum/event/wormholes/get_conditions_description()
	. = "<em>Wormholes</em> should not be <em>running</em>.<br>"

/datum/event/wormholes/check_conditions()
	. = SSevents.evars["wormholes_running"] != TRUE

/datum/event/wormholes/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (6 MINUTES))
	. = max(1 HOUR, .)

/datum/event/wormholes/on_fire()
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
		var/turf/enter = safepick(pick_turfs)?.resolve()
		var/turf/exit = safepick(pick_turfs)?.resolve()
		if(!istype(enter) || !istype(exit))
			continue
		pick_turfs -= weakref(enter)
		pick_turfs -= weakref(exit)

		wormholes += create_wormhole(enter, exit)

	set_next_think_ctx("announce", world.time + (rand(0, 5) SECONDS))
	set_next_think_ctx("end", world.time + (rand(1, 3) MINUTES))
	set_next_think(world.time)

/datum/event/wormholes/think()
	for(var/obj/effect/portal/wormhole/O in wormholes)
		var/turf/T = safepick(pick_turfs)?.resolve()
		if(T)
			O.forceMove(T)

	set_next_think(world.time + 3 SECONDS)

/datum/event/wormholes/proc/announce()
	GLOB.using_map.space_time_anomaly_detected_annoncement()

/datum/event/wormholes/proc/end()
	SSevents.evars["wormholes_running"] = FALSE
	set_next_think(0)
	QDEL_NULL_LIST(wormholes)

/proc/create_wormhole(turf/enter, turf/exit)
	if(!enter || !exit)
		return
	var/obj/effect/portal/wormhole/W = new (enter)
	W.target = exit
	return W
