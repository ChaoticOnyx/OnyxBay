/atom/movable/proc/say(message, datum/language/language = null, verb="says", alt_name="", whispering, log_message = TRUE)
	message = html_decode(message)
	message = sanitize(message)

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

	message_data["language"] = parse_language(message)

	var/turf/T = get_turf(src)
	if(T)
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = (environment) ? environment.return_pressure() : 0
		if(pressure < SOUND_MINIMUM_PRESSURE)
			message_data["message_range"] = 1

		if(pressure < ONE_ATMOSPHERE*0.4) // sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
			message_data["italics"] = TRUE
			message_data["sound_volume"] *= 0.5 // muffle the sound a bit, so it's like we're actually talking through contact

	say_do_say(message_data)

/atom/movable/proc/say_do_say(list/message_data)
	var/list/listeners = get_hearers_in_view(world.view, src)

	for(var/atom/movable/M in listeners)
		if(M == src)
			continue

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

/// Returns say quote (say, yell e.t.c.) based on a message ending.
/atom/movable/proc/say_quote(message, datum/language/language = null)
	var/ending = copytext(message, length(message))
	if(language)
		return language.get_spoken_verb(ending)

	var/verb = pick(speak_emote)
	if(verb == "says") // a little bit of a hack, but we can't let speak_emote default to an empty list without breaking other things
		if(ending == "!")
			verb = pick("exclaims", "shouts", "yells")
		else if(ending == "?")
			verb ="asks"
	return verb

/// Parses the language code (e.g. :j) from supplied message text. Returns null if there is no suitable language.
/atom/movable/proc/parse_language(message)
	return all_languages[LANGUAGE_GALCOM]

/atom/movable/proc/GetVoice()
	return name

// Can we speak this language, as opposed to just understanding it?
/atom/movable/proc/can_speak(datum/language/speaking)
	if(!speaking)
		return FALSE

	if(only_species_language && speaking != all_languages[species_language])
		return FALSE

	return (speaking.can_speak_special(src) && (universal_speak || (speaking && speaking.flags & INNATE) || (speaking in src.languages)))
