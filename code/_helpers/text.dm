/*
 * Holds procs designed to help with filtering text
 * Contains groups:
 *			SQL sanitization
 *			Text sanitization
 *			Text searches
 *			Text modification
 *			Misc
 */


/*
 * SQL sanitization
 */

// Run all strings to be used in an SQL query through this proc first to properly escape out injection attempts.
/proc/sanitizeSQL(t as text)
	var/sqltext = dbcon.Quote(t);
	return copytext_char(sqltext, 2, length_char(sqltext));//Quote() adds quotes around input, we already do that

/proc/decode_from_db(text)
	if(config.db_uses_cp1251_encoding)
		return cp1251toutf8(text)
	return text

/proc/encode_for_db(text)
	if(config.db_uses_cp1251_encoding)
		return utf8tocp1251(text)
	return text

/*
 * Text sanitization
 */

//Used for preprocessing entered text
//Added in an additional check to alert players if input is too long
/proc/sanitize(input, max_length = MAX_MESSAGE_LEN, encode = 1, trim = 1, extra = 1)
	if(!input)
		return

	if(max_length)
		var/input_length = length_char(input)
		if(input_length > max_length)
			to_chat(usr, SPAN_WARNING("Your message is too long by [input_length - max_length] character\s."))
			return
		input = copytext_char(input, 1, max_length+1)

	if(extra)
		input = replace_characters(input, list("\n"=" ","\t"=" "))

	if(encode)
		// The below \ escapes have a space inserted to attempt to enable Travis auto-checking of span class usage. Please do not remove the space.
		//In addition to processing html, html_encode removes byond formatting codes like "\ red", "\ i" and other.
		//It is important to avoid double-encode text, it can "break" quotes and some other characters.
		//Also, keep in mind that escaped characters don't work in the interface (window titles, lower left corner of the main window, etc.)
		input = html_encode(input)
	else
		//If not need encode text, simply remove < and >
		//note: we can also remove here byond formatting codes: 0xFF + next byte
		input = replace_characters(input, list("<"=" ", ">"=" "))

	if(trim)
		//Maybe, we need trim text twice? Here and before copytext?
		input = trim(input)

	return input

/proc/sanitizeFileName(input)
	input = replace_characters(input, list(" "="_", "\\" = "_", "\""="'", "/" = "_", ":" = "_", "*" = "_", "?" = "_", "|" = "_", "<" = "_", ">" = "_"))
	if(findtext(input,"_") == 1)
		input = copytext(input, 2)
	return input

//Run sanitize(), but remove <, >, " first to prevent displaying them as &gt; &lt; &34; in some places, after html_encode().
//Best used for sanitize object names, window titles.
//If you have a problem with sanitize() in chat, when quotes and >, < are displayed as html entites -
//this is a problem of double-encode(when & becomes &amp;), use sanitize() with encode=0, but not the sanitizeSafe()!
/proc/sanitizeSafe(input, max_length = MAX_MESSAGE_LEN, encode = 1, trim = 1, extra = 1)
	return sanitize(replace_characters(input, list(">"=" ","<"=" ", "\""="'")), max_length, encode, trim, extra)

#define NO_CHARS_DETECTED 0
#define SPACES_DETECTED 1
#define SYMBOLS_DETECTED 2
#define NUMBERS_DETECTED 3
#define LETTERS_DETECTED 4

/**
  * Filters out undesirable characters from names.
  *
  * * strict - return null immidiately instead of filtering out  TODO: port from tg
  * * allow_numbers - allows numbers and common special characters - used for silicon/other weird things names
  */

