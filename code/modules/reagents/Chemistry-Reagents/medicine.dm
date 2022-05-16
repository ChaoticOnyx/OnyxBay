#define DRUGS_MESSAGE_DELAY 1*60*10
#define ANTIDEPRESSANT_MESSAGE_DELAY 5*60*10

/* General medicine */

/datum/reagent/inaprovaline
	name = "Inaprovaline"
	description = "Inaprovaline is a multipurpose neurostimulant and cardioregulator. Commonly used to slow bleeding and stabilize patients."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#00bfff"
	overdose = REAGENTS_OVERDOSE * 2
	metabolism = REM * 0.5
	scannable = TRUE
	flags = IGNORE_MOB_SIZE

/datum/reagent/inaprovaline/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien != IS_DIONA)
		var/effect_mult = removed / metabolism
		M.add_chemical_effect(CE_STABLE)
		M.add_chemical_effect(CE_PAINKILLER, 10 * effect_mult)

/datum/reagent/inaprovaline/overdose(mob/living/carbon/M, alien)
	M.add_chemical_effect(CE_SLOWDOWN, 1)
	if(prob(5))
		M.slurring = max(M.slurring, 10)
	if(prob(2))
		M.drowsyness = max(M.drowsyness, 5)

/datum/reagent/bicaridine
	name = "Bicaridine"
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	taste_description = "bitterness"
	taste_mult = 3
	reagent_state = LIQUID
	color = "#bf0000"
	overdose = REAGENTS_OVERDOSE
	scannable = TRUE
	flags = IGNORE_MOB_SIZE

/datum/reagent/bicaridine/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien != IS_DIONA)
		var/effect_mult = removed / metabolism
		M.heal_organ_damage(6 * removed, 0)
		M.add_chemical_effect(CE_PAINKILLER, 10 * effect_mult)

/datum/reagent/bicaridine/overdose(mob/living/carbon/M, alien)
	..()
	if(ishuman(M))
		M.add_chemical_effect(CE_BLOCKAGE, (15 + volume - overdose)/100)
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/external/E in H.organs)
			if(E.status & ORGAN_ARTERY_CUT && prob(2))
				E.status &= ~ORGAN_ARTERY_CUT

/datum/reagent/kelotane
	name = "Kelotane"
	description = "Kelotane is a drug used to treat burns."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#ffa800"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/kelotane/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien != IS_DIONA)
		M.heal_organ_damage(0, 6 * removed)

/datum/reagent/dermaline
	name = "Dermaline"
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	taste_description = "bitterness"
	taste_mult = 1.5
	reagent_state = LIQUID
	color = "#ff8000"
	overdose = REAGENTS_OVERDOSE * 0.5
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/dermaline/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien != IS_DIONA)
		M.heal_organ_damage(0, 12 * removed)

/datum/reagent/dylovene
	name = "Dylovene"
	description = "Dylovene is a broad-spectrum antitoxin used to neutralize poisons before they can do significant harm."
	taste_description = "a roll of gauze"
	reagent_state = LIQUID
	color = "#00a000"
	scannable = 1
	flags = IGNORE_MOB_SIZE
	var/remove_generic = 1
	var/static/list/remove_toxins = list(
		/datum/reagent/toxin/zombiepowder
	)

/datum/reagent/dylovene/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return

	if(remove_generic)
		M.drowsyness = max(0, M.drowsyness - 6 * removed)
		M.adjust_hallucination(-9 * removed)
		M.add_up_to_chemical_effect(CE_ANTITOX, 1)

	var/removing = (4 * removed)
	var/datum/reagents/ingested = M.get_ingested_reagents()
	for(var/datum/reagent/R in ingested.reagent_list)
		if((remove_generic && istype(R, /datum/reagent/toxin)) || (R.type in remove_toxins))
			ingested.remove_reagent(R.type, removing)
			return
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if((remove_generic && istype(R, /datum/reagent/toxin)) || (R.type in remove_toxins))
			M.reagents.remove_reagent(R.type, removing)
			return

