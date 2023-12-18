/datum/orbit
	var/atom/movable/orbiter
	var/atom/orbiting
	var/lock = TRUE
	var/turf/lastloc
	var/lastprocess

/datum/orbit/New(_orbiter, _orbiting, _lock)
	orbiter = _orbiter
	orbiting = _orbiting
	SSorbit.orbits += src
	if(!orbiting.orbiters)
		orbiting.orbiters = list()
	orbiting.orbiters += src

	if(orbiter.orbiting)
		orbiter.stop_orbit()
	orbiter.orbiting = src

	if(!Check())
		return

	lock = _lock

	SEND_SIGNAL(orbiter, SIGNAL_ORBIT_BEGIN, orbiting)

//do not qdel directly, use stop_orbit on the orbiter. (This way the orbiter can bind to the orbit stopping)
/datum/orbit/Destroy()
	SEND_SIGNAL(orbiter, SIGNAL_ORBIT_STOP, orbiting)
	SSorbit.orbits -= src

	if(orbiter)
		orbiter.orbiting = null
		orbiter = null

	if(orbiting)
		if(orbiting.orbiters)
			orbiting.orbiters -= src
			if(!orbiting.orbiters.len)//we are the last orbit, delete the list
				orbiting.orbiters = null
		orbiting = null

	return ..()

/datum/orbit/proc/Check(turf/targetloc)
	if(!orbiter)
		qdel_self()
		return FALSE

	if(!orbiting)
		orbiter.stop_orbit()
		return FALSE

	if(!orbiter.orbiting) //admin wants to stop the orbit.
		orbiter.orbiting = src //set it back to us first
		orbiter.stop_orbit()

	lastprocess = world.time

	if(!targetloc)
		targetloc = get_turf(orbiting)

	if(!targetloc || (!lock && orbiter.loc != lastloc && orbiter.loc != targetloc))
		orbiter.stop_orbit()
		return FALSE

	orbiter.loc = targetloc
	lastloc = orbiter.loc
	return TRUE

/atom/movable
	var/datum/orbit/orbiting = null
	var/cached_transform = null

/atom
	var/list/orbiters = null

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lockinorbit = FALSE)
	if(!istype(A))
		return

	new /datum/orbit(src, A, lockinorbit)

	if(!orbiting) //something failed, and our orbit datum deleted itself
		return

	var/matrix/initial_transform = matrix(transform)
	cached_transform = initial_transform

	//Head first!
	if(pre_rotation)
		var/matrix/M = matrix(transform)
		var/pre_rot = 90
		if(!clockwise)
			pre_rot = -90
		M.Turn(pre_rot)
		transform = M

	var/matrix/shift = matrix(transform)
	shift.Translate(0,radius)
	transform = shift

	SpinAnimation(rotation_speed, -1, clockwise, rotation_segments)

/atom/movable/proc/stop_orbit()
	SpinAnimation(0, 0)
	QDEL_NULL(orbiting)
	transform = cached_transform

/atom/Destroy()
	. = ..()
	if(orbiters)
		for(var/thing in orbiters)
			var/datum/orbit/O = thing
			if(O.orbiter)
				O.orbiter.stop_orbit()

/atom/movable/Destroy()
	. = ..()
	if(orbiting)
		stop_orbit()
