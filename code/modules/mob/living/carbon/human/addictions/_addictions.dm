/mob/living/carbon/human/var/list/addictions = list()

// Per-addiction runtime state (keyed by addiction typepath)
/// When detox started (world.time, deciseconds). Null/absent => not detoxing.
/mob/living/carbon/human/var/list/addiction_detox_clean_since
/// Next allowed times (world.time) for various effects, to prevent spam.
/mob/living/carbon/human/var/list/addiction_next_msg
/mob/living/carbon/human/var/list/addiction_next_symptom
/mob/living/carbon/human/var/list/addiction_next_pain
/// Withdrawal relief [0..1] computed from antagonist reagents each tick.
/mob/living/carbon/human/var/list/addiction_withdrawal_relief

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
	/// A reagent that helps with withdrawal (reduces symptoms, does NOT replace the substance).
	/// Can be a list too.
	var/list/antagonist_reagent

	/// Amount of "satisfaction" drained per second if required reagents are not ingested. Calculations take into account SSmob's wait.
	var/drain_per_second = 1
	/// Amount of "satisfaction" gained per second if required reagents are ingested. Calculations take into account SSmob's wait.
	var/satisfaction_per_second = 1

	/// Chem doses with value lower than this will not be considered.
	var/min_chem_dose_required = 2

	/// Detox duration required to get rid of this addiction (abstinence from CAUSE reagent).
	var/detox_time_required = 45 MINUTES

	/// How much antagonists slow down satisfaction drain (0..1). Applied as: drain *= (1 - relief * antagonist_drain_reduction)
	var/antagonist_drain_reduction = 0.45
	/// Maximum relief (0..1) that antagonists can provide.
	var/antagonist_max_relief = 0.65
	/// Scaling for antagonist dose -> relief. relief_raw = antagonist_amt / antagonist_relief_dose
	var/antagonist_relief_dose = 10

/datum/addiction/proc/tick(mob/living/carbon/human/H)
	. = calculate_satisfaction_drain(H)

/datum/addiction/proc/on_relapse(mob/living/carbon/human/H)
	return

/datum/addiction/proc/on_cured(mob/living/carbon/human/H)
	return

/datum/addiction/proc/calculate_satisfaction_drain(mob/living/carbon/human/H)
	if(!H.addiction_detox_clean_since) H.addiction_detox_clean_since = list()
	if(!H.addiction_next_msg) H.addiction_next_msg = list()
	if(!H.addiction_next_symptom) H.addiction_next_symptom = list()
	if(!H.addiction_next_pain) H.addiction_next_pain = list()
	if(!H.addiction_withdrawal_relief) H.addiction_withdrawal_relief = list()

	var/cause_reagent_amt = 0
	var/antagonist_reagent_amt = 0

	for(var/r_type in H.chem_doses)
		if(H.chem_doses[r_type] < min_chem_dose_required)
			continue

		if(is_path_in_list(r_type, cause_reagent))
			cause_reagent_amt += H.chem_doses[r_type]

		if(is_path_in_list(r_type, antagonist_reagent))
			antagonist_reagent_amt += H.chem_doses[r_type]

	// Compute relief from antagonists (does not replace the substance; only reduces symptoms)
	var/relief = 0
	if(antagonist_reagent_amt > 0)
		relief = antagonist_reagent_amt / antagonist_relief_dose
		if(relief > antagonist_max_relief)
			relief = antagonist_max_relief

	H.addiction_withdrawal_relief[type] = relief

	// Detox / relapse logic (cause reagents only)
	if(cause_reagent_amt > 0)
		// If we were detoxing - relapse resets detox progress
		if(type in H.addiction_detox_clean_since)
			on_relapse(H)
			H.addiction_detox_clean_since -= type

		// On relapse we fully reset withdrawal progress (per design)
			H.addictions[type] = 0

	else
		// Start or continue detox timer (antagonists do not break detox)
		if(!(type in H.addiction_detox_clean_since))
			H.addiction_detox_clean_since[type] = world.time

		// If detox timer completed and addiction can be removed - remove it
		if(can_get_rid(H))
			var/clean_since = H.addiction_detox_clean_since[type]
			if(!isnull(clean_since) && (world.time - clean_since) >= detox_time_required)
				on_cured(H)
				H.addictions -= type
				H.addiction_detox_clean_since -= type
				H.addiction_withdrawal_relief -= type
				H.addiction_next_msg -= type
				H.addiction_next_symptom -= type
				H.addiction_next_pain -= type
				return 0

	// Satisfaction changes (antagonists reduce drain only)
	var/previous_satisfaction = H.addictions[type]
	if(cause_reagent_amt > 0)
		H.addictions[type] += satisfaction_per_second * SSmobs.wait
	else
		var/effective_drain = drain_per_second
		if(relief > 0)
			effective_drain = drain_per_second * (1 - relief * antagonist_drain_reduction)
		H.addictions[type] -= effective_drain * SSmobs.wait

	// Return absolute change for callers (kept compatible)
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
