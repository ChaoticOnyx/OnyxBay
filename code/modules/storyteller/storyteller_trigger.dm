/storyteller_trigger
	var/name = "Unknown Trigger"

	var/__debug = TRUE                // print debug logs

/storyteller_trigger/proc/invoke()
	ASSERT("Storyteller trigger '[name]' invoke method is not implemented!")

/storyteller_trigger/proc/_log_debug(text, verbose = FALSE)
	if (!__debug)
		return
	var/string_to_log = "\[Storyteller Trigger [name]]: [text]"
	if (!verbose)
		log_debug(string_to_log)
	else
		log_debug_verbose(string_to_log)
