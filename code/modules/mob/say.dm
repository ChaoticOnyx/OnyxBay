/mob/proc/say()
	return

/mob/verb/whisper()
	set name = "Whisper"
	set category = "IC"
	return

/mob/verb/say_verb(message as text|null)
	set name = "Say"
	set hidden = TRUE

	ASSERT(client && usr == src)

	client.close_saywindow()

	usr.say(message)

/mob/verb/say_verb_fake()
	set name = "Say Verb"
	set category = "IC"

	ASSERT(client && usr == src)

	winset(usr, null, "saywindow.is-visible=true;saywindow-input.focus=true;")

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	message = sanitize(message)

	if(use_me)
		usr.emote("me",usr.emote_type,message)
	else
		usr.emote(message)

	client?.spellcheck(message)

	var/ckeyname = "[usr.ckey]/[usr.name]"
	webhook_send_me(ckeyname, message)

/mob/proc/say_dead(message)
	communicate(/decl/communication_channel/dsay, client, message)

/mob/proc/say_understands(mob/other,datum/language/language = null)

	if(src.stat == DEAD)
		return TRUE

	// Universal speak makes everything understandable, for obvious reasons.
	else if(src.universal_speak || src.universal_understand)
		return TRUE

	// Languages are handled after.
	if(!language)
		if(!other)
			return TRUE
		if(other.universal_speak)
			return TRUE
		if(isAI(src) && ispAI(other))
			return TRUE
		if(istype(other, src.type) || istype(src, other.type))
			return TRUE
		return FALSE

	if(language.flags & INNATE)
		return TRUE

	//Language check.
	for(var/datum/language/L in src.languages)
		if(language.name == L.name)
			return TRUE

	return FALSE

/mob/proc/say_quote(message, datum/language/language = null)
	var/ending = copytext(message, length(message))
	if(language)
		return language.get_spoken_verb(ending)

	var/verb = pick(speak_emote)
	if(verb == "says") // a little bit of a hack, but we can't let speak_emote default to an empty list without breaking other things
		if(ending == "!")
			verb = pick("exclaims","shouts","yells")
		else if(ending == "?")
			verb ="asks"
	return verb

/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)

/mob/proc/say_test(text)
	var/ending = copytext(text, length(text))
	if(ending == "?")
		return "1"
	else if(ending == "!")
		return "2"
	return "0"

// parses the message mode code (e.g. :h, :w) from text, such as that supplied to say.
// returns the message mode string or null for no message mode.
// standard mode is the mode returned for the special ';' radio code.
/mob/proc/parse_message_mode(message, standard_mode="headset")
	if(length_char(message) >= 1 && copytext_char(message,1,2) == get_prefix_key(/decl/prefix/radio_main_channel))
		return standard_mode

	if(length_char(message) >= 2)
		var/channel_prefix = copytext_char(message, 1 ,3)
		return department_radio_keys[channel_prefix]

	return null

// parses the language code (e.g. :j) from text, such as that supplied to say.
// returns the language object only if the code corresponds to a language that src can speak, otherwise null.
/mob/proc/parse_language(message)
	var/prefix = copytext_char(message,1,2)
	if(length_char(message) >= 1 && prefix == get_prefix_key(/decl/prefix/audible_emote))
		return all_languages["Noise"]

	if(length_char(message) >= 2 && is_language_prefix(prefix))
		var/language_prefix = sanitize_cyrillic_char(copytext_char(message, 2 ,3))
		var/datum/language/L = language_keys[language_prefix]
		if(can_speak(L))
			return L

	return null