/datum/reagent/dexalin
	name = "Dexalin"
	description = "Dexalin is used in the treatment of oxygen deprivation."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#0080ff"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE
	absorbability = 1.0 // Just sip your oxygen cocktail and stay cool

/datum/reagent/dexalin/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_VOX)
		M.adjustToxLoss(removed * 6)
	else if(alien != IS_DIONA)
		M.add_chemical_effect(CE_OXYGENATED, 1)
	holder.remove_reagent(/datum/reagent/lexorin, 2 * removed)

/datum/reagent/dexalinp
	name = "Dexalin Plus"
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. It is highly effective."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#0040ff"
	overdose = REAGENTS_OVERDOSE * 0.5
	scannable = 1
	flags = IGNORE_MOB_SIZE
	absorbability = 1.0

/datum/reagent/dexalinp/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_VOX)
		M.adjustToxLoss(removed * 9)
	else if(alien != IS_DIONA)
		M.add_chemical_effect(CE_OXYGENATED, 2)
	holder.remove_reagent(/datum/reagent/lexorin, 3 * removed)

/datum/reagent/tricordrazine
	name = "Tricordrazine"
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	taste_description = "grossness"
	reagent_state = LIQUID
	color = "#8040ff"
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/tricordrazine/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien != IS_DIONA)
		M.heal_organ_damage(3 * removed, 3 * removed)

/datum/reagent/cryoxadone
	name = "Cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#8080ff"
	metabolism = REM * 0.25
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/cryoxadone/affect_blood(mob/living/carbon/M, alien, removed)
	M.add_chemical_effect(CE_CRYO, 1)
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-50 * removed)
		M.add_chemical_effect(CE_PAINKILLER, 80)
		M.add_chemical_effect(CE_OXYGENATED, 1)
		M.add_chemical_effect(CE_PULSE, -2)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.adjustToxLoss(max(-1, -12/max(1, H.getToxLoss())) * H.stasis_value)

			for(var/obj/item/organ/external/E in H.organs)
				if(BP_IS_ROBOTIC(E))
					continue
				if(E.status & ORGAN_BLEEDING && prob(50))
					E.status &= ~ORGAN_BLEEDING
					for(var/datum/wound/W in E.wounds)
						W.clamped = 1
					H.update_surgery()

			for(var/obj/item/organ/internal/I in H.internal_organs)
				if(BP_IS_ROBOTIC(I))
					continue
				if(I.damage >= I.min_bruised_damage)
					continue
				I.damage = max(I.damage - (removed * H.stasis_value), 0)

			H.heal_organ_damage((5 * removed * H.stasis_value), (7.5 * removed * H.stasis_value))

/datum/reagent/clonexadone
	name = "Clonexadone"
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
	taste_description = "metroid"
	reagent_state = LIQUID
	color = "#80bfff"
	metabolism = REM * 0.25
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/clonexadone/affect_blood(mob/living/carbon/M, alien, removed)
	M.add_chemical_effect(CE_CRYO, 1)
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-150 * removed)
		M.add_chemical_effect(CE_PAINKILLER, 160)
		M.add_chemical_effect(CE_OXYGENATED, 2)
		M.add_chemical_effect(CE_PULSE, -2)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.adjustToxLoss(max(-1, -16/max(1, H.getToxLoss())) * H.stasis_value)

			for(var/obj/item/organ/external/E in H.organs)
				if(BP_IS_ROBOTIC(E))
					continue
				if(E.status & ORGAN_BLEEDING && prob(80))
					E.status &= ~ORGAN_BLEEDING
					for(var/datum/wound/W in E.wounds)
						W.clamped = 1
					H.update_surgery()
				if(E.status & ORGAN_ARTERY_CUT && prob(8 * removed * H.stasis_value))
					E.status &= ~ORGAN_ARTERY_CUT

			for(var/obj/item/organ/internal/I in H.internal_organs)
				if(BP_IS_ROBOTIC(I))
					continue
				if(I.damage >= I.min_broken_damage)
					continue
				I.damage = max(I.damage - (2 * removed * H.stasis_value), 0)

			H.heal_organ_damage((10 * removed * H.stasis_value), (12.5 * removed * H.stasis_value))

