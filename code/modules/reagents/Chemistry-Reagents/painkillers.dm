
/datum/reagent/painkiller
	name = "Metazine"
	description = "Metazine is a very potent painkiller. Although it's not an opiate, users may quickly develop a tolerance to the drug."
	taste_description = "numbness"
	reagent_state = LIQUID
	color = "#b5af80"
	overdose = REAGENTS_OVERDOSE * 0.5
	scannable = TRUE
	metabolism = REM * 0.5
	ingest_met = REM * 0.25
	absorbability = 0.25
	excretion = 0.25
	flags = IGNORE_MOB_SIZE

	var/pain_power = 200 // Magnitide of painkilling effect
	var/effective_dose = 0.5 // How many units it need to process to reach max power
	var/soft_overdose = 7.5 // Determines when it starts causing negative effects w/out actually causing OD
	var/tolerance_threshold = 7.5 // Having more than this value in chem_traces will reduce effectiveness
	var/tolerance_mult = 0.1 // Percentage of effect weakening by each unit over tolerance_threshold

/datum/reagent/painkiller/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	var/effectiveness = removed / metabolism
	handle_painkiller_effect(M, affecting_dose, effectiveness)
	handle_painkiller_overdose(M, affecting_dose)

/datum/reagent/painkiller/overdose(mob/living/carbon/M, alien)
	..()
	M.hallucination(120, 30)
	M.druggy = max(M.druggy, 10)
	M.add_chemical_effect(CE_PAINKILLER, pain_power * 0.5) // extra painkilling for extra trouble
	M.add_chemical_effect(CE_BREATHLOSS, 0.6) // Have trouble breathing, need more air

/datum/reagent/painkiller/proc/handle_painkiller_effect(mob/living/carbon/M, affecting_dose, effectiveness)
	if(affecting_dose < effective_dose) //some ease-in ease-out for the effect
		effectiveness = (affecting_dose / effective_dose) * effectiveness
	if(M.chem_traces[type] > tolerance_threshold)
		effectiveness *= 1.0 - ((M.chem_traces[type] - tolerance_threshold) * tolerance_mult)
	M.add_chemical_effect(CE_PAINKILLER, pain_power * effectiveness)

/datum/reagent/painkiller/proc/handle_painkiller_overdose(mob/living/carbon/M, affecting_dose)
	if(M.chem_doses[type] > soft_overdose)
		M.add_chemical_effect(CE_SLOWDOWN, 1)
		if(prob(1))
			M.slurring = max(M.slurring, 10)
	if(M.chem_doses[type] > (overdose + soft_overdose) / 2)
		if(prob(5))
			M.slurring = max(M.slurring, 20)
	if(M.chem_doses[type] > overdose)
		M.slurring = max(M.slurring, 30)
		if(prob(1))
			M.Weaken(2)
			M.drowsyness = max(M.drowsyness, 5)

/datum/reagent/painkiller/proc/isboozed(mob/living/carbon/M)
	. = 0
	var/datum/reagents/ingested = M.get_ingested_reagents()
	if(ingested)
		var/list/pool = M.reagents.reagent_list | ingested.reagent_list
		for(var/datum/reagent/ethanol/booze in pool)
			if(M.chem_doses[booze.type] < 2) //let them experience false security at first
				continue
			. = 1
			if(booze.strength < 40) //liquor stuff hits harder
				return 2


/datum/reagent/painkiller/tramadol
	name = "Tramadol"
	description = "A simple, yet effective painkiller. Don't mix with alcohol."
	taste_description = "sourness"
	reagent_state = LIQUID
	color = "#cb68fc"
	overdose = REAGENTS_OVERDOSE
	scannable = TRUE
	metabolism = REM * 0.5
	ingest_met = REM * 0.25
	absorbability = 1.0 // real-life tramadol bioavailability is surprisingly high, hitting almost 100%

	pain_power = 100
	effective_dose = 2.5
	soft_overdose = 15
	tolerance_threshold = 15.0
	tolerance_mult = 0.05

/datum/reagent/painkiller/tramadol/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	..()
	var/boozed = isboozed(M)
	if(boozed)
		M.add_chemical_effect(CE_ALCOHOL_TOXIC, 1)
		M.add_chemical_effect(CE_BREATHLOSS, 0.1 * boozed) //drinking and opiating makes breathing kinda hard

/datum/reagent/painkiller/tramadol/overdose(mob/living/carbon/M, alien)
	..()
	if(isboozed(M))
		M.add_chemical_effect(CE_BREATHLOSS, 0.2) //Don't drink and OD on opiates folks


/datum/reagent/painkiller/tramadol/oxycodone
	name = "Oxycodone"
	description = "An effective and very addictive painkiller. Don't mix with alcohol."
	taste_description = "bitterness"
	color = "#800080"
	overdose = REAGENTS_OVERDOSE * 0.5

	pain_power = 180
	effective_dose = 2.0
	tolerance_threshold = 10.0
	tolerance_mult = 0.075

/datum/reagent/painkiller/tramadol/oxycodone/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	..()
	if(affecting_dose > effective_dose)
		M.add_chemical_effect(CE_SLOWDOWN, 1)
		M.add_chemical_effect(CE_TOXIN, 1)

