/mob/living/carbon/human/say(var/message)
	if(mutantrace == "lizard")
		message = dd_replaceText(message, "s", stutter("ss"))
	..(message)

/mob/living/carbon/human/say_understands(var/other)
	if (istype(other, /mob/living/carbon/human))
		if(zombie && other:zombie)
			return 1
		else if((!zombie) && (!other:zombie))
			return 1
		else
			return 0
	if (istype(other, /mob/living/silicon/ai))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	return ..()
/mob/living/carbon/human/say_unknown()
	if(zombie)
		return pick(list("Brains...","Brains","HURGH"))