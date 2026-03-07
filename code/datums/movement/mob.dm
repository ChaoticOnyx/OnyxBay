// Movement relayed to self handling
/datum/movement_handler/mob/relayed_movement
	var/prevent_host_move = FALSE
	var/list/allowed_movers

/datum/movement_handler/mob/relayed_movement/MayMove(mob/mover, is_external)
	if(is_external)
		return MOVEMENT_PROCEED
	if(mover == mob && !(prevent_host_move && LAZYLEN(allowed_movers) && !LAZYISIN(allowed_movers, mover)))
		return MOVEMENT_PROCEED
	if(LAZYISIN(allowed_movers, mover))
		return MOVEMENT_PROCEED

	return MOVEMENT_STOP

/datum/movement_handler/mob/relayed_movement/proc/AddAllowedMover(mover)
	LAZYDISTINCTADD(allowed_movers, mover)

/datum/movement_handler/mob/relayed_movement/proc/RemoveAllowedMover(mover)
	LAZYREMOVE(allowed_movers, mover)

// Admin object possession
/datum/movement_handler/mob/admin_possess/DoMove(direction, mob/mover, is_external)
	if(QDELETED(mob.control_object))
		return MOVEMENT_REMOVE

	. = MOVEMENT_HANDLED

	var/atom/movable/control_object = mob.control_object
	step(control_object, direction)
	if(QDELETED(control_object))
		. |= MOVEMENT_REMOVE
	else
		control_object.set_dir(direction)

// Death handling
/datum/movement_handler/mob/death/DoMove(direction, mob/mover, is_external)
	if(!mob.is_ooc_dead())
		return
	. = MOVEMENT_HANDLED
	if(!mob.client)
		if(mover != mob)
			. = MOVEMENT_PROCEED
		return
	mob.ghostize()

// Incorporeal/Ghost movement
/datum/movement_handler/mob/incorporeal/DoMove(direction, mob/mover, is_external)
	. = MOVEMENT_HANDLED
	direction = mob.AdjustMovementDirection(direction)

	var/turf/T = get_step(mob, direction)
	if(!mob.MayEnterTurf(T))
		return

	if(!mob.forceMove(T))
		return

	mob.set_dir(direction)
	mob.PostIncorporealMovement()

/mob/proc/PostIncorporealMovement()
	return

// Eye movement
/datum/movement_handler/mob/eye/DoMove(direction, mob/mover, is_external)
	if(IS_NOT_SELF(mover)) // We only care about direct movement
		return
	if(!mob.eyeobj)
		return
	if(direction & (UP|DOWN))
		var/turf/destination = (direction == UP) ? GetAbove(mob.eyeobj) : GetBelow(mob.eyeobj)
		if(!destination)
			to_chat(mob, SPAN("notice", "There is nothing of interest in this direction."))
			return MOVEMENT_HANDLED
	mob.eyeobj.EyeMove(direction)
	return MOVEMENT_HANDLED

/datum/movement_handler/mob/eye/MayMove(mob/mover, is_external)
	if(IS_NOT_SELF(mover))
		return MOVEMENT_PROCEED
	if(is_external)
		return MOVEMENT_PROCEED
	if(!mob.eyeobj)
		return MOVEMENT_PROCEED
	return (MOVEMENT_PROCEED|MOVEMENT_HANDLED)

// Space movement
/datum/movement_handler/mob/space
	var/last_space_move_result

// Notes on space movement chain:
// - owning mob calls MayMove() via normal movement handler chain
// - MayMove() sets last_space_move_result based on is_space_movement_permitted() (checks for footing, magboots, etc)
// - last_space_move_result is checked in DoMove() and passed to try_space_move() as a param, which returns TRUE/FALSE
// - if the original move result was forbidden, or try_space_move() fails, the handler prevents movement.
// - Otherwise it goes ahead and lets the mob move.

/datum/movement_handler/mob/space/DoMove(direction, mob/mover, is_external)
	if(mob.has_gravity() || (IS_NOT_SELF(mover) && is_external))
		return
	if(last_space_move_result == SPACE_MOVE_FORBIDDEN || !mob.try_space_move(last_space_move_result, direction))
		return MOVEMENT_HANDLED

/datum/movement_handler/mob/space/MayMove(mob/mover, is_external)
	if(IS_NOT_SELF(mover) && is_external)
		return MOVEMENT_PROCEED

	if(!mob.has_gravity())
		last_space_move_result = mob.is_space_movement_permitted(allow_movement = TRUE)
		if(last_space_move_result == SPACE_MOVE_FORBIDDEN)
			return MOVEMENT_STOP

	return MOVEMENT_PROCEED

