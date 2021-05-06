/datum/artifact_effect/cultify
	name = "cultify"
	effect_type = EFFECT_TRANSFORM

/datum/artifact_effect/cultify/DoEffectAura()
	make_culty(min(3, effectrange))

/datum/artifact_effect/cultify/DoEffectPulse()
	make_culty(min(20, effectrange))

/datum/artifact_effect/cultify/proc/make_culty(range)
	if(holder)
		for(var/turf/T in range(get_turf(holder), range))
			T.cultify()
			sleep(1)
