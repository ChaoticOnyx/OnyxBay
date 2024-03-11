/atom/movable/proc/say(message, datum/language/language = null, verb = "says", alt_name = "", whispering, log_message = TRUE, sanitize = TRUE,	forced = FALSE,	fillog_message = TRUE,	list/message_mods = list())
	message = html_decode(message)

	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message || message == "")
		return

	say_do_say()

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

/atom/movable/proc/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = FALSE, mob/speaker = null, sound/speech_sound, sound_vol)
	var/dist_speech = get_dist(speaker, src)
	var/near = dist_speech <= world.view

	//make sure the air can transmit speech - hearer's side
	var/turf/T = get_turf(src)
	if(T && !isghost(src)) //Ghosts can hear even in vacuum.
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = (environment) ? environment.return_pressure() : 0
		if(pressure < SOUND_MINIMUM_PRESSURE && dist_speech > 1)
			return

		if (pressure < ONE_ATMOSPHERE*0.4) //sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
			italics = TRUE
			sound_vol *= 0.5 //muffle the sound a bit, so it's like we're actually talking through contact
7
