/mob/living/carbon/human/var/list/addictions = list()

GLOBAL_LIST_INIT(all_addictions, init_addictions())

/proc/init_addictions()
	var/list/addictions = list()
	for(var/path in subtypesof(/datum/addiction))
		addictions += new path()

	return addictions

/// ITS A FUCKING SINGLETONE!!!
/datum/addiction
	var/name

	/// A reagent that causes this addiction.
	var/list/cause_reagent
	/// A reagent that supresses the negative effects of addiction and helps with withdrawal.
	/// Can be a list too.
	var/list/antagonist_reagent
	/// Amount of "satisfaction" drained per second if required reagents are not ingested. Calculations take into account SSmob's wait.
	var/drain_per_second = 1
	/// Amount of "satisfaction" gained per second if required reagents are not ingested. Calculations take into account SSmob's wait.
	var/satisfaction_per_second = 1

	/// Chem doses with value lower than this will not be considered.
	var/min_chem_dose_required = 2

/datum/addiction/proc/tick(mob/living/carbon/human/H)
	. = calculate_satisfaction_drain(H)

/datum/addiction/proc/calculate_satisfaction_drain(mob/living/carbon/human/H)
	var/cause_reagent_amt = 0
	var/antagonist_reagent_amt = 0
	for(var/type in H.chem_doses)
		if(H.chem_doses[type] < 1)
			continue

		if(is_path_in_list(type, cause_reagent))
			cause_reagent_amt += H.chem_doses[type]

		if(is_path_in_list(type, antagonist_reagent))
			antagonist_reagent_amt += H.chem_doses[type]

	var/previous_satisfaction = H.addictions[type]
	if(cause_reagent_amt > 0 || antagonist_reagent_amt > 0)
		H.addictions[type] += satisfaction_per_second * SSmobs.wait
	else
		H.addictions[type] -= drain_per_second * SSmobs.wait

	if(previous_satisfaction > H.addictions[type])
		return H.addictions[type] - previous_satisfaction
	else
		return previous_satisfaction - H.addictions[type]

/datum/addiction/proc/can_get_rid(mob/living/carbon/human/H)
	return TRUE

/mob/living/carbon/human/proc/add_addiction(datum/addiction/A, initial_satisfaction = 0)
	addictions[A.type] = initial_satisfaction

/mob/living/carbon/human/proc/handle_addictions()
	for(var/datum/addiction/A in GLOB.all_addictions)
		if(!(A.type in addictions))
			continue

		A.tick(src)
