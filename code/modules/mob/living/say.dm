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
	var/message = html_decode(message_data[1])
	var/verb = message_data[2]

	. = FALSE

	if((MUTATION_HULK in mutations) && health >= 25 && length(message))
		message = "[uppertext(message)]!!!"
		verb = pick("yells","roars","hollers")
		message_data[3] = 0
		. = TRUE
	if(lisping)
		message = lisp(message)
		verb = pick("lisps","croups")
		. = TRUE
	if(burrieng)
		message = burr(message)
		verb = pick("burrs","croups")
		. = TRUE
	if(slurring)
		message = slur(message)
		verb = pick("slobbers","slurs")
		. = TRUE
	if(stammering)
		message = stammer(message)
		verb = pick("stammers","stutters")
		. = TRUE
	if(stuttering)
		message = stutter(message)
		verb = pick("stammers","stutters")
		. = TRUE

	message_data[1] = message
	message_data[2] = verb

/mob/living/proc/handle_message_mode(message_mode, message, verb, language, used_radios, alt_name)
	if(message_mode == "intercom")
		for(var/obj/item/device/radio/intercom/I in view(1, null))
			I.talk_into(src, message, verb, language)
			used_radios += I
	return FALSE

/mob/living/proc/handle_speech_sound()
	var/list/returns[2]
	returns[1] = null
	returns[2] = null
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

	if(stat)
		if(stat == DEAD)
			return say_dead(message)
		return FALSE

	var/prefix = copytext_char(message,1,2)
	if(prefix == get_prefix_key(/decl/prefix/custom_emote))
		return emote(copytext_char(message,2))
	if(prefix == get_prefix_key(/decl/prefix/visible_emote))
		return custom_emote(1, copytext_char(message,2))

	// parse the radio code and consume it
	var/message_mode = parse_message_mode(message, "headset")
	if(message_mode)
		if(message_mode == "headset")
			message = copytext_char(message,2)	// it would be really nice if the parse procs could do this for us.
		else
			message = copytext_char(message,3)

	message = trim_left(message)

	// parse the language code and consume it
	if(!language)
		language = parse_language(message)
		if(language)
			message = copytext_char(message,2+length_char(language.key))
		else
			language = get_default_language()

	// This is broadcast to all mobs with the language,
	// irrespective of distance or anything else.
	if(language?.flags & HIVEMIND)
		language.broadcast(src,trim(message))
		return TRUE

	if(is_muzzled() && !(language?.flags & (NONVERBAL|SIGNLANG)))
		to_chat(src, SPAN("danger", "You're muzzled and cannot speak!"))
		return FALSE

	if(language)
		if(whispering)
			verb = language.whisper_verb ? language.whisper_verb : language.speech_verb
		else
			verb = say_quote(message, language)
	client?.spellcheck(message)

	message = trim_left(message)

	message = handle_autohiss(message, language)

	if(!(language?.flags & NO_STUTTER))
		var/list/message_data = list(message, verb, 0)
		if(handle_speech_problems(message_data))
			message = message_data[1]
			verb = message_data[2]

	if(!message || message == "")
		return FALSE

	var/list/obj/item/used_radios = new
	if(handle_message_mode(message_mode, message, verb, language, used_radios, alt_name))
		return TRUE

	var/list/handle_v = handle_speech_sound()
	var/sound/speech_sound = handle_v[1]
	var/sound_vol = handle_v[2]

	var/italics = FALSE
	var/message_range = world.view

	if(whispering)
		italics = TRUE
		message_range = 1

	// language into radios
	if(used_radios.len)
		italics = TRUE
		message_range = 1
		if(language)
			message_range = language.get_talkinto_msg_range(message)

		if(!(language?.flags & NO_TALK_MSG))
			var/msg = SPAN("notice", "\The [src] talks into \the [used_radios[1]]")
			for(var/mob/living/M in hearers(5, src))
				if(M != src)
					M.show_message(msg)
			if(speech_sound)
				sound_vol *= 0.5

	// handle nonverbal and sign languages here
	if(language)
		if(language.flags & NONVERBAL)
			if(prob(30))
				src.custom_emote(1, "[pick(language.signlang_verb)].")

		if(language.flags & SIGNLANG)
			if(log_message)
				log_say("[name]/[key]: SIGN: [message]")
				log_message(message, INDIVIDUAL_SAY_LOG)
			return say_signlang(message, pick(language.signlang_verb), language)

	var/list/listening = list()
	var/list/listening_obj = list()
	var/turf/T = get_turf(src)

	if(T)
		// make sure the air can transmit speech - speaker's side
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = (environment) ? environment.return_pressure() : 0
		if(pressure < SOUND_MINIMUM_PRESSURE)
			message_range = 1

		if(pressure < ONE_ATMOSPHERE*0.4) // sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
			italics = TRUE
			sound_vol *= 0.5 // muffle the sound a bit, so it's like we're actually talking through contact

		get_mobs_and_objs_in_view_fast(T, message_range, listening, listening_obj, /datum/client_preference/ghost_ears)


	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('icons/mob/talk.dmi',src,"h[speech_bubble_test]")
	speech_bubble.alpha = 0
	speech_bubble.plane = MOUSE_INVISIBLE_PLANE
	speech_bubble.layer = FLOAT_LAYER

	// VOREStation Port - Attempt Multi-Z Talking
	var/mob/above = src.shadow
	while(!QDELETED(above))
		var/turf/ST = get_turf(above)
		if(ST)

			get_mobs_and_objs_in_view_fast(ST, world.view, listening, listening_obj, /datum/client_preference/ghost_ears)
			var/image/z_speech_bubble = image('icons/mob/talk.dmi', above, "h[speech_bubble_test]")
			spawn(30) qdel(z_speech_bubble)
		above = above.shadow

	// VOREStation Port End

	var/list/speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M)
			M.hear_say(message, verb, language, alt_name, italics, src, speech_sound, sound_vol)
			if(M.client)
				speech_bubble_recipients += M.client

	INVOKE_ASYNC(GLOBAL_PROC, /.proc/animate_speech_bubble, speech_bubble, speech_bubble_recipients, 3 SECONDS)

	for(var/obj/O in listening_obj)
		spawn(0)
			if(O) // It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message, verb, language)

	if(whispering)
		var/eavesdroping_range = 5
		var/list/eavesdroping = list()
		var/list/eavesdroping_obj = list()
		get_mobs_and_objs_in_view_fast(T, eavesdroping_range, eavesdroping, eavesdroping_obj)
		eavesdroping -= listening
		eavesdroping_obj -= listening_obj
		for(var/mob/M in eavesdroping)
			if(M)
				image_to(M, speech_bubble)
				M.hear_say(stars(message), verb, language, alt_name, italics, src, speech_sound, sound_vol)

		for(var/obj/O in eavesdroping_obj)
			spawn(0)
				if(O) // It's possible that it could be deleted in the meantime.
					O.hear_talk(src, stars(message), verb, language)


	if(log_message)
		if(whispering)
			log_whisper("[key_name(src)]: [message]")
			log_message(message, INDIVIDUAL_SAY_LOG)
		else
			log_say("[key_name(src)]: [message]")
			log_message(message, INDIVIDUAL_SAY_LOG)
	return TRUE

/mob/living/proc/say_signlang(message, verb="gestures", datum/language/language)
	for (var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)
	return TRUE

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name
