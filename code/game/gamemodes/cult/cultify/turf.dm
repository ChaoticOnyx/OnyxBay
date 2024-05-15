/turf/proc/cultify()
	return

/turf/floor/cultify()
	cultify_floor()

/turf/shuttle/wall/cultify()
	cultify_wall()

/turf/wall/cultify()
	cultify_wall()

/turf/wall/cultify()
	cultify_wall()

/turf/floor/misc/cult/cultify()
	return

/turf/floor/proc/cultify_floor()
	var/turf/floor/floor = src
	var/old_type = floor.type
	var/turf/floor/misc/cult/cult_floor = src
	ChangeTurf(/turf/floor/misc/cult)
	cult_floor.previous_type = old_type
	GLOB.cult.add_cultiness(CULTINESS_PER_TURF)

/turf/floor/misc/cult/proc/decultify_floor()
	ChangeTurf(previous_type)
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)

/turf/proc/cultify_wall()
	var/turf/wall/wall = src
	var/old_type = wall.type
	var/turf/wall/cult/cult_wall = src
	if(!istype(wall))
		return
	if(wall.reinf_material)
		ChangeTurf(/turf/wall/cult/reinf)
		cult_wall.previous_type = old_type
	else
		ChangeTurf(/turf/wall/cult)
		cult_wall.previous_type = old_type
	GLOB.cult.add_cultiness(CULTINESS_PER_TURF)

/turf/wall/cult/proc/decultify_wall()
	ChangeTurf(previous_type)
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)
