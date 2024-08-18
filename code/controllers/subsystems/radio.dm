SUBSYSTEM_DEF(radio)
	name = "Radio"
	flags = SS_NO_FIRE|SS_NO_INIT

	/// Associative list of text -> datum, where text is a frequency string, datum is a `/datum/frequency`.
	var/list/frequencies = list()

/datum/controller/subsystem/radio/stat_entry()
	..("F:[length(frequencies)]")

/**
 * Adds an object to the specified frequency with a specified filter.
 *
 * Vars:
 * * device - object that will be listening to signals.
 * * new_frequency - numeric value that will be used as a key to store a `datum/frequency`.
 * * filter - numeric value that will be used as key, if `null` is passed `RADIO_DEFAULT` will be used instead.
 *
 * Tries to access a datum.
 *
 * If none is present - creates a new one.
 *
 * Adds an object to a frequency.
 *
 * Returns `datum/frequency`.
 *
 */
/datum/controller/subsystem/radio/proc/add_object(obj/device, new_frequency, filter)
	var/f_text = num2text(new_frequency)
	var/datum/frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new(new_frequency)
		LAZYSET(frequencies, f_text, frequency)

	frequency.add_listener(device, filter)
	return frequency

/**
 * Removes object from the specified frequency.
 *
 * Vars:
 * * device - object that will be removed from listeners list.
 * * old_frequency -  numeric value that will be used as a key to access a `datum/frequency`.
 *
 * Tries to access a datum.
 *
 * If any is present - removes it.
 *
 */
/datum/controller/subsystem/radio/proc/remove_object(obj/device, old_frequency)
	var/f_text = num2text(old_frequency)
	var/datum/frequency/frequency = frequencies[f_text]

	if(frequency)
		frequency.remove_listener(device)

		if(!length(frequency.filters))
			LAZYREMOVE(frequencies, f_text)
			qdel(frequency)

/**
 * Returns a reference to a frequency datum for the future use.
 *
 * Vars:
 * * new_frequency - numeric value that will be used as a key to access a `datum/frequency`.
 *
 * Tries to access a datum.
 *
 * If none is present - creates a new one.
 *
 * Returns `datum/frequency`.
 */
/datum/controller/subsystem/radio/proc/return_frequency(new_frequency)
	var/f_text = num2text(new_frequency)
	var/datum/frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new(new_frequency)
		LAZYSET(frequencies, f_text, frequency)

	return frequency
