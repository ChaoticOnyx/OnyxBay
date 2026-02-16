/obj/machinery/atmospherics/var/image/pipe_image

/obj/machinery/atmospherics/Destroy()
	for(var/mob/living/M in src) //ventcrawling is serious business
		M.remove_ventcrawl()
		M.dropInto(loc)
	if(pipe_image)
		for(var/mob/living/M in GLOB.player_list)
			if(M.client)
				M.client.images -= pipe_image
				M.pipes_shown -= pipe_image
		pipe_image = null
	return ..()

/obj/machinery/atmospherics/ex_act(severity)
	for(var/atom/movable/A in src) //ventcrawling is serious business
		A.ex_act(severity)
	. = ..()

/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	if(user.loc != src || !(direction & initialize_directions)) //can't go in a way we aren't connecting to
		return
	var/datum/movement_handler/mob/delay/delay = user.GetMovementHandler(/datum/movement_handler/mob/delay)
	if(delay && delay.MayMove(user, FALSE) == MOVEMENT_PROCEED) // Yes, this DOES look fucked up. It shouldn't be used this way. But screw it this whole ventcrawl thing is a mess so who the fuck cares
		direction = ((direction) & -(direction)) // Only cardinals allowed.
		ventcrawl_to(user, findConnecting(direction), direction) // TODO: Make a fucking handler for this piece of VG shit
		user.setMoveCooldown(user.movement_delay())

/obj/machinery/atmospherics/proc/ventcrawl_to(mob/living/user, obj/machinery/atmospherics/target_move, direction)
	if(target_move)
		if(is_type_in_list(target_move, ventcrawl_machinery))
			if(!target_move.can_crawl_through())
				if(!target_move.breakout(user))
					return
			user.remove_ventcrawl()
			user.forceMove(target_move.loc) //handles entering and so on
			user.visible_message("You hear something squeezing through the ducts.", "You climb out the ventilation system.")
		else if(target_move.can_crawl_through())
			if(target_move.return_network(target_move) != return_network(src))
				user.remove_ventcrawl()
				user.add_ventcrawl(target_move)
			user.forceMove(target_move)
			user.client.eye = target_move //if we don't do this, Byond only updates the eye every tick - required for smooth movement
			if(world.time > user.next_play_vent)
				user.next_play_vent = world.time + 15
				playsound(src, SFX_VENT, rand(20, 45), FALSE)
	else
		if((direction & initialize_directions) || is_type_in_list(src, ventcrawl_machinery) && src.can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
			user.remove_ventcrawl()
			user.forceMove(src.loc)
			user.visible_message("You hear something squeezing through the pipes.", "You climb out the ventilation system.")

/obj/machinery/atmospherics/proc/can_crawl_through()
	return 1

/obj/machinery/atmospherics/unary/vent_pump/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/unary/vent_scrubber/can_crawl_through()
	return !welded


/obj/machinery/atmospherics/proc/breakout(mob/living/user)
	return

/obj/machinery/atmospherics/unary/vent_pump/breakout(mob/living/user)
	var/datum/modifier/trait/vent_breaker/vent_breaker = locate(/datum/modifier/trait/vent_breaker) in user.modifiers
	if(vent_breaker && (vent_breaker?.ignore_size_restrictions || !issmall(user)))
		if(broken == VENT_BROKEN)
			return 1
		user.visible_message(SPAN_WARNING("You hear something start break the ducts."), SPAN_NOTICE("You start breaking out the ventilation system."))
		shake_animation(stime=20)
		switch(broken)
			if(VENT_UNDAMAGED)

				if(do_after(user, 50, src, 1, 1))
					broken = VENT_DAMAGED_STAGE_ONE

			if(VENT_DAMAGED_STAGE_ONE)
				if(do_after(user, 50, src, 1, 1))
					broken = VENT_DAMAGED_STAGE_TWO

			if(VENT_DAMAGED_STAGE_TWO)
				if(do_after(user, 40, src, 1, 1))
					broken = VENT_DAMAGED_STAGE_THREE

			if(VENT_DAMAGED_STAGE_THREE)
				if(do_after(user, 30, src, 1, 1))
					broken = VENT_BROKEN
					welded = 0
					update_icon()
					return 1

		update_icon()
		return 0

	if(issmall(user))
		to_chat(user, SPAN_NOTICE("Sorry but you are too small."))

	user.visible_message(SPAN_WARNING("You hear something bumped into the ducts."), SPAN_NOTICE("You bumped into the ventilation system."))
	shake_animation()
	return 0

/obj/machinery/atmospherics/unary/vent_scrubber/breakout(mob/living/user)
	var/datum/modifier/trait/vent_breaker/vent_breaker = locate(/datum/modifier/trait/vent_breaker) in user.modifiers
	if(vent_breaker && (vent_breaker?.ignore_size_restrictions || !issmall(user)))
		if(broken == VENT_BROKEN)
			return 1
		user.visible_message(SPAN_WARNING("You hear something start break the ducts."), SPAN_NOTICE("You start breaking out the ventilation system."))
		shake_animation(stime=20)
		switch(broken)
			if(VENT_UNDAMAGED)

				if(do_after(user, 50, src, 1, 1))
					broken = VENT_DAMAGED_STAGE_ONE

			if(VENT_DAMAGED_STAGE_ONE)
				if(do_after(user, 50, src, 1, 1))
					broken = VENT_DAMAGED_STAGE_TWO

			if(VENT_DAMAGED_STAGE_TWO)
				if(do_after(user, 40, src, 1, 1))
					broken = VENT_DAMAGED_STAGE_THREE

			if(VENT_DAMAGED_STAGE_THREE)
				if(do_after(user, 30, src, 1, 1))
					broken = VENT_BROKEN
					welded = 0
					update_icon()
					return 1

		update_icon()
		return 0

	if(issmall(user))
		to_chat(user, SPAN_NOTICE("Sorry but you are too small."))

	user.visible_message(SPAN_WARNING("You hear something bumped into the ducts."), SPAN_NOTICE("You bumped into the ventilation system."))
	shake_animation()
	return 0


/obj/machinery/atmospherics/proc/findConnecting(direction)
	for(var/obj/machinery/atmospherics/target in get_step(src,direction))
		if(target.initialize_directions & get_dir(target,src))
			if(isConnectable(target) && target.isConnectable(src))
				return target

/obj/machinery/atmospherics/proc/isConnectable(obj/machinery/atmospherics/target)
	return (target == node1 || target == node2)

/obj/machinery/atmospherics/pipe/manifold/isConnectable(obj/machinery/atmospherics/target)
	return (target == node3 || ..())

/obj/machinery/atmospherics/trinary/isConnectable(obj/machinery/atmospherics/target)
	return (target == node3 || ..())

/obj/machinery/atmospherics/pipe/manifold4w/isConnectable(obj/machinery/atmospherics/target)
	return (target == node3 || target == node4 || ..())

/obj/machinery/atmospherics/tvalve/isConnectable(obj/machinery/atmospherics/target)
	return (target == node3 || ..())

/obj/machinery/atmospherics/pipe/cap/isConnectable(obj/machinery/atmospherics/target)
	return (target == node || ..())

/obj/machinery/atmospherics/portables_connector/isConnectable(obj/machinery/atmospherics/target)
	return (target == node || ..())

/obj/machinery/atmospherics/unary/isConnectable(obj/machinery/atmospherics/target)
	return (target == node || ..())

/obj/machinery/atmospherics/valve/isConnectable()
	return (open && ..())
