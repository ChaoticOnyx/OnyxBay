#define UPDATE_DELAY 1 MINUTE

/// Helper for adding nutrition. Automatically updates movespeed. Use this instead of adding nutrition manually.
/mob/living/carbon/proc/add_nutrition(amount)
	nutrition = max(0, nutrition += amount)
	if(amount >= 1 || world.time >= last_nutrition_speed_update + UPDATE_DELAY) // This proc is often called with extremely small amounts
		update_nutrition_movespeed_if_necessary()

/// Helper for subtracting nutrition. Automatically updates movespeed. Use this instead of subtracting nutrition manually.
/mob/living/carbon/proc/remove_nutrition(amount)
	nutrition = max(0, nutrition -= amount)
	if(amount >= 1  || world.time >= last_nutrition_speed_update + UPDATE_DELAY) // This proc is often called with extremely small amounts
		update_nutrition_movespeed_if_necessary()

/// Helper for setting nutrition. Automatically updates movespeed. Use this instead of subtracting nutrition manually.
/mob/living/carbon/proc/set_nutrition(amount)
	var/nut_old = nutrition
	nutrition = max(0, amount)

	if(nut_old != nutrition)
		update_nutrition_movespeed_if_necessary()

/mob/living/carbon/proc/update_nutrition_movespeed_if_necessary()
	return

/mob/living/carbon/human/update_nutrition_movespeed_if_necessary()
	last_nutrition_speed_update = world.time
	if(full_prosthetic)
		return

	var/normalized_nutrition = nutrition / body_build.stomach_capacity
	switch(normalized_nutrition)
		if(0 to STOMACH_FULLNESS_LOW)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/nutrition_slowdown, slowdown = (1.25 - (normalized_nutrition / 100)))
		if(STOMACH_FULLNESS_HIGH to INFINITY)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/nutrition_slowdown, slowdown = ((normalized_nutrition / 100) - 4.25))
		else if(has_movespeed_modifier(/datum/movespeed_modifier/nutrition_slowdown))
			remove_movespeed_modifier(/datum/movespeed_modifier/nutrition_slowdown)

#undef UPDATE_DELAY
