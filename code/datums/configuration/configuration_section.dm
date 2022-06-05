/datum/configuration_section
	var/protection_state = PROTECTION_NONE

	/// Name of a section in `.toml`.
	var/name = null

/datum/configuration_section/proc/load_data(list/data)
	SHOULD_CALL_PARENT(FALSE)

	CRASH("load() not overriden for [type]!")

/datum/configuration_section/VV_static()
	if(protection_state == PROTECTION_READONLY)
		return vars
	
	return ..()

/datum/configuration_section/VV_hidden()
	if(protection_state in list(PROTECTION_PRIVATE, PROTECTION_READONLY))
		return vars

	return ..()

/datum/configuration_section/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)

	// This is going to stay existing. I dont care.
	return QDEL_HINT_LETMELIVE
