/atom
	/// Reference to atom being orbited
	var/atom/orbit_target
	/// The orbiter component, exists if there's anything orbiting this atom
	var/datum/component/orbiter/orbiters
	/// If this atom is orbiting something, this is references target atom's component
	var/datum/component/orbiter/orbiting

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE)
	if(!istype(A) || !get_turf(A) || A == src)
		return

	orbit_target = A
	return A.AddComponent(/datum/component/orbiter, src, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)

/atom/movable/proc/stop_orbit(datum/component/orbiter/orbits)
	orbit_target = null
	return
