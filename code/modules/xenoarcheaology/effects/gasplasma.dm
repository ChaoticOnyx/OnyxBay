/datum/artifact_effect/gasplasma
	name = "plasma creation"

/datum/artifact_effect/gasplasma/New()
	..()
	effect = pick(EFFECT_TOUCH, EFFECT_AURA)
	effect_type = pick(EFFECT_BLUESPACE, EFFECT_SYNTH)

/datum/artifact_effect/gasplasma/DoEffectTouch(mob/user)
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("plasma", rand(2, 15))

/datum/artifact_effect/gasplasma/DoEffectAura()
	if(holder)
		var/turf/holder_loc = holder.loc
		if(istype(holder_loc))
			holder_loc.assume_gas("plasma", pick(0, 0, 0.1, rand()))
