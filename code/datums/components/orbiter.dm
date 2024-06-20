/datum/component/orbiter
	can_transfer = TRUE
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/orbiter_list
	var/datum/movement_detector/tracker

//radius: range to orbit at, radius of the circle formed by orbiting (in pixels)
//clockwise: whether you orbit clockwise or anti clockwise
//rotation_speed: how fast to rotate (how many ds should it take for a rotation to complete)
//rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
//pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
/datum/component/orbiter/Initialize(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(!istype(orbiter) || !isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	orbiter_list = list()

	begin_orbit(orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)

/datum/component/orbiter/register_with_parent()
	var/atom/target = parent

	target.orbiters = src

	if(ismovable(target))
		tracker = new(target, CALLBACK(src, nameof(.proc/move_react)))

	register_signal(parent, SIGNAL_UPDATE_GLIDE_SIZE, nameof(.proc/orbiter_glide_size_update))

/datum/component/orbiter/unregister_from_parent()
	unregister_signal(parent, SIGNAL_UPDATE_GLIDE_SIZE)
	var/atom/target = parent
	target.orbiters = null
	QDEL_NULL(tracker)

/datum/component/orbiter/Destroy()
	var/atom/master = parent

	if(master.orbiters == src)
		master.orbiters = null

	for(var/i in orbiter_list)
		end_orbit(i)

	orbiter_list = null
	return ..()

/datum/component/orbiter/inherit_component(datum/component/orbiter/newcomp, original, atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(!newcomp)
		begin_orbit(arglist(args.Copy(3)))
		return

	for(var/o in newcomp.orbiter_list)
		var/atom/movable/incoming_orbiter = o
		incoming_orbiter.orbiting = src
		newcomp.unregister_signal(incoming_orbiter, SIGNAL_MOVED)
		register_signal(incoming_orbiter, SIGNAL_MOVED, nameof(.proc/orbiter_move_react))

	orbiter_list += newcomp.orbiter_list
	newcomp.orbiter_list = null

/datum/component/orbiter/post_transfer()
	if(!isatom(parent) || isarea(parent) || !get_turf(parent))
		return COMPONENT_INCOMPATIBLE

	move_react(parent)

/datum/component/orbiter/proc/begin_orbit(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(orbiter.orbiting)
		if(orbiter.orbiting == src)
			orbiter.orbiting.end_orbit(orbiter, TRUE)
		else
			orbiter.orbiting.end_orbit(orbiter)

	orbiter_list[orbiter] = TRUE
	orbiter.orbiting = src

	register_signal(orbiter, SIGNAL_MOVED, nameof(.proc/orbiter_move_react))

	SEND_SIGNAL(parent, SIGNAL_ORBIT_BEGIN, orbiter)

	var/matrix/initial_transform = matrix(orbiter.transform)
	orbiter_list[orbiter] = initial_transform

	if(pre_rotation)
		var/matrix/M = matrix(orbiter.transform)
		var/pre_rot = 90
		if(!clockwise)
			pre_rot = -90
		M.Turn(pre_rot)
		orbiter.transform = M

	var/matrix/shift = matrix(orbiter.transform)
	shift.Translate(0, radius)
	orbiter.transform = shift

	orbiter.SpinAnimation(rotation_speed, -1, clockwise, rotation_segments)

	if(ismovable(parent))
		var/atom/movable/movable_parent = parent
		orbiter.glide_size = movable_parent.glide_size

	orbiter.forceMove(get_turf(parent))
	to_chat(orbiter, SPAN_NOTICE("Now orbiting [parent]."))

/datum/component/orbiter/proc/end_orbit(atom/movable/orbiter, refreshing=FALSE)
	if(!orbiter_list[orbiter])
		return

	unregister_signal(orbiter, SIGNAL_MOVED)
	SEND_SIGNAL(parent, SIGNAL_ORBIT_STOP, orbiter)
	to_chat(orbiter, SPAN_NOTICE("No longer orbiting \the [parent]."))
	orbiter.SpinAnimation(0, 0)

	if(istype(orbiter_list[orbiter], /matrix))
		orbiter.transform = orbiter_list[orbiter]

	orbiter_list -= orbiter
	orbiter.stop_orbit(src)
	orbiter.orbiting = null

	if(ismob(orbiter))
		var/mob/orbiter_mob = orbiter
		orbiter_mob.glide_size = initial(orbiter_mob.glide_size)

	if(!refreshing && !length(orbiter_list) && !QDELETED(src))
		qdel_self()

/// This proc can receive signals by either the thing being directly orbited or anything holding it
/datum/component/orbiter/proc/move_react(atom/movable/master, atom/mover, atom/oldloc, direction)
	if(master.loc == oldloc)
		return

	var/turf/newturf = get_turf(master)
	if(!newturf)
		qdel_self()

	for(var/atom/movable/movable_orbiter as anything in orbiter_list)
		if(QDELETED(movable_orbiter) || movable_orbiter.loc == newturf)
			continue

		movable_orbiter.forceMove(newturf)

/datum/component/orbiter/proc/orbiter_move_react(atom/movable/orbiter, atom/oldloc, direction)
	if(orbiter.loc == get_turf(parent))
		return

	end_orbit(orbiter)

/datum/component/orbiter/proc/orbiter_glide_size_update(datum/source, target)
	for(var/orbiter in orbiter_list)
		var/atom/movable/movable_orbiter = orbiter
		movable_orbiter.glide_size = target