// Buckle movement
/datum/movement_handler/mob/buckle_relay/DoMove(direction, mob/mover, is_external)
	// TODO: Datumlize buckle-handling
	if(istype(mob.buckled, /obj/vehicle))
		//drunk driving
		if(mob.confused && prob(20)) //vehicles tend to keep moving in the same direction
			direction = turn(direction, pick(90, -90))
		mob.buckled.DoMove(direction, mob)
		return MOVEMENT_HANDLED

	if(mob.pulledby || mob.buckled) // Wheelchair driving!
		if(istype(mob.buckled, /obj/effect/dummy/immaterial_form))
			mob.buckled.relaymove(mob, direction)
			return MOVEMENT_HANDLED
		if(istype(mob.loc, /turf/space))
			return // No wheelchair driving in space
		if(istype(mob.buckled, /obj/structure/bed/chair/pedalgen))
			mob.buckled.relaymove(mob, direction)
			return MOVEMENT_HANDLED
		if(istype(mob.pulledby, /obj/structure/bed/chair/wheelchair))
			. = MOVEMENT_HANDLED
			mob.pulledby.DoMove(direction, mob)
		else if(istype(mob.buckled, /obj/structure/bed/chair/wheelchair))
			. = MOVEMENT_HANDLED
			if(ishuman(mob))
				var/mob/living/carbon/human/driver = mob
				var/obj/item/organ/external/l_hand = driver.get_organ(BP_L_HAND)
				var/obj/item/organ/external/r_hand = driver.get_organ(BP_R_HAND)
				if((!l_hand || l_hand.is_stump()) && (!r_hand || r_hand.is_stump()))
					return // No hands to drive your chair? Tough luck!
			//drunk wheelchair driving
			direction = mob.AdjustMovementDirection(direction)
			mob.buckled.DoMove(direction, mob)

/datum/movement_handler/mob/buckle_relay/MayMove(mover, is_external)
	if(mob.buckled)
		return mob.buckled.MayMove(mover, FALSE) ? (MOVEMENT_PROCEED|MOVEMENT_HANDLED) : MOVEMENT_STOP
	return MOVEMENT_PROCEED

// Movement delay
/datum/movement_handler/mob/delay
	var/next_move
	var/delay = 1

/datum/movement_handler/mob/delay/DoMove(direction, mover, is_external)
	if(is_external)
		return
	delay = max(1, (mob.movement_delay() / (IS_POWER_OF_TWO(direction) ? 1.0 : 0.7)) + GetGrabSlowdown())
	next_move = world.time + delay
	UpdateGlideSize()

/datum/movement_handler/mob/delay/MayMove(mover, is_external)
	if(IS_NOT_SELF(mover) && is_external)
		return MOVEMENT_PROCEED
	return ((mover && mover != mob) ||  world.time >= next_move) ? MOVEMENT_PROCEED : MOVEMENT_STOP

/datum/movement_handler/mob/delay/proc/SetDelay(new_delay)
	delay = new_delay
	next_move = max(next_move, world.time + delay)
	UpdateGlideSize()

/datum/movement_handler/mob/delay/proc/AddDelay(add_delay)
	delay += add_delay
	next_move += max(0, add_delay)
	UpdateGlideSize()

/datum/movement_handler/mob/delay/proc/UpdateGlideSize()
	if(mob.buckled)
		mob.buckled.set_glide_size(DELAY2GLIDESIZE(delay))
	else
		host.set_glide_size(DELAY2GLIDESIZE(delay))

/datum/movement_handler/mob/delay/proc/GetGrabSlowdown()
	. = 0
	for (var/obj/item/grab/G in mob)
		if(G.assailant == G.affecting)
			return
		. = max(., G.grab_slowdown())

/datum/movement_handler/mob/delay/proc/InstantUpdateGlideSize()
	var/supposed_delay = max(1, mob.movement_delay() + GetGrabSlowdown())
	host.set_glide_size(DELAY2GLIDESIZE(supposed_delay))

// Stop effect
/datum/movement_handler/mob/stop_effect/DoMove(direction, mob/mover, is_external)
	if(MayMove(mover, is_external) == MOVEMENT_STOP)
		return MOVEMENT_HANDLED

/datum/movement_handler/mob/stop_effect/MayMove(mob/mover, is_external)
	for(var/obj/effect/stop/S in mob.loc)
		if(S.victim == mob)
			return MOVEMENT_STOP
	return MOVEMENT_PROCEED

// Transformation
/datum/movement_handler/mob/transformation/MayMove(mob/mover, is_external)
	return MOVEMENT_STOP

// Consciousness - Is the entity trying to conduct the move conscious?
/datum/movement_handler/mob/conscious/MayMove(mob/mover, is_external)
	return (mover ? mover.stat == CONSCIOUS : mob.stat == CONSCIOUS) ? MOVEMENT_PROCEED : MOVEMENT_STOP

// Along with more physical checks
/datum/movement_handler/mob/physically_capable/MayMove(mob/mover, is_external)
	// We only check physical capability if the host mob tried to do the moving
	return ((mover && mover != mob) || !mob.incapacitated(INCAPACITATION_DISABLED & ~INCAPACITATION_FORCELYING)) ? MOVEMENT_PROCEED : MOVEMENT_STOP

