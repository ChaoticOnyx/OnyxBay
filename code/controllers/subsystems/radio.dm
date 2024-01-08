SUBSYSTEM_DEF(radio)
	name = "Radio"
	flags = SS_NO_FIRE|SS_NO_INIT

	/// Associative list of text -> datum, where text is a frequency string, datum is a `/datum/frequency`.
	var/list/frequencies = list()


/datum/controller/subsystem/radio/stat_entry(msg)
	..("FU:[length(frequencies)]")


/datum/controller/subsystem/radio/proc/add_object(obj/device, new_frequency, filter)
	var/f_text = num2text(new_frequency)
	var/datum/frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new(new_frequency)
		LAZYSET(frequencies, f_text, frequency)

	frequency.add_listener(device, filter)
	return frequency


/datum/controller/subsystem/radio/proc/remove_object(obj/device, old_frequency)
	var/f_text = num2text(old_frequency)
	var/datum/frequency/frequency = frequencies[f_text]

	if(frequency)
		frequency.remove_listener(device)

		if(!length(frequency.filters))
			LAZYREMOVE(frequencies, f_text)
			qdel(frequency)


/datum/controller/subsystem/radio/proc/return_frequency(new_frequency)
	var/f_text = num2text(new_frequency)
	var/datum/frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new(new_frequency)
		LAZYSET(frequencies, f_text, frequency)

	return frequency
