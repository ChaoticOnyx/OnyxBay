/mob/living/death()
	if(hiding)
		hiding = FALSE
	if(controllable)
		controllable = FALSE
		GLOB.available_mobs_for_possess -= src
	. = ..()
