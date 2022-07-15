/mob/living/carbon/human/say(message, datum/language/language = null, whispering)
	var/alt_name = ""
	if(name != GetVoice())
		if(get_id_name("Unknown") != GetVoice())
			alt_name = "(as [get_id_name("Unknown")])"
		else
			SetName(get_id_name("Unknown"))

	//parse the language code and consume it
	if(!language)
		language = parse_language(message)
		if (language)
			message = copytext_char(message,2+length(language.key))
		else
			language = get_default_language()

	if(has_chem_effect(CE_VOICELOSS, 1))
		whispering = TRUE

	message = sanitize(message)
	var/obj/item/organ/internal/voicebox/vox = locate() in internal_organs
	var/snowflake_speak = (language?.flags & (NONVERBAL|SIGNLANG)) || (vox?.is_usable() && (language in vox.assists_languages))
	if(!full_prosthetic && need_breathe() && failed_last_breath && !snowflake_speak)
		var/obj/item/organ/internal/lungs/L = internal_organs_by_name[species.breathing_organ]
		if(QDELETED(L) || L.is_broken())
			visible_message(SPAN("warning", "[src] moves his lips as if trying to say something"), SPAN("danger", "You try to make sounds but you can't exhale."))
			return

		if(L.breath_fail_ratio > 0.9)
			if(world.time < L.last_successful_breath + 2 MINUTES) //if we're in grace suffocation period, give it up for last words
				to_chat(src, "<span class='warning'>You use your remaining air to say something!</span>")
				L.last_successful_breath = world.time - 2 MINUTES
				return ..(message, alt_name = alt_name, language = language)

			to_chat(src, "<span class='warning'>You don't have enough air in [L] to make a sound!</span>")
			return FALSE
		else if(L.breath_fail_ratio > 0.7)
			return whisper_say(length(message) > 5 ? stars(message) : message, language, alt_name)
		else if(L.breath_fail_ratio > 0.4)
			return whisper_say(length(message) > 10 ? stars(message) : message, language, alt_name)
	else
		return ..(message, alt_name = alt_name, language = language, whispering = whispering)


/mob/living/carbon/human/proc/forcesay(list/append)
	if(stat != CONSCIOUS || !client)
		return

	var/temp = client.close_saywindow(return_content = TRUE)

	if(!temp)
		temp = winget(client, "input", "text")
		if(length(temp) > 4 && findtextEx(temp, "Say ", 1, 5))
			temp = copytext(temp, 5)
			if (text2ascii(temp, 1) == text2ascii("\""))
				temp = copytext(temp, 2)
			var/custom_emote_key = get_prefix_key(/decl/prefix/custom_emote)
			if(findtext(temp, custom_emote_key, 1, 2))	//emotes
				return
		else
			return
		winset(client, "input", "text=\"Say \\\"\"")
	temp = trim_left(temp)

	if(length(temp))
		if(append)
			temp += pick(append)
			say(temp)

/mob/living/carbon/human/say_understands(mob/other,datum/language/language = null)

	if(has_brain_worms()) //Brain worms translate everything. Even mice and alien speak.
		return TRUE

	if(species.can_understand(other))
		return TRUE

	//These only pertain to common. Languages are handled by mob/say_understands()
	if(!language)
		if(istype(other, /mob/living/carbon/alien/diona))
			if(other.languages.len >= 2) //They've sucked down some blood and can speak common now.
				return TRUE
		if(istype(other, /mob/living/silicon))
			return TRUE
		if(istype(other, /mob/living/carbon/brain))
			return TRUE
		if(istype(other, /mob/living/carbon/metroid))
			return TRUE

	return ..()

/mob/living/carbon/human/GetVoice()

	var/voice_sub
	if(istype(back,/obj/item/rig))
		var/obj/item/rig/rig = back
		if(rig.speech?.voice_holder?.active && rig.speech.voice_holder.voice)
			voice_sub = rig.speech.voice_holder.voice
	if(!voice_sub)
		for(var/obj/item/gear in list(wear_mask,wear_suit,head))
			if(!gear)
				continue
			var/obj/item/voice_changer/changer = locate() in gear
			if(changer?.active)
				voice_sub = changer.voice
				break
	if(voice_sub)
		return voice_sub
	if(mind?.changeling?.mimicing)
		return mind.changeling.mimicing
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/proc/SetSpecialVoice(new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice


/mob/living/carbon/human/say_quote(message, datum/language/language = null)
	var/verb = "says"
	var/ending = copytext(message, length(message))

	if(language)
		verb = language.get_spoken_verb(ending)
	else
		if(ending == "!")
			verb=pick("exclaims","shouts","yells")
		else if(ending == "?")
			verb="asks"

	return verb

/mob/living/carbon/human/handle_speech_problems(list/message_data)
	if(silent || (sdisabilities & MUTE))
		message_data[1] = ""
		. = TRUE

	else if(istype(wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/M = wear_mask
		if(M.voicechange)
			message_data[1] = pick(M.say_messages)
			message_data[2] = pick(M.say_verbs)
			. = TRUE
		else
			. = ..(message_data)
	else
		. = ..(message_data)

/mob/living/carbon/human/handle_message_mode(message_mode, message, verb, language, used_radios, alt_name)
	switch(message_mode)
		if("intercom")
			if(!src.restrained())
				for(var/obj/item/device/radio/intercom/I in view(1))
					I.talk_into(src, message, null, verb, language)
					I.add_fingerprint(src)
					used_radios += I
		if("headset")
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = l_ear
				R.talk_into(src,message,null,verb,language)
				used_radios += l_ear
			else if(r_ear && istype(r_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = r_ear
				R.talk_into(src,message,null,verb,language)
				used_radios += r_ear
		if("right ear")
			var/obj/item/device/radio/R
			var/has_radio = FALSE
			if(r_ear && istype(r_ear,/obj/item/device/radio))
				R = r_ear
				has_radio = TRUE
			if(r_hand && istype(r_hand, /obj/item/device/radio))
				R = r_hand
				has_radio = TRUE
			if(has_radio)
				R.talk_into(src,message,null,verb,language)
				used_radios += R
		if("left ear")
			var/obj/item/device/radio/R
			var/has_radio = FALSE
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				R = l_ear
				has_radio = TRUE
			if(l_hand && istype(l_hand,/obj/item/device/radio))
				R = l_hand
				has_radio = TRUE
			if(has_radio)
				R.talk_into(src,message,null,verb,language)
				used_radios += R
		if("whisper")
			whisper_say(message, language, alt_name)
			return TRUE
		else
			if(message_mode)
				if(l_ear && istype(l_ear,/obj/item/device/radio))
					l_ear.talk_into(src,message, message_mode, verb, language)
					used_radios += l_ear
				else if(r_ear && istype(r_ear,/obj/item/device/radio))
					r_ear.talk_into(src,message, message_mode, verb, language)
					used_radios += r_ear
	return FALSE

/mob/living/carbon/human/handle_speech_sound()
	if(species.speech_sounds && prob(species.speech_chance))
		var/list/returns[2]
		returns[1] = sound(pick(species.speech_sounds))
		returns[2] = 50
		return returns
	return ..()

/mob/living/carbon/human/can_speak(datum/language/language)
	var/needs_assist = FALSE
	var/can_speak_assist = FALSE

	if(species && (language.name in species.assisted_langs))
		needs_assist = TRUE
		for(var/obj/item/organ/internal/I in src.internal_organs)
			if((language in I.assists_languages) && (I.is_usable()))
				can_speak_assist = TRUE

	if(needs_assist)
		return can_speak_assist

	return ..()