/proc/sanitizeName(input, max_length = MAX_NAME_LEN, allow_numbers = FALSE)
	if(!input)
		return //Rejects the input if it is null

	var/number_of_alphanumeric = 0
	var/last_char_group = NO_CHARS_DETECTED
	var/output = ""
	var/t_len = length_char(input)
	var/charcount = 0

	// This is a sanity short circuit, if the users name is three times the maximum allowable length of name
	// We bail out on trying to process the name at all, as it could be a bug or malicious input and we dont
	// Want to iterate all of it.
	if(t_len > 3 * MAX_NAME_LEN)
		return
	for(var/char in splittext_char(input, ""))
		var/char_code = text2ascii_char(char)
		switch(char_code)
			// A  .. Z
			if(65 to 90)   //Uppercase Letters
				number_of_alphanumeric++
				last_char_group = LETTERS_DETECTED

			// a  .. z
			if(97 to 122)   //Lowercase Letters
				number_of_alphanumeric++
				last_char_group = LETTERS_DETECTED

			// 0  .. 9
			if(48 to 57)   //Numbers
				if(!allow_numbers)
					continue
				number_of_alphanumeric++
				last_char_group = NUMBERS_DETECTED

			// '   -   .
			if(39, 45, 46)   //Common name punctuation
				last_char_group = SYMBOLS_DETECTED

			// ~    |    @   :   #   $   %   &   *   +
			if(126, 124, 64, 58, 35, 36, 37, 38, 42, 43)			//Other symbols that we'll allow (mainly for AI)
				if(!allow_numbers)
					continue
				last_char_group = SYMBOLS_DETECTED

			//Space
			if(32)
				if(last_char_group == NO_CHARS_DETECTED || last_char_group == SPACES_DETECTED) //suppress double-spaces and spaces at start of string
					continue
				last_char_group = SPACES_DETECTED

			if(127 to INFINITY) // cyrillic, chinese, and other unicode stuff
				return
			else
				continue
		output += char
		charcount++
		if(charcount >= max_length)
			break

	if(number_of_alphanumeric < 2)
		return //protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == SPACES_DETECTED)
		output = copytext_char(output, 1, -1) //removes the last character (in this case a space)

	for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai"))	//prevents these common metagamey names
		if(cmptext(output,bad_name))
			return	//(not case sensitive)

	return output

#undef NO_CHARS_DETECTED
#undef SPACES_DETECTED
#undef SYMBOLS_DETECTED
#undef NUMBERS_DETECTED
#undef LETTERS_DETECTED

//Returns null if there is any bad text in the string
/proc/reject_bad_text(text, max_length=512)
	if(length_char(text) > max_length)	return			//message too long
	var/non_whitespace = 0
	for(var/i=1, i<=length_char(text), i++)
		switch(text2ascii_char(text,i))
			if(62,60,92,47)	return			//rejects the text if it contains these bad characters: <, >, \ or /
			if(127 to 255)	return			//rejects weird letters like �
			if(0 to 31)		return			//more weird stuff
			if(32)			continue		//whitespace
			else			non_whitespace = 1
	if(non_whitespace)		return text		//only accepts the text if it has some non-spaces


//Old variant. Haven't dared to replace in some places.
/proc/sanitize_old(t,list/repl_chars = list("\n"="#","\t"="#"))
	return html_encode(replace_characters(t,repl_chars))

/*
 * Text searches
 */

//Checks the beginning of a string for a specified sub-string
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext_char(text, prefix, start, end)

//Checks the beginning of a string for a specified sub-string. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix_case(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtextEx_char(text, prefix, start, end)

//Checks the end of a string for a specified substring.
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext_char(text, suffix, start, null)
	return

//Checks the end of a string for a specified substring. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix_case(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtextEx_char(text, suffix, start, null)

/*
 * Text modification
 */

/proc/replace_characters(t,list/repl_chars)
	for(var/char in repl_chars)
		t = replacetext_char(t, char, repl_chars[char])
	return t

//Adds 'u' number of zeros ahead of the text 't'
/proc/add_zero(t, u)
	while (length(t) < u)
		t = "0[t]"
	return t

//Adds 'u' number of spaces ahead of the text 't'
/proc/add_lspace(t, u)
	while(length(t) < u)
		t = " [t]"
	return t

//Adds 'u' number of spaces behind the text 't'
/proc/add_tspace(t, u)
	while(length(t) < u)
		t = "[t] "
	return t

//Returns a string with reserved characters and spaces before the first letter removed
/proc/trim_left(text)
	for (var/i = 1 to length_char(text))
		if (text2ascii_char(text, i) > 32)
			return copytext_char(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for (var/i = length_char(text), i > 0, i--)
		if (text2ascii_char(text, i) > 32)
			return copytext_char(text, 1, i + 1)
	return ""

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text)
	return trim_left(trim_right(text))

//Returns a string with the first element of the string capitalized, ignoring html-tags
/proc/capitalize(t as text)
	var/i = 1
	while(copytext_char(t, i, i + 1) == "<")
		i = findtext_char(t, ">", i + 1)
		if(i)
			i++
		else
			i = 2
			break
	return copytext_char(t, 1, i) + uppertext(copytext_char(t, i, i + 1)) + copytext_char(t, i + 1)

