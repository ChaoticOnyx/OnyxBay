/mob/living/silicon/robot/drone/say(message)
	if(local_transmit)
		if (src.client)
			if(client.prefs.muted & MUTE_IC)
				to_chat(src, "You cannot send IC messages (muted).")
				return 0

		message = sanitize(message)

		if (is_ooc_dead())
			return say_dead(message)

		if(copytext(message,1,2) == "*")
			return emote(copytext(message, 2), intentional = TRUE)

		if(copytext(message,1,2) == ";")
			var/datum/language/L = all_languages[LANGUAGE_DRONE]
			if(istype(L))
				return L.broadcast(src,trim(copytext(message,2)))

		//Must be concious to speak
		if (stat)
			return 0

		var/list/listeners = hearers(5,src)
		listeners |= src

		for(var/mob/living/silicon/D in listeners)
			if(D.client && D.local_transmit)
				to_chat(D, "<b>[src]</b> transmits, \"[message]\"")

		for (var/mob/M in GLOB.player_list)
			if (istype(M, /mob/new_player))
				continue
			else if(M.is_ooc_dead() && M.get_preference_value(/datum/client_preference/staff/ghost_ears) == GLOB.PREF_ALL_SPEECH)
				if(M.client) to_chat(M, "<b>[src]</b> transmits, \"[message]\"")
		return 1
	return ..(message, 0)
