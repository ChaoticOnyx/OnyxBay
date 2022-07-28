/atom/movable
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | TILE_BOUND
	glide_size = 8

	var/last_move = null
	var/anchored = 0
	// var/elevation = 2    - not used anywhere
	var/move_speed = 10
	var/l_move_time = 1
	var/m_flag = 1
	var/throwing = 0
	var/thrower
	var/throw_dir
	var/turf/throw_source = null
	var/atom/thrown_to
	var/throwed_dist
	var/throw_speed = 1 // Number of ticks to travel 1 tile. Values between 0 and 1 allow traveling multiple tiles per tick, though it looks ugly and ain't recommended unless totally needed.
	var/throw_range = 7
	var/throw_spin = TRUE // Should the atom spin when thrown.
	var/moved_recently = 0
	var/mob/pulledby = null
	var/item_state = null // Used to specify the item state for the on-mob overlays.
	var/pull_sound = null

/atom/movable/Destroy()
	if(!(atom_flags & ATOM_FLAG_INITIALIZED))
		crash_with("Was deleted before initalization")

	walk(src, 0) // Because we might have called walk_to, we must stop the walk loop or BYOND keeps an internal reference to us forever.

	for(var/A in src)
		qdel(A)

	forceMove(null)
	if(pulledby)
		if(pulledby.pulling == src)
			pulledby.pulling = null
		pulledby = null

	if(LAZYLEN(movement_handlers) && !ispath(movement_handlers[1]))
		QDEL_NULL_LIST(movement_handlers)

	if(virtual_mob && !ispath(virtual_mob))
		QDEL_NULL(virtual_mob)

	thrown_to = null
	throwed_dist = 0
	throwing = FALSE
	thrower = null
	throw_source = null

	return ..()

/atom/movable/Bump(atom/A, yes)
	if(src.throwing)
		src.throw_impact(A)
		src.throwing = 0

	spawn(0)
		if (A && yes)
			A.last_bumped = world.time
			SEND_SIGNAL(src, SIGNAL_MOVABLE_BUMP, A)
			A.Bumped(src)
		return
	..()
	return

/atom/movable/proc/get_selected_zone()
	return

/atom/movable/proc/get_active_item()
	return

/atom/movable/proc/on_purchase()
	return

/atom/movable/proc/forceMove(atom/destination)
	if((gc_destroyed && gc_destroyed != GC_CURRENTLY_BEING_QDELETED) && !isnull(destination))
		CRASH("Attempted to forceMove a QDELETED [src] out of nullspace!")
	if(loc == destination)
		return 0
	var/is_origin_turf = isturf(loc)
	var/is_destination_turf = isturf(destination)
	// It is a new area if:
	//  Both the origin and destination are turfs with different areas.
	//  When either origin or destination is a turf and the other is not.
	var/is_new_area = (is_origin_turf ^ is_destination_turf) || (is_origin_turf && is_destination_turf && loc.loc != destination.loc)

	var/atom/origin = loc
	loc = destination

	if(origin)
		origin.Exited(src, destination)
		if(is_origin_turf)
			for(var/atom/movable/AM in origin)
				AM.Uncrossed(src)
			if(is_new_area && is_origin_turf)
				origin.loc.Exited(src, destination)

	if(destination)
		destination.Entered(src, origin)
		if(is_destination_turf) // If we're entering a turf, cross all movable atoms
			for(var/atom/movable/AM in loc)
				if(AM != src)
					AM.Crossed(src)
			if(is_new_area && is_destination_turf)
				destination.loc.Entered(src, origin)

	SEND_SIGNAL(src, SIGNAL_MOVED, src, origin, destination)

	return 1

//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, speed, target_zone)
	if(isliving(hit_atom))
		var/mob/living/M = hit_atom
		M.hitby(src, speed)

	else if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored)
			step(O, src.last_move)
		O.hitby(src, speed)

	else if(isturf(hit_atom))
		throwing = 0
		var/turf/T = hit_atom
		T.hitby(src, speed)

//decided whether a movable atom being thrown can pass through the turf it is in.
/atom/movable/proc/hit_check(speed, thrown_with, target_zone)
	if(!throwing)
		return

	for(var/atom/movable/A in get_turf(src))
		if(A == src)
			continue

		if(isliving(A))
			var/mob/living/L = A
			if(L.lying)
				continue
			throw_impact(A, speed, thrown_with, target_zone)

		if(isobj(A))
			if(A.density && !A.throwpass)	// **TODO: Better behaviour for windows which are dense, but shouldn't always stop movement
				throw_impact(A, speed)