//This proc strips html properly, remove < > and all text between
//for complete text sanitizing should be used sanitize()
/proc/strip_html_properly(input)
	if(!input)
		return
	var/opentag = 1 //These store the position of < and > respectively.
	var/closetag = 1
	while(1)
		opentag = findtext(input, "<")
		closetag = findtext(input, ">")
		if(closetag && opentag)
			if(closetag < opentag)
				input = copytext(input, (closetag + 1))
			else
				input = copytext(input, 1, opentag) + copytext(input, (closetag + 1))
		else if(closetag || opentag)
			if(opentag)
				input = copytext(input, 1, opentag)
			else
				input = copytext(input, (closetag + 1))
		else
			break

	return input

//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
/proc/stringmerge(text,compare,replace = "*")
	var/newtext = text
	if(length(text) != length(compare))
		return 0
	for(var/i = 1, i < length(text), i++)
		var/a = copytext(text,i,i+1)
		var/b = copytext(compare,i,i+1)
		//if it isn't both the same letter, or if they are both the replacement character
		//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext,1,i) + b + copytext(newtext, i+1)
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext,1,i) + a + copytext(newtext, i+1)
			else //The lists disagree, Uh-oh!
				return 0
	return newtext

//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
/proc/stringpercent(text,character = "*")
	if(!text || !character)
		return 0
	var/count = 0
	for(var/i = 1, i <= length(text), i++)
		var/a = copytext(text,i,i+1)
		if(a == character)
			count++
	return count

/proc/reverse_text(text = "")
	var/new_text = ""
	for(var/i = length(text); i > 0; i--)
		new_text += copytext(text, i, i+1)
	return new_text

//Used in preferences' SetFlavorText and human's set_flavor verb
//Previews a string of len or less length
proc/TextPreview(string, len=40)
	if(length(string) <= len)
		if(!length(string))
			return "\[...\]"
		else
			return string
	else
		return "[copytext_preserve_html(string, 1, 37)]..."

//alternative copytext() for encoded text, doesn't break html entities (&#34; and other)
/proc/copytext_preserve_html(text, first, last)
	return html_encode(copytext(html_decode(text), first, last))

//For generating neat chat tag-images
//The icon var could be local in the proc, but it's a waste of resources
//	to always create it and then throw it out.
/var/icon/text_tag_icons = new('./icons/chattags.dmi')
/proc/create_text_tag(tagname, tagdesc = tagname, client/C = null)
	if(!(C && C.get_preference_value(/datum/client_preference/chat_tags) == GLOB.PREF_SHOW))
		return tagdesc
	return icon2html(icon(text_tag_icons, tagname), world, realsize=TRUE, class="text_tag")

/proc/contains_az09(input)
	for(var/i=1, i<=length(input), i++)
		var/ascii_char = text2ascii(input,i)
		switch(ascii_char)
			// A  .. Z
			if(65 to 90)			//Uppercase Letters
				return 1
			// a  .. z
			if(97 to 122)			//Lowercase Letters
				return 1

			// 0  .. 9
			if(48 to 57)			//Numbers
				return 1
	return 0

/proc/generateRandomString(length)
	. = list()
	for(var/a in 1 to length)
		var/letter = rand(33,126)
		. += ascii2text(letter)
	. = jointext(.,null)

#define starts_with(string, substring) (copytext(string,1,1+length(substring)) == substring)

#define gender2text(gender) capitalize(gender)

/**
 * Strip out the special beyond characters for \proper and \improper
 * from text that will be sent to the browser.
 */
#define strip_improper(input_text) replacetext(replacetext(input_text, "\proper", ""), "\improper", "")

