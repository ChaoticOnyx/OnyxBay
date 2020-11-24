////////////////////////STAGE 1/////////////////////////////////

////////////////////////STAGE 2/////////////////////////////////

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/emp
	name = "Electromagnetic Mismatch Syndrome"
	stage = 3
	badness = VIRUS_MUTATION
	possible_mutations = list(/datum/disease2/effect/radian)

/datum/disease2/effect/emp/activate(var/mob/living/carbon/human/mob)
	if(prob(35))
		to_chat(mob, "<span class='danger'>Your inner energy breaks out!</span>")
		empulse(mob.loc, 3, 2)
	if(prob(50))
		to_chat(mob, "<span class='warning'>You are overwhelmed with electricity from the inside!</span>")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, mob)
		s.start()

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/monkey
	name = "Two Percent Syndrome"
	stage = 4
	badness = VIRUS_MUTATION

/datum/disease2/effect/monkey/activate(var/mob/living/carbon/human/mob,var/multiplier)
	mob.monkeyize()



/datum/disease2/effect/fluspanish
	name = "Spanish Flu Virion"
	stage = 4
	delay = 25 SECONDS
	badness = VIRUS_MUTATION
	possible_mutations = list(/datum/disease2/effect/cold9,
							  /datum/disease2/effect/flu)

/datum/disease2/effect/fluspanish/activate(var/mob/living/carbon/human/mob, var/multiplier)
	if(mob.reagents.get_reagent_amount(/datum/reagent/leporazine) < 5)
		mob.bodytemperature += 25
		if(prob(15))
			mob.bodytemperature += 35
			to_chat(mob, "<span class='warning'>Your insides burn out.</span>")
			mob.take_organ_damage((4*multiplier))
		if(prob(10))
			mob.bodytemperature += 40
			to_chat(mob, "<span class='warning'>You're burning in your own skin!</span>")
