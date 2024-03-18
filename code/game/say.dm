/atom/movable/proc/say(message, datum/language/language = null, verb = "says", alt_name = "", whispering, log_message = TRUE, sanitize = TRUE,	forced = FALSE,	fillog_message = TRUE,	list/message_mods = list())
	message = html_decode(message)

	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message || message == "")
		return

	var/list/message_data = list(
	  "message" = message,
	  "language" = language,
	  "verb" = verb,
	  "whispering" = whispering,
	  "italics" = FALSE,
	  "message_range" = 0,
	  "sound" = null,
	  "sound_volume" = 0,
	  "log_message" = log_message,
	  "alt_name" = alt_name,
	)


	say_do_say(message_data)

/atom/movable/proc/say_do_say(list/message_data)
	var/list/listeners = get_hearers_in_view(world.view, src)

	for(var/atom/movable/M in listeners)
		if(M)
			M.hear_say(
				message_data["message"],
				message_data["verb"],
				message_data["language"],
				message_data["alt_name"],
				message_data["italics"],
				src,
				message_data["sound"],
				message_data["sound_volume"]
			)

/// Called when this movable hears a message from a source.
/// Returns TRUE if the message was received and understood.
// At minimum every atom movable has a hear_say proc.

/atom/movable/proc/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = FALSE, atom/movable/speaker = null, sound/speech_sound, sound_vol)
	pass()

/atom/movable/proc/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0, vname ="", loud)
	hear_say(message, verb, language, speaker = speaker)

/atom/movable/proc/say_understands(atom/movable/other, datum/language/language = null)
	if(universal_speak || universal_understand)
		return TRUE

	if(other?.universal_speak)
		return TRUE

	if(language?.flags & INNATE)
		return TRUE

	return FALSE
