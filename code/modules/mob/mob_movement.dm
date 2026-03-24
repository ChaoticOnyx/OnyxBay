/mob
	var/moving = FALSE

/mob/proc/SelfMove(direction)
	if(DoMove(direction, src) & MOVEMENT_HANDLED)
		return TRUE // Doesn't necessarily mean the mob physically moved

/mob/CanPass(atom/movable/mover, turf/target)
	if(ismob(mover))
		var/mob/moving_mob = mover
		if(other_mobs && moving_mob.other_mobs)
			return TRUE
	return (!mover.density || !density || lying)

/mob/proc/setMoveCooldown(timeout)
	var/datum/movement_handler/mob/delay/delay = GetMovementHandler(/datum/movement_handler/mob/delay)
	if(delay)
		delay.SetDelay(timeout)

/mob/proc/addMoveCooldown(timeout)
	var/datum/movement_handler/mob/delay/delay = GetMovementHandler(/datum/movement_handler/mob/delay)
	if(delay)
		delay.AddDelay(timeout)

/client/proc/client_dir(input, direction=-1)
	return turn(input, direction*dir2angle(dir))

/mob/forceMove(atom/destination, unbuckle_mob = TRUE)
	. = ..()
	if(!.)
		return
	if(unbuckle_mob)
		buckled?.unbuckle_mob()

/client/Northeast()
	diagonal_action(NORTHEAST)
/client/Northwest()
	diagonal_action(NORTHWEST)
/client/Southeast()
	diagonal_action(SOUTHEAST)
/client/Southwest()
	diagonal_action(SOUTHWEST)

/client/proc/diagonal_action(direction)
	switch(client_dir(direction, 1))
		if(NORTHEAST)
			swap_hand()
			return
		if(SOUTHEAST)
			attack_self()
			return
		if(SOUTHWEST)
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.toggle_throw_mode()
			else
				to_chat(usr, "<span class='warning'>This mob type cannot throw items.</span>")
			return
		if(NORTHWEST)
			mob.hotkey_drop()

/mob/proc/hotkey_drop(drop_inactive = FALSE)
	to_chat(usr, "<span class='warning'>This mob type cannot drop items.</span>")

/mob/living/carbon/hotkey_drop(drop_inactive = FALSE)
	if(!can_use_hands)
		return
	var/obj/item/I = drop_inactive ? get_inactive_hand() : get_active_hand()
	if(!I)
		to_chat(usr, SPAN("warning", "You have nothing to drop in your hand."))
		return
	if(!(I.force_drop || can_unequip(I)))
		to_chat(usr, SPAN("warning", "\The [I] cannot be dropped."))
		return
	else
		return drop_inactive ? drop_inactive_hand(force = TRUE) : drop_active_hand(force = TRUE)

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		to_chat(usr, "<span class='notice'>You are not pulling anything.</span>")
		return
	usr.stop_pulling()

/client/verb/swap_hand()
	set hidden = 1
	if(istype(mob, /mob/living/carbon))
		var/mob/living/carbon/C = mob
		C.swap_hand()
	if(istype(mob, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = mob
		R.cycle_modules()
	return



/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.use_attack_self()
	return


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return


/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob) && mob.stat == CONSCIOUS && isturf(mob.loc))
		var/obj/item/I = mob.get_active_hand()
		if(I && mob.can_unequip(I))
			mob.drop_active_hand()

/atom/movable/proc/set_glide_size(glide_size_override = 0, min = 0.9, max = world.icon_size / 2)
	if (!glide_size_override || glide_size_override > max)
		glide_size = 0
	else
		glide_size = max(min, glide_size_override)

	if(istype(src, /obj))
		var/obj/O = src
		if(O.buckled_mob)
			O.buckled_mob.set_glide_size(glide_size, min, max)

	SEND_SIGNAL(src, SIGNAL_UPDATE_GLIDE_SIZE, glide_size)

