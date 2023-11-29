/mob/living/death()
	. = ..()
	if(.)
		if(hiding)
			hiding = FALSE
		if(controllable)
			controllable = FALSE
			GLOB.available_mobs_for_possess -= "\ref[src]"

/mob/living/is_ooc_dead()
	return (..() && !(mind?.changeling && !mind.changeling.true_dead))
