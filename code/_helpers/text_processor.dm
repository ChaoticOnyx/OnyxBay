// This proc should not be redefined.
/datum/text_processor/proc/process(message)
	var/static/list/regexs = list(
		new /regex("([SYMBOL_CKEY_START])(.*?)[SYMBOL_CKEY_END]", "g"),
		new /regex("([SYMBOL_CHARACTER_NAME_START])(.*?)[SYMBOL_CHARACTER_NAME_END]", "g"),
		new /regex("([SYMBOL_COMPUTER_ID_START])(.*?)[SYMBOL_COMPUTER_ID_END]", "g"),
		new /regex("([SYMBOL_IP_START])(.*?)[SYMBOL_IP_END]", "g")
	)

	for(var/regex/R in regexs)
		var/start = 1
		while(R.Find(message, start))
			message = visit(message, R.group[1], R)
			start = R.next

	return message

// This proc may be redefined.
// The proc must always return original string if nothing can be done.
/datum/text_processor/proc/visit(message, symbol, regex/R)
	return message

// Text processor for replacing confidential information.
/datum/text_processor/confidential/visit(message, symbol, regex/R)
	switch(symbol)
		if(SYMBOL_CKEY_START)
			return R.Replace(message, MARK_CKEY(GLOB.moniker.get(R.group[2])), R.index, R.next)
		if(SYMBOL_COMPUTER_ID_START)
			return R.Replace(message, MARK_COMPUTER_ID("**********"), R.index, R.next)
		if(SYMBOL_IP_START)
			return R.Replace(message, MARK_IP("***.***.***.***"), R.index, R.next)

	return message
