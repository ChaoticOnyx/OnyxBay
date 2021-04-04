/datum/artifact_effect/plantkiller
	name = "plantkiller"
	effect = list(EFFECT_TOUCH, EFFECT_AURA, EFFECT_PULSE)
	effect_type = EFFECT_ORGANIC

/datum/artifact_effect/plantkiller/DoEffectTouch()
	if(holder)
		Kill_plants(1)
		return 1

/datum/artifact_effect/plantkiller/DoEffectAura()
	if(holder)
		Kill_plants()
		return 1

/datum/artifact_effect/plantkiller/DoEffectPulse()
	if(holder)
		Kill_plants()
		return 1

/datum/artifact_effect/plantkiller/proc/Kill_plants(range = src.effectrange)
	for(var/obj/machinery/portable_atmospherics/hydroponics/H in range(range, holder))
		if(H.seed && !H.dead) // Get your xenobotanist/vox trader/hydroponist mad with you in less than 1 minute with this simple trick.
			switch(rand(1,3))
				if(1)
					if(H.waterlevel >= 10)
						H.waterlevel -= rand(1,10)
					if(H.nutrilevel >= 5)
						H.nutrilevel -= rand(1,5)
				if(2)
					if(H.toxins <= 50)
						H.toxins += rand(1,50)
				if(3)
					H.weedlevel++
					H.pestlevel++
					if(prob(5))
						H.dead = 1
