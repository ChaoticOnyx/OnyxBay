/turf/unsimulated/floor/liquid_plasma
	icon_state = "liquidplasma"
	temperature = -30 CELSIUS

// /turf/unsimulated/floor/liquid_plasma/proc/attack_hand()
// 	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
// 	if(istype(/obj/item/reagent_containers))
// 		standard_dispenser_refill

/turf/unsimulated/floor/liquid_plasma/is_plating(mob/user)
	return TRUE
