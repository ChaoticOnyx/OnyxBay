/datum/artifact_effect/darkness
	name = "darkness"
	effect_type = EFFECT_ENERGY
	effect = list(EFFECT_AURA, EFFECT_PULSE)
	var/dark_level

/datum/artifact_effect/darkness/New()
	..()
	effectrange = rand(2,12)
	dark_level = rand(2,7)

/datum/artifact_effect/darkness/ToggleActivate()
	..()
	if(holder)
		if(!activated)
			holder.set_light(effectrange, -dark_level)
		else
			holder.set_light(0)
