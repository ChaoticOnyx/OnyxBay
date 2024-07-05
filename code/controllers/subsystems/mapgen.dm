SUBSYSTEM_DEF(mapgen)
	name = "Mapgen"
	wait = 1 SECOND
	priority = SS_PRIORITY_MAPGEN

	/// Current mapgen datum.
	var/datum/map_generator/current_mapgen = null
	/// List of all turfs that will be changed by mapgen
	var/list/turfs = list()
	var/list/generated_turfs = list()
	var/list/smooth_queue = list()
	var/list/populate_queue = list()

/datum/controller/subsystem/mapgen/fire(resumed = FALSE)
	while(turfs.len)
		var/turf/gen_turf = turfs[turfs.len]
		if(!istype(gen_turf))
			continue

		current_mapgen.generate_turf(gen_turf, CHANGETURF_IGNORE_AIR | CHANGETURF_DEFER_CHANGE | CHANGETURF_DEFER_BATCH)
		generated_turfs |= gen_turf
		turfs.len --
		if(MC_TICK_CHECK)
			return

	while(generated_turfs.len)
		var/turf/generated = generated_turfs[generated_turfs.len]
		if(!istype(generated))
			continue

		var/neighbors = RANGE_TURFS(1, generated)
		smooth_queue |= generated
		for(var/turf/T in neighbors)
			smooth_queue |= T

		for(var/turf/space/S in neighbors)
			S.update_starlight()

		generated_turfs.len--
		if(MC_TICK_CHECK)
			return

	while(smooth_queue.len)
		var/turf/to_smooth = smooth_queue[smooth_queue.len]
		if(!istype(to_smooth))
			continue

		to_smooth.update_icon()
		smooth_queue.len--
		populate_queue |= to_smooth
		if(MC_TICK_CHECK)
			return

	while(populate_queue.len)
		var/turf/to_populate = populate_queue[populate_queue.len]
		if(!istype(to_populate))
			continue

		current_mapgen._populate_turf(to_populate)
		populate_queue.len--
		if(populate_queue.len <= 0)
			new /datum/random_map/automata/cave_system(null, 1, 1, 1, world.maxx, world.maxy)
			new /datum/random_map/noise/ore(null, 1, 1, 1, world.maxx, world.maxy)
			current_mapgen = null

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/mapgen/Recover()
	current_mapgen = SSmapgen.current_mapgen
	turfs = SSmapgen.turfs
	generated_turfs = SSmapgen.generated_turfs
	smooth_queue = SSmapgen.smooth_queue

// Some queueing mechanism is needed, but not now, not now.
/datum/controller/subsystem/mapgen/proc/generate(datum/map_generator/mapgen, list/turfs)
	if(!current_mapgen)
		current_mapgen = mapgen
		src.turfs = turfs.Copy()
		return TRUE
	else
		return FALSE
