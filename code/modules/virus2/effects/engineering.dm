////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/beesease
	name = "Bee Infestation"
	stage = 2
	delay = 15 SECONDS
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/cough)

/datum/disease2/effect/beesease/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.emote("cough")
	var/obj/item/blocked = mob.check_mouth_coverage()
	if(blocked)
		to_chat(mob, SPAN("danger", "Something is trying to escape from your throat, but [blocked] stops them!"))
		mob.internal_organs["lungs"].take_internal_damage(10)
		return
	new /mob/living/simple_animal/bee(mob.loc)
	var/datum/gender/G = gender_datums[mob.get_visible_gender()]
	mob.visible_message(SPAN("warning", "Bees fly out of [mob]'s throat when [G.he] coughs!"),
						SPAN("danger", "Bees fly out of your throat when you cough!"))


////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/click
	name = "Uncontrollable Actions"
	stage = 2
	badness = VIRUS_ENGINEERED

/datum/disease2/effect/click/activate(mob/living/carbon/human/mob)
	if(..())
		return
	var/list/target_list = istype(mob.get_active_hand(), /obj/item/weapon/gun) ? view(mob) : view(1, mob) //Dont put far objects in list unless we can shoot it
	target_list -= (mob.organs + mob.internal_organs) //exclude organs from target list
	var/list/target_list_clear = list(/datum/disease2/effect/aggressive)
	for(var/T in target_list)
		if(istype(T, /obj) || istype(T, /turf) || istype(T, /mob)) //exclude lighting overlays and other service atoms and areas
			target_list_clear += T
	var/target = pick(target_list_clear)
	mob.ClickOn(target)

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/cold9
	name = "The Cold"
	stage = 3
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/fluspanish)

/datum/disease2/effect/cold9/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(mob.reagents.get_reagent_amount(/datum/reagent/leporazine) < 2)
		mob.bodytemperature -= rand(35, 75)
		if(prob(35))
			mob.bodytemperature -= rand(45, 55)
			to_chat(mob, SPAN("danger", "Your throat feels sore."))
		if(prob(30))
			mob.bodytemperature -= rand(65, 80)
			to_chat(mob, SPAN("danger", "You feel stiff."))
		if(prob(5))
			mob.bodytemperature -= rand(85, 200)
			to_chat(mob, SPAN("danger", "You stop feeling your limbs."))


/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	stage = 3
	badness = VIRUS_ENGINEERED

/datum/disease2/effect/bones/activate(mob/living/carbon/human/mob)
	if(..())
		return
	for(var/obj/item/organ/external/E in mob.organs)
		E.min_broken_damage = max(5, E.min_broken_damage - 30)

/datum/disease2/effect/bones/deactivate(mob/living/carbon/human/mob)
	if(..())
		return
	for(var/obj/item/organ/external/E in mob.organs)
		E.min_broken_damage = initial(E.min_broken_damage)


/datum/disease2/effect/spread_radiation
	name = "Radioactivity Increase"
	stage = 3
	badness = VIRUS_ENGINEERED
	delay = 15 SECONDS
	possible_mutations = list(/datum/disease2/effect/radian)

/datum/disease2/effect/spread_radiation/activate(mob/living/carbon/human/mob)
	if(..())
		return
	SSradiation.radiate(mob, 5 * multiplier)


/datum/disease2/effect/loyalty
	name = "Loyalty Syndrome"
	stage = 3
	badness = VIRUS_ENGINEERED
	delay = 20 SECONDS
	multiplier_max = 10
	possible_mutations = list(/datum/disease2/effect/adaptation_kill)
	var/isking = null

/datum/disease2/effect/loyalty/generate(c_data)
	if(c_data)
		data = c_data