/atom/movable/proc/throw_at(atom/target, range, speed = throw_speed, atom/thrower, thrown_with, target_zone, launched_mult)
	set waitfor = FALSE

	if(!target || QDELETED(src))
		return FALSE
	if(target.z != src.z)
		return FALSE
	// src loc check
	if(thrower && !isturf(thrower.loc))
		return FALSE

	speed = max(0, (speed || throw_speed))

	throwing = TRUE
	src.thrower = thrower
	throw_source = get_turf(src)	//store the origin turf
	pixel_z = 0
	thrown_to = target
	throwed_dist = range
	throw_dir = get_dir(src, target)
	if(usr)
		if(MUTATION_HULK in usr.mutations)
			src.throwing = 2 // really strong throw!

	var/dist_travelled = 0
	var/dist_since_sleep = 0
	var/time_travelled = 0
	var/tiles_per_tick = speed
	speed = round(speed)
	var/impact_speed = speed
	if(launched_mult)
		impact_speed *= launched_mult
		pre_launched()
	var/area/a = get_area(loc)

	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target
	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)

	var/dx
	if(target.x > src.x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if(target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH

	var/error
	var/major_dir
	var/major_dist
	var/minor_dir
	var/minor_dist
	if(dist_x > dist_y)
		error = dist_x / 2 - dist_y
		major_dir = dx
		major_dist = dist_x
		minor_dir = dy
		minor_dist = dist_y
	else
		error = dist_y / 2 - dist_x
		major_dir = dy
		major_dist = dist_y
		minor_dir = dx
		minor_dist = dist_x

	if(throw_spin)
		SpinAnimation(speed = 4, loops = 1)

	while(!QDELETED(src) && target && throwing && isturf(loc) \
			&& ((abs(target.x - src.x) + abs(target.y - src.y) > 0 && dist_travelled < range) \
			|| !a?.has_gravity \
			|| isspaceturf(loc)))
		// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
		var/atom/step
		if(error >= 0)
			step = get_step(src, major_dir)
			error -= minor_dist
		else
			step = get_step(src, minor_dir)
			error += major_dist
		if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
			break
		var/atom/previous = src.loc
		src.loc = null
		if (Move(previous))
			Move(step)
		hit_check(impact_speed)
		dist_travelled++
		dist_since_sleep += tiles_per_tick
		if(throw_spin && !(time_travelled % 4))
			SpinAnimation(speed = 4, loops = 1)
		if(dist_since_sleep >= 1)
			dist_since_sleep = 0
			time_travelled += speed
			sleep(speed)
		a = get_area(loc)
		// and yet it moves

	if(!src)
		return

	//done throwing, either because it hit something or it finished moving
	if(isobj(src))
		throw_impact(get_turf(src), impact_speed)

	if(launched_mult)
		post_launched()

	thrown_to = null
	throw_dir = null
	throwing = FALSE
	src.thrower = null
	throw_source = null
	fall()

// Used when the atom's thrown by a launcher-type gun (or by anything that provides a nulln't launcher_mult arg)
/atom/movable/proc/pre_launched()
	return

/atom/movable/proc/post_launched()
	return

//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/New()
	src.verbs.Cut()
	..()

/atom/movable/overlay/Destroy()
	master = null
	. = ..()

/atom/movable/overlay/attackby(a, b)
	if (src.master)
		return src.master.attackby(a, b)
	return

/atom/movable/overlay/attack_hand(a, b, c)
	if (src.master)
		return src.master.attack_hand(a, b, c)
	return

/atom/movable/proc/touch_map_edge()
	if(!simulated)
		return

	if(!z || (z in GLOB.using_map.get_levels_with_trait(ZTRAIT_SEALED)))
		return

	if(!GLOB.universe.OnTouchMapEdge(src))
		return

	var/new_x
	var/new_y
	var/new_z = GLOB.using_map.get_transit_zlevel(z)
	if(new_z)
		if(x <= TRANSITION_EDGE)
			new_x = world.maxx - TRANSITION_EDGE - 2
			new_y = rand(TRANSITION_EDGE + 2, world.maxy - TRANSITION_EDGE - 2)

		else if (x >= (world.maxx - TRANSITION_EDGE + 1))
			new_x = TRANSITION_EDGE + 1
			new_y = rand(TRANSITION_EDGE + 2, world.maxy - TRANSITION_EDGE - 2)

		else if (y <= TRANSITION_EDGE)
			new_y = world.maxy - TRANSITION_EDGE -2
			new_x = rand(TRANSITION_EDGE + 2, world.maxx - TRANSITION_EDGE - 2)

		else if (y >= (world.maxy - TRANSITION_EDGE + 1))
			new_y = TRANSITION_EDGE + 1
			new_x = rand(TRANSITION_EDGE + 2, world.maxx - TRANSITION_EDGE - 2)

		var/turf/T = locate(new_x, new_y, new_z)
		if(T)
			forceMove(T)

/atom/movable/Entered(atom/movable/am, atom/old_loc)
	. = ..()

	am.register_signal(src, SIGNAL_DIR_SET, /atom/proc/recursive_dir_set, TRUE)

/atom/movable/Exited(atom/movable/am, atom/old_loc)
	. = ..()

	am.unregister_signal(src, SIGNAL_DIR_SET)
	am.unregister_signal(src, SIGNAL_MOVED)

/atom/movable/proc/move_to_turf(atom/movable/am, old_loc, new_loc)
	var/turf/T = get_turf(new_loc)

	if(T && T != loc)
		forceMove(T)

// Similar to above but we also follow into nullspace
/atom/movable/proc/move_to_turf_or_null(atom/movable/am, old_loc, new_loc)
	var/turf/T = get_turf(new_loc)
	if(T != loc)
		forceMove(T)

/// Called on `/mob/proc/start_pulling`.
/atom/movable/proc/on_pulling_try(mob/user)
	return
