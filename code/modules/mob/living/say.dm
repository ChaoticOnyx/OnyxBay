var/list/department_radio_keys = list(
	  ":r" = "right ear",	":к" = "right ear",
	  ":l" = "left ear",	":д" = "left ear",
	  ":i" = "intercom",	":ш" = "intercom",
	  ":h" = "department",	":р" = "department",
	  ":+" = "special",		".+" = "special", // activate radio-specific special functions
	  ":c" = "Command",		":с" = "Command",
	  ":n" = "Science",		":т" = "Science",
	  ":m" = "Medical",		":ь" = "Medical",
	  ":e" = "Engineering", ":у" = "Engineering",
	  ":s" = "Security",	":ы" = "Security",
	  ":w" = "whisper",		":ц" = "whisper",
	  ":t" = "Syndicate",	":е" = "Syndicate",
	  ":x" = "Raider",		":ч" = "Raider",
	  ":u" = "Supply",		":г" = "Supply",
	  ":v" = "Service",		":м" = "Service",
	  ":p" = "AI Private",	":з" = "AI Private",
	  ":z" = "Entertainment",":я" = "Entertainment",
	  ":y" = "Exploration",		":н" = "Exploration",

	  ":R" = "right ear",	":К" = "right ear",
	  ":L" = "left ear",	":Д" = "left ear",
	  ":I" = "intercom",	":Ш" = "intercom",
	  ":H" = "department",	":Р" = "department",
	  ":C" = "Command",		":С" = "Command",
	  ":N" = "Science",		":Т" = "Science",
	  ":M" = "Medical",		":Ь" = "Medical",
	  ":E" = "Engineering",	":У" = "Engineering",
	  ":S" = "Security",	":Ы" = "Security",
	  ":W" = "whisper",		":Ц" = "whisper",
	  ":T" = "Syndicate",	":Е" = "Syndicate",
	  ":X" = "Raider",		":Ч" = "Raider",
	  ":U" = "Supply",		":Г" = "Supply",
	  ":V" = "Service",		":М" = "Service",
	  ":P" = "AI Private",	":З" = "AI Private",
	  ":Z" = "Entertainment",":Я" = "Entertainment",
	  ":Y" = "Exploration",		":Н" = "Exploration",
)


var/list/channel_to_radio_key = new

/proc/get_radio_key_from_channel(channel)
	var/key = channel_to_radio_key[channel]
	if(!key)
		for(var/radio_key in department_radio_keys)
			if(department_radio_keys[radio_key] == channel)
				key = radio_key
				break
		if(!key)
			key = ""
		channel_to_radio_key[channel] = key

	return key

/mob/living/proc/binarycheck()

	if(istype(src, /mob/living/silicon/pai))
		return FALSE

	if(!ishuman(src))
		return FALSE

	var/mob/living/carbon/human/H = src
	if(H.l_ear || H.r_ear)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.l_ear,/obj/item/device/radio/headset))
			dongle = H.l_ear
		else
			dongle = H.r_ear
		if(!istype(dongle))
			return FALSE
		if(dongle.translate_binary)
			return TRUE

	return FALSE

/mob/living/proc/get_default_language()
	return default_language

/mob/proc/is_muzzled()
	return (wear_mask && (istype(wear_mask, /obj/item/clothing/mask/muzzle) || istype(src.wear_mask, /obj/item/grenade)))

// Takes a list of the form list(message, verb, whispering) and modifies it as needed
// Returns TRUE if a speech problem was applied, FALSE otherwise
/mob/living/proc/handle_speech_problems(list/message_data)
	. = FALSE

	if((MUTATION_HULK in mutations) && health >= 25 && length(message_data["message"]))
		message_data["message"] = "[uppertext(message_data["message"])]!!!"
		message_data["verb"] = pick("yells","roars","hollers")
		. = TRUE
	if(lisping)
		message_data["message"] = lisp(message_data["message"])
		message_data["verb"] = pick("lisps","croups")
		. = TRUE
	if(burrieng)
		message_data["message"] = burr(message_data["message"])
		message_data["verb"] = pick("burrs","croups")
		. = TRUE
	if(slurring)
		message_data["message"] = slur(message_data["message"])
		message_data["verb"] = pick("slobbers","slurs")
		. = TRUE
	if(stammering)
		message_data["message"] = stammer(message_data["message"])
		message_data["verb"] = pick("stammers","stutters")
		. = TRUE
	if(stuttering)
		message_data["message"] = stutter(message_data["message"])
		message_data["verb"] = pick("stammers","stutters")
		. = TRUE

/mob/living/proc/handle_message_mode(message_mode, message, verb, language, used_radios, alt_name)
	if(message_mode == "intercom")
		for(var/obj/item/device/radio/intercom/I in view(1, null))
			I.talk_into(src, message, verb, language)
			used_radios += I
	return FALSE

