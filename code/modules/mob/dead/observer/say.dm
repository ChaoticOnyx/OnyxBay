/mob/dead/observer/say_understands(var/other)
	return 1

/mob/dead/observer/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_say("Ghost/[src.key] : [message]")

	if (src.muted)
		return

	. = src.say_dead(message)