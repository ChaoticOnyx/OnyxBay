/mob/living/silicon/robot/has_non_slip_footing(obj/item/shoes)
	if(module && module.no_slip)
		return TRUE
	return FALSE

/mob/living/silicon/robot/has_magnetised_footing(obj/item/shoes)
	if(module && module.no_slip)
		return TRUE
	return FALSE

/mob/living/silicon/robot/get_jetpack()
	return locate(/obj/item/tank/jetpack) in module?.modules

/mob/living/silicon/robot/Initialize(mapload, ...)
	. = ..()
	add_movespeed_modifier(/datum/movespeed_modifier/robot_movement)
