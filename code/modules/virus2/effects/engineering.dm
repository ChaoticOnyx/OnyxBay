////////////////////////STAGE 1/////////////////////////////////

////////////////////////STAGE 2/////////////////////////////////

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/cold9
	name = "The Cold"
	stage = 3
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/fluspanish)

/datum/disease2/effect/cold9/activate(var/mob/living/carbon/human/mob)
	if(mob.reagents.get_reagent_amount(/datum/reagent/leporazine) < 2)
		mob.bodytemperature -= rand(35,75)
		if(prob(35))
			mob.bodytemperature -= rand(45,55)
			to_chat(mob, "<span class='danger'>Your throat feels sore.</span>")
		if(prob(30))
			mob.bodytemperature -= rand(65,80)
			to_chat(mob, "<span class='danger'>You feel stiff.</span>")
		if(prob(5))
			mob.bodytemperature -= rand(85,200)
			to_chat(mob, "<span class='danger'>You stop feeling your limbs.</span>")

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED

/datum/disease2/effect/bones/activate(var/mob/living/carbon/human/mob,var/multiplier)
	for (var/obj/item/organ/external/E in mob.organs)
		E.min_broken_damage = max(5, E.min_broken_damage - 30)

/datum/disease2/effect/bones/deactivate(var/mob/living/carbon/human/mob,var/multiplier)
	for (var/obj/item/organ/external/E in mob.organs)
		E.min_broken_damage = initial(E.min_broken_damage)



/datum/disease2/effect/immortal
	name = "Longevity Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED

/datum/disease2/effect/immortal/activate(mob/living/carbon/human/mob, multiplier)
	for (var/obj/item/organ/external/E in mob.organs)
		if (E.status & ORGAN_BROKEN && prob(30))
			to_chat(mob, IMMORTAL_RECOVER_EFFECT_WARNING(E.name))
			E.status ^= ORGAN_BROKEN
			break
	for (var/obj/item/organ/internal/I in mob.internal_organs)
		if (I.damage && prob(30))
			to_chat(mob, IMMORTAL_HEALING_EFFECT_WARNING(mob.get_organ(I.parent_organ)))
			I.take_internal_damage(-2*multiplier)
			break
	var/heal_amt = -5*multiplier
	mob.apply_damages(heal_amt,heal_amt,heal_amt,heal_amt)

/datum/disease2/effect/immortal/deactivate(var/mob/living/carbon/human/mob,var/multiplier)
	to_chat(mob, IMMORTAL_AGING_EFFECT_WARNING)
	mob.age += 8
	var/backlash_amt = 5*multiplier
	mob.apply_damages(backlash_amt,backlash_amt,backlash_amt,backlash_amt)



/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/toxins,
							  /datum/disease2/effect/killertoxins)

/datum/disease2/effect/organs/activate(var/mob/living/carbon/human/mob,var/multiplier)
	var/organ = pick(list(BP_R_ARM,BP_L_ARM,BP_R_LEG,BP_L_LEG))
	var/obj/item/organ/external/E = mob.organs_by_name[organ]
	if (!(E.status & ORGAN_DEAD))
		E.status |= ORGAN_DEAD
		to_chat(mob, ORGANS_SHUTDOWN_EFFECT_WARNING(E.name))
		for (var/obj/item/organ/external/C in E.children)
			C.status |= ORGAN_DEAD
	mob.update_body(1)
	mob.adjustToxLoss(15*multiplier)

/datum/disease2/effect/organs/deactivate(var/mob/living/carbon/human/mob,var/multiplier)
	for (var/obj/item/organ/external/E in mob.organs)
		E.status &= ~ORGAN_DEAD
		for (var/obj/item/organ/external/C in E.children)
			C.status &= ~ORGAN_DEAD
	mob.update_body(1)



/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED

/datum/disease2/effect/dna/activate(var/mob/living/carbon/human/mob,var/multiplier)
	mob.bodytemperature = max(mob.bodytemperature, 350)
	scramble(0,mob,10)
	mob.apply_damage(10, CLONE)



/datum/disease2/effect/gbs
	name = "Gravitokinetic Bipotential SADS+"
	stage = 4
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/fake_gbs)

/datum/disease2/effect/gbs/activate(var/mob/living/carbon/human/mob)
	to_chat(mob, "<span class='danger'>Your body feels as if it's trying to rip itself open...</span>")
	mob.weakened += 5
	if(prob(50))
		if(mob.reagents.get_reagent_amount(/datum/reagent/chloralhydrate) < 2)
			mob.gib()



/datum/disease2/effect/fake_gbs
	name = "Gravitokinetic Bipotential SADS+"
	stage = 4
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/gbs)

/datum/disease2/effect/fake_gbs/activate(var/mob/living/carbon/human/mob)
	to_chat(mob, "<span class='danger'>Your body feels as if it's trying to rip itself open...</span>")
	mob.weakened += 5
