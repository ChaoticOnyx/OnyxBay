/datum/artifact_effect/radiate
	name = "radiation"
	var/radiation_strength

/datum/artifact_effect/radiate/New()
	..()
	radiation_strength = rand(10, 50)
	effect_type = pick(EFFECT_PARTICLE, EFFECT_ORGANIC)

/datum/artifact_effect/radiate/DoEffectAura()
	if(holder)
		var/datum/radiation_source/rad_source = SSradiation.radiate(holder, new /datum/radiation/preset/artifact(radiation_strength))
		rad_source.schedule_decay(10 SECONDS)

		return 1

/datum/artifact_effect/radiate/DoEffectPulse()
	if(holder)
		var/datum/radiation_source/rad_source = SSradiation.radiate(holder, new /datum/radiation/preset/artifact(rand(5, 10)))
		rad_source.schedule_decay(10 SECONDS)

		return 1
