
///// Changeling reagents /////
/datum/reagent/toxin/cyanide/change_toxin //Fast and Lethal
	name = "Changeling reagent"
	description = "A highly toxic chemical extracted from strange alien-looking biostructure."
	taste_mult = 0.6
	reagent_state = LIQUID
	color = "#cf3600"
	strength = 30
	metabolism = REM * 0.5
	target_organ = BP_HEART

/datum/reagent/toxin/cyanide/change_toxin/biotoxin //Fast and Lethal
	name = "Strange biotoxin"
	description = "Destroys any biological tissue in seconds."
	taste_mult = 0.6
	reagent_state = LIQUID
	color = "#cf3600"
	strength = 80
	metabolism = REM * 0.5
	target_organ = BP_BRAIN

/datum/reagent/toxin/cyanide/change_toxin/biotoxin/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	var/datum/changeling/changeling = M.mind.changeling
	if(changeling)
		M.mind.changeling.die()
		M.mind.changeling.geneticpoints = 0
		M.mind.changeling.chem_storage = 0
		M.mind.changeling.chem_recharge_rate = 0

/datum/reagent/rezadone/change_reviver
	name = "Strange bioliquid"
	description = "Smells like acetone."
	taste_description = "sourness"
	reagent_state = LIQUID
	color = "#cb68fc"
	overdose = 4
	scannable = 1
	metabolism = 0.05
	ingest_met = 0.02
	flags = IGNORE_MOB_SIZE

/datum/reagent/rezadone/change_reviver/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	var/datum/antagonist/changeling/changeling = GLOB.all_antag_types_[MODE_CHANGELING]
	if(prob(1) && M.mind && !changeling.is_antagonist(M.mind))
		changeling.add_antagonist(M.mind, ignore_role = TRUE, do_not_equip = TRUE)

/datum/reagent/rezadone/change_reviver/overdose(mob/living/carbon/M, alien)
	..()
	M.revive()

///// Changeling reagets recipes /////
/datum/chemical_reaction/change_reviver
	name = "Strange bioliquid"
	result = /datum/reagent/rezadone/change_reviver
	required_reagents = list(/datum/reagent/toxin/cyanide/change_toxin = 5, /datum/reagent/dylovene = 5, /datum/reagent/cryoxadone = 5)
	result_amount = 5

/datum/chemical_reaction/Biotoxin
	name = "Strange biotoxin"
	result = /datum/reagent/toxin/cyanide/change_toxin/biotoxin
	required_reagents = list(/datum/reagent/toxin/cyanide/change_toxin = 5, /datum/reagent/toxin/plasma = 5, /datum/reagent/mutagen = 5)
	result_amount = 3