/* Other medicine */

/datum/reagent/synaptizine
	name = "Synaptizine"
	description = "Synaptizine is used to treat various diseases."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#99ccff"
	metabolism = REM * 0.05
	overdose = REAGENTS_OVERDOSE
	scannable = 1

/datum/reagent/synaptizine/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	if(alien == IS_DIONA)
		return
	var/effect_mult = removed / metabolism
	M.drowsyness = max(M.drowsyness - (5 * effect_mult), 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	holder.remove_reagent(/datum/reagent/mindbreaker, 5 * effect_mult)
	M.adjust_hallucination(-10 * effect_mult)
	M.add_chemical_effect(CE_MIND, 2)
	M.adjustToxLoss(5 * removed) // It used to be incredibly deadly due to an oversight. Not anymore!

	if(affecting_dose < 1.5)
		effect_mult *= affecting_dose / 1.5 // We no longer use effect_mult for other purposes, safe to change it
	M.add_chemical_effect(CE_PAINKILLER, 20 * effect_mult)

/datum/reagent/alkysine
	name = "Alkysine"
	description = "Alkysine is a drug used to lessen the damage to neurological tissue after a injury. Can aid in healing brain tissue."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#ffff66"
	metabolism = REM * 0.25
	absorbability = 1.0 // TODO: Redo CE_BRAIN_REGEN some day to make orally-taken alkysine weaker
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/alkysine/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	M.add_chemical_effect(CE_PAINKILLER, 10)
	M.add_chemical_effect(CE_BRAIN_REGEN, 1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.confused++
		H.drowsyness++

/datum/reagent/imidazoline
	name = "Imidazoline"
	description = "Heals eye damage"
	taste_description = "dull toxin"
	reagent_state = LIQUID
	color = "#c8a5dc"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/imidazoline/affect_blood(mob/living/carbon/M, alien, removed)
	var/effect_mult = removed / metabolism
	M.eye_blurry = max(M.eye_blurry - (5 * effect_mult), 0)
	M.eye_blind = max(M.eye_blind - (5 * effect_mult), 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/eyes/E = H.internal_organs_by_name[BP_EYES]
		if(E && istype(E))
			if(E.damage > 0)
				E.damage = max(E.damage - 5 * removed, 0)

/datum/reagent/peridaxon
	name = "Peridaxon"
	description = "Used to encourage recovery of internal organs and nervous systems. Medicate cautiously."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#561ec3"
	overdose = 10
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/peridaxon/affect_blood(mob/living/carbon/M, alien, removed)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/internal/I in H.internal_organs)
			if(BP_IS_ROBOTIC(I))
				continue
			if(I.organ_tag == BP_BRAIN)
				H.confused++
				H.drowsyness++
				if(I.damage >= I.min_bruised_damage)
					continue
			I.damage = max(I.damage - removed*3, 0)

/datum/reagent/ryetalyn
	name = "Ryetalyn"
	description = "Ryetalyn can cure all genetic abnomalities via a catalytic process."
	taste_description = "acid"
	reagent_state = SOLID
	color = "#004000"
	overdose = REAGENTS_OVERDOSE

/datum/reagent/ryetalyn/affect_blood(mob/living/carbon/M, alien, removed)
	var/needs_update = M.mutations.len > 0

	M.mutations = list()
	M.disabilities = 0
	M.sdisabilities = 0

	// Might need to update appearance for hulk etc.
	if(needs_update && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_mutations()

/datum/reagent/hyperzine
	name = "Hyperzine"
	description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
	taste_description = "acid"
	reagent_state = LIQUID
	color = "#ff3300"
	metabolism = REM * 0.5
	ingest_met = REM * 0.25 // True speed requires shots, you weakling
	absorbability = 1.0 // But at least some speed is still achievable even thru oral intake
	excretion = 0.5
	overdose = REAGENTS_OVERDOSE * 0.5
	var/tolerance_threshold = 15.0 // Having more than this value in chem_traces will cause pain
	var/tolerance_mult = 2.0 // Amount of pain for each unit over tolerance_threshold

/datum/reagent/hyperzine/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	if(alien == IS_DIONA)
		return
	if(affecting_dose < 0.5)
		if(M.chem_doses[type] == metabolism * 2 && M.chem_traces[type] < tolerance_threshold)
			to_chat(M, SPAN("notice", "You can feel your muscles tense up!"))
		return
	if(prob(5))
		M.emote(pick("twitch", "blink_r", "shiver"))

	var/effectiveness = removed / metabolism
	if(M.chem_traces[type] > tolerance_threshold)
		var/tolerance_excess = M.chem_traces[type] - tolerance_threshold
		if(prob(min(25, tolerance_excess)))
			M.custom_pain("Your muscles ache from tension!", tolerance_excess * tolerance_mult, FALSE)

	M.add_up_to_chemical_effect(CE_SPEEDBOOST, 2 * effectiveness)
	M.add_chemical_effect(CE_PULSE, 2)

/datum/reagent/ethylredoxrazine
	name = "Ethylredoxrazine"
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = SOLID
	color = "#605048"
	overdose = REAGENTS_OVERDOSE

/datum/reagent/ethylredoxrazine/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	var/datum/reagents/ingested = M.get_ingested_reagents()
	if(ingested)
		for(var/datum/reagent/R in ingested.reagent_list)
			if(istype(R, /datum/reagent/ethanol))
				M.chem_doses[R.type] = max(M.chem_doses[R.type] - removed * 5, 0)
				M.chem_traces[R.type] = max(M.chem_traces[R.type] - removed * 3, 0)

/datum/reagent/hyronalin
	name = "Hyronalin"
	description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#408000"
	metabolism = REM * 0.25
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/hyronalin/affect_blood(mob/living/carbon/M, alien, removed)
	M.radiation = max(M.radiation - 30 * removed, 0)

/datum/reagent/arithrazine
	name = "Arithrazine"
	description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
	reagent_state = LIQUID
	color = "#008000"
	metabolism = REM * 0.25
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/arithrazine/affect_blood(mob/living/carbon/M, alien, removed)
	M.radiation = max(M.radiation - 70 * removed, 0)
	M.adjustToxLoss(-10 * removed)
	if(prob(60))
		if(ishuman(M))
			var/mob/living/carbon/human/human = M
			human.take_organic_organ_damage(4 * removed, 0)
		else
			M.take_organ_damage(4 * removed, 0)

/datum/reagent/spaceacillin
	name = "Spaceacillin"
	description = "An all-purpose antiviral agent."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#c1c1c1"
	metabolism = REM * 0.1
	overdose = REAGENTS_OVERDOSE/2
	scannable = 1

/datum/reagent/spaceacillin/affect_blood(mob/living/carbon/M, alien, removed)
	M.immunity = max(M.immunity - 0.1, 0)
	M.add_chemical_effect(CE_ANTIVIRAL, VIRUS_COMMON)
	M.add_chemical_effect(CE_ANTIBIOTIC, 1)
	if(volume > 10)
		M.immunity = max(M.immunity - 0.3, 0)
		M.add_chemical_effect(CE_ANTIVIRAL, VIRUS_ENGINEERED)
	if(M.chem_doses[type] > 15)
		M.immunity = max(M.immunity - 0.25, 0)

/datum/reagent/spaceacillin/overdose(mob/living/carbon/M, alien)
	..()
	M.immunity = max(M.immunity - 0.25, 0)
	M.add_chemical_effect(CE_ANTIVIRAL, VIRUS_EXOTIC)
	if(prob(2))
		M.immunity_norm = max(M.immunity_norm - 1, 0)

/datum/reagent/sterilizine
	name = "Sterilizine"
	description = "Sterilizes wounds in preparation for surgery and thoroughly removes blood."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#c8a5dc"
	touch_met = 5

/datum/reagent/sterilizine/affect_touch(mob/living/carbon/M, alien, removed)
	if(M.germ_level < INFECTION_LEVEL_TWO) // rest and antibiotics is required to cure serious infections
		M.germ_level -= min(removed*20, M.germ_level)
	for(var/obj/item/I in M.contents)
		I.was_bloodied = null
	M.was_bloodied = null

/datum/reagent/sterilizine/touch_obj(obj/O)
	O.germ_level -= min(volume*20, O.germ_level)
	O.was_bloodied = null

/datum/reagent/sterilizine/touch_turf(turf/T)
	T.germ_level -= min(volume*20, T.germ_level)
	for(var/obj/item/I in T.contents)
		I.was_bloodied = null
	for(var/obj/effect/decal/cleanable/blood/B in T)
		qdel(B)

/datum/reagent/leporazine
	name = "Leporazine"
	description = "Leporazine can be use to stabilize an individuals body temperature."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#c8a5dc"
	overdose = REAGENTS_OVERDOSE
	scannable = 1

/datum/reagent/leporazine/affect_blood(mob/living/carbon/M, alien, removed)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

/* Antidepressants */

/datum/reagent/methylphenidate
	name = "Methylphenidate"
	description = "Improves the ability to concentrate."
	taste_description = "sourness"
	reagent_state = LIQUID
	color = "#bf80bf"
	metabolism = 0.01
	data = 0

/datum/reagent/methylphenidate/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	if(volume <= 0.1 && M.chem_doses[type] >= 0.5 && world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
		data = world.time
		to_chat(M, "<span class='warning'>You lose focus...</span>")
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, "<span class='notice'>Your mind feels focused and undivided.</span>")

/datum/reagent/citalopram
	name = "Citalopram"
	description = "Stabilizes the mind a little."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#ff80ff"
	metabolism = 0.01
	data = 0

/datum/reagent/citalopram/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	if(volume <= 0.1 && M.chem_doses[type] >= 0.5 && world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
		data = world.time
		to_chat(M, "<span class='warning'>Your mind feels a little less stable...</span>")
	else
		M.add_chemical_effect(CE_MIND, 1)
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, "<span class='notice'>Your mind feels stable... a little stable.</span>")

/datum/reagent/paroxetine
	name = "Paroxetine"
	description = "Stabilizes the mind greatly, but has a chance of adverse effects."
	reagent_state = LIQUID
	color = "#ff80bf"
	metabolism = 0.01
	data = 0

/datum/reagent/paroxetine/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	if(volume <= 0.1 && M.chem_doses[type] >= 0.5 && world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
		data = world.time
		to_chat(M, "<span class='warning'>Your mind feels much less stable...</span>")
	else
		M.add_chemical_effect(CE_MIND, 2)
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			if(prob(90))
				to_chat(M, "<span class='notice'>Your mind feels much more stable.</span>")
			else
				to_chat(M, "<span class='warning'>Your mind breaks apart...</span>")
				M.hallucination(200, 100)

/datum/reagent/nicotine
	name = "Nicotine"
	description = "A sickly yellow liquid sourced from tobacco leaves. Stimulates and relaxes the mind and body."
	taste_description = "peppery bitterness"
	reagent_state = LIQUID
	color = "#efebaa"
	metabolism = REM * 0.025
	excretion = 1.0
	overdose = 6
	scannable = 1
	data = 0

/datum/reagent/nicotine/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	if(prob(volume*20))
		M.add_chemical_effect(CE_PULSE, 1)
	if(volume <= 0.02 && M.chem_traces[type] >= 0.05 && world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY * 0.3)
		data = world.time
		to_chat(M, SPAN("warning", "You feel antsy, your concentration wavers..."))
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY * 0.3)
			data = world.time
			if(volume <= 4.0)
				to_chat(M, SPAN("notice", "You feel invigorated and calm."))
			else
				to_chat(M, SPAN("warning", "You feel like you should smoke less often..."))

/datum/reagent/nicotine/overdose(mob/living/carbon/M, alien)
	..()
	M.add_chemical_effect(CE_PULSE, 2)

/datum/reagent/tobacco
	name = "Tobacco"
	description = "Cut and processed tobacco leaves."
	taste_description = "tobacco"
	reagent_state = SOLID
	color = "#684b3c"
	scannable = 1
	var/nicotine = REM * 0.1

/datum/reagent/tobacco/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	M.reagents.add_reagent(/datum/reagent/nicotine, nicotine)

/datum/reagent/tobacco/fine
	name = "Fine Tobacco"
	taste_description = "fine tobacco"
	nicotine = REM * 0.075

/datum/reagent/tobacco/bad
	name = "Terrible Tobacco"
	taste_description = "acrid smoke"
	nicotine = REM * 0.2

/datum/reagent/tobacco/liquid
	name = "Nicotine Solution"
	description = "A diluted nicotine solution."
	reagent_state = LIQUID
	taste_mult = 0
	color = "#fcfcfc"
	nicotine = REM * 0.02

/datum/reagent/menthol
	name = "Menthol"
	description = "Tastes naturally minty, and imparts a very mild numbing sensation."
	taste_description = "mint"
	reagent_state = LIQUID
	color = "#80af9c"
	metabolism = REM * 0.002
	overdose = REAGENTS_OVERDOSE * 0.25
	scannable = 1
	data = 0

/datum/reagent/menthol/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY * 0.35)
		data = world.time
		to_chat(M, "<span class='notice'>You feel faintly sore in the throat.</span>")

/datum/reagent/rezadone
	name = "Rezadone"
	description = "A powder with almost magical properties, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
	taste_description = "sickness"
	reagent_state = SOLID
	color = "#669900"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/rezadone/affect_blood(mob/living/carbon/M, alien, removed)
	M.adjustCloneLoss(-20 * removed)
	M.adjustOxyLoss(-2 * removed)
	M.heal_organ_damage(20 * removed, 20 * removed)
	M.adjustToxLoss(-20 * removed)
	if(M.chem_doses[type] > 3 && ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/external/head/h in H.organs)
			h.status |= ORGAN_DISFIGURED //currently only matters for the head, but might as well disfigure them all. // ONLY HEAD JESUS CHRIST ONLY HEAD, IF IT'S NOT HEAD IT CAN'T BE HEALED AND IT WILL DESTROY handle_stance() WITH SANITY OF ALL PLAYERS WHO TOUCHED 0.00001337 UNITS OF ANY SHIT PLEASE GOD NO
	if(M.chem_doses[type] > 10)
		M.make_dizzy(5)
		M.make_jittery(5)

/datum/reagent/noexcutite
	name = "Noexcutite"
	description = "A thick, syrupy liquid that has a lethargic effect. Used to cure cases of jitteriness."
	taste_description = "numbing coldness"
	reagent_state = LIQUID
	color = "#bc018a"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/noexcutite/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	var/effect_mult = removed / metabolism
	M.make_jittery(-50 * effect_mult)

/datum/reagent/antidexafen
	name = "Antidexafen"
	description = "All-in-one cold medicine. Fever, cough, sneeze, safe for babies."
	taste_description = "cough syrup"
	reagent_state = LIQUID
	color = "#c8a5dc"
	overdose = 60
	scannable = 1
	metabolism = REM * 0.15
	flags = IGNORE_MOB_SIZE

/datum/reagent/antidexafen/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return

	M.add_chemical_effect(CE_PAINKILLER, 15)
	M.add_chemical_effect(CE_ANTIVIRAL, 1)

/datum/reagent/antidexafen/overdose(mob/living/carbon/M, alien)
	M.add_chemical_effect(CE_TOXIN, 1)
	M.hallucination(60, 20)
	M.druggy = max(M.druggy, 2)

/datum/reagent/adrenaline
	name = "Adrenaline"
	description = "Adrenaline is a hormone used as a drug to treat cardiac arrest and other cardiac dysrhythmias resulting in diminished or absent cardiac output."
	taste_description = "rush"
	reagent_state = LIQUID
	color = "#c8a5dc"
	scannable = 1
	overdose = 20
	metabolism = REM * 0.5

/datum/reagent/adrenaline/affect_blood(mob/living/carbon/human/M, alien, removed)
	if(alien == IS_DIONA)
		return

	if(M.chem_doses[type] < 0.2)	//not that effective after initial rush
		M.add_chemical_effect(CE_PAINKILLER, min(30*volume, 80))
		M.add_chemical_effect(CE_PULSE, 1)
	else if(M.chem_doses[type] < 1)
		M.add_chemical_effect(CE_PAINKILLER, min(10*volume, 20))
	M.add_chemical_effect(CE_PULSE, 2)
	if(M.chem_doses[type] > 10)
		M.make_jittery(5)
	if(volume >= 5 && M.is_asystole())
		remove_self(5)
		M.resuscitate()

/datum/reagent/nanoblood
	name = "Nanoblood"
	description = "A stable hemoglobin-based nanoparticle oxygen carrier, used to rapidly replace lost blood. Toxic unless injected in small doses. Does not contain white blood cells."
	taste_description = "blood with bubbles"
	reagent_state = LIQUID
	color = "#c10158"
	scannable = 1
	overdose = 5
	metabolism = REM * 5

/datum/reagent/nanoblood/affect_blood(mob/living/carbon/human/M, alien, removed)
	if(!M.should_have_organ(BP_HEART)) //We want the var for safety but we can do without the actual blood.
		return
	if(M.regenerate_blood(4 * removed))
		M.immunity = max(M.immunity - 0.1, 0)
		if(M.chem_traces[type] > M.species.blood_volume/8) //half of blood was replaced with us, rip white bodies
			M.immunity = max(M.immunity - 0.5, 0)

/* Cannabis Stuff ~TobyThorne */
/*							  */
/* THC - done				  */
/* CBD - to be done			  */
/* cannabis oil - to be done  */

/datum/reagent/thc   // -SECURITY OPEN UP!!! - Ha-ha. No. c:
	name = "Tetrahydrocannabinol"
	description = "THC, or tetrahydrocannabinol, is the chemical responsible for most of marijuana's psychological effects. THC stimulates cells in the brain to release dopamine, effectively causing euphoria."
	taste_description = "dope stuff"
	reagent_state = LIQUID
	color = "#778800"
	scannable = 1
	overdose = 50
	metabolism = REM * 0.25
	ingest_met = REM * 0.15
	absorbability = 0.75
	data = 0
	var/thcdata = 0

/datum/reagent/thc/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	if(alien == IS_DIONA)
		return

	if(affecting_dose >= 15) // Stoned
		M.add_chemical_effect(CE_MIND, 3)
		M.nutrition = max(0, M.nutrition - 50 * removed)
		M.add_chemical_effect(CE_PAINKILLER, 75)
		M.drowsyness = max(M.drowsyness, 10)
		if(prob(30))
			M.druggy = max(M.druggy, 6)
		if(prob(5))
			M.emote(pick("cough", "giggle", "laugh"))
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, SPAN("notice", "You don't give a fuck about anything."))
		if(world.time > thcdata + DRUGS_MESSAGE_DELAY)
			thcdata = world.time
			if(prob(60))
				to_chat(M, SPAN("warning", "You feel stoned."))
			else
				to_chat(M, SPAN("warning", "You are hungry as fuck!"))

	else if(affecting_dose >= 10) // Smoked a good load of kush.
		M.add_chemical_effect(CE_MIND, 2)
		M.nutrition -= max(0, M.nutrition - 20 * removed)
		M.add_chemical_effect(CE_PAINKILLER, 50)
		if(prob(15))
			M.druggy = max(M.druggy, 2)
		if(prob(5))
			M.druggy = max(M.druggy, 4)
			M.emote(pick("cough", "giggle"))
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, SPAN("notice", "Your mind feels much more stable."))
		if(world.time > thcdata + DRUGS_MESSAGE_DELAY)
			thcdata = world.time
			if(prob(60))
				to_chat(M, SPAN("notice", "You feel high and happy."))
			else
				to_chat(M, SPAN("warning", "You feel really hungry."))

	else if(affecting_dose >= 5) // Smoked a single bud.
		M.add_chemical_effect(CE_MIND, 1)
		M.nutrition -= max(0, M.nutrition - 10 * removed)
		M.add_chemical_effect(CE_PAINKILLER, 25)
		if(prob(10))
			M.druggy = max(M.druggy, 2)
		if(prob(4))
			M.druggy = max(M.druggy, 3)
			M.emote(pick("cough"))
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, SPAN("notice", "Your mind feels stable."))
		if(world.time > thcdata + DRUGS_MESSAGE_DELAY)
			thcdata = world.time
			if(prob(60))
				to_chat(M, SPAN("notice", "You feel high and happy."))
			else
				to_chat(M, SPAN("notice", "Why not to find something to eat?"))

	else if(affecting_dose >= 2) // The end of the trip.
		M.add_chemical_effect(CE_MIND, 0.5)
		M.nutrition -= max(0, M.nutrition - 3 * removed)
		M.add_chemical_effect(CE_PAINKILLER, 5)
		if(prob(3))
			M.druggy = max(M.druggy, 2)
			M.emote(pick("cough"))
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, SPAN("notice", "Your mind feels stable... a little stable."))
		if(world.time > thcdata + DRUGS_MESSAGE_DELAY)
			thcdata = world.time
			if(prob(60))
				to_chat(M, SPAN("notice", "You feel funny."))
			else
				to_chat(M, SPAN("notice", "You are a bit hungry."))

	else if(affecting_dose <= 0.5 && world.time > thcdata + DRUGS_MESSAGE_DELAY)
		thcdata = world.time
		to_chat(M, SPAN("notice", "Weed..."))

