/datum/artifact_effect/darkness
	name = "darkness"
	effect_type = EFFECT_ENERGY
	var/dark_level

/datum/artifact_effect/darkness/New()
	..()
	effect = EFFECT_AURA
	effectrange = rand(2,12)
	dark_level = rand(2,7)

/datum/artifact_effect/darkness/ToggleActivate()
	..()
	if(holder)
		if(!activated)
			holder.set_light(-dark_level, 1, effectrange)
		else
			holder.set_light(0)
