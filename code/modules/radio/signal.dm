/datum/signal
	/// Object that emitted a signal.
	var/obj/source
	/// Associative list of key -> value, where key is generally a string, value is anything.
	var/list/data
	/// 'Transmission method' of a signal, can be either `TRANSMISSION_RADIO` or `TRANSMISSION_SUBSPACE`. Generally used be telecomms.
	var/method
	/// Numeric value that allows to filter out 'garbage' signal.
	var/encryption
	/// Numeric value that is used generally by telecomms to filter out signals.
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
