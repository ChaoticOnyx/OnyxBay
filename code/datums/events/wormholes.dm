/datum/event/wormholes
	id = "wormholes"
	name = "Wormholes"
	description = "Womrholes will appear throughout the station"

	mtth = 4 HOURS
	difficulty = 60

	var/list/pick_turfs = list()
	var/shift_frequency = 5 SECONDS // How often wormhole batches should spawn
	var/number_of_wormholes = 400 // Overall number of wormholes spawned, might randomize a bit
	var/total_duration = 90 SECONDS // Total duration of the wormholes event, 90 sec on average
	var/end_time = 0

/datum/event/wormholes/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce)), 0)
	add_think_ctx("end", CALLBACK(src, nameof(.proc/end)), 0)

/datum/event/wormholes/get_conditions_description()
	. = "<em>Wormholes</em> should not be <em>running</em>.<br>"

/datum/event/wormholes/check_conditions()
	. = SSevents.evars["wormholes_running"] != TRUE

/datum/event/wormholes/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (6 MINUTES))
	. = max(1 HOUR, .)

/datum/event/wormholes/on_fire()
	set waitfor = FALSE

	SSevents.evars["wormholes_running"] = TRUE
	var/list/affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)

	for(var/z in affecting_z)
		for(var/turf/simulated/floor/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			if(turf_contains_dense_objects(T))
				continue
			pick_turfs.Add(weakref(T))

	total_duration = rand(60, 180) SECONDS
	end_time = world.time + total_duration

	set_next_think_ctx("announce", world.time + (rand(0, 5) SECONDS))
	set_next_think_ctx("end", end_time)
	set_next_think(world.time)

/datum/event/wormholes/think()
	for(var/i in 1 to round(number_of_wormholes / (total_duration / shift_frequency)))
		var/turf/enter = safepick(pick_turfs)?.resolve()
		var/turf/exit = safepick(pick_turfs)?.resolve()
		if(!istype(enter) || !istype(exit))
			continue
		pick_turfs -= weakref(enter)
		pick_turfs -= weakref(exit)
		create_wormhole(enter, exit)

	if(world.time < end_time)
		set_next_think(world.time + shift_frequency)

/datum/event/wormholes/proc/announce()
	SSannounce.play_station_announce(/datum/announce/space_time_anomaly)

/datum/event/wormholes/proc/end()
	SSevents.evars["wormholes_running"] = FALSE
	set_next_think(0)
	pick_turfs.Cut()

/proc/create_wormhole(turf/enter, turf/exit)
	if(!enter || !exit)
		return
	var/obj/effect/portal/wormhole/W = new (enter)
	W.target = exit
	return W
