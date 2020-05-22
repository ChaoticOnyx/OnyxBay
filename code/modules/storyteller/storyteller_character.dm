/datum/storyteller_character
	var/name = "Unknown Storyteller character"
	var/desc = ""
	var/__metrics

// returns time for next cycle
/datum/storyteller_character/proc/process_round_start()
	_log_debug("Round start processing begins")

/datum/storyteller_character/proc/process_new_cycle_start()
	_log_debug("New cycle processing begins")

/datum/storyteller_character/proc/_log_debug(text)
	log_debug("\[Storyteller Character]: [text]")

/datum/storyteller_character/proc/_get_metric(type)
	return SSstoryteller.get_metric(type)

/datum/storyteller_character/proc/_run_trigger(type)
	return SSstoryteller.run_trigger(type)
