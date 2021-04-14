/datum/reagent/hormone
	metabolism = REM * 0.2
	reagent_state = LIQUID
	color = "#eeddff"
	scannable = TRUE
	overdose = REAGENTS_OVERDOSE * 0.33
	var/min_normal = 0
	var/max_normal = 0
	var/average_normal = 0

	var/normal_msg

	var/min_bad = 0
	var/max_bad = 0
	var/low_bad_msg
	var/high_bad_msg

	var/low_critical_msg
	var/high_critical_msg

/datum/reagent/hormone/proc/get_level(mob/living/carbon/M)
	var/value = M.reagents.get_reagent_amount(type)
	if(value >= min_normal && value <= max_normal)
		return HORMONE_LEVEL_NORMAL

	if(value >= min_bad && value <= max_bad)
		return HORMONE_LEVEL_BAD

	return HORMONE_LEVEL_CRITICAL

/datum/reagent/hormone/proc/get_msg(mob/living/carbon/M)
	var/level = get_level(M)

	switch(level)
		if(HORMONE_LEVEL_NORMAL)
			return normal_msg

		if(HORMONE_LEVEL_BAD)
			return value < average_normal ? high_bad_msg : low_bad_msg

		if(HORMONE_LEVEL_CRITICAL)
			return value < average_normal ? high_critical_msg : low_critical_msg

/datum/reagent/hormone/glucose
	name = "Glucose"
	description = "Glucose is a main energy-containing hormone."
	overdose = BLOOD_SUGAR_HBAD + 10
	metabolism = 0.01
	min_normal = BLOOD_SUGAR_LBAD + 5
	max_normal = BLOOD_SUGAR_HBAD - 5
	average_normal = BLOOD_SUGAR_NORMAL

	normal_msg = "Normal glucose level."

	min_bad = BLOOD_SUGAR_LCRITICAL
	max_bad = BLOOD_SUGAR_HCRITICAL

	low_bad_msg = "Reduced glucose level."
	high_bad_msg = "Elevated glucose level."

	low_critical_msg = "Hypoglycemia shock."
	high_critical_msg = "Hyperglycemia shock."

	var/last_blockage = 0

/datum/reagent/hormone/glucose/affect_blood(mob/living/carbon/M, alien, removed)
	if(!ishuman(M))
		return

	var/amount = M.reagents.get_reagent_amount(/datum/reagent/hormone/glucose)
	var/new_blockage = 0
	if(amount < BLOOD_SUGAR_LBAD)
		new_blockage = 0.25
		--M.nutrition
	if(amount < BLOOD_SUGAR_LCRITICAL)
		new_blockage = 0.5
		M.nutrition -= 2

	if(amount > BLOOD_SUGAR_HBAD)
		new_blockage = 0.25
	if(amount > BLOOD_SUGAR_HCRITICAL)
		new_blockage = 0.5

	if(last_blockage > 0)
		M.chem_effects[CE_BLOCKAGE] = lerp(last_blockage, new_blockage, 0.01)
	else
		M.chem_effects[CE_BLOCKAGE] = new_blockage * 0.01
	last_blockage = M.chem_effects[CE_BLOCKAGE]

/datum/reagent/hormone/glucose/overdose(mob/living/carbon/M, alien)
	M.adjustBrainLoss(0.25)

/datum/reagent/hormone/insulin
	name = "Insulin"
	description = "Insulin is a hormone used to assimilate glucose into nutrients. Decreases nearly 10 Gu by 1 unit."
	overdose = 1000
	metabolism = 0.2

/datum/reagent/hormone/insulin/affect_blood(mob/living/carbon/M, alien, removed)
	if(!ishuman(M))
		return

	var/glucose_removed = min(M.reagents.get_reagent_amount(/datum/reagent/hormone/glucose), removed * 10)
	M.remove_glucose(glucose_removed)

	if(glucose_removed > removed * 10)
		M.nutrition -= removed * 10 - M.reagents.get_reagent_amount(/datum/reagent/hormone/glucose)

	M.nutrition += glucose_removed