/proc/intonation(text)
	if (copytext(text,-1) == "!")
		text = "<b>[text]</b>"
	return text

GLOBAL_LIST_INIT(rkeys, list(
	"а" = "f", "в" = "d", "г" = "u", "д" = "l",
	"е" = "t", "з" = "p", "и" = "b", "й" = "q",
	"к" = "r", "л" = "k", "м" = "v", "н" = "y",
	"о" = "j", "п" = "g", "р" = "h", "с" = "c",
	"т" = "n", "у" = "e", "ф" = "a", "ц" = "w",
	"ч" = "x", "ш" = "i", "щ" = "o", "ы" = "s",
	"ь" = "m", "я" = "z"
))


// Transform keys from russian keyboard layout to eng analogues and lowertext it.
/proc/sanitize_cyrillic_char(t)
	t = lowertext(t)
	if(t in GLOB.rkeys)
		return GLOB.rkeys[t]
	return t

/proc/sanitize_cyrillic_string(text)
	. = ""
	for(var/i in 1 to length_char(text))
		. += sanitize_cyrillic_char(copytext_char(text, i, i+1))
	return .
