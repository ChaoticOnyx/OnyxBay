/mob/living/carbon/human/say(var/message)
	if(mutantrace == "lizard")
		var/list/wordlist = dd_text2list(message," ")
		var/i = 1
		world << "Before for"
		world << wordlist.len
		for(,i <= (wordlist.len),i++)
			world << "Forloop"
			var/word = wordlist[i]
			var/randomS = rand(1,4)
			world << "Word before text change: " + word
			switch(randomS)
				if(1)
					word = dd_replaceText(word, "s", "ss")
				if(2)
					word = dd_replaceText(word, "s", NewStutter("s"))
				if(3)
					word = dd_replaceText(word, "s", NewStutter("ss"))
				if(4)
					word = word
			wordlist[i] = word
			world << "Word after text change: " + word
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