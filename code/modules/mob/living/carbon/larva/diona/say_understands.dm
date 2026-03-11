/mob/living/carbon/larva/diona/say_understands(mob/other, datum/language/speaking = null)
	if (istype(other, /mob/living/carbon/human) && !speaking)
		if(languages.len >= 2) // They have sucked down some blood.
			return 1
	return ..()
