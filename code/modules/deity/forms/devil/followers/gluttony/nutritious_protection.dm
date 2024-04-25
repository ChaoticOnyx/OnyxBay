/datum/modifier/nutritious_protection/tick()
	var/mob/living/carbon/human/H = holder
	if(!istype(H))
		return

	var/normalized_nutrition = H.nutrition / H.body_build.stomach_capacity
	switch(normalized_nutrition)
		if(0 to STOMACH_FULLNESS_LOW)
			incoming_damage_percent = 2
		if(STOMACH_FULLNESS_MEDIUM to STOMACH_FULLNESS_HIGH)
			incoming_damage_percent = 1
		if(STOMACH_FULLNESS_HIGH to STOMACH_FULLNESS_SUPER_HIGH)
			incoming_damage_percent = 0.75
		else
			incoming_damage_percent = 0.5
