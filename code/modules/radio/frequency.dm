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

	LAZYADDASSOC(filters, filter, device)


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
	for(var/devices_filter in filters)
		LAZYREMOVEASSOC(filters, devices_filter, device)


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
	var/turf/start_point
	if(range)
		start_point = get_turf(source)
		if(!start_point)
			qdel(signal)
			return

	if(filter)
		_send_to_filter(source, signal, filter, start_point, range)
		_send_to_filter(source, signal, RADIO_DEFAULT, start_point, range)
		return

	for(var/next_filter in filters)
		_send_to_filter(source, signal, next_filter, start_point, range)


/**
 * 'Semi-private' proc that is used to asynchronously call `receive_signal` on all
 * objects that satisfies specified conditions.
 *
 * Vars:
 * * source - atom that emited a signal, used to not trigger `receive_signal` on the sender.
 * * signal - signal datum containig all the extra information.
 * * filter - string that will be used to pick a list from the `filters`.
 * * start_point - used to calculate distance between sender and recipient.
 * * range - numeric value that will be used to check distance between sender and recipient, use `null` to skip.
 *
 * Checks whether range and turf are present, returns otherwise.
 *
 * Cycles through filters and invokes `receive_signal` asynchronously. Extra checks can be
 * preformed if range is present.
 *
 */
/datum/frequency/proc/_send_to_filter(obj/source, datum/signal/signal, filter, turf/start_point = null, range = null)
	if(range && !start_point)
		return

	for(var/obj/device in filters[filter])
		if(device == source)
			continue

		if(range)
			var/turf/end_point = get_turf(device)
			if(!end_point)
				continue

			if(start_point.z != end_point.z || get_dist(start_point, end_point) > range)
				continue

		INVOKE_ASYNC(device, nameof(/obj.proc/receive_signal), signal, frequency)
