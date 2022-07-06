/decl/turf_selection/proc/get_turfs(atom/origin, range)
	return list()

/decl/turf_selection/line/get_turfs(atom/origin, range)
	. = list()
	var/T = get_turf(origin)
	if(!T)
		return
	. += T
	for(var/i = 1 to range)
		T = get_step(T, origin.dir)
		if(!T) // Reached the end of the world most likely
			return
		. += T

/decl/turf_selection/line/transparent/get_turfs(atom/origin, range)
	. = list()
	var/turf/T = get_turf(origin)
	if(!T || T.opacity)
		return
	. += T
	for(var/i = 1 to range)
		T = get_step(T, origin.dir)
		if(!T || T.opacity)
			return
		. += T

/decl/turf_selection/square/get_turfs(atom/origin, range)
	. = list()
	var/center = get_turf(origin)
	if(!center)
		return
	for(var/turf/T in trange(range, center))
		. += T
