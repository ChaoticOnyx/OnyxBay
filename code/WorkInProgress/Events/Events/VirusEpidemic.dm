/datum/event/viralinfection

	Announce()
		for(var/mob/living/carbon/human/H in world)
			if((H.virus2) || (H.stat == 2) || prob(30))
				continue
			if(prob(90))	//may need changing, currently 10% chance for "deadly" disease
				infect_mob_random_lesser(H)
			else
				infect_mob_random_greater(H)
			break

	Tick()
		ActiveFor = Lifetime //killme