/datum/disease2/effect/loyalty/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(!istype(data, /mob/living/carbon/human))
		data = mob
		isking = 1
		return
	if(!isking)
		for(var/mob/living/carbon/human/dead in GLOB.dead_mob_list_)
			if(dead == data)
				to_chat(mob, SPAN("danger", "You didn't protect your master! Now all you deserve is to die in disgrace."))
				var/obj/item/organ/internal/brain/B = mob.internal_organs_by_name[BP_BRAIN]
				if(B && B.damage < B.min_broken_damage)
					B.take_internal_damage(100)
				return

		for(var/mob/living/carbon/human/king in view(mob))
			if(king == data)
				mob.poise += round(multiplier/2)
				return

		var/mob/living/carbon/human/king = data
		var/message = pick("[king.real_name] is your Master. Come to [king.gender == MALE ? "him" : king.gender == FEMALE ? "her" : "them"] and protect [king.gender == MALE ? "him" : king.gender == FEMALE ? "her" : "them"] by your own life!",
						   "You have to find [king.real_name], your Master, immediately.",
						   "You have to protect your Master, [king.real_name], so find [king.gender == MALE ? "him" : king.gender == FEMALE ? "her" : "them"] faster!")
		mob.custom_pain(message, 10)

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/immortal
	name = "Longevity Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/curer)

/datum/disease2/effect/immortal/activate(mob/living/carbon/human/mob)
	if(..())
		return
	for(var/obj/item/organ/external/E in mob.organs)
		if(E.status & ORGAN_BROKEN && prob(30))
			to_chat(mob, IMMORTAL_RECOVER_EFFECT_WARNING(E.name))
			E.status ^= ORGAN_BROKEN
			break
	for(var/obj/item/organ/internal/I in mob.internal_organs)
		if(I.damage && prob(30))
			to_chat(mob, IMMORTAL_HEALING_EFFECT_WARNING(mob.get_organ(I.parent_organ)))
			I.take_internal_damage(-2 * multiplier)
			break
	var/heal_amt = -5 * multiplier
	mob.apply_damages(heal_amt, heal_amt, heal_amt, heal_amt)

/datum/disease2/effect/immortal/deactivate(mob/living/carbon/human/mob)
	if(..())
		return
	to_chat(mob, IMMORTAL_AGING_EFFECT_WARNING)
	mob.age += 8
	var/backlash_amt = 5 * multiplier
	mob.apply_damages(backlash_amt, backlash_amt, backlash_amt, backlash_amt)


/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/toxins,
							  /datum/disease2/effect/killertoxins)

/datum/disease2/effect/organs/activate(mob/living/carbon/human/mob)
	if(..())
		return
	var/organ = pick(list(BP_R_ARM, BP_L_ARM, BP_R_LEG, BP_L_LEG))
	var/obj/item/organ/external/E = mob.organs_by_name[organ]
	if(!(E.status & ORGAN_DEAD))
		E.status |= ORGAN_DEAD
		to_chat(mob, ORGANS_SHUTDOWN_EFFECT_WARNING(E.name))
		for (var/obj/item/organ/external/C in E.children)
			C.status |= ORGAN_DEAD
	mob.update_body(1)
	mob.adjustToxLoss(15 * multiplier)

/datum/disease2/effect/organs/deactivate(mob/living/carbon/human/mob)
	if(..())
		return
	for(var/obj/item/organ/external/E in mob.organs)
		E.status &= ~ORGAN_DEAD
		for(var/obj/item/organ/external/C in E.children)
			C.status &= ~ORGAN_DEAD
	mob.update_body(1)


/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED

/datum/disease2/effect/dna/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.bodytemperature = max(mob.bodytemperature, 350)
	scramble(0, mob, 10)
	mob.apply_damage(10, CLONE)


/datum/disease2/effect/gbs
	name = "Gravitokinetic Bipotential SADS+"
	stage = 4
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/fake_gbs)

/datum/disease2/effect/gbs/activate(mob/living/carbon/human/mob)
	if(..())
		return
	to_chat(mob, SPAN("danger", "Your body feels as if it's trying to rip itself open..."))
	mob.weakened += 5
	if(prob(50))
		if(mob.reagents.get_reagent_amount(/datum/reagent/chloralhydrate) < 2)
			mob.gib()


/datum/disease2/effect/fake_gbs
	name = "Gravitokinetic Bipotential SADS+"
	stage = 4
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/gbs)

/datum/disease2/effect/fake_gbs/activate(mob/living/carbon/human/mob)
	if(..())
		return
	to_chat(mob, SPAN("danger", "Your body feels as if it's trying to rip itself open..."))
	mob.weakened += 5


