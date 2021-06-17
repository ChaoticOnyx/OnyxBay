/turf/proc/cultify()
	return
/turf/proc/decultify()
	return
/turf/simulated/floor/cultify()
	//todo: flooring datum cultify check
	cultify_floor()

/turf/simulated/shuttle/wall/cultify()
	cultify_wall()

/turf/simulated/shuttle/wall/decultify()
	decultify_wall()
/turf/simulated/wall/cultify()
	cultify_wall()
/turf/simulated/wall/decultify()
	decultify_wall()
/turf/simulated/wall/cult/cultify()
	return
/turf/unsimulated/wall/cult/cultify()
	return

/turf/unsimulated/beach/cultify()
	return

/turf/unsimulated/wall/cultify()
	cultify_wall()

/turf/unsimulated/wall/decultify()
	decultify_wall()

/turf/simulated/floor/cultify()
	cultify_floor()

/turf/simulated/floor/decultify()
	decultify_floor()

/turf/proc/cultify_wall()
	var/turf/simulated/wall/wall = src
	if(!istype(wall))
		return
	if(wall.reinf_material)
		ChangeTurf(/turf/simulated/wall/cult/reinf)
	else
		ChangeTurf(/turf/simulated/wall/cult)
	GLOB.cult.add_cultiness(CULTINESS_PER_TURF)

/turf/proc/decultify_wall()
	var/turf/simulated/wall/wall = src
	if(!istype(wall))
		return
	if(wall.reinf_material)
		ChangeTurf(/turf/simulated/wall/r_wall)
	else
		ChangeTurf(/turf/simulated/wall)
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)

/turf/proc/decultify_floor()
	var/turf/simulated/floor/misc/cult/F = src
	F.ChangeTurf(/turf/simulated/floor/tiled)
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)

/turf/proc/cultify_floor()
	var/turf/simulated/floor/tiled/F = src
	F.ChangeTurf(/turf/simulated/floor/misc/cult)
	GLOB.cult.add_cultiness(CULTINESS_PER_TURF)
