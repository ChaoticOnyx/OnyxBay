/datum/event/viralinfection

	Announce()
		for(var/mob/living/carbon/human/H in world)
			if((H.virus2) || (H.stat == 2) || prob(30))
				continue
			if(prob(90))	//may need changing, currently 10% chance for "deadly" disease
				infect_mob_random_lesser(H)
				if(prob(20))//don't want people to know that the virus alert = greater virus
					command_alert("An unknown virus has been detected onboard the ship.", "Virus Alert")
			else
				infect_mob_random_greater(H)
				if(prob(80))
					command_alert("An unknown virus has been detected onboard the ship.", "Virus Alert")
			break
		//overall virus alert happens 26% of the time, might need to be higher
	Tick()
		ActiveFor = Lifetime //killme

