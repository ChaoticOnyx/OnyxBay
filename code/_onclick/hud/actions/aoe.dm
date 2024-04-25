/**
 * AOE spell
 *
 * Iterates over atoms near the caster and casts a spell on them.
 * Calls cast_on_thing_in_aoe on all atoms returned by get_things_to_cast_on by default.
 */
/datum/action/cooldown/spell/aoe
	check_flags = EMPTY_BITFIELD
	click_to_activate = TRUE
	/// The max amount of targets we can affect via our AOE. 0 = unlimited
	var/max_targets = 0
	/// Should we shuffle the targets lift after getting them via get_things_to_cast_on?
	var/shuffle_targets_list = FALSE
	/// The radius of the aoe.
	var/aoe_radius = 7

/datum/action/cooldown/spell/aoe/cast(atom/target)
	var/list/atom/things_to_cast_on = get_things_to_cast_on(target)

	// Now go through and cast our spell where applicable
	var/num_targets = 0
	for(var/thing_to_target in things_to_cast_on)
		if(max_targets > 0 && num_targets >= max_targets)
			continue

		cast_on_thing_in_aoe(thing_to_target, target)
		num_targets++

/datum/action/cooldown/spell/aoe/proc/get_things_to_cast_on(atom/center)
	RETURN_TYPE(/list)

	var/list/things = list()
	// Default behavior is to get all atoms in range, center and owner not included.
	for(var/atom/nearby_thing in range(aoe_radius, center))
		if(nearby_thing == owner)
			continue

		things += nearby_thing

	return things

/// Implement actual casting code here
/datum/action/cooldown/spell/aoe/proc/cast_on_thing_in_aoe(atom/victim, atom/caster)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement cast_on_thing_in_aoe and either has no effects or implemented the spell incorrectly.")
