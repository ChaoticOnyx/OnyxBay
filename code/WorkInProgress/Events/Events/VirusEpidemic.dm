/*/datum/event/viralinfection

	Announce()
		var/virus_type = pick(/datum/disease/cold, /datum/disease/flu, /datum/disease/fake_gbs)
		for(var/mob/living/carbon/human/H in world)
			if((H.virus) || (H.stat == 2) || prob(30))
				continue
			H.virus = new virus_type()
			H.virus.affected_mob = H
			H.virus.carrier = 1
			break

	Tick()
		ActiveFor = Lifetime //killme
		*/