/proc/pencode2html(t)
	t = replacetext(t, "\n", "<BR>")
	t = replacetext(t, "\[center\]", "<center>")
	t = replacetext(t, "\[/center\]", "</center>")
	t = replacetext(t, "\[right\]", "<div style=\"text-align:right\">")
	t = replacetext(t, "\[/right\]", "</div>")
	t = replacetext(t, "\[left\]", "<div style=\"text-align:left\">")
	t = replacetext(t, "\[/left\]", "</div>")
	t = replacetext(t, "\[br\]", "<BR>")
	t = replacetext(t, "\[b\]", "<B>")
	t = replacetext(t, "\[/b\]", "</B>")
	t = replacetext(t, "\[i\]", "<I>")
	t = replacetext(t, "\[/i\]", "</I>")
	t = replacetext(t, "\[u\]", "<U>")
	t = replacetext(t, "\[/u\]", "</U>")
	t = replacetext(t, "\[time\]", "[stationtime2text()]")
	t = replacetext(t, "\[date\]", "[stationdate2text()]")
	t = replacetext(t, "\[large\]", "<font size=\"4\">")
	t = replacetext(t, "\[/large\]", "</font>")
	t = replacetext(t, "\[field\]", "<!--paper_field-->")
	t = replacetext(t, "\[h1\]", "<H1>")
	t = replacetext(t, "\[/h1\]", "</H1>")
	t = replacetext(t, "\[h2\]", "<H2>")
	t = replacetext(t, "\[/h2\]", "</H2>")
	t = replacetext(t, "\[h3\]", "<H3>")
	t = replacetext(t, "\[/h3\]", "</H3>")
	t = replacetext(t, "\[*\]", "<li>")
	t = replacetext(t, "\[hr\]", "<HR>")
	t = replacetext(t, "\[small\]", "<font size = \"1\">")
	t = replacetext(t, "\[/small\]", "</font>")
	t = replacetext(t, "\[medium\]", "<font size = \"2\">")
	t = replacetext(t, "\[/medium\]", "</font>")
	t = replacetext(t, "\[list\]", "<ul>")
	t = replacetext(t, "\[/list\]", "</ul>")
	t = replacetext(t, "\[item\]", "<li>")
	t = replacetext(t, "\[/item\]", "</li>")
	t = replacetext(t, "\[ord\]", "<ol>")
	t = replacetext(t, "\[/ord\]", "</ol>")
	t = replacetext(t, "\[table\]", "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>")
	t = replacetext(t, "\[/table\]", "</td></tr></table>")
	t = replacetext(t, "\[grid\]", "<table>")
	t = replacetext(t, "\[/grid\]", "</td></tr></table>")
	t = replacetext(t, "\[row\]", "</td><tr>")
	t = replacetext(t, "\[cell\]", "<td>")
	t = replacetext(t, "\[logo\]", "<img src = ntlogo.png>")
	t = replacetext(t, "\[bluelogo\]", "<img src = bluentlogo.png>")
	t = replacetext(t, "\[solcrest\]", "<img src = sollogo.png>")
	t = replacetext(t, "\[terraseal\]", "<img src = terralogo.png>")
	t = replacetext(t, "\[editorbr\]", "")
	return t

// Random password generator
/proc/GenerateKey()
	//Feel free to move to Helpers.
	var/newKey
	newKey += pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	newKey += pick("diamond", "beer", "mushroom", "assistant", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	newKey += pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	return newKey

//Used for applying byonds text macros to strings that are loaded at runtime
/proc/apply_text_macros(string)
	var/next_backslash = findtext(string, "\\")
	if(!next_backslash)
		return string

	var/leng = length(string)

	var/next_space = findtext_char(string, " ", next_backslash + 1)
	if(!next_space)
		next_space = leng - next_backslash

	if(!next_space)	//trailing bs
		return string

	var/base = next_backslash == 1 ? "" : copytext(string, 1, next_backslash)
	var/macro = lowertext(copytext(string, next_backslash + 1, next_space))
	var/rest = next_backslash > leng ? "" : copytext(string, next_space + 1)

	//See http://www.byond.com/docs/ref/info.html#/DM/text/macros
	switch(macro)
		//prefixes/agnostic
		if("the")
			rest = text("\the []", rest)
		if("a")
			rest = text("\a []", rest)
		if("an")
			rest = text("\an []", rest)
		if("proper")
			rest = text("\proper []", rest)
		if("improper")
			rest = text("\improper []", rest)
		if("roman")
			rest = text("\roman []", rest)
		//postfixes
		if("th")
			base = text("[]\th", rest)
		if("s")
			base = text("[]\s", rest)
		if("he")
			base = text("[]\he", rest)
		if("she")
			base = text("[]\she", rest)
		if("his")
			base = text("[]\his", rest)
		if("himself")
			base = text("[]\himself", rest)
		if("herself")
			base = text("[]\herself", rest)
		if("hers")
			base = text("[]\hers", rest)

	. = base
	if(rest)
		. += .(rest)

/proc/deep_string_equals(A, B)
	if (length(A) != length(B))
		return FALSE
	for (var/i = 1 to length(A))
		if (text2ascii(A, i) != text2ascii(B, i))
			return FALSE
	return TRUE

/proc/counttext(haystack, needle, start = 0)
	. = 0
	while ((start = findtext(haystack, needle, start + 1)))
		.++

