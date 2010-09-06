/datum/disease/flu
	name = "The Space Flu"
	max_stages = 5
	spread = "Airborne"
	cure = "Rest"
	resistant = 0

/datum/disease/flu/stage_act()
	..()
	if (!affected_mob.stat != 2)
		return
	switch(stage)
		if(2)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.bruteloss += 1
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.updatehealth()

		if(3)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.bruteloss += 1
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.updatehealth()
			if(prob(20))
				affected_mob << "\red Your eyes hurt"
				affected_mob.eye_blurry += 20
		if(4)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.bruteloss += 1
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.updatehealth()
			if(prob(25))
				affected_mob << "\red The world around you feels surreal"
				if(prob(50))
					affected_mob.hallucination += 100
					shake_camera(affected_mob,20)
			if(prob(20))
				affected_mob << "\red Your eyes hurt"
				affected_mob.eye_blurry += 20
		if(5)
			resistant = 0
			affected_mob << "\ AGH"
			affected_mob.toxloss += 2
			affected_mob.stunned += 5
			shake_camera(affected_mob,20)
			if(prob(1))
				affected_mob.gib()
