var/church_name = null
/proc/church_name()
	if (church_name)
		return church_name

	var/name = ""

	name += pick("Holy", "United", "First", "Second", "Last")

	if (prob(20))
		name += " Space"

	name += " " + pick("Church", "Cathedral", "Body", "Worshippers", "Movement", "Witnesses")
	name += " of [religion_name()]"

	return name

var/command_name = null
/proc/command_name()
	if (command_name)
		return command_name

	var/name = "[GLOB.using_map.boss_name]"

	command_name = name
	return name

/proc/change_command_name(name)

	command_name = name

	return name

var/religion_name = null
/proc/religion_name()
	if (religion_name)
		return religion_name

	var/name = ""

	name += pick("bee", "science", "edu", "captain", "assistant", "monkey", "alien", "space", "unit", "sprocket", "gadget", "bomb", "revolution", "beyond", "station", "goon", "robot", "ivor", "hobnob")
	name += pick("ism", "ia", "ology", "istism", "ites", "ick", "ian", "ity")

	return capitalize(name)

/proc/system_name()
	return GLOB.using_map.system_name ? GLOB.using_map.system_name : generate_system_name()

/proc/generate_system_name()
	return "[pick("Gilese","GSC", "Luyten", "GJ", "HD", "SCGECO")][prob(10) ? " Eridani" : ""] [rand(100,999)]"

/proc/generate_planet_name()
	return "[capitalize(pick(GLOB.last_names))]-[pick(GLOB.greek_letters)]"

/proc/generate_planet_type()
	return pick("terrestial planet", "ice planet", "dwarf planet", "desert planet", "ocean planet", "lava planet", "gas giant", "forest planet")

/proc/station_name()
	if(!GLOB.using_map)
		return server_name
	if (GLOB.using_map.station_name)
		return GLOB.using_map.station_name

	var/random = rand(1,5)
	var/name = ""

	//Rare: Pre-Prefix
	if (prob(10))
		name = pick(GLOB.station_prefixes)
		GLOB.using_map.station_name = name + " "

	// Prefix
	switch(Holiday)
		//get normal name
		if(null,"",0)
			name = pick(GLOB.station_names)
			if(name)
				GLOB.using_map.station_name += name + " "

		//For special days like christmas, easter, new-years etc ~Carn
		if("Friday the 13th")
			name = pick("Mike","Friday","Evil","Myers","Murder","Deathly","Stabby")
			GLOB.using_map.station_name += name + " "
			random = 13
		else
			//get the first word of the Holiday and use that
			var/i = findtext(Holiday," ",1,0)
			name = copytext(Holiday,1,i)
			GLOB.using_map.station_name += name + " "

	// Suffix
	name = pick(GLOB.station_suffixes)
	GLOB.using_map.station_name += name + " "

	// ID Number
	switch(random)
		if(1)
			GLOB.using_map.station_name += "[rand(1, 99)]"
		if(2)
			GLOB.using_map.station_name += pick(GLOB.greek_letters)
		if(3)
			GLOB.using_map.station_name += "\Roman[rand(1,99)]"
		if(4)
			GLOB.using_map.station_name += pick(GLOB.phonetic_alphabet)
		if(5)
			GLOB.using_map.station_name += pick(GLOB.numbers_as_words)
		if(13)
			GLOB.using_map.station_name += pick("13","XIII","Thirteen")


	if (config && config.game.use_age_restriction_for_jobs)
		world.name = "[config.game.use_age_restriction_for_jobs]: [name]"
	else
		world.name = GLOB.using_map.station_name

	return GLOB.using_map.station_name

/proc/world_name(name)
	GLOB.using_map.station_name = name

	if (config && config.game.use_age_restriction_for_jobs)
		world.name = "[config.game.use_age_restriction_for_jobs]: [name]"
	else
		world.name = name

	return name

var/syndicate_name = null
/proc/syndicate_name()
	if (syndicate_name)
		return syndicate_name

	var/name = ""

	// Prefix
	name += pick("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib")

	// Suffix
	if (prob(80))
		name += " "

		// Full
		if (prob(60))
			name += pick("Syndicate", "Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Family", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
		// Broken
		else
			name += pick("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
			name += pick("", "-")
			name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Code")
	// Small
	else
		name += pick("-", "*", "")
		name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive")

	syndicate_name = name
	return name


//Traitors and traitor silicons will get these. Revs will not.
GLOBAL_LIST_EMPTY(syndicate_code_phrase) //Code phrase for traitors.
GLOBAL_LIST_EMPTY(syndicate_code_response) //Code response for traitors.
GLOBAL_DATUM(code_phrase_highlight_rule, /regex)
GLOBAL_DATUM(code_response_highlight_rule, /regex)

	/*
	Should be expanded.
	How this works:
	Instead of "I'm looking for James Smith," the traitor would say "James Smith" as part of a conversation.
	Another traitor may then respond with: "They enjoy running through the void-filled vacuum of the derelict."
	The phrase should then have the words: James Smith.
	The response should then have the words: run, void, and derelict.
	This way assures that the code is suited to the conversation and is unpredicatable.
	Obviously, some people will be better at this than others but in theory, everyone should be able to do it and it only enhances roleplay.
	Can probably be done through "{ }" but I don't really see the practical benefit.
	One example of an earlier system is commented below.
	-N
	*/

/proc/generate_code_phrase()//Proc is used for phrase and response in subsystem init.
	var/words_count = pick(//How many words there will be. Minimum of two. 2, 4 and 5 have a lesser chance of being selected. 3 is the most likely.
		50; 2,
		200; 3,
		50; 4,
		25; 5
	)
	var/code_phrase[words_count]
	for(var/i = 1, i <= code_phrase.len, i++)
		var/word = pick(
			80; pick(GLOB.rus_occupations),
			70; pick(GLOB.rus_bays),
			65; pick(GLOB.rus_local_terms),
			65; pick(GLOB.rus_adjectives),
			55; pick(GLOB.rus_nouns),
			40; pick(GLOB.rus_verbs)
		)
		if(!word || code_phrase.Find(word,1,i)) // Reroll duplicates and errors
			i--
			continue
		var separator_position = findtext(word, "|")
		code_phrase[i] = copytext(word, 1, separator_position) // Word's root
		code_phrase[code_phrase[i]] = separator_position == length(word) ? "" : copytext(word, separator_position + 1) // Associated ending

	return code_phrase

/proc/generate_code_regex(list/words, ending_chars)
	return regex("(^|\[^[ending_chars]])((?:[jointext(words,  "|")])\[[ending_chars]]{0,3})(?:(?!\[[ending_chars]]))", "ig")

/proc/highlight_codewords(t, regex/rule, css_class = "notice")
	if (!rule)
		return t
	return rule.Replace(t, "$1[SPAN(css_class, "$2")]")

/proc/get_name(atom/A)
	return A.name

/proc/codewords2string(list/codewords)
	ASSERT(islist(codewords))
	for(var/i = 1, i <= codewords.len, i++)
		. += SPAN("danger", "[codewords[i]]")
		if (codewords[codewords[i]])
			. += "(-[codewords[codewords[i]]])"
		. += i != codewords.len ? ", " : "."
	return

/proc/get_name_and_coordinates(atom/A)
	return "[A.name] \[[A.x],[A.y],[A.z]\]"
