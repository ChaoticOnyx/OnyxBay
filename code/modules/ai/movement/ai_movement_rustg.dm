/datum/ai_movement/rustg
	max_pathing_attempts = 4
	requires_processing = TRUE

///Put your movement behavior in here!
/datum/ai_movement/rustg/think()
	for(var/datum/ai_controller/controller as anything in moving_controllers)

		//if(!COOLDOWN_FINISHED(controller, movement_cooldown))
		//	continue
		//COOLDOWN_START(controller, movement_cooldown, controller.movement_delay)

		var/atom/movable/movable_pawn = controller.pawn

		// Check if this controller can actually run, so we don't chase people with corpses
		if(!controller.able_to_run())
			walk(controller.pawn, 0) //stop moving
			controller.CancelActions()
			continue

		if(!isturf(movable_pawn.loc)) //No moving if not on a turf
			continue

		if(controller.ai_traits & STOP_MOVING_WHEN_PULLED && movable_pawn.pulledby)
			continue

		var/minimum_distance = controller.max_target_distance
		// right now I'm just taking the shortest minimum distance of our current behaviors, at some point in the future
		// we should let whatever sets the current_movement_target also set the min distance and max path length
		// (or at least cache it on the controller)
		if(LAZYLEN(controller.current_behaviors))
			for(var/datum/ai_behavior/iter_behavior as anything in controller.current_behaviors)
				if(iter_behavior.required_distance < minimum_distance)
					minimum_distance = iter_behavior.required_distance

		if(get_dist(movable_pawn, controller.current_movement_target) <= minimum_distance)
			continue

		var/generate_path = FALSE // set to TRUE when we either have no path, or we failed a step
		if(length(controller.movement_path))
			var/list/pos = controller.movement_path[controller.movement_path.len - 1]
			var/turf/next_step = locate(pos["x"], pos["y"], pos["z"])

			movable_pawn.Move(next_step)

			// this check if we're on exactly the next tile may be overly brittle for dense pawns who may get bumped slightly
			// to the side while moving but could maybe still follow their path without needing a whole new path
			if(get_turf(movable_pawn) == next_step)
				controller.movement_path.Cut(controller.movement_path.len - 1, controller.movement_path.len)
			else
				generate_path = TRUE
		else
			generate_path = TRUE

		if(generate_path)
			//if(!COOLDOWN_FINISHED(controller, repath_cooldown))
			//	continue

			controller.pathing_attempts++
			if(controller.pathing_attempts >= max_pathing_attempts)
				controller.CancelActions()
				continue

			//COOLDOWN_START(controller, repath_cooldown, 2 SECONDS)
			var/result = rustg_generate_path_astar(\
				json_encode(list("x" = movable_pawn.x, "y" = movable_pawn.y, "z" = movable_pawn.z)),\
				json_encode(list("x" = controller.current_movement_target.x, "y" = controller.current_movement_target.y, "z" = controller.current_movement_target.z)),\
				NODE_TURF_BIT,\
				(NODE_DENSE_BIT | NODE_SPACE_BIT),\
				null\
			)

			if(!rustg_json_is_valid(result))
				util_crash_with(result)
				continue

			controller.movement_path = json_decode(result)

	set_next_think(world.time + 0.5 SECONDS)

/datum/ai_movement/rustg/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target)
	controller.movement_path = null
	return ..()

/datum/ai_movement/rustg/stop_moving_towards(datum/ai_controller/controller)
	controller.movement_path = null
	return ..()

/datum/ai_movement/rustg/bot
	max_pathing_attempts = 25

/datum/ai_movement/rustg/bot/travel_to_beacon
	//maximum_length = 200
