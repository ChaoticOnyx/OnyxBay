/datum/ai_behavior/basic_melee_attack
	action_cooldown = 0.2 SECONDS // We gotta check unfortunately often because we're in a race condition with nextmove
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	///do we finish this action after hitting once?
	var/terminate_after_action = FALSE

/datum/ai_behavior/basic_melee_attack/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!controller.blackboard[targeting_strategy_key])
		CRASH("No targeting strategy was supplied in the blackboard for [controller.pawn]")
	//if(HAS_TRAIT(controller.pawn, TRAIT_HANDS_BLOCKED))
	//	return FALSE
	//Hiding location is priority
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	set_movement_target(controller, target)

/datum/ai_behavior/basic_melee_attack/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	if (isliving(controller.pawn))
		var/mob/living/pawn = controller.pawn
		if (world.time < pawn.next_move)
			return AI_BEHAVIOR_INSTANT

	var/mob/living/basic_mob = controller.pawn
	//targeting strategy will kill the action if not real anymore
	var/atom/target = controller.blackboard[target_key]
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy.can_attack(basic_mob, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/hiding_target = targeting_strategy.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!

	controller.set_blackboard_key(hiding_location_key, hiding_target)

	if(hiding_target) //Slap it!
		basic_mob.UnarmedAttack(hiding_target)
	else
		basic_mob.UnarmedAttack(target)

	if(terminate_after_action)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/basic_melee_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key)

/datum/ai_behavior/basic_melee_attack/interact_once
	terminate_after_action = TRUE

/datum/ai_behavior/basic_melee_attack/interact_once/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
