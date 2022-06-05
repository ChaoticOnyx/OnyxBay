/datum/storyteller_character
	var/name = "Unknown Storyteller character"
	var/desc = ""
	var/__metrics
	
	var/__debug = TRUE                // print debug logs

// returns time for next cycle
/datum/storyteller_character/proc/process_round_start()
	_log_debug("Round start processing begins")

/datum/storyteller_character/proc/process_new_cycle_start()
	_log_debug("New cycle processing begins")

/datum/storyteller_character/proc/get_params_for_ui()
	var/list/data = list(
		"name" = name,
		"description" = desc
	)
	return data

/datum/storyteller_character/proc/_log_debug(text, verbose = FALSE)
	if (!__debug)
		return
	var/string_to_log = "\[Storyteller Character]: [text]"
	if (!verbose)
		log_debug(string_to_log)
	else
		log_debug_verbose(string_to_log)

/datum/storyteller_character/proc/_get_metric(type)
	return SSstoryteller.get_metric(type)

/datum/storyteller_character/proc/_run_trigger(type)
	return SSstoryteller.run_trigger(type)

/datum/storyteller_character/proc/get_available_vacancies()
	return round(round_duration_in_ticks/JOB_VACANCIES_SLOT_PER_TIME) + JOB_VACANCIES_SLOTS_AVAILABLE_AT_ROUNDSTART
