/datum/frequency
	/// Numeric frequency identifier, ranges between `RADIO_LOW_FREQ` and `RADIO_HIGH_FREQ`.
	var/frequency
	/// Associative list of text -> object, where IDK LOL
	var/list/filters = list()


/datum/frequency/New(new_frequency)
	frequency = new_frequency


/datum/frequency/proc/add_listener(obj/device, filter)
	if(!filter)
		filter = RADIO_DEFAULT

	LAZYADDASSOC(filters, filter, device)


/datum/frequency/proc/remove_listener(obj/device)
	for(var/devices_filter in filters)
		LAZYREMOVEASSOC(filters, devices_filter, device)


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
