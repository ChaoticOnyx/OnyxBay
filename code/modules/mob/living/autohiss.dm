#define AUTOHISS_NUM 3


/mob/living/proc/handle_autohiss(message, datum/language/L)
	return message // no autohiss at this level

/mob/living/carbon/human/handle_autohiss(message, datum/language/L)
	if(!client) // no need to process if there's no client
		return message
	return species.handle_autohiss(message, L)

/datum/species
	var/list/hiss_letters = null
	var/list/autohiss_exempt = null

/datum/species/unathi
	hiss_letters = list("s", "с", "ш", "щ")
	autohiss_exempt = list(LANGUAGE_UNATHI)

/datum/species/tajaran
	hiss_letters = list("r", "р")
	autohiss_exempt = list(LANGUAGE_SIIK_MAAS)

/datum/species/proc/handle_autohiss(message, datum/language/lang)
	if(!hiss_letters)
		return message
	if(lang.flags & NO_STUTTER)	// Currently prevents EAL, Sign language, and emotes from autohissing
		return message
	if(autohiss_exempt && (lang.name in autohiss_exempt))
		return message

	. = ""
	for(var/i = 1, i <= length_char(message), i++)
		var/letter = copytext_char(message, i, i + 1)
		var/replacement = letter
		if(lowertext(letter) in hiss_letters)
			replacement = pick("[letter][letter]", "[letter]-[letter]", "[letter][letter][letter]")
			if(uppertext(letter) == letter)
				replacement = uppertext(replacement)
		. += replacement
