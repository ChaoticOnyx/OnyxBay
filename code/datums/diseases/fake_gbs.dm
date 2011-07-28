/datum/disease/fake_gbs
	name = "GBS"
	max_stages = 5
	spread = "Airborne"
	cure = "Epilepsy Pills"
	affected_species = list("Human")

/datum/disease/fake_gbs/stage_act()
	..()
	if (!affected_mob.stat != 2)
		return
	switch(stage)
		if(2)
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

		if(5)
			if(prob(10))
				affected_mob.emote("cough_disease")
