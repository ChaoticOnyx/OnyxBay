/mob/living/carbon/proc/add_nutrition(amount)
	nutrition = max(0, nutrition += amount)
	if(amount >= 1) // This proc is often called with extremely small amounts
		update_movespeed_if_necessary()

/mob/living/carbon/proc/remove_nutrition(amount)
	nutrition = max(0, nutrition -= amount)
	if(amount >= 1) // This proc is often called with extremely small amounts
		update_movespeed_if_necessary()

/mob/living/carbon/proc/set_nutrition(amount)
	if(nutrition != amount)
		update_movespeed_if_necessary()

	nutrition = max(0, amount)

/mob/living/carbon/proc/update_movespeed_if_necessary()
	return

/mob/living/carbon/human/update_movespeed_if_necessary()
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
