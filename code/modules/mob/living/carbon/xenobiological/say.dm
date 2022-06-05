/mob/living/carbon/metroid/say(message)

	message = sanitize(message)

	var/verb = say_quote(message)

	if(copytext(message,1,2) == get_prefix_key(/decl/prefix/custom_emote))
		return emote(copytext(message,2))

	return ..(message, null, verb)

/mob/living/carbon/metroid/say_quote(text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "asks";
	else if (ending == "!")
		return "cries";

	return "chirps";

/mob/living/carbon/metroid/say_understands(other)
	if (istype(other, /mob/living/carbon/metroid))
		return 1
	return ..()

/mob/living/carbon/metroid/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)
	if (speaker in Friends)
		speech_buffer = list()
		speech_buffer.Add(speaker)
		speech_buffer.Add(lowertext(html_decode(message)))
	..()

/mob/living/carbon/metroid/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0, vname ="")
	if (speaker in Friends)
		speech_buffer = list()
		speech_buffer.Add(speaker)
		speech_buffer.Add(lowertext(html_decode(message)))
	..()
