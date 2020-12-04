////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/beard
	name = "Facial Hypertrichosis"
	stage = 1
	badness = VIRUS_COMMON
	oneshot = 1
	possible_mutations = list(/datum/disease2/effect/unified_appearance)

/datum/disease2/effect/beard/activate(var/mob/living/carbon/human/mob)
	var/list/possible_beards = list("Long Beard", "Very Long Beard", "Dwarf Beard", "Braided Beard", "Sea Dog", "Lumberjack")
	var/datum/sprite_accessory/facial_hair_style = pick(possible_beards)
	mob.change_facial_hair(facial_hair_style)
	to_chat(mob, SPAN_WARNING("Your chin itches."))

////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/stimulant
	name = "Adrenaline Extra"
	stage = 2
	badness = VIRUS_COMMON

/datum/disease2/effect/stimulant/activate(var/mob/living/carbon/human/mob)
	to_chat(mob, STIMULANT_EFFECT_WARNING)
	if (mob.reagents.get_reagent_amount(/datum/reagent/hyperzine) < 10)
		mob.reagents.add_reagent(/datum/reagent/hyperzine, 4)
	if (prob(30))
		mob.jitteriness += 10



/datum/disease2/effect/hair
	name = "Hair Loss"
	stage = 2
	badness = VIRUS_COMMON

/datum/disease2/effect/hair/activate(var/mob/living/carbon/human/mob)
	if(mob.species.name == SPECIES_HUMAN && !(mob.h_style == "Bald") && !(mob.h_style == "Balding Hair"))
		to_chat(mob, HAIR_EFFECT_WARNING)
		spawn(50)
			mob.h_style = "Balding Hair"
			mob.update_hair()



/datum/disease2/effect/blind
	name = "Blackout Syndrome"
	stage = 2
	badness = VIRUS_COMMON

/datum/disease2/effect/blind/activate(var/mob/living/carbon/human/mob)
	mob.eye_blind = max(mob.eye_blind, 4)

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

/datum/disease2/effect/chem_synthesis/activate(var/mob/living/carbon/human/mob)
	if (mob.reagents.get_reagent_amount(data) < 5)
		mob.reagents.add_reagent(data, 2)



/datum/disease2/effect/mutation
	name = "DNA Degradation"
	stage = 3
	badness = VIRUS_COMMON

/datum/disease2/effect/mutation/activate(var/mob/living/carbon/human/mob)
	mob.apply_damage(2, CLONE)



/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	stage = 3
	badness = VIRUS_COMMON

/datum/disease2/effect/mind/activate(var/mob/living/carbon/human/mob)
	var/obj/item/organ/internal/brain/B = mob.internal_organs_by_name[BP_BRAIN]
	if (B && B.damage < B.min_broken_damage)
		B.take_internal_damage(5)



/datum/disease2/effect/toxins
	name = "Hyperacidity"
	stage = 3
	multiplier_max = 3
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/organs,
							  /datum/disease2/effect/killertoxins)

/datum/disease2/effect/toxins/activate(var/mob/living/carbon/human/mob)
	mob.adjustToxLoss((2*multiplier))

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	stage = 4
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/organs,
							  /datum/disease2/effect/toxins)

/datum/disease2/effect/killertoxins/activate(var/mob/living/carbon/human/mob)
	mob.adjustToxLoss(15*multiplier)



/datum/disease2/effect/deaf
	name = "Dead Ear Syndrome"
	stage = 4
	badness = VIRUS_COMMON

/datum/disease2/effect/deaf/activate(var/mob/living/carbon/human/mob)
	mob.ear_deaf += 20



/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	stage = 4
	multiplier_max = 3
	badness = VIRUS_COMMON
	possible_mutations = list(/datum/disease2/effect/spread_radiation)

/datum/disease2/effect/radian/activate(var/mob/living/carbon/human/mob)
	mob.apply_effect(2*multiplier, IRRADIATE, blocked = 0)
