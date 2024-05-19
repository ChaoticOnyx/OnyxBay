/datum/ai_controller/basic_controller
	movement_delay = 0.4 SECONDS

/datum/ai_controller/basic_controller/TryPossessPawn(atom/new_pawn)
	if(!ismob(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	var/mob/living/basic_mob = new_pawn

	update_speed(basic_mob)

	//register_signal(basic_mob, list(POST_BASIC_MOB_UPDATE_VARSPEED, COMSIG_MOB_MOVESPEED_UPDATED), nameof(.proc/update_speed))

	return ..() //Run parent at end

/datum/ai_controller/basic_controller/able_to_run()
	. = ..()
	if(!isliving(pawn))
		return
	var/mob/living/living_pawn = pawn
	var/incap_flags = 0
	if(!(ai_traits & CAN_ACT_WHILE_DEAD) && (living_pawn.incapacitated(incap_flags) || living_pawn.stat))
		return FALSE
	if(ai_traits & PAUSE_DURING_DO_AFTER && LAZYLEN(living_pawn.do_afters))
		return FALSE

/datum/ai_controller/basic_controller/proc/update_speed(mob/living/basic_mob)
	SIGNAL_HANDLER
	movement_delay = basic_mob.cached_slowdown

/mob/living/carbon/alien
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile

/mob/living/carbon/alien/Initialize()
	. = ..()
	ai_controller = new ai_controller(src)
