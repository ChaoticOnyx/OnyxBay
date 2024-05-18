/// Management class used to handle successive calls used to generate a list of turfs.
/datum/map_generator
	/// List of necessary ruins that will always spawn
	var/list/necessary_ruins

	/// Weighed list of random ruins
	var/list/random_ruins

	/// Baseturf that will be used to override all areas' base_turf vars.
	var/turf/baseturf

	/// Turf that will be placed on map's edge (7 turfs border)
	var/turf/edgeturf

/// Given a list of turfs, asynchronously changes a list of turfs and their areas.
/// Does not fill them with objects; this should be done with populate_turfs.
/// This is a wrapper proc for generate_turf(), handling batch processing of turfs.
/datum/map_generator/proc/generate_turfs(list/turf/turfs)
	var/start_time = REALTIMEOFDAY
	var/message = "MAPGEN: MAPGEN any2ref [any2ref(src)] ([type]) STARTING TURF GEN"
	to_world_log(message)

	for(var/turf/gen_turf in turfs)
		if(!istype(gen_turf))
			continue

		// deferring AfterChange() means we don't get huge atmos flows in the middle of making changes
		generate_turf(gen_turf, CHANGETURF_IGNORE_AIR | CHANGETURF_DEFER_CHANGE | CHANGETURF_DEFER_BATCH)
		CHECK_TICK

	for(var/turf/gen_turf in turfs)
		if(!istype(gen_turf))
			continue

		//gen_turf.AfterChange(CHANGETURF_IGNORE_AIR)

		//QUEUE_SMOOTH(gen_turf)
		//QUEUE_SMOOTH_NEIGHBORS(gen_turf)

		for(var/turf/space/S in RANGE_TURFS(1, gen_turf))
			S.update_starlight()

		// CHECK_TICK here is fine -- we are assuming that the turfs we're generating are staying relatively constant
		CHECK_TICK

	message = "MAPGEN: MAPGEN REF [any2ref(src)] ([type]) HAS FINISHED TURF GEN IN [(REALTIMEOFDAY - start_time)/10]s"
	to_world_log(message)

/// Given a list of turfs, presumed to have been previously changed by generate_turfs,
/// asynchronously fills them with objects and decorations.
/// This is a wrapper proc for _populate_turf(), handling batch processing of turfs to improve speed.
/datum/map_generator/proc/populate_turfs(list/turf/turfs)
	var/start_time = REALTIMEOFDAY
	var/message = "MAPGEN: MAPGEN REF [any2ref(src)] ([type]) STARTING TURF POPULATION"
	to_world_log(message)

	for(var/turf/gen_turf in turfs)
		if(!istype(gen_turf))
			continue

		_populate_turf(gen_turf)
		CHECK_TICK

	message = "MAPGEN: MAPGEN REF [any2ref(src)] ([type]) HAS FINISHED TURF POPULATION IN [(REALTIMEOFDAY - start_time)/10]s"
	to_world_log(message)

/// Builds a map's border
/datum/map_generator/proc/generate_edge_turf(z)
	var/turf/center = locate(world.maxx / 2, world.maxy / 2, z)
	if(!center)
		return

	var/list/turf/turfs = RANGE_TURFS(world.maxx / 2, center)
	for(var/turf/gen_turf in turfs)
		if(gen_turf.x <= TRANSITION_EDGE || gen_turf.x >= world.maxx - TRANSITION_EDGE)
			gen_turf.ChangeTurf(edgeturf)
			CHECK_TICK
			continue

		if(gen_turf.y <= TRANSITION_EDGE || gen_turf.y >= world.maxy - TRANSITION_EDGE)
			gen_turf.ChangeTurf(edgeturf)
			CHECK_TICK
			continue

/// Internal proc that actually calls ChangeTurf on and changes the area of
/// a turf passed to generate_turfs(). Should never sleep; should always
/// respect changeturf_flags in the call to ChangeTurf.
/datum/map_generator/proc/generate_turf(turf/gen_turf, changeturf_flags)
	//SHOULD_NOT_SLEEP(TRUE) UNFORTUNATELY i had to comment this as /atom/proc/Entered() sleeps and this causes fuckton of warnings
	return

/// Internal proc that actually adds objects to a turf passed to populate_turfs().
/datum/map_generator/proc/_populate_turf(turf/gen_turf)
	//SHOULD_NOT_SLEEP(TRUE) UNFORTUNATELY i had to comment this as /atom/proc/Entered() sleeps and this causes fuckton of warnings
	return

/datum/map_generator/proc/load_necessary_ruins(z_level)
	for(var/path in necessary_ruins)
		var/datum/map_template/ruin = new path()
		var/turf/ruin_turf = get_unused_square(z_level, tries = 5, width = ruin.width, height = ruin.height)
		if(!istype(ruin_turf))
			continue

		ruin.load(ruin_turf)

/datum/map_generator/proc/get_unused_square(z_level, tries = 5, width = 0, height = 0)
	var/turf/possible_turf = locate(
		rand(0 + TRANSITION_EDGE + 1, 255 - width - TRANSITION_EDGE + 1),
		rand(0 + TRANSITION_EDGE + 1, 255 - height - TRANSITION_EDGE + 1),
		z_level
	)

	for(var/i in 1 to tries)
		if(locate(/atom/movable) in block(locate(possible_turf.x, possible_turf.y, z_level), locate(possible_turf.x + width, possible_turf.y + height, z_level)))
			continue

		return possible_turf

	return FALSE
