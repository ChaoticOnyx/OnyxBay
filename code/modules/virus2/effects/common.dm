////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/beard
	name = "Facial Hypertrichosis"
	stage = 1
	badness = VIRUS_COMMON
	oneshot = 1
	possible_mutations = list(/datum/disease2/effect/unified_appearance)

/datum/disease2/effect/beard/activate(mob/living/carbon/human/mob)
	if(..())
		return
	var/list/possible_beards = list("Long Beard", "Very Long Beard", "Dwarf Beard", "Braided Beard", "Sea Dog", "Lumberjack")
	var/datum/sprite_accessory/facial_hair_style = pick(possible_beards)
	mob.change_facial_hair(facial_hair_style)
	to_chat(mob, SPAN("warning", "Your chin itches."))



/datum/disease2/effect/adaptation_chem
	name = "-intolerant Adaptation"
	stage = 1
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/adaptation_chem,
							  /datum/disease2/effect/chem_synthesis)

/datum/disease2/effect/adaptation_chem/generate(c_data)
	if(c_data)
		data = c_data
	else
		data = pick(/datum/reagent/bicaridine, /datum/reagent/kelotane, /datum/reagent/dylovene, /datum/reagent/inaprovaline, /datum/reagent/space_drugs, /datum/reagent/sugar,
					/datum/reagent/tramadol, /datum/reagent/dexalin, /datum/reagent/cryptobiolin, /datum/reagent/impedrezene, /datum/reagent/hyperzine, /datum/reagent/ethylredoxrazine,
					/datum/reagent/mindbreaker, /datum/reagent/nutriment/glucose)
	var/datum/reagent/R = data
	name = "[initial(R.name)][initial(name)]"

/datum/disease2/effect/adaptation_chem/change_parent()
	parent_disease.antigen = list()

/datum/disease2/effect/adaptation_chem/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(mob.reagents.get_reagent_amount(data) > multiplier)
		parent_disease.cure()

////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/stimulant
	name = "Adrenaline Extra"
	stage = 2
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/chem_synthesis)

/datum/disease2/effect/stimulant/activate(mob/living/carbon/human/mob)
	if(..())
		return
	to_chat(mob, STIMULANT_EFFECT_WARNING)
	if(mob.reagents.get_reagent_amount(/datum/reagent/hyperzine) < 10)
		mob.reagents.add_reagent(/datum/reagent/hyperzine, 4)
	if(prob(30))
		mob.jitteriness += 10



/datum/disease2/effect/hair
	name = "Hair Loss"
	stage = 2
	badness = VIRUS_COMMON

/datum/disease2/effect/hair/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(mob.species.name == SPECIES_HUMAN && !(mob.h_style == "Bald") && !(mob.h_style == "Balding Hair"))
		to_chat(mob, HAIR_EFFECT_WARNING)
		spawn(50)
			mob.h_style = "Balding Hair"
			mob.update_hair()



/datum/disease2/effect/blind
	name = "Blackout Syndrome"
	stage = 2
	badness = VIRUS_COMMON

/datum/disease2/effect/blind/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.eye_blind = max(mob.eye_blind, 4)



/datum/disease2/effect/adaptation_damage
	name = "Hurt-intolerant Adaptation"
	stage = 2
	badness = VIRUS_COMMON

/datum/disease2/effect/adaptation_damage/change_parent()
	parent_disease.antigen = list()

/datum/disease2/effect/adaptation_damage/activate(mob/living/carbon/human/mob)
	if(..())
		return
	for(var/obj/item/organ/external/E in mob.organs)
		var/dmg = E.get_damage()
		if(dmg > 8*multiplier)
			parent_disease.cure()



/datum/disease2/effect/adaptation_rads
	name = "Radiation-intolerant Adaptation"
	stage = 2
	badness = VIRUS_COMMON

/datum/disease2/effect/adaptation_rads/change_parent()
	parent_disease.antigen = list()

/datum/disease2/effect/adaptation_rads/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(mob.radiation > 10*multiplier)
		parent_disease.cure()
////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/chem_synthesis
	name = "Chemical Synthesis"
	stage = 3
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/toxins,
							  /datum/disease2/effect/killertoxins)
	chance_max = 25

/datum/disease2/effect/chem_synthesis/generate(c_data)
	if(c_data)
		data = c_data
	else
		data = pick(/datum/reagent/bicaridine, /datum/reagent/kelotane, /datum/reagent/dylovene, /datum/reagent/inaprovaline, /datum/reagent/space_drugs, /datum/reagent/sugar,
					/datum/reagent/tramadol, /datum/reagent/dexalin, /datum/reagent/cryptobiolin, /datum/reagent/impedrezene, /datum/reagent/hyperzine, /datum/reagent/ethylredoxrazine,
					/datum/reagent/mindbreaker, /datum/reagent/nutriment/glucose)
	var/datum/reagent/R = data
	name = "[initial(name)] ([initial(R.name)])"

/datum/disease2/effect/chem_synthesis/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(mob.reagents.get_reagent_amount(data) < 5)
		mob.reagents.add_reagent(data, 2)



/datum/disease2/effect/mutation
	name = "DNA Degradation"
	stage = 3
	badness = VIRUS_COMMON

/datum/disease2/effect/mutation/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.apply_damage(2, CLONE)



/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	stage = 3
	badness = VIRUS_COMMON

/datum/disease2/effect/mind/activate(mob/living/carbon/human/mob)
	if(..())
		return
	var/obj/item/organ/internal/brain/B = mob.internal_organs_by_name[BP_BRAIN]
	if(B && B.damage < B.min_broken_damage)
		B.take_internal_damage(5)



/datum/disease2/effect/toxins
	name = "Hyperacidity"
	stage = 3
	multiplier_max = 3
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/organs,
							  /datum/disease2/effect/killertoxins)

/datum/disease2/effect/toxins/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.adjustToxLoss((2*multiplier))



/datum/disease2/effect/escaping
	name = "Forced Freedom Syndrome"
	stage = 3
	badness = VIRUS_COMMON

/datum/disease2/effect/escaping/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(!mob.handcuffed)
		return
	mob.visible_message(
		SPAN("danger", "\The [mob] manages to remove \the [mob.handcuffed]!"),
		SPAN("warning", "[mob.handcuffed] suddenly fall off you.")
		)
	mob.drop_from_inventory(mob.handcuffed)


////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	stage = 4
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/organs,
							  /datum/disease2/effect/toxins)

/datum/disease2/effect/killertoxins/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.adjustToxLoss(15*multiplier)



/datum/disease2/effect/deaf
	name = "Dead Ear Syndrome"
	stage = 4
	badness = VIRUS_COMMON

/datum/disease2/effect/deaf/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.ear_deaf += 20



/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	stage = 4
	multiplier_max = 3
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/spread_radiation)

/datum/disease2/effect/radian/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.apply_effect(2*multiplier, IRRADIATE, blocked = 0)



/datum/disease2/effect/gas
	name = "Gas Synthesis"
	stage = 4
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/gas,
							  /datum/disease2/effect/gas_danger)

/datum/disease2/effect/gas/generate(c_data)
	if(c_data)
		data = c_data
	else
		data = pick("oxygen", "nitrogen", "carbon_dioxide", "hydrogen")
	var/gas_name = gas_data.name[data]
	name = "[initial(name)]([gas_name])"

/datum/disease2/effect/gas/activate(mob/living/carbon/human/mob)
	if(..())
		return
	var/datum/gas_mixture/env = mob.loc.return_air()
	env.adjust_gas(data, multiplier)
