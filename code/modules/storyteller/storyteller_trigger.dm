/storyteller_trigger
	var/name = "Unknown Trigger"

/storyteller_trigger/proc/invoke()
	ASSERT("Storyteller trigger '[name]' invoke method is not implemented!")

/storyteller_trigger/proc/_log_debug(text)
	log_debug("\[Storyteller Trigger [name]]: [text]")
