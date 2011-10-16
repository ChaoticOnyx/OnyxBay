/mob/living/silicon/say(var/message)
	if (!message || muted || stat == 1)
		return

	if (stat == 2)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		return say_dead(message)


	// emotes
	if (copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	if (length(message) >= 2)
		if (copytext(message, 1, 3) == ":s")
			message = copytext(message, 3)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			robot_talk(message)
		else if(copytext(message,1,2) == ";" && isrobot(src))
			message = copytext(message, 2)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			radio_talk(message)
			return ..(message)
		else if(copytext(message,1,3) == ":h" && isrobot(src))
			message = copytext(message, 3)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			secure_talk(message)
			return ..(message)
		else
			return ..(message)
	else
		return ..(message)

/mob/living/silicon/proc/radio_talk(var/message)
	if(src:radio)
		src:radio.talk_into(src,message)

/mob/living/silicon/proc/secure_talk(var/message)
	if(src:radio)
		src:radio.security_talk_into(src,message)

/mob/living/silicon/proc/robot_talk(var/message)

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/message_a = say_quote(message)
	var/rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"
	for (var/mob/living/silicon/S in world)
		if(!S.stat && S.client)
			S.show_message(rendered, 2)

	var/list/listening = hearers(1, src)
	listening -= src
	listening += src

	var/list/heard = list()
	for (var/mob/M in listening)
		if(!istype(M, /mob/living/silicon))
			heard += M


	if (length(heard))
		var/message_b

		message_b = "beep beep beep"
		message_b = say_quote(message_b)
		message_b = "<i>[message_b]</i>"

		rendered = "<i><span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span></i>"

		for (var/mob/M in heard)
			M.show_message(rendered, 2)

	message = say_quote(message)

	rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"

	for (var/client/C)
		if (istype(C.mob, /mob/new_player))
			continue
		if (C.mob.stat > 1)
			C.mob.show_message(rendered, 2)



/mob/living/silicon/emote(var/act)
	if(src.stat == 2 && act != "stopbreath")
		return

	var/param = null

	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/message = ""
	var/m_type = 0
	switch(act)
		if ("custom")
			m_type = 0
			if(copytext(param,1,2) == "v")
				m_type = 1
			else if(copytext(param,1,2) == "h")
				m_type = 2
			else
				var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
				if (input2 == "Visible")
					m_type = 1
				else if (input2 == "Hearable")
					m_type = 2
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
			if(m_type)
				param = trim(copytext(param,2))
			else
				param = trim(param)
			var/input
			if(param == "")
				input = input("Choose an emote to display.")
			else
				input = param
			if(input != "")
				message = "<B>[src]</B> [input]"

	if (message != "")
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src, null))
				O.show_message(message, m_type)