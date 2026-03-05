/atom/movable
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | TILE_BOUND
	vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_ID
	glide_size = 8

	var/last_move = null
	var/anchored = 0
	// var/elevation = 2    - not used anywhere
	var/move_speed = 10
	var/l_move_time = 1
	var/const/FIRST_DIAGONAL_STEP = 1
	var/const/SECOND_DIAGONAL_STEP = 2
	var/moving_diagonally = FALSE // Used so we don't break grabs mid-diagonal-move.
	var/m_flag = 1
	var/datum/thrownthing/throwing
	var/throw_speed = 1 // Number of deciseconds per tile.
	var/throw_range = 7
	var/throw_spin = TRUE // Should the atom spin when thrown.
	var/moved_recently = 0
	var/mob/pulledby = null
	var/item_state = null // Used to specify the item state for the on-mob overlays.
	var/pull_sound = null

	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5
	var/atom/movable/inertia_ignore

	/// Either [EMISSIVE_BLOCK_NONE], [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = EMISSIVE_BLOCK_NONE
	/// Internal holder for emissive blocker object, DO NOT USE DIRECTLY. Use blocks_emissive
	var/mutable_appearance/em_block
	/// [EMISSIVE_BLOCK_GENERIC] will use this as the em_block mask if specified. Cause we have /obj/item/'s with emissives.
	var/em_block_state

/atom/movable/Initialize()
	. = ..()
	update_emissive_blocker()
	if(em_block)
		AddOverlays(em_block)

/atom/movable/Destroy()
	if(!(atom_flags & ATOM_FLAG_INITIALIZED))
		util_crash_with("GC: -- [name] | [type] was deleted before initalization --")

	walk(src, 0) // Because we might have called walk_to, we must stop the walk loop or BYOND keeps an internal reference to us forever.

	for(var/atom/A in src)
		if(QDELING(A))
			continue
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

	if(em_block)
		QDEL_NULL(em_block)

	if(throwing)
		QDEL_NULL(throwing)

	return ..()

/atom/movable/Bump(atom/A, yes)
	if(!A)
		util_crash_with("Bump was called with no argument! Source: [src]")

	if(inertia_dir)
		inertia_dir = 0

	. = ..()

	if(!QDELETED(throwing))
		throwing.hit_atom(A)
		. = TRUE
		if(QDELETED(A))
			return

	if(yes)
		A.last_bumped = world.time
		SEND_SIGNAL(src, SIGNAL_MOVABLE_BUMP, A)
		INVOKE_ASYNC(A, nameof(.proc/Bumped), src) // Avoids bad actors sleeping or unexpected side effects, as the legacy behavior was to spawn here

/atom/movable/proc/get_selected_zone()
	return

/atom/movable/proc/get_active_item()
	return

/atom/movable/proc/get_inactive_item()
	return get_active_item()

/atom/movable/proc/on_purchase()
	return

/atom/movable/proc/forceMove(atom/destination)
	if((gc_destroyed && gc_destroyed != GC_CURRENTLY_BEING_QDELETED) && !isnull(destination))
		util_crash_with("Attempted to forceMove a QDELETED [src] out of nullspace! Destination: [destination].")
		return 0
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

	if(origin?.z != destination?.z)
		SEND_SIGNAL(src, SIGNAL_Z_CHANGED, src, origin, destination)

	SEND_SIGNAL(src, SIGNAL_MOVED, src, origin, destination)

	return 1

//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(hit_atom) && !QDELETED(hit_atom))
		hit_atom.hitby(src, TT)

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, obj/launcher, datum/callback/callback) //If this returns FALSE then callback will not be called.
	. = TRUE
	if(!target || QDELETED(src) || (target.z != z))
		return FALSE

	if(pulledby)
		if(ismob(pulledby))
			var/mob/puller = pulledby
			puller.stop_pulling()
		else
			return FALSE // Something with wheelchair or something, worth investigating later.

	if(!range)
		range = throw_range
	if(!speed)
		speed = throw_speed

	if(launcher)
		pre_launched()

	var/datum/thrownthing/TT = new(src, target, range, speed, thrower, launcher, callback)
	throwing = TT

	pixel_z = 0
	if(spin && throw_spin)
		SpinAnimation(4, 1)

	SSthrowing.processing[src] = TT
	if(SSthrowing.state == SS_PAUSED && length(SSthrowing.currentrun))
		SSthrowing.currentrun[src] = TT

// Used when the atom's thrown by a launcher-type gun (or by anything that provides a nulln't launcher_mult arg)
/atom/movable/proc/pre_launched()
	return

/atom/movable/proc/post_launched()
	return

/atom/movable/proc/update_emissive_blocker()
	switch(blocks_emissive)
		if(EMISSIVE_BLOCK_GENERIC)
			em_block = fast_emissive_blocker(src)
		if(EMISSIVE_BLOCK_UNIQUE)
			if(!em_block && !QDELING(src))
				appearance_flags |= KEEP_TOGETHER
				render_target = ref(src)
				em_block = emissive_blocker(
					icon = icon,
					appearance_flags = appearance_flags,
					source = render_target
				)
	return em_block

