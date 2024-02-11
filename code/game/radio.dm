/**
 * Used by SSRadio to trigger specific behaviour when device receives a
 * signal over a frequency.
 *
 * Vars:
 * * signal - signal datum that have been broadcasted on a frequency.
 * * frequency - frequency that have been used to broadcast a signal.
 */
/obj/proc/receive_signal(datum/signal/signal, frequency)
	set waitfor = FALSE
	return


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

/datum/signal/New(list/data = list(), method = TRANSMISSION_RADIO, encryption, source, frequency)
	if(data)
		src.data = data
	if(method)
		src.method = method
	if(encryption)
		src.encryption = encryption

	// Variables below are usually set internally by `/datum/frequency/proc/post_signal`,
	// but telecomms code is a special snowflake.
	if(source)
		src.source = source
	if(frequency)
		src.frequency = frequency


/datum/frequency
	/// Numeric frequency identifier, ranges between `RADIO_LOW_FREQ` and `RADIO_HIGH_FREQ`.
	var/frequency
	/// Associative list of key -> value, where key is a filter, value is a list of `obj`.
	var/list/filters = list()

/datum/frequency/New(new_frequency)
	frequency = new_frequency

/**
 * Adds an object to the specified filter's list.
 *
 * Vars:
 * * device - object that will be added to a specified associated list.
 * * filter - numeric value that will be used as key, if `null` is passed `RADIO_DEFAULT` will be used instead.
 *
 * If filter is not specified uses `RADIO_DEFAULT`.
 *
 * Adds device to an associated filter list.
 *
 */
/datum/frequency/proc/add_listener(obj/device, filter)
	if(!filter)
		filter = RADIO_DEFAULT

	var/weakref/listener_ref = weakref(device)
	if(isnull(listener_ref))
		CRASH("null, non-datum or qdeleted device")

	LAZYADDASSOC(filters, filter, listener_ref)

/**
 * Removes an object from all of the filters.
 *
 * Vars:
 * * device - object that will be removed from all the filter lists.
 *
 * Removes device from all filter lists.
 *
 */
/datum/frequency/proc/remove_listener(obj/device)
	for(var/filter in filters)
		var/list/filtered_list = filters[filter]
		if(!length(filtered_list))
			filters -= filter

		LAZYREMOVEASSOC(filters, filter, weakref(device))

/**
 * Posts a signal on a frequency.
 *
 * Vars:
 * * source - atom that emited a signal, used with a `range` variable.
 * * signal - signal datum containig all the extra information.
 * * filter - filter string, if `null` is passed all the filters will be triggered.
 * * range - numeric value, that is used to braodcast signal to objects in range.
 *
 * Checks whether range is specified.
 *
 * Tries to get source's turf, qdels src if none is present.
 *
 * Sends a signal to the specified filter and `RADIO_DEFAULT`. Returns.
 *
 * Sends a signal to all filters.
 *
 */
/datum/frequency/proc/post_signal(obj/source, datum/signal/signal, filter, range)
	signal.source = source
	signal.frequency = frequency

	var/list/filter_list

	if(filter)
		filter_list = list(filter, RADIO_DEFAULT)
	else
		filter_list = filters

	var/turf/start_point
	if(range)
		start_point = get_turf(source)
		if(!start_point)
			return

	for(var/current_filter in filter_list)
		for(var/weakref/listener_ref as anything in filters[current_filter])
			var/obj/listener = listener_ref.resolve()
			if(isnull(listener))
				LAZYREMOVEASSOC(filters, current_filter, listener_ref)
				continue

			if(listener == source)
				continue

			if(range)
				var/turf/end_point = get_turf(listener)
				if(!end_point)
					continue

				if(start_point.z != end_point.z || get_dist(start_point, end_point) > range)
					continue

			listener.receive_signal(signal)
