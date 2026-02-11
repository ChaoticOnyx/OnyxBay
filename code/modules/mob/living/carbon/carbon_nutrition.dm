#define UPDATE_DELAY 1 MINUTE

/// Helper for adding nutrition. Automatically updates movespeed. Use this instead of adding nutrition manually.
/mob/living/carbon/proc/add_nutrition(amount)
	if(isSynthetic())
		return

	nutrition = max(0, nutrition + amount)
	if(amount >= 1 || world.time >= last_nutrition_speed_update + UPDATE_DELAY) // This proc is often called with extremely small amounts
		update_nutrition_movespeed_if_necessary()

/mob/living/carbon/human/add_nutrition(amount)
	if(isSynthetic())
		return

	nutrition = clamp(nutrition + amount, 0, STOMACH_FULLNESS_CAP * body_build.stomach_capacity)
	if(amount >= 1 || world.time >= last_nutrition_speed_update + UPDATE_DELAY) // This proc is often called with extremely small amounts
		update_nutrition_movespeed_if_necessary()


/// Helper for subtracting nutrition. Automatically updates movespeed. Use this instead of subtracting nutrition manually.
/mob/living/carbon/proc/remove_nutrition(amount)
	if(isSynthetic())
		return

	nutrition = max(0, nutrition - amount)
	if(amount >= 1  || world.time >= last_nutrition_speed_update + UPDATE_DELAY) // This proc is often called with extremely small amounts
		update_nutrition_movespeed_if_necessary()

/mob/living/carbon/human/remove_nutrition(amount)
	if(isSynthetic())
		return

	nutrition = clamp(nutrition - amount, 0, STOMACH_FULLNESS_CAP * body_build.stomach_capacity)
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
	if(isSynthetic())
		return

	var/normalized_nutrition = nutrition / body_build.stomach_capacity

	var/res_slowdown = 0.0

	if(normalized_nutrition < STOMACH_FULLNESS_LOW)
		res_slowdown = 1.25 - (normalized_nutrition / 100)

	if(should_have_organ(BP_STOMACH))
		var/obj/item/organ/internal/stomach/S = internal_organs_by_name[BP_STOMACH]
		if(S)
			res_slowdown = max(res_slowdown, (S.get_fullness() - 100) / 50)

	if(res_slowdown)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/nutrition_slowdown, slowdown = res_slowdown)
	else if(has_movespeed_modifier(/datum/movespeed_modifier/nutrition_slowdown))
		remove_movespeed_modifier(/datum/movespeed_modifier/nutrition_slowdown)

#undef UPDATE_DELAY
