/mob/living/carbon/human/say(var/message)
	if(mutantrace == "lizard")
		if(copytext(message,1,2) == "*")
			return ..(message)
		message = html_decode(message)
		var/list/wordlist = dd_text2list(message," ")
		var/i = 1
		for(,i <= (wordlist.len),i++)
			if(copytext(message,1,2) == "&")
				continue
			var/word = wordlist[i]
			var/randomS = rand(1,3)
			switch(randomS)
				if(1)
					word = dd_replaceText(word, "s", "ss")
				if(2)
					word = dd_replaceText(word, "s", stutter("s"))
				if(3)
					word = dd_replaceText(word, "s", stutter("ss"))
			wordlist[i] = word
		message = sanitize(dd_list2text(wordlist," "))
	..(message)

/mob/living/carbon/human/say_understands(var/other)
	if (istype(other, /mob/living/carbon/human))
		return 1

	if (istype(other, /mob/living/silicon/ai))
		if(src.zombie)
			return 0
		return 1

	if (istype(other, /mob/living/silicon/robot))
		if(src.zombie)
			return 0
		return 1

	return ..()

/mob/living/carbon/human/say_unknown()
	if(zombie)
		return pick(list("Brains...","Brains","HURGH"))