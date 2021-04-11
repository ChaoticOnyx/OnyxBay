/datum/reagent/gormone
	can_be_dialysed = FALSE
	metabolism = REM * 0.2
	reagent_state = LIQUID
	color = "#eeddff"
	overdose = REAGENTS_OVERDOSE * 0.33

/datum/reagent/gormone/glucose
	overdose = REAGENTS_OVERDOSE
	metabolism = 0.01

/datum/reagent/gormone/glucose/affect_blood(mob/living/carbon/M, alien, removed)
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M

/datum/reagent/gormone/insulin
	overdose = REAGENTS_OVERDOSE
	metabolism = 0.02

/datum/reagent/gormone/insulin/affect_blood(mob/living/carbon/M, alien, removed)
	if(!ishuman(M))
		return

	var/glucose_removed = max(M.chem_doses[/datum/reagent/gormone/glucose], removed * 4)
	M.reagents.remove_reagent(/datum/reagent/gormone/glucose, glucose_removed)

	var/mob/living/carbon/human/H = M
	H.nutrition += glucose_removed * 2