// Is anything physically preventing movement?
/datum/movement_handler/mob/physically_restrained/MayMove(mob/mover, is_external)
	if(istype(mob.buckled) && !(mob.buckled.buckle_movable || mob.buckled.buckle_relaymove))
		if(mover == mob)
			to_chat(mob, SPAN("notice", "You're buckled to \the [mob.buckled]!"))
		return MOVEMENT_STOP

	if(LAZYLEN(mob.pinned))
		if(mover == mob)
			to_chat(mob, SPAN("notice", "You're pinned down by \a [mob.pinned[1]]!"))
		return MOVEMENT_STOP

	if(mob.anchored)
		if(mover == mob)
			to_chat(mob, SPAN("notice", "You're anchored down!"))
		return MOVEMENT_STOP

	for(var/obj/item/grab/G in mob.grabbed_by)
		if(G.assailant != mob && G.assailant != mover && (mob.restrained() || G.stop_move()))
			if(mover == mob)
				to_chat(mob, SPAN("notice", "You're stuck in a grab!"))
			mob.ProcessGrabs()
			return MOVEMENT_STOP

	if(mob.restrained())
		for(var/mob/M in range(mob, 1))
			if(M.pulling == mob)
				if(!M.incapacitated() && mob.Adjacent(M))
					if(mover == mob)
						to_chat(mob, SPAN("notice", "You're restrained! You can't move!"))
					return MOVEMENT_STOP
				else
					M.stop_pulling()

	return MOVEMENT_PROCEED


/mob/living/ProcessGrabs()
	//if we are being grabbed
	if(grabbed_by.len)
		resist_grab("auto_move_process") // Uses GRAB_RESIST_CD and does not touch click cooldown.

/mob/proc/ProcessGrabs()
	return


// Finally.. the last of the mob movement junk
/datum/movement_handler/mob/movement/DoMove(direction, mob/mover, is_external)
	. = MOVEMENT_HANDLED
	if(mob.moving)
		return

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	//We are now going to move
	mob.moving = 1

	direction = mob.AdjustMovementDirection(direction)
	var/old_turf = get_turf(mob)

	if(direction & (UP|DOWN))
		var/txt_dir = direction & UP ? "upwards" : "downwards"
		mob.visible_message(SPAN("notice", "[mob] moves [txt_dir]."))
		if(mob.pulling)
			mob.zPull(direction)

	step(mob, direction)

	if(QDELETED(mob))
		return // If the mob gets deleted on move (e.g. Entered, whatever), it wipes this reference on us in Destroy (and we should be aborting all action anyway).
	// Something with pulling things

	if(mob.loc == old_turf) // Did not move for whatever reason.
		mob.moving = FALSE
		return

	var/turf/new_loc = mob.loc
	if(istype(new_loc))
		HandleGrabs(direction, old_turf)

	for(var/obj/item/grab/G in mob)
		if(G.reverse_moving())
			G.assailant.set_dir(GLOB.reverse_dir[direction])
			G.affecting.set_dir(GLOB.reverse_dir[direction])
		if(G.current_grab.downgrade_on_move)
			G.downgrade()
	for(var/obj/item/grab/G in mob.grabbed_by)
		G.adjust_position()

	mob.moving = FALSE

/datum/movement_handler/mob/movement/MayMove(mob/mover, is_external)
	return IS_SELF(mover) && mob.moving ? MOVEMENT_STOP : MOVEMENT_PROCEED

/datum/movement_handler/mob/movement/proc/HandleGrabs(direction, old_turf)
	. = 0
	// TODO: Look into making grabs use movement events instead, this is a mess.
	for(var/obj/item/grab/G in mob)
		if(G.assailant == G.affecting)
			return
		var/list/L = mob.ret_grab()
		if(istype(L, /list))
			if(L.len == 2)
				L -= mob
				var/mob/M = L[1]
				if(M)
					if(get_dist(old_turf, M) <= 1)
						if(isturf(M.loc) && isturf(mob.loc))
							if(mob.loc != old_turf && M.loc != mob.loc)
								step_glide(M, get_dir(M.loc, old_turf), host.glide_size)
			else
				for(var/mob/M in L)
					M.other_mobs = 1
					if(mob != M)
						M.animate_movement = 3
				for(var/mob/M in L)
					spawn(0)
						step(M, direction)
						return
					spawn(1)
						M.other_mobs = null
						M.animate_movement = 2
						return
			G.adjust_position()

// Misc. helpers
/mob/proc/MayEnterTurf(turf/T)
	return T && !((mob_flags & MOB_FLAG_HOLY_BAD) && check_is_holy_turf(T))

/mob/proc/AdjustMovementDirection(direction)
	. = direction
	if(!confused)
		return

	if(lying)
		return

	switch(m_intent)
		if(M_RUN)
			if(prob(25))
				return
		if(M_WALK)
			if(prob(75))
				return

	return prob(50) ? GLOB.cw_dir[.] : GLOB.ccw_dir[.]
