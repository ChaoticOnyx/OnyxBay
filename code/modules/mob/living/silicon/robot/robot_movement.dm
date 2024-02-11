/mob/living/silicon/robot/slip_chance(prob_slip)
	if(module && module.no_slip)
		return 0
	..(prob_slip)

/mob/living/silicon/robot/Check_Shoegrip()
	if(module && module.no_slip)
		return 1
	return 0

/mob/living/silicon/robot/Allow_Spacemove()
	if(module)
		for(var/obj/item/tank/jetpack/J in module.modules)
			if(J && J.allow_thrust(0.01))
				return 1
	. = ..()

/mob/living/silicon/robot/Initialize(mapload, ...)
	. = ..()
	add_movespeed_modifier(/datum/movespeed_modifier/robot_movement)