/atom/movable/update_icon()
	..()
	if(em_block)
		CutOverlays(em_block)
	update_emissive_blocker()
	if(em_block)
		AddOverlays(em_block)

//Overlays
/atom/movable/fake_overlay
	var/atom/master = null
	anchored = 1

/atom/movable/fake_overlay/New()
	src.verbs.Cut()
	..()

/atom/movable/fake_overlay/Destroy()
	master = null
	. = ..()

/atom/movable/fake_overlay/attackby(a, b)
	if (src.master)
		return src.master.attackby(a, b)
	return

/atom/movable/fake_overlay/attack_hand(a, b, c)
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

	am.register_signal(src, SIGNAL_DIR_SET, nameof(.proc/recursive_dir_set), TRUE)

/atom/movable/Exited(atom/movable/am, atom/old_loc)
	. = ..()

	am.unregister_signal(src, SIGNAL_DIR_SET)

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

/**
* A wrapper for setDir that should only be able to fail by living mobs.
*
* Called from '/atom/movable/proc/keyLoop', this exists to be overwritten by living mobs with a check to see if we're actually alive enough to change directions
*/
/atom/movable/proc/keybind_face_direction(direction)
	return

//call this proc to start space drifting
/atom/movable/proc/space_drift(direction)//move this down
	if(!loc || direction & (UP|DOWN) || is_space_movement_permitted() != SPACE_MOVE_FORBIDDEN)
		inertia_dir = 0
		inertia_ignore = null
		return 0

	inertia_dir = direction
	if(!direction)
		return TRUE
	inertia_last_loc = loc
	SSspacedrift.processing[src] = src
	return 1

//return 0 to space drift, 1 to stop, -1 for mobs to handle space slips
/atom/movable/proc/is_space_movement_permitted(allow_movement = FALSE)
	if(!simulated)
		return TRUE

	if(pulledby)
		return SPACE_MOVE_PERMITTED

	if(throwing)
		return SPACE_MOVE_PERMITTED

	if(anchored)
		return SPACE_MOVE_PERMITTED

	if(has_gravity())
		return SPACE_MOVE_PERMITTED

	if(!isturf(loc))
		return SPACE_MOVE_PERMITTED

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return SPACE_MOVE_SUPPORTED

	return SPACE_MOVE_FORBIDDEN

/atom/movable/hitby(atom/movable/AM, datum/thrownthing/TT)
	..()
	process_momentum(AM, TT)

/atom/movable/proc/process_momentum(atom/movable/AM, datum/thrownthing/TT)//physic isn't an exact science
	. = momentum_power(AM,TT)

	if(.)
		momentum_do(., TT, AM)

/atom/movable/proc/momentum_power(atom/movable/AM, datum/thrownthing/TT)
	if(anchored)
		return 0

	. = (AM.get_mass()*TT.speed)/(get_mass()*min(AM.throw_speed,2))
	if(has_gravity())
		. *= 0.5

/atom/movable/proc/momentum_do(power, datum/thrownthing/TT)
	var/direction = TT.init_dir
	switch(power)
		if(0.75 to INFINITY)		//blown backward, also calls being pinned to walls
			throw_at(get_edge_target_turf(src, direction), min((TT.maxrange - TT.dist_travelled) * power, 10), throw_speed * min(power, 1.5))

		if(0.5 to 0.75)	//knocks them back and changes their direction
			step(src, direction)

		if(0.25 to 0.5)	//glancing change in direction
			var/drift_dir
			if(direction & (NORTH|SOUTH))
				if(inertia_dir & (NORTH|SOUTH))
					drift_dir |= (direction & (NORTH|SOUTH)) & (inertia_dir & (NORTH|SOUTH))
				else
					drift_dir |= direction & (NORTH|SOUTH)
			else
				drift_dir |= inertia_dir & (NORTH|SOUTH)
			if(direction & (EAST|WEST))
				if(inertia_dir & (EAST|WEST))
					drift_dir |= (direction & (EAST|WEST)) & (inertia_dir & (EAST|WEST))
				else
					drift_dir |= direction & (EAST|WEST)
			else
				drift_dir |= inertia_dir & (EAST|WEST)
			space_drift(drift_dir)

/atom/movable/proc/get_mass()
	return 1.5

/atom/movable/proc/get_ghost_image(atom/target)
	var/_pixel_x = pixel_x
	var/_pixel_y = pixel_y
	pixel_x = 0
	pixel_y = 0
	var/image/I = image(src, null, layer = target.layer + 1)
	pixel_x = _pixel_x
	pixel_y = _pixel_y
	I.SetTransform(scale = 0.75)
	I.appearance_flags |= RESET_COLOR|KEEP_APART
	I.alpha = 128
	return I
