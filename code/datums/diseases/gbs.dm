/datum/disease/gbs
	name = "GBS"
	max_stages = 5
	spread = "Airborne"
	cure = "Epilepsy Pills"
	affected_species = list("Human")

/datum/disease/gbs/stage_act()
	..()
	if (!affected_mob.stat != 2)
		return
	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.toxloss += 5
				affected_mob.updatehealth()
			if(prob(1))
				affected_mob.emote("sneeze_disease")
		if(3)
			if(prob(5))
				affected_mob.emote("cough_disease")
			else if(prob(5))
				affected_mob.emote("gasp_air")
			if(prob(10))
				affected_mob << "\red You're starting to feel very weak..."
		if(4)
			if(prob(10))
				affected_mob.emote("cough_disease")
			affected_mob.toxloss += 5
			affected_mob.updatehealth()
		if(5)
			affected_mob << "\red Your body feels as if it's trying to rip itself open..."
			if(prob(50))
				affected_mob.gib()
		else
			return