/datum/signal
	/// Bruh
	var/obj/source
	/// Уээээээ
	var/list/data
	/// "Transmission method" of a signal, can be either `TRANSMISSION_RADIO` or `TRANSMISSION_SUBSPACE`.
	var/method
	/// Numeric value that allows to IDK i'll do it later.
	var/encryption
	/// Same, lol.
	var/frequency


/datum/signal/New(obj/source, list/data = list(), method = TRANSMISSION_RADIO, encryption, frequency)
	if(source)
		src.source = source
	if(data)
		src.data = data
	if(method)
		src.method = method
	if(encryption)
		src.encryption = encryption
	if(frequency)
		src.frequency = frequency

/datum/signal/proc/debug_print()
	if (source)
		. = "signal = {source = '[source]' ([source:x],[source:y],[source:z])\n"
	else
		. = "signal = {source = '[source]' ()\n"
	for (var/i in data)
		. += "data\[\"[i]\"\] = \"[data[i]]\"\n"
		if(islist(data[i]))
			var/list/L = data[i]
			for(var/t in L)
				. += "data\[\"[i]\"\] list has: [t]"
