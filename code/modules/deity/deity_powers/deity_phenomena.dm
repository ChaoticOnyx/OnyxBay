/datum/deity_power/phenomena
	expected_type = /mob/

/datum/deity_power/phenomena/can_manifest(atom/target, mob/living/deity/D)
	if(!..())
		return FALSE

	if(!istype(target, expected_type))
		return FALSE

	return TRUE