/mob/living/proc/handle_speech_sound()
	var/list/returns[2]
	returns[1] = null
	returns[2] = 0
	return returns

/mob/living/proc/get_speech_ending(verb, ending)
	if(ending=="!")
		return pick("exclaims","shouts","yells")
	if(ending=="?")
		return "asks"
	return verb

/mob/living/say(message, datum/language/language = null, verb="says", alt_name="", whispering, log_message = TRUE)
	if(client?.prefs.muted & MUTE_IC)
		to_chat(src, SPAN("warning", "You cannot speak in IC (Muted)."))
		return FALSE

	message = html_decode(message)
	message = sanitize(message)

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
	  "stop_say" = FALSE,
	  "say_result" = FALSE
	)

	if(!say_check_stat(message_data))
		return message_data["say_result"]

	// if message is emote then return emote result
	if(!say_check_emote(message_data))
		return message_data["say_result"]

	// parse the radio code and consume it
	say_get_radio(message_data)

	// parse the language code and consume it
	say_get_language(message_data)

	say_get_alt_name(message_data)

	client?.spellcheck(message_data["message"])

	// This is broadcast to all mobs with the language,
	// irrespective of distance or anything else.
	if(message_data["language"]?.language_flags & HIVEMIND)
		message_data["language"].broadcast(src, message_data["message"])
		return TRUE

	if(message_data["language"])
		if(message_data["whispering"])
			message_data["verb"] = message_data["language"].whisper_verb ? message_data["language"].whisper_verb : message_data["language"].speech_verb
		else
			message_data["verb"] = say_quote(message, message_data["language"])

	message_data["message"] = handle_autohiss(message_data["message"], message_data["language"])

	if(!(message_data["language"]?.language_flags & NO_STUTTER))
		handle_speech_problems(message_data)

	if(!message_data["message"] || message_data["message"] == "")
		return FALSE

	//handle nonverbal and sign languages here
	say_handle_inaudible_language(message_data)
	if(message_data["stop_say"])
		return message_data["say_result"]


	var/list/handle_v = handle_speech_sound()
	message_data["sound"] = handle_v[1]
	message_data["sound_volume"] = handle_v[2]

	if(whispering)
		message_data["italics"] = TRUE
		message_data["message_range"] = 1
	else
		message_data["message_range"] = world.view

	say_handle_radio(message_data)
	if(message_data["stop_say"])
		return message_data["say_result"]

	message_data["listening"] = list()
	message_data["listening_obj"] = list()
	var/turf/T = get_turf(src)
	if(T)
		// make sure the air can transmit speech - speaker's side
		say_handle_enviroment(message_data, T)

	say_do_say(message_data)

	if(message_data["log_message"])
		say_log_message(message_data)

	return TRUE

/mob/living/proc/say_check_stat(list/message_data)
	if(stat)
		if(is_ooc_dead())
			message_data["say_result"] = say_dead(message_data["message"])
		message_data["say_result"] = FALSE
		return FALSE
	return TRUE

/mob/living/proc/say_check_emote(list/message_data)
	var/prefix = copytext_char(message_data["message"], 1, 2)
	if(prefix == get_prefix_key(/decl/prefix/custom_emote))
		message_data["say_result"] = emote(copytext_char(message_data["message"], 2), intentional = TRUE, target = null)
		return FALSE
	if(prefix == get_prefix_key(/decl/prefix/visible_emote))
		message_data["say_result"] = custom_emote(1, copytext_char(message_data["message"], 2))
		return FALSE
	return TRUE

/mob/living/proc/say_get_radio(list/message_data)
	message_data["message_mode"] = parse_message_mode(message_data["message"], "headset")
	if(message_data["message_mode"])
		if(message_data["message_mode"] == "headset")
			message_data["message"] = copytext_char(message_data["message"], 2)
		else
			message_data["message"] = copytext_char(message_data["message"], 3)
	message_data["message"] = trim_left(message_data["message"])

	return TRUE

/mob/living/proc/say_get_language(list/message_data)
	if(!message_data["language"])
		message_data["language"] = parse_language(message_data["message"])
		if(message_data["language"])
			message_data["message"] = copytext_char(message_data["message"], 2+length_char(message_data["language"].key))
			message_data["message"] = trim_left(message_data["message"])
		else
			message_data["language"] = get_default_language()
	return TRUE

/mob/living/proc/say_get_alt_name(list/message_data)
	return

