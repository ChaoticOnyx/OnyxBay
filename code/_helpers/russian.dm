/proc/intonation(text)
	if (copytext(text,-1) == "!")
		text = "<b>[text]</b>"
	return text

// Highlights every entry of 'codeword + 3 russian letters' in text
/proc/highlight_rus_codewords(t as text, list/words, css_class = "notice")
	var/pattern = lowertext(jointext(words,  "|"))
	var/word_chars = @"\u0430-\u0451" // Russian chars only
	var/regex/highlight = new("(^|\[^[word_chars]])((?:[pattern])\[[word_chars]]{0,3})(?:(?!\[[word_chars]]))", "ig")
	return highlight.Replace(t, "$1[SPAN(css_class, "$2")]")