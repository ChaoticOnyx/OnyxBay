/mob/living/silicon/robot/say_understands(var/other)
	if (istype(other, /mob/living/silicon/ai))
		return 1
	if (istype(other, /mob/living/carbon/human))
		var/mob/living/carbon/human/D = other
		if(!D.zombie)
			return 1
	return ..()

/mob/living/silicon/robot/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[copytext(text, 1, length(text))]\"";

	return "states, \"[text]\"";
/mob/living/silicon/robot/say_test(var/text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "R1"
	else if (ending == "!")
		return "R2"
	return "R0"