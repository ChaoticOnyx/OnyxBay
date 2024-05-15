/datum/evolution_holder/gluttony
	evolution_categories = list(
		/datum/evolution_category/gluttony
	)
	default_modifiers = list(/datum/modifier/sin/gluttony)

/datum/evolution_category/gluttony
	name = "Sin of Gluttony"
	items = list(
		/datum/evolution_package/gluttony_heal,
		/datum/evolution_package/nutritious_protection,
		/datum/evolution_package/edible_shield,
	)

/datum/evolution_package/gluttony_heal
	name = "Nutritious Heal"
	desc = "Turn fats, carbs and proteins into a regenerative energy for you and your comrades."
	cost = 0
	actions = list(
		/datum/action/cooldown/spell/gluttony_heal
	)

/datum/evolution_package/nutritious_protection
	name = "Nutritious Protection"
	desc = "Use carbohydrates as an additional level of protection."
	cost = 1
	modifiers = list(
		/datum/modifier/nutritious_protection
	)
	unlocked_by = list(/datum/evolution_package/gluttony_heal)

/datum/evolution_package/edible_shield
	name = "Edible Shield"
	desc = "Creates a whirl of food, creating a protective shield around you."
	cost = 1
	modifiers = list(
		/datum/action/cooldown/spell/edible_shield
	)
	unlocked_by = list(/datum/evolution_package/gluttony_heal)

/datum/modifier/sin/gluttony
	name = "Gluttony"
	desc = "GLUTTONY."

	metabolism_percent = 2
	incoming_healing_percent = 1.5

	var/sin_points = 0

/datum/modifier/sin/gluttony/tick()
	var/mob/living/carbon/human/H = holder
	ASSERT(H)

	var/normalized_nutrition = H.nutrition / H.body_build.stomach_capacity
	if(normalized_nutrition >= STOMACH_FULLNESS_HIGH)
		sin_points += 1 * SSmobs.wait