/mob/living/proc/say_handle_inaudible_language(list/message_data)
	if(message_data["language"])
		var/verb = pick(message_data["language"].signlang_verb)

		if(message_data["language"].language_flags & NONVERBAL && prob(30))
			src.custom_emote(VISIBLE_MESSAGE, "[verb].")

		if(message_data["language"].language_flags & SIGNLANG)
			if(message_data["log_message"])
				log_say("[name]/[key]: SIGN: [message_data["message"]]")
				log_message(message_data["message"], INDIVIDUAL_SAY_LOG)
			message_data["say_result"] = say_signlang(message_data["message"], verb, message_data["language"])
			message_data["stop_say"] = TRUE
			return TRUE
	return FALSE

/mob/living/proc/say_handle_radio(list/message_data)
	var/list/obj/item/used_radios = new
	if(
	  handle_message_mode(message_data["message_mode"],
	                      message_data["message"],
	                      message_data["verb"],
	                      message_data["language"],
	                      used_radios,
	                      message_data["alt_name"]
	                     )
	)
		message_data["say_result"] = TRUE
		message_data["stop_say"] = TRUE
		return TRUE

	// language into radios
	if(used_radios.len)
		message_data["italics"] = TRUE
		message_data["message_range"] = 1
		if(message_data["language"])
			message_data["message_range"] = message_data["language"].get_talkinto_msg_range(message_data["message"])

		if(!(message_data["language"]?.language_flags & NO_TALK_MSG))
			var/msg = SPAN("notice", "\The [src] talks into \the [used_radios[1]]")
			for(var/mob/living/M in hearers(5, src))
				if(M != src)
					M.show_message(msg)
			if(message_data["sound"])
				message_data["sound_volume"] *= 0.5

/mob/living/proc/say_handle_enviroment(list/message_data, turf/T)
	var/datum/gas_mixture/environment = T.return_air()
	var/pressure = (environment) ? environment.return_pressure() : 0
	if(pressure < SOUND_MINIMUM_PRESSURE)
		message_data["message_range"] = 1

	if(pressure < ONE_ATMOSPHERE*0.4) // sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
		message_data["italics"] = TRUE
		message_data["sound_volume"] *= 0.5 // muffle the sound a bit, so it's like we're actually talking through contact

	get_mobs_and_objs_in_view_fast(T, message_data["message_range"], message_data["listening"], message_data["listening_obj"], /datum/client_preference/staff/ghost_ears)

/mob/living/proc/say_do_say(list/message_data)
	var/mob/above = shadow
	var/above_range = message_data["message_range"] //Gets lower every z-level
	while(!QDELETED(above))
		var/turf/ST = get_turf(above)
		above_range = max(--above_range, 0)
		if(ST)
			get_mobs_and_objs_in_view_fast(ST, above_range, message_data["listening"], message_data["listening_obj"]) //No need to check for ghosts, that will hear anyway
		if(!above_range)
			break
		above = above.shadow

	for(var/mob/M in message_data["listening"])
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

	for(var/obj/O in message_data["listening_obj"])
		spawn(0)
			if(O) // It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message_data["message"], message_data["verb"], message_data["language"])

	if(message_data["whispering"])
		var/eavesdroping_range = 5
		var/list/eavesdroping = list()
		var/list/eavesdroping_obj = list()
		get_mobs_and_objs_in_view_fast(get_turf(src), eavesdroping_range, eavesdroping, eavesdroping_obj)
		eavesdroping -= message_data["listening"]
		eavesdroping_obj -= message_data["listening_obj"]
		for(var/mob/M in eavesdroping)
			if(M)
				M.hear_say(
				  stars(message_data["message"]),
				  message_data["verb"],
				  message_data["language"],
				  message_data["alt_name"],
				  message_data["italics"],
				  src,
				  message_data["sound"],
				  message_data["sound_vol"]
		        )

		for(var/obj/O in eavesdroping_obj)
			spawn(0)
				if(O) // It's possible that it could be deleted in the meantime.
					O.hear_talk(src, stars(message_data["message"]), message_data["verb"], message_data["language"])

	// Showing speech bubble is a logical end of this function. - N
	var/list/speech_bubble_recipients
	for(var/mob/M in message_data["listening"])
		if(M.client)
			LAZYADD(speech_bubble_recipients, M.client)
	show_bubble_to_clients(bubble_icon, say_test(message_data["message"]), src, speech_bubble_recipients)

/mob/living/proc/say_log_message(list/message_data)
	if(message_data["whispering"])
		log_whisper("[key_name(src)]: [message_data["message"]]")
	else
		log_say("[key_name(src)]: [message_data["message"]]")
	log_message(message_data["message"], INDIVIDUAL_SAY_LOG)

/mob/living/proc/say_signlang(message, verb="gestures", datum/language/language)
	for (var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)
	return TRUE

/mob/living/proc/GetVoice()
	return name
