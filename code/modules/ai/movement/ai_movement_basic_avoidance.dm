///Uses Byond's basic obstacle avoidance mvovement
/datum/ai_movement/basic_avoidance
	requires_processing = TRUE
	max_pathing_attempts = 10

///Put your movement behavior in here!
/datum/ai_movement/basic_avoidance/think()
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		///if(!COOLDOWN_FINISHED(controller, movement_cooldown))
		///	continue
		///COOLDOWN_START(controller, movement_cooldown, controller.movement_delay)

		var/atom/movable/movable_pawn = controller.pawn

		// Check if this controller can actually run, so we don't chase people with corpses
		if(!controller.able_to_run())
			walk(controller.pawn, 0) //stop moving
			controller.CancelActions()
			continue

		var/can_move = TRUE

		if(controller.ai_traits & STOP_MOVING_WHEN_PULLED && movable_pawn.pulledby)
			can_move = FALSE

		if(!isturf(movable_pawn.loc)) //No moving if not on a turf
			can_move = FALSE

		var/current_loc = get_turf(movable_pawn)

		if(can_move)
			step_to(movable_pawn, controller.current_movement_target, controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE], controller.movement_delay)

		if(current_loc == get_turf(movable_pawn)) //Did we even move after trying to move?
			controller.pathing_attempts++
			if(controller.pathing_attempts >= max_pathing_attempts)
				controller.CancelActions()

	set_next_think(world.time + 1)
