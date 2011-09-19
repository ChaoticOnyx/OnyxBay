//Lallander was here
/mob/living/carbon/human/whisper(message as text)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_whisper("[name]/[key] : [message]")

	if (muted)
		return

	if (stat == 2)
		return say_dead(message)

	if (stat)
		return

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && (name != real_name || face_dmg))
		if (src:wear_id && src:wear_id:registered)
			alt_name = " (as [src:wear_id:registered])"
		else
			alt_name = " (as Unknown)"

	// Mute disability
	if (sdisabilities & 2)
		return

	if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return

	var/italics = 1
	var/message_range = 1

	if (stuttering)
		world << "IMALIZARD"
		message = NewStutter(message,stunned)
	if (intoxicated)
		message = Intoxicated(message)



	if(mutantrace == "lizard")
		world << "IMALIZARD"
		if(copytext(message,1,2) == "*")
			return ..(message)
		var/list/wordlist = dd_text2list(message," ")
		var/i = 1
		world << "beforefor"
		for(,i <= (wordlist.len),i++)
			if(copytext(message,1,2) == "&")
				continue
			var/word = wordlist[i]
			var/randomS = rand(1,4)
			switch(randomS)
				if(1)
					word = dd_replaceText(word, "s", "ss")
				if(2)
					word = dd_replaceText(word, "s", stutter("s"))
				if(3)
					word = dd_replaceText(word, "s", stutter("ss"))
				if(4)
					word = word
			wordlist[i] = word
		message = sanitize(dd_list2text(wordlist," "))



	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	var/list/listening = hearers(message_range, src)
	listening -= src
	listening += src
	var/list/eavesdropping = hearers(2, src)
	eavesdropping -= src
	eavesdropping -= listening
	var/list/watching  = hearers(5, src)
	watching  -= src
	watching  -= listening
	watching  -= eavesdropping

	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/mob/M in listening)
		if (M.say_understands(src))
			heard_a += M
		else
			heard_b += M

	var/rendered = null

	for (var/mob/M in watching)
		if (M.say_understands(src))
			rendered = "<span class='game say'><span class='name'>[name]</span> whispers something.</span>"
		else
			rendered = "<span class='game say'><span class='name'>[voice_name]</span> whispers something.</span>"
		M.show_message(rendered, 2)

	if (length(heard_a))
		var/message_a = message

		if (italics)
			message_a = "<i>[message_a]</i>"

		if (!istype(src, /mob/living/carbon/human) || istype(wear_mask, /obj/item/clothing/mask/gas/voice))
			rendered = "<span class='game say'><span class='name'>[name]</span> whispers, <span class='message'>\"[message_a]\"</span></span>"
		else if(face_dmg)
			rendered = "<span class='game say'><span class='name'>Unknown</span>[alt_name] whispers, <span class='message'>\"[message_a]\"</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] whispers, <span class='message'>\"[message_a]\"</span></span>"

		for (var/mob/M in heard_a)
			M.show_message(rendered, 2)

	if (length(heard_b))
		var/message_b

		if (voice_message)
			message_b = voice_message
		else
			message_b = Ellipsis(message)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[voice_name]</span> whispers, <span class='message'>\"[message_b]\"</span></span>"

		for (var/mob/M in heard_b)
			M.show_message(rendered, 2)

	for (var/mob/M in eavesdropping)
		if (M.say_understands(src))
			var/message_c
			message_c = Ellipsis(message)
			if (!istype(src, /mob/living/carbon/human) || istype(wear_mask, /obj/item/clothing/mask/gas/voice))
				rendered = "<span class='game say'><span class='name'>[name]</span> whispers, <span class='message'>\"[message_c]\"</span></span>"
			else if(face_dmg)
				rendered = "<span class='game say'><span class='name'>Unknown</span>[alt_name] whispers, <span class='message'>\"[message_c]\"</span></span>"
			else
				rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] whispers, <span class='message'>\"[message_c]\"</span></span>"
			M.show_message(rendered, 2)
		else
			rendered = "<span class='game say'><span class='name'>[voice_name]</span> whispers something.</span>"
			M.show_message(rendered, 2)

	if (italics)
		message = "<i>[message]</i>"

	if (!istype(src, /mob/living/carbon/human) || istype(wear_mask, /obj/item/clothing/mask/gas/voice))
		rendered = "<span class='game say'><span class='name'>[name]</span> whispers, <span class='message'>\"[message]\"</span></span>"
	else if(face_dmg)
		rendered = "<span class='game say'><span class='name'>Unknown</span>[alt_name] whispers, <span class='message'>\"[message]\"</span></span>"
	else
		rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] whispers, <span class='message'>\"[message]\"</span></span>"

	for (var/client/C)
		if (istype(C.mob, /mob/new_player))
			continue
		if (C.mob && C.mob.stat > 1 && !(C.mob in heard_a))
			C.mob.show_message(rendered, 2)
