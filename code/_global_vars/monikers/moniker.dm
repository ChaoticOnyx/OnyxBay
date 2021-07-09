/datum/moniker
	var/list/names = list()
	var/list/descriptors = list()
	var/list/hash = list()

/datum/moniker/proc/get(key)
	var/result = hash[key]
	
	if(!result)
		var/new_moniker = "[pick(descriptors)]-[pick(names)][rand(0, length(key))]"
		hash[key] = result = new_moniker

	return result

GLOBAL_DATUM_INIT(moniker, /datum/moniker/animals, new())

/datum/moniker_handler
	var/static/list/regexs = list(
		new /regex("([SYMBOL_CKEY_START])(.*?)[SYMBOL_CKEY_END]", "g"),
		new /regex("([SYMBOL_CHARACTER_NAME_START])(.*?)[SYMBOL_CHARACTER_NAME_END]", "g"),
		new /regex("([SYMBOL_COMPUTER_ID_START])(.*?)[SYMBOL_COMPUTER_ID_END]", "g")
	)

// This proc should not be redefined.
/datum/moniker_handler/proc/process_message(message)
	for(var/regex/R in regexs)
		if(R.Find(message))
			message = visit(message, R.group[1], R)

	return message

// This proc may be redefined.
// The proc must always return original string if nothing can be done.
/datum/moniker_handler/proc/visit(message, symbol, regex/R)
	switch(symbol)
		if(SYMBOL_CKEY_START)
			return R.Replace(message, MARK_CKEY(GLOB.moniker.get(R.group[2])))
		if(SYMBOL_COMPUTER_ID_START)
			return R.Replace(message, MARK_COMPUTER_ID("**********"))
		if(SYMBOL_IP_START)
			return R.Replace(message, MARK_IP("***.***.***.***"))
	
	return message

GLOBAL_DATUM_INIT(moniker_handler, /datum/moniker_handler, new())
