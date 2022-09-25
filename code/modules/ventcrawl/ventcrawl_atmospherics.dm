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
		ventcrawl_to(user, findConnecting(direction), direction) // TODO: Make a fucking handler for this piece of VG shit
		user.setMoveCooldown(user.movement_delay())

/obj/machinery/atmospherics/proc/ventcrawl_to(mob/living/user, obj/machinery/atmospherics/target_move, direction)
	if(target_move)
		if(istype(target_move, /obj/machinery/atmospherics/unary/vent))
			var/obj/machinery/atmospherics/unary/vent/vent_move = target_move
			if(vent_move.can_crawl_through())
				user.remove_ventcrawl()
				user.forceMove(vent_move.loc) //handles entering and so on
				user.visible_message("You hear something squeezing through the ducts.", "You climb out the ventilation system.")
			else if(!vent_move.in_use && vent_move.can_break_weld(user))
				if(vent_move.break_weld(user, target_move))
					user.remove_ventcrawl()
					user.forceMove(vent_move.loc)
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
	return TRUE

/obj/machinery/atmospherics/unary/vent/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/unary/vent/proc/can_break_weld(user)
	return isxenomorph(user)

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

/obj/machinery/atmospherics/unary/vent/proc/break_weld(mob/living/user)
	to_chat(user, SPAN_WARNING("You start breaking through \the [src] in an attempt to break through"))
	in_use = TRUE
	for(var/i in 1 to 3)
		if(!do_after(user, 2 SECOND, src, incapacitation_flags = INCAPACITATION_DEFAULT & ~INCAPACITATION_RESTRAINED)) //5 seconds
			in_use = FALSE
			return FALSE
		if(can_crawl_through())
			in_use = FALSE
			return TRUE
		playsound(loc, 'sound/effects/fighting/smash.ogg', 65, 1)
		visible_message(SPAN_DANGER("\The [src] begins to shake violently!"))
		shake_animation()
	in_use = FALSE
	welded = FALSE
	stat |= BROKEN_CONTROL
	stat |= BROKEN_GRATE
	error_msg = pick(prob(70); "Hardware Error: Control system failure", prob(20); "Hardware Error: Short circuit detected", prob(10); "Hardware Error: Unknown")
	update_icon()
	to_chat(user, SPAN_WARNING("You successfully break out!"))
	visible_message(SPAN_DANGER("\The [user] successfully broke out of \the [src]!"))
	playsound(loc, 'sound/effects/fighting/smash.ogg', 1, 1)
	playsound(src.loc, 'sound/effects/grillehit.ogg', 65, 1)
	shake_animation()
	return TRUE
