/mob/living/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	// sdisabilities & 2 is the mute disability
	if (!message || muted || stat == 1 || istype(wear_mask, /obj/item/clothing/mask/muzzle) || sdisabilities & 2)
		return

	log_say("[name]/[key] : [message]")

	if (stat == 2)
		return say_dead(message)

	// emotes
	if (copytext(message, 1, 2) == "*" && !stat)
		return emote(copytext(message, 2))


	// In case an object applies custom effects to the spoken message.
	// This offers more flexibility (overwrite brainloss effects, headset stunned check etc.) here than if it were inserted further below.

	// However, if you need to copy-paste a lot of the code below, consider whether it would be better to insert another hook underneath.
	if(isobj(src.loc))
		if(src.loc:overrideMobSay(message, src) != "not used") // if the obj has a custom effect
			return

	//custom modes
	//if theres no space then theyre being a derpface
	var/custommode = ""
	var/firstspace = findtext(message, " ")
	if(copytext(message,1,6) == "&amp;" && firstspace > 7) //one character verbs?
		custommode = copytext(message,6,firstspace)
		message = copytext(message, firstspace+1)

	var/alt_name = "" // In case your face is burnt or you're wearing a mask
	if (istype(src, /mob/living/carbon/human) && name != real_name)
		if (src:wear_id && src:wear_id:registered)
			alt_name = " (as [src:wear_id:registered])"
		else
			alt_name = " (as Unknown)"

	var/italics = 0
	var/message_range = null
	var/message_mode = null

	if (brainloss >= 60 && prob(50))
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

		else if (copytext(message, 1, 3) == ":i")
			message_mode = "intercom"
			message = copytext(message, 3)
		else if (copytext(message, 1 ,3) == ":h")
			message_mode = "security_headset"
			message = copytext(message, 3)

	if(src.stunned > 0)
		message_mode = "" //Stunned people shouldn't be able to physically turn on their radio/hold down the button to speak into it

	message = trim(message)

	if (!message)
		return

	message = addtext(uppertext(copytext(message,1,2)), copytext(message, 2)) //capitalize the first letter of what they actually say

	if (stuttering)
		message = NewStutter(message,stunned)
	if (intoxicated)
		message = Intoxicated(message)

	// :downs:
	if (brainloss >= 60)
		message = dd_replacetext(message, " am ", " ")
		message = dd_replacetext(message, " is ", " ")
		message = dd_replacetext(message, " are ", " ")
		message = dd_replacetext(message, "you", "u")
		message = dd_replacetext(message, "help", "halp")
		message = dd_replacetext(message, "grief", "grife")
		if(prob(50))
			message = uppertext(message)
			message = "[message][stutter(pick("!", "!!", "!!!"))]"
		if(!stuttering && prob(15))
			message = NewStutter(message)

	if (!istype(src, /mob/living/silicon))
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
				if (r_hand)
					r_hand.talk_into(src, message)

				message_range = 1
				italics = 1

			if ("left hand")
				if (l_hand)
					l_hand.talk_into(src, message)

				message_range = 1
				italics = 1

			if ("intercom")
				for (var/obj/item/device/radio/intercom/I in view(1, null))
					I.talk_into(src, message)

				message_range = 1
				italics = 1

	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message,italics,alt_name)

	var/list/listening
	if(isturf(src.loc))
		listening = hearers(message_range, src)
	else
		var/atom/object = src.loc
		listening = hearers(message_range, object)
	listening -= src
	listening += src

	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/mob/M in listening)
		if (M.say_understands(src))
			heard_a += M
		else
			heard_b += M

	for(var/obj/O in view(3,src))
		O.catchMessage(message,src)

	var/rendered = null

	if (length(heard_a))
		var/message_a = say_quote(message, custommode)
		var/test = say_test(message)
		var/image/test2 = image('talk.dmi',src,"h[test]")
		if (italics)
			message_a = "<i>[message_a]</i>"

		if (!istype(src, /mob/living/carbon/human) || istype(wear_mask, /obj/item/clothing/mask/gas/voice))
			rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message_a]</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] <span class='message'>[message_a]</span></span>"

		for (var/mob/M in heard_a) // Sending over the message to mobs who can understand
			M.show_message(rendered, 6)
			M << test2
		spawn(30) del(test2)

	var/renderedold = rendered // Used for the voice recorders below

	if (length(heard_b))
		var/message_b

		if(say_unknown())
			message_b = say_unknown()

		else if (voice_message)
			message_b = voice_message
		else
			message_b = stars(message)
			message_b = say_quote(message_b, custommode)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span>"

		for (var/mob/M in heard_b) // Sending over the message to mobs who can't understand
			M.show_message(rendered, 6)

	message = say_quote(message, custommode)
	if (italics)
		message = "<i>[message]</i>"

	if (!istype(src, /mob/living/carbon/human) || istype(wear_mask, /obj/item/clothing/mask/gas/voice))
		rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message]</span></span>"
	else
		rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] <span class='message'>[message]</span></span>"
	for (var/client/C)
		if (C.mob)
			if (istype(C.mob, /mob/new_player))
				continue
			if (C.mob.stat > 1 && !(C.mob in heard_a))
				C.mob.show_message(rendered, 2)

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
		var/obj/item/weapon/implant/I = locate() in M.contents
		if(I)
			I.hear(message,src)
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
	log_m("Said [message]")