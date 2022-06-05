/mob/living/death()
	. = ..()
	if(.)
		if(hiding)
			hiding = FALSE
		if(controllable)
			controllable = FALSE
			GLOB.available_mobs_for_possess -= src
