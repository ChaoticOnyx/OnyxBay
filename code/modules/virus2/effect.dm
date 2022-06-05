////////////////////////////////////////////////////////////////
////////////////////////EFFECTS/////////////////////////////////
////////////////////////////////////////////////////////////////
/proc/get_random_virus2_effect(stage, badness, exclude)
	var/list/datum/disease2/effect/candidates = list()
	for(var/T in subtypesof(/datum/disease2/effect))
		var/datum/disease2/effect/E = T
		if(E in exclude)
			continue
		if(initial(E.badness) > badness)	//we don't want such strong effects
			continue
		if(initial(E.stage) <= stage)
			candidates += T
	var/type = pick(candidates)
	var/datum/disease2/effect/effect = new type
	effect.generate()
	effect.chance = rand(0,effect.chance_max)
	effect.multiplier = rand(1,effect.multiplier_max)
	effect.stage = stage
	return effect

/proc/get_mutated_effect(original_effect)
	var/list/datum/disease2/effect/candidates = list()
	var/datum/disease2/effect/original = original_effect
	var/stage = original.stage
	for(var/T in original.possible_mutations)
		var/datum/disease2/effect/E = T
		if(initial(E.stage) <= stage)
			candidates += T
	var/type = candidates.len ? pick(candidates) : null
	if(!type)
		return null
	var/datum/disease2/effect/effect = new type
	effect.generate()
	effect.chance = rand(0,effect.chance_max)
	effect.multiplier = rand(1,effect.multiplier_max)
	effect.stage = stage
	return effect

/datum/disease2/effect
	var/name = "Blanking effect"
	var/datum/disease2/disease/parent_disease //disease causing current effect
	var/chance			//probality to fire every tick
	var/chance_max = 50
	var/multiplier = 1	//effect magnitude multiplier
	var/multiplier_max = 5
	var/stage = 4		//minimal stage
	var/list/possible_mutations //Effects that we can get by using mutagen on virus. Radiation mutations dont use this
	var/badness = VIRUS_MILD	//Used in random generation to limit how bad result should come out.
	var/list/data = list()	//For semi-procedural effects; this should be generated in generate() if used
	var/oneshot
	var/delay = 5 SECONDS	//minimal time between activations
	var/hold_until		//can only fire after this worldtime
	var/allow_multiple	//allow to have more than 1 effect of this type in the same virus

/datum/disease2/effect/proc/fire(current_stage)
	if(oneshot == -1)
		return
	if(hold_until > world.time)
		return
	if(parent_disease.infected.chem_effects[CE_ANTIVIRAL] >= badness)
		return
	if(stage <= current_stage && prob(chance))
		hold_until = world.time + delay
		activate(parent_disease.infected)
		if(oneshot == 1)
			oneshot = -1

/datum/disease2/effect/proc/minormutate()
	switch(pick(1,2,3,4,5))
		if(1)
			chance = rand(0,chance_max)
		if(2)
			multiplier = rand(1,multiplier_max)

/datum/disease2/effect/proc/activate(mob/living/carbon/human/mob)
	if(!istype(mob))
		if(parent_disease) // if virus not in mob, delete this fucking shit, that's buggy virus
			QDEL_NULL(parent_disease)
		return TRUE
/datum/disease2/effect/proc/deactivate(mob/living/carbon/human/mob)
	if(!istype(mob))
		if(parent_disease) // if virus not in mob, delete this fucking shit, that's buggy virus
			QDEL_NULL(parent_disease)
		return TRUE

/datum/disease2/effect/proc/generate(copy_data) // copy_data will be non-null if this is a copy; it should be used to initialise the data for this effect if present
	if(!copy_data) // are you fucking sure in our fucking build, n-word?
		if(parent_disease) // if virus not in mob, delete this fucking shit, that's buggy virus
			QDEL_NULL(parent_disease)
		return TRUE

/datum/disease2/effect/proc/change_parent()