/datum/reagent/thc/overdose(mob/living/carbon/M, alien)
	if(world.time > thcdata + DRUGS_MESSAGE_DELAY/2)
		thcdata = world.time
		var/message = pick("That's it. Whitey. Man up and deal with it.", "You are stoned as hell.", "Damn it...", "You can barely stand.")
		to_chat(M, SPAN("warning", "[message]"))  // Blyat pacani ya blednogo lovlu, pomogite!
	if(prob(10))
		M.emote(pick("cough", "vomit", "drool", "moan"))
	M.hallucination(15, 15)
	M.drowsyness = max(M.drowsyness, 30)
	M.add_chemical_effect(CE_PAINKILLER, 100)



/datum/reagent/albumin
	name = "Albumin"
	description = "Serum albumin is the most abundant blood plasma protein and is produced in the liver and forms a large proportion of all plasma protein. Used to improve blood regeneration rate."
	taste_description = "iron"
	reagent_state = LIQUID
	color = "#803835"
	scannable = 1
	overdose = 25
	metabolism = REM
	ingest_met = REM * 0.5
	absorbability = 1.0

/datum/reagent/albumin/affect_blood(mob/living/carbon/human/M, alien, removed)
	if(!M.should_have_organ(BP_HEART)) //We want the var for safety but we can do without the actual blood.
		return
	M.regenerate_blood(1.5 * removed)

/datum/reagent/immunobooster
	name = "Immunobooster"
	description = "A drug that helps restore the immune system. Will not replace a normal immunity."
	taste_description = "chalky"
	reagent_state = LIQUID
	color = "#ffc0cb"
	metabolism = REM
	overdose = REAGENTS_OVERDOSE
	value = 1.5
	scannable = 1

/datum/reagent/immunobooster/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	if(volume < REAGENTS_OVERDOSE && !M.chem_effects[CE_ANTIVIRAL])
		M.immunity = min(M.immunity_norm * 0.5, removed + M.immunity) // Rapidly brings someone up to half immunity.
	if(M.chem_effects[CE_ANTIVIRAL]) //don't take with 'cillin
		M.add_chemical_effect(CE_TOXIN, 4) // as strong as taking vanilla 'toxin'


/datum/reagent/immunobooster/overdose(mob/living/carbon/M, alien)
	..()
	M.add_chemical_effect(CE_TOXIN, 1)
	M.immunity -= 0.5 //inverse effects when abused
