/mob/living/carbon/human/say(message, datum/language/speaking = null, whispering)
	var/alt_name = ""
	if(name != GetVoice())
		if(get_id_name("Unknown") != GetVoice())
			alt_name = "(as [get_id_name("Unknown")])"
		else
			SetName(get_id_name("Unknown"))

	//parse the language code and consume it
	if(!speaking)
		speaking = parse_language(message)
		if (speaking)
			message = copytext_char(message,2+length(speaking.key))
		else
			speaking = get_default_language()

	if(has_chem_effect(CE_VOICELOSS, 1))
		whispering = TRUE

	message = sanitize(message)
	var/obj/item/organ/internal/voicebox/vox = locate() in internal_organs
	var/snowflake_speak = (speaking && (speaking.flags & NONVERBAL|SIGNLANG)) || (vox && vox.is_usable() && (speaking in vox.assists_languages))
	if(!full_prosthetic && need_breathe() && failed_last_breath && !snowflake_speak)
		var/obj/item/organ/internal/lungs/L = internal_organs_by_name[species.breathing_organ]
		if(L.breath_fail_ratio > 0.9)
			if(world.time < L.last_failed_breath + 2 MINUTES) //if we're in grace suffocation period, give it up for last words
				to_chat(src, "<span class='warning'>You use your remaining air to say something!</span>")
				L.last_failed_breath = world.time - 2 MINUTES
				return ..(message, alt_name = alt_name, speaking = speaking)

			to_chat(src, "<span class='warning'>You don't have enough air in [L] to make a sound!</span>")
			return
		else if(L.breath_fail_ratio > 0.7)
			whisper_say(length(message) > 5 ? stars(message) : message, speaking, alt_name)
		else if(L.breath_fail_ratio > 0.4 && length(message) > 10)
			whisper_say(message, speaking, alt_name)
	else
		return ..(message, alt_name = alt_name, speaking = speaking, whispering = whispering)


/mob/living/carbon/human/proc/forcesay(list/append)
	if(stat != CONSCIOUS || !client)
		return

	var/temp = client.close_saywindow(return_content = TRUE)

	if (!temp)
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

/mob/living/carbon/human/say_understands(mob/other,datum/language/speaking = null)

	if(has_brain_worms()) //Brain worms translate everything. Even mice and alien speak.
		return 1

	if(species.can_understand(other))
		return 1

	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if (istype(other, /mob/living/carbon/alien/diona))
			if(other.languages.len >= 2) //They've sucked down some blood and can speak common now.
				return 1
		if (istype(other, /mob/living/silicon))
			return 1
		if (istype(other, /mob/living/carbon/brain))
			return 1
		if (istype(other, /mob/living/carbon/metroid))
			return 1

	//This is already covered by mob/say_understands()
	//if (istype(other, /mob/living/simple_animal))
	//	if((other.universal_speak && !speaking) || src.universal_speak || src.universal_understand)
	//		return 1
	//	return 0

	return ..()

/mob/living/carbon/human/GetVoice()

	var/voice_sub
	if(istype(back,/obj/item/weapon/rig))
		var/obj/item/weapon/rig/rig = back
		// todo: fix this shit
		if(rig.speech && rig.speech.voice_holder && rig.speech.voice_holder.active && rig.speech.voice_holder.voice)
			voice_sub = rig.speech.voice_holder.voice
	else
		for(var/obj/item/gear in list(wear_mask,wear_suit,head))
			if(!gear)
				continue
			var/obj/item/voice_changer/changer = locate() in gear
			if(changer && changer.active && changer.voice)
				voice_sub = changer.voice
	if(voice_sub)
		return voice_sub
	if(mind && mind.changeling && mind.changeling.mimicing)
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


/mob/living/carbon/human/say_quote(message, datum/language/speaking = null)
	var/verb = "says"
	var/ending = copytext(message, length(message))

	if(speaking)
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending == "!")
			verb=pick("exclaims","shouts","yells")
		else if(ending == "?")
			verb="asks"

	return verb

/mob/living/carbon/human/handle_speech_problems(list/message_data)
	if(silent || (sdisabilities & MUTE))
		message_data[1] = ""
		. = 1

	else if(istype(wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/M = wear_mask
		if(M.voicechange)
			message_data[1] = pick(M.say_messages)
			message_data[2] = pick(M.say_verbs)
			. = 1
		else
			. = ..(message_data)
	else
		. = ..(message_data)

/mob/living/carbon/human/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	switch(message_mode)
		if("intercom")
			if(!src.restrained())
				for(var/obj/item/device/radio/intercom/I in view(1))
					I.talk_into(src, message, null, verb, speaking)
					I.add_fingerprint(src)
					used_radios += I
		if("headset")
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = l_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += l_ear
			else if(r_ear && istype(r_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = r_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += r_ear
		if("right ear")
			var/obj/item/device/radio/R
			var/has_radio = 0
			if(r_ear && istype(r_ear,/obj/item/device/radio))
				R = r_ear
				has_radio = 1
			if(r_hand && istype(r_hand, /obj/item/device/radio))
				R = r_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R
		if("left ear")
			var/obj/item/device/radio/R
			var/has_radio = 0
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				R = l_ear
				has_radio = 1
			if(l_hand && istype(l_hand,/obj/item/device/radio))
				R = l_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R
		if("whisper")
			whisper_say(message, speaking, alt_name)
			return 1
		else
			if(message_mode)
				if(l_ear && istype(l_ear,/obj/item/device/radio))
					l_ear.talk_into(src,message, message_mode, verb, speaking)
					used_radios += l_ear
				else if(r_ear && istype(r_ear,/obj/item/device/radio))
					r_ear.talk_into(src,message, message_mode, verb, speaking)
					used_radios += r_ear

/mob/living/carbon/human/handle_speech_sound()
	if(species.speech_sounds && prob(species.speech_chance))
		var/list/returns[2]
		returns[1] = sound(pick(species.speech_sounds))
		returns[2] = 50
		return returns
	return ..()

/mob/living/carbon/human/can_speak(datum/language/speaking)
	var/needs_assist = 0
	var/can_speak_assist = 0

	if(species && (speaking.name in species.assisted_langs))
		needs_assist = 1
		for(var/obj/item/organ/internal/I in src.internal_organs)
			if((speaking in I.assists_languages) && (I.is_usable()))
				can_speak_assist = 1

	if(needs_assist && !can_speak_assist)
		return 0
	else if(needs_assist && can_speak_assist)
		return 1

	return ..()