/datum/reagent/painkiller/tramadol/oxycodone/affect_ingest(mob/living/carbon/M, alien, removed, affecting_dose)
	var/effectiveness = removed / ingest_met
	handle_painkiller_effect(M, affecting_dose, effectiveness)
	handle_painkiller_overdose(M, affecting_dose)
	var/boozed = isboozed(M)
	if(boozed)
		M.add_chemical_effect(CE_ALCOHOL_TOXIC, 1)
		M.add_chemical_effect(CE_BREATHLOSS, 0.1 * boozed) //drinking and opiating makes breathing kinda hard


/datum/reagent/painkiller/opium // yes, opium is a subtype of tramadol, for reasons ~Toby
	name = "Opium"
	description = "Latex obtained from the opium poppy. An effective, but addictive painkiller."
	taste_description = "bitterness"
	color = "#63311b"
	overdose = 20
	soft_overdose = 10
	scannable = 0
	reagent_state = SOLID
	data = 0
	metabolism = REM * 0.5
	ingest_met = REM * 0.25

	pain_power = 150
	effective_dose = 2.5
	soft_overdose = 15
	tolerance_threshold = 15.0
	tolerance_mult = 0.05

	var/drugdata = 0

/datum/reagent/painkiller/opium/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	..()
	var/boozed = isboozed(M)
	if(boozed)
		M.add_chemical_effect(CE_ALCOHOL_TOXIC, 1)
		M.add_chemical_effect(CE_BREATHLOSS, 0.1 * boozed) //drinking and opiating makes breathing kinda hard
	if(world.time > drugdata + DRUGS_MESSAGE_DELAY)
		drugdata = world.time
		var/msg = ""
		if(pain_power > 200)
			msg = pick("unbeliveably happy", "like living your best life", "blissful", "blessed", "unearthly tranquility")
		else
			msg = pick("happy", "joyful", "relaxed", "tranquility")
		to_chat(M, SPAN("notice", "You feel [msg]."))

/datum/reagent/painkiller/opium/handle_painkiller_overdose(mob/living/carbon/M, affecting_dose)
	var/whole_volume = (volume + M.chem_traces[type]) // side effects are more robust (dose-wise) than in the case of *legal* painkillers usage
	if(whole_volume > soft_overdose)
		M.add_chemical_effect(CE_SLOWDOWN, 1)
		M.druggy = max(M.druggy, 10)
		if(prob(1))
			M.slurring = max(M.slurring, 10)
	if(whole_volume > (overdose+soft_overdose)/2)
		M.eye_blurry = max(M.eye_blurry, 10)
		if(prob(5))
			M.slurring = max(M.slurring, 20)
	if(whole_volume > overdose)
		M.add_chemical_effect(CE_SLOWDOWN, 2)
		M.slurring = max(M.slurring, 30)
		if(prob(1))
			M.Weaken(2)
			M.drowsyness = max(M.drowsyness, 5)

/datum/reagent/painkiller/opium/overdose(mob/living/carbon/M, alien)
	..()
	if(isboozed(M))
		M.add_chemical_effect(CE_BREATHLOSS, 0.2) //Don't drink and OD on opiates folks

/datum/reagent/painkiller/opium/tarine
	name = "Tarine"
	description = "An opioid most commonly used as a recreational drug for its euphoric effects. An extremely effective painkiller, yet is terribly addictive and notorious for its life-threatening side-effects."
	color = "#b79a8d"
	overdose = 15
	scannable = 0
	reagent_state = SOLID

	soft_overdose = 7.5
	pain_power = 240
	tolerance_threshold = 10.0

/datum/reagent/painkiller/opium/tarine/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	..()
	M.add_chemical_effect(CE_SLOWDOWN, 1)

/datum/reagent/painkiller/opium/tarine/handle_painkiller_overdose(mob/living/carbon/M, affecting_dose)
	var/whole_volume = (volume + M.chem_traces[type]) // side effects are more robust (dose-wise) than in the case of *legal* painkillers usage
	if(whole_volume > soft_overdose)
		M.hallucination(30, 30)
		M.eye_blurry = max(M.eye_blurry, 10)
		M.drowsyness = max(M.drowsyness, 5)
		M.druggy = max(M.druggy, 10)
		M.add_chemical_effect(CE_SLOWDOWN, 2)
		if(prob(5))
			M.slurring = max(M.slurring, 20)
	if(whole_volume > overdose)
		M.add_chemical_effect(CE_SLOWDOWN, 3)
		M.slurring = max(M.slurring, 30)
		M.Weaken(5)
		if(prob(25))
			M.sleeping = max(M.sleeping, 3)
		M.add_chemical_effect(CE_BREATHLOSS, 0.2)


/datum/reagent/painkiller/paracetamol
	name = "Paracetamol"
	description = "Most probably know this as Tylenol, but this chemical is a mild, simple painkiller."
	taste_description = "sickness"
	reagent_state = LIQUID
	color = "#c8a5dc"
	overdose = REAGENTS_OVERDOSE
	overdose = 60
	scannable = 1
	metabolism = REM * 0.2
	ingest_met = 0
	flags = IGNORE_MOB_SIZE
	absorbability = 0.8 // Actually, it's a real-life value
	excretion = 0.75

	pain_power = 35
	effective_dose = 2.5
	soft_overdose = 30.0
	tolerance_threshold = 30.0
	tolerance_mult = 0.05

/datum/reagent/painkiller/paracetamol/overdose(mob/living/carbon/M, alien)
	M.add_chemical_effect(CE_TOXIN, 1)
	M.druggy = max(M.druggy, 2)
	M.add_chemical_effect(CE_PAINKILLER, 10)
