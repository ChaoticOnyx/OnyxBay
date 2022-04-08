/turf/proc/cultify()
	return

/turf/simulated/floor/cultify()
	cultify_floor()

/turf/simulated/shuttle/wall/cultify()
	cultify_wall()

/turf/simulated/wall/cultify()
	cultify_wall()

/turf/unsimulated/wall/cultify()
	cultify_wall()

turf/simulated/floor/misc/cult/cultify()
	return

/turf/simulated/floor/proc/cultify_floor()
	var/turf/simulated/floor/floor = src
	var/old_type = floor.type
	var/turf/simulated/floor/misc/cult/cult_floor = src
	ChangeTurf(/turf/simulated/floor/misc/cult)
	cult_floor.previous_type = old_type
	GLOB.cult.add_cultiness(CULTINESS_PER_TURF)

/turf/simulated/floor/misc/cult/proc/decultify_floor()
	ChangeTurf(previous_type)
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)

/turf/proc/cultify_wall()
	var/turf/simulated/wall/wall = src
	var/old_type = wall.type
	var/turf/simulated/wall/cult/cult_wall = src
	if(!istype(wall))
		return
	if(wall.reinf_material)
		ChangeTurf(/turf/simulated/wall/cult/reinf)
		cult_wall.previous_type = old_type
	else
		ChangeTurf(/turf/simulated/wall/cult)
		cult_wall.previous_type = old_type
	GLOB.cult.add_cultiness(CULTINESS_PER_TURF)

/turf/simulated/wall/cult/proc/decultify_wall()
	ChangeTurf(previous_type)
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)
