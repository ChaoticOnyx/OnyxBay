/datum/modifier/status_effect/water_affected
	name = "wateraffected"

/datum/modifier/status_effect/water_affected/on_applied()
	//We should be inside a liquid turf if this is applied
	calculate_water_slow()
	return TRUE

/datum/modifier/status_effect/water_affected/proc/calculate_water_slow()
	//Factor in swimming skill here?
	var/turf/T = get_turf(holder)
	var/slowdown_amount = T.liquids.liquid_state * 0.5
	holder.setMoveCooldown(slowdown_amount)

/datum/modifier/status_effect/water_affected/tick()
	var/turf/T = get_turf(holder)
	if(!T || !T.liquids || T.liquids.liquid_state == LIQUID_STATE_PUDDLE)
		qdel(src)
		return
	calculate_water_slow()
	//Make the reagents touch the person
	var/fraction = SUBMERGEMENT_PERCENT(holder, T.liquids)
	var/datum/reagents/tempr = T.liquids.simulate_reagents_flat(SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT*fraction)
	tempr.touch_mob(holder)
	tempr.trans_to(holder)
	qdel(tempr)
	return ..()

/datum/modifier/status_effect/water_affected/on_expire()
	holder.setMoveCooldown(holder.movement_delay())
