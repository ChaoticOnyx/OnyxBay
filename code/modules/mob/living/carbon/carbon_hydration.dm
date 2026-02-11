#define UPDATE_DELAY 1 MINUTE

/// Helper for adding hydration. Automatically updates movespeed. Use this instead of adding hydration manually.
/mob/living/carbon/proc/add_hydration(amount)
	return

/mob/living/carbon/human/add_hydration(amount)
	if(isSynthetic())
		return

	hydration = clamp(hydration + amount, HYDRATION_NONE, HYDRATION_LIMIT)
	if(amount >= 1 || world.time >= last_hydration_speed_update + UPDATE_DELAY) // This proc is often called with extremely small amounts
		update_hydration_movespeed_if_necessary()


/// Helper for subtracting hydration. Automatically updates movespeed. Use this instead of subtracting hydration manually.
/mob/living/carbon/proc/remove_hydration(amount)
	return

/mob/living/carbon/human/remove_hydration(amount)
	if(isSynthetic())
		return

	hydration = clamp(hydration - amount, HYDRATION_NONE, HYDRATION_LIMIT)
	if(amount >= 1  || world.time >= last_hydration_speed_update + UPDATE_DELAY) // This proc is often called with extremely small amounts
		update_hydration_movespeed_if_necessary()


/// Helper for setting hydration. Automatically updates movespeed. Use this instead of subtracting hydration manually.
/mob/living/carbon/proc/set_hydration(amount)
	var/hyd_old = hydration
	hydration = max(0, amount)

	if(hyd_old != hydration)
		update_hydration_movespeed_if_necessary()


/mob/living/carbon/proc/update_hydration_movespeed_if_necessary()
	return

/mob/living/carbon/human/update_hydration_movespeed_if_necessary()
	last_hydration_speed_update = world.time
	if(isSynthetic())
		return

	if(hydration <= HYDRATION_NONE)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hydration_slowdown, slowdown = 1.0)
	else if(hydration <= HYDRATION_LOW)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hydration_slowdown, slowdown = 0.5)
	else if(has_movespeed_modifier(/datum/movespeed_modifier/hydration_slowdown))
		remove_movespeed_modifier(/datum/movespeed_modifier/hydration_slowdown)

#undef UPDATE_DELAY
