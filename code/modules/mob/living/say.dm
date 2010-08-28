/mob/living/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_say("[src.name]/[src.key] : [message]")

	if (src.muted)
		return

	if (src.stat == 2)
		return src.say_dead(message)

	// wtf?
	if (src.stat)
		return

	// emotes
	if (copytext(message, 1, 2) == "*" && !src.stat)
		return src.emote(copytext(message, 2))

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && src.name != src.real_name)
		if (src:wear_id && src:wear_id:registered)
			alt_name = " (as [src:wear_id:registered])"
		else
			alt_name = " (as Unknown)"

	// Mute disability
	if (src.sdisabilities & 2)
		return

	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		return

	var/italics = 0
	var/message_range = null
	var/message_mode = null

	if (src.brainloss >= 60 && prob(50))
		if (ishuman(src))
			message_mode = "headset"
	// Special message handling
	else if (copytext(message, 1, 2) == ";")
		if (ishuman(src))
			message_mode = "headset"
		message = copytext(message, 2)

	else if (length(message) >= 2)
		if (copytext(message, 1, 3) == ":r")
			message_mode = "right hand"
			message = copytext(message, 3)

		else if (copytext(message, 1, 3) == ":l")
			message_mode = "left hand"
			message = copytext(message, 3)

		/*else if (copytext(message, 1, 3) == ":w")
			message_mode = "whisper"
			message = copytext(message, 3)*/

		else if (copytext(message, 1, 3) == ":i")
			message_mode = "intercom"
			message = copytext(message, 3)
		else if (copytext(message, 1 ,3) == ":h")
			message_mode = "security_headset"
			message = copytext(message, 3)
	//

	message = trim(message)

	if (!message)
		return

	if (src.stuttering)
		message = NewStutter(message,stunned)
	if (src.intoxicated)
		message = Intoxicated(message)

	// :downs:
	if (src.brainloss >= 60)
		message = dd_replacetext(message, " am ", " ")
		message = dd_replacetext(message, " is ", " ")
		message = dd_replacetext(message, " are ", " ")
		message = dd_replacetext(message, "you", "u")
		message = dd_replacetext(message, "help", "halp")
		message = dd_replacetext(message, "grief", "grife")
		if(prob(50))
			message = uppertext(message)
			message = "[message][stutter(pick("!", "!!", "!!!"))]"
		if(!src.stuttering && prob(15))
			message = NewStutter(message)

	switch (message_mode)
		if ("headset")
			if (src:ears)
				src:ears.talk_into(src, message)

			message_range = 1
			italics = 1

		if ("security_headset")
			if (src:ears)
				src:ears.security_talk_into(src, message)

			message_range = 1
			italics = 1

		if ("right hand")
			if (src.r_hand)
				src.r_hand.talk_into(src, message)

			message_range = 1
			italics = 1

		if ("left hand")
			if (src.l_hand)
				src.l_hand.talk_into(src, message)

			message_range = 1
			italics = 1

		//Might put this back if people are used to the old system.
		/*if ("whisper")
			message_range = 1
			italics = 1*/

		if ("intercom")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message)

			message_range = 1
			italics = 1

	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	var/list/listening = hearers(message_range, src)
	listening -= src
	listening += src

	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/mob/M in listening)
		if (M.say_understands(src))
			heard_a += M
		else
			heard_b += M

	var/rendered = null
	if (length(heard_a))
		var/message_a = src.say_quote(message)
		var/test = say_test(message)
		var/image/test2 = image('talk.dmi',src,"h[test]")
		if (italics)
			message_a = "<i>[message_a]</i>"

		if (!istype(src, /mob/living/carbon/human) || istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
			rendered = "<span class='game say'><span class='name'>[src.name]</span> <span class='message'>[message_a]</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[src.real_name]</span>[alt_name] <span class='message'>[message_a]</span></span>"

		for (var/mob/M in heard_a)
			M.show_message(rendered, 6)
			M << test2
		spawn(30) del(test2)
	var/renderedold = rendered

	if (length(heard_b))
		var/message_b

		if (src.voice_message)
			message_b = src.voice_message
		else
			message_b = stars(message)
			message_b = src.say_quote(message_b)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> <span class='message'>[message_b]</span></span>"

		for (var/mob/M in heard_b)
			M.show_message(rendered, 6)

	message = src.say_quote(message)
	if (italics)
		message = "<i>[message]</i>"

	if (!istype(src, /mob/living/carbon/human) || istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		rendered = "<span class='game say'><span class='name'>[src.name]</span> <span class='message'>[message]</span></span>"
	else
		rendered = "<span class='game say'><span class='name'>[src.real_name]</span>[alt_name] <span class='message'>[message]</span></span>"
	for (var/mob/M in world)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat > 1 && !(M in heard_a))
			M.show_message(rendered, 2)
	for(var/obj/item/weapon/recorder/R in oview(message_range,src))
		if(R.recording)
			over
			var/id = rand(1,9999)
			var/test = R.disk.mobtype["[id]"]
			if(test)
				id = rand(1,9999)
				if(id == test)
					goto over
			if(istype(src, /mob/living/carbon/human))
				R.disk.memory["[id]"] += renderedold
				R.disk.mobtype["[id]"] += "human"
	for(var/mob/M in viewers(message_range,src))
		var/obj/item/weapon/recorder/R = locate() in M.contents
		if(R)
			if(R.recording)
				over
				var/id = rand(1,9999)
				var/test = R.disk.mobtype["[id]"]
				if(test)
					id = rand(1,9999)
					if(id == test)
						goto over
				if(istype(src, /mob/living/carbon/human))
					R.disk.memory["[id]"] += renderedold
					R.disk.mobtype["[id]"] += "human"
				if(istype(src,/mob/living/carbon/monkey))
					R.disk.memory["[id]"] += renderedold
					R.disk.mobtype["[id]"] += "monkey"
				if(istype(src,/mob/living/silicon))
					R.disk.memory["[id]"] += renderedold
					R.disk.mobtype["[id]"] += "bot"
				if(istype(src,/mob/living/carbon/alien))
					R.disk.memory["[id]"] += renderedold
					R.disk.mobtype["[id]"] += "alien"
//headfindback
	src.log_m("Said [message]")