//This proc should never be overridden elsewhere at /atom/movable to keep directions sane.
// TODO: Dump the entire movement code, and rip a sane one from TG or something.
//       For now, it's but a magic box that runs in an unpredictable order.
/atom/movable/Move(newloc, direct)
	if(!loc || !newloc)
		return

	var/oldloc = loc

	var/turf/old_turf = get_turf(oldloc)
	var/turf/new_turf = get_turf(newloc)

	if(loc != newloc)
		if(old_turf?.z != new_turf?.z)
			SEND_SIGNAL(src, SIGNAL_Z_CHANGED, src, old_turf, new_turf)

		if(ISCARDINALDIR(direct)) // Cardinal move
			. = ..()
			if(dir != direct)
				set_dir(direct)
		else // Diagonal move, split it into cardinal moves
			moving_diagonally = /atom/movable::FIRST_DIAGONAL_STEP
			var/first_step_dir
			// The `&& moving_diagonally` checks are so that a forceMove taking
			// place due to a Crossed, Bumped, etc. call will interrupt
			// the second half of the diagonal movement, or the second attempt
			// at a first half if step() fails because we hit something.
			if(direct & NORTH)
				if(direct & EAST)
					if(step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = /atom/movable::SECOND_DIAGONAL_STEP
						. = step(src, EAST)
					else if(moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = /atom/movable::SECOND_DIAGONAL_STEP
						. = step(src, NORTH)
				else if(direct & WEST)
					if(step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = /atom/movable::SECOND_DIAGONAL_STEP
						. = step(src, WEST)
					else if (moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = /atom/movable::SECOND_DIAGONAL_STEP
						. = step(src, NORTH)
			else if(direct & SOUTH)
				if(direct & EAST)
					if (step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = /atom/movable::SECOND_DIAGONAL_STEP
						. = step(src, EAST)
					else if(moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = /atom/movable::SECOND_DIAGONAL_STEP
						. = step(src, SOUTH)
				else if(direct & WEST)
					if(step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = /atom/movable::SECOND_DIAGONAL_STEP
						. = step(src, WEST)
					else if(moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = /atom/movable::SECOND_DIAGONAL_STEP
						. = step(src, SOUTH)

			if(moving_diagonally == /atom/movable::SECOND_DIAGONAL_STEP)
				if(!.)
					set_dir(first_step_dir)
				else if(!inertia_moving)
					inertia_next_move = world.time + inertia_move_delay
					space_drift(direct ? direct : last_move)

			moving_diagonally = FALSE
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	last_move = direct
	move_speed = world.time - src.l_move_time
	l_move_time = world.time

	// Cursed pieces of code that we need right here for reasons.
	if(.)
		// 'Check code/modules/lighting/lighting_atom.dm'
		if(light_sources)
			for(var/datum/light_source/L in light_sources)
				L.source_atom.update_light()

		// Check '‎code/modules/mob/observer/freelook/update_triggers.dm'
		if(opacity)
			updateVisibility(src)

		if(!inertia_moving)
			inertia_next_move = world.time + inertia_move_delay
			space_drift(direct ? direct : last_move)

		SEND_SIGNAL(src, SIGNAL_MOVED, src, oldloc, loc)

	return

/proc/step_glide(atom/movable/am, dir, glide_size_override)
	am.set_glide_size(glide_size_override)
	return step(am, dir)

/client/Move(n, direction)
	return mob.SelfMove(direction)

/mob/is_space_movement_permitted(allow_movement = FALSE)
	. = ..()
	if(.)
		return

	if(length(grabbed_by))
		return SPACE_MOVE_PERMITTED

	var/atom/movable/footing = get_solid_footing(!has_magnetised_footing())
	if(footing)
		if(istype(footing) && allow_movement)
			return footing
		return SPACE_MOVE_SUPPORTED

/mob/living/is_space_movement_permitted(allow_movement = FALSE)
	. = ..()
	if(.)
		return

	var/obj/item/tank/jetpack/thrust = get_jetpack()
	if(thrust && thrust.on && (allow_movement || thrust.stabilization_on) && thrust.allow_thrust(0.01, src))
		return SPACE_MOVE_PERMITTED

/mob/proc/get_jetpack()
	return

// space_move_result can be:
// - SPACE_MOVE_FORBIDDEN,
// - SPACE_MOVE_PERMITTED,
// - SPACE_MOVE_SUPPORTED (for non-movable atoms),
// - or an /atom/movable that provides footing.
/mob/proc/try_space_move(space_move_result, direction)
	if(ismovable(space_move_result))//push off things in space
		handle_space_pushoff(space_move_result, direction)
		space_move_result = SPACE_MOVE_SUPPORTED
	return space_move_result != SPACE_MOVE_SUPPORTED || !handle_spaceslipping()

/mob/proc/handle_space_pushoff(atom/movable/AM, direction)
	if(AM.anchored)
		return

	if(ismob(AM))
		var/mob/M = AM
		if(!M.can_slip(magboots_only = TRUE))
			return

	AM.inertia_ignore = src
	if(step(AM, turn(direction, 180)))
		to_chat(src, SPAN("notice", "You push off of [AM] to propel yourself."))
		inertia_ignore = AM

//return 1 if slipped, 0 otherwise
/mob/proc/handle_spaceslipping()
	if(!buckled && prob(get_eva_slip_prob()))
		to_chat(src, "<span class='warning'>You slipped!</span>")
		step(src, turn(last_move, pick(45,-45)))
		return 1
	return 0

/mob/proc/get_eva_slip_prob(prob_slip = 10)
	// General slip check.
	if((has_gravity() || has_magnetised_footing()) && get_solid_footing() || m_intent == M_WALK)
		return 0
	var/obj/item/tank/jetpack/thrust = get_jetpack()
	if(thrust && thrust.on && thrust.stabilization_on)
		return 0 // Otherwise we are unable to slip in outer space, but still may slip while crawling along the hull.
	if(m_intent != M_RUN)
		prob_slip *= 0.5
	return max(prob_slip, 0)

/mob/proc/update_gravity()
	return

/mob/proc/mob_has_gravity()
	return has_gravity(src)

/mob/proc/mob_negates_gravity()
	return 0

#define DO_MOVE(this_dir) var/final_dir = turn(this_dir, -dir2angle(dir)); Move(get_step(mob, final_dir), final_dir);

/client/verb/moveup()
	set name = ".moveup"
	set instant = 1
	DO_MOVE(NORTH)

/client/verb/movedown()
	set name = ".movedown"
	set instant = 1
	DO_MOVE(SOUTH)

/client/verb/moveright()
	set name = ".moveright"
	set instant = 1
	DO_MOVE(EAST)

/client/verb/moveleft()
	set name = ".moveleft"
	set instant = 1
	DO_MOVE(WEST)

#undef DO_MOVE

/mob/proc/update_move_intent_slowdown()
	add_movespeed_modifier((m_intent == M_WALK) ? /datum/movespeed_modifier/walk : /datum/movespeed_modifier/run)