/datum/disease2/effect/gas_danger
	name = "Gas Synthesis"
	stage = 4
	badness = VIRUS_ENGINEERED
	possible_mutations = list(/datum/disease2/effect/gas,
							  /datum/disease2/effect/gas_danger)

/datum/disease2/effect/gas_danger/generate(c_data)
	if(c_data)
		data = c_data
	else
		data = pick("sleeping_agent", "plasma")
	var/gas_name = gas_data.name[data]
	name = "[initial(name)]([gas_name])"

/datum/disease2/effect/gas_danger/activate(mob/living/carbon/human/mob)
	if(..())
		return
	var/datum/gas_mixture/env = mob.loc.return_air()
	env.adjust_gas(data, multiplier)


/datum/disease2/effect/limbreject
	name = "Limb Rejection"
	stage = 4
	delay = 70 SECONDS
	badness = VIRUS_ENGINEERED

/datum/disease2/effect/limbreject/activate(mob/living/carbon/human/mob)
	if(..())
		return
	var/list/detachable_limbs = mob.organs.Copy()
	for(var/obj/item/organ/external/E in detachable_limbs)
		if(E.organ_tag == BP_R_HAND || E.organ_tag == BP_L_HAND || E.organ_tag == BP_R_FOOT || E.organ_tag == BP_L_FOOT || E.organ_tag == BP_CHEST || E.organ_tag == BP_GROIN || E.organ_tag == BP_HEAD || E.is_stump())
			detachable_limbs -= E
	var/obj/item/organ/external/organ_to_remove = pick(detachable_limbs)
	if(!mob.organs.Find(organ_to_remove))
		return 0

	mob.visible_message(SPAN("warning", "The [organ_to_remove] is ripping off from [mob]."),
						SPAN("danger", "Your [organ_to_remove] is ripping off you!"))
	playsound(mob.loc, 'sound/effects/bonebreak1.ogg', 100, 1)

	if(organ_to_remove.organ_tag == BP_L_LEG || organ_to_remove.organ_tag == BP_R_LEG)
		var/mob/living/simple_animal/hostile/little_changeling/leg_chan/disease/L = new /mob/living/simple_animal/hostile/little_changeling/leg_chan/disease(get_turf(mob))
		for(var/ID in mob.virus2)
			var/datum/disease2/disease/D = mob.virus2[ID]
			L.diseases_list += D
	else if(organ_to_remove.organ_tag == BP_L_ARM || organ_to_remove.organ_tag == BP_R_ARM)
		var/mob/living/simple_animal/hostile/little_changeling/leg_chan/disease/L = new /mob/living/simple_animal/hostile/little_changeling/arm_chan/disease(get_turf(mob))
		for(var/ID in mob.virus2)
			var/datum/disease2/disease/D = mob.virus2[ID]
			L.diseases_list += D
	organ_to_remove.droplimb(1)
	qdel(organ_to_remove)

	var/mob/living/carbon/human/H = mob
	if(istype(H))
		H.regenerate_icons()

/mob/living/simple_animal/hostile/little_changeling/leg_chan/disease
	var/list/diseases_list
/mob/living/simple_animal/hostile/little_changeling/leg_chan/disease/AttackingTarget()
	if(ishuman(target_mob))
		for(var/datum/disease2/disease/D in diseases_list)
			infect_virus2(target_mob, D)
	..()

/mob/living/simple_animal/hostile/little_changeling/arm_chan/disease
	var/list/diseases_list
/mob/living/simple_animal/hostile/little_changeling/arm_chan/disease/AttackingTarget()
	if(ishuman(target_mob))
		for(var/datum/disease2/disease/D in diseases_list)
			infect_virus2(target_mob, D)
	..()



/datum/disease2/effect/virus_changer
	name = "Unstable Nucleotide"
	stage = 4
	badness = VIRUS_ENGINEERED
	oneshot = 1

/datum/disease2/effect/virus_changer/activate(mob/living/carbon/human/mob)
	if(..())
		return
	var/datum/disease2/disease/D = new /datum/disease2/disease
	D.makerandom(VIRUS_ENGINEERED)
	infect_virus2(mob, D, 1)
	if(parent_disease) // what the fuck? If virus must be changed and you created a new one, THAN DELETE OLD VIRUS, BIGOTS!
		QDEL_NULL(parent_disease)
