/**
 * Liquid Height element; for dynamically applying liquid blockages.
 *
 * Used for reinforced tables, sandbags, and the likes.
 */
/datum/element/liquids_height
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2

	///Height applied by this element
	var/height_applied

/datum/element/liquids_height/attach(datum/target, height_applied)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.height_applied = height_applied

	register_signal(target, SIGNAL_MOVED, .proc/on_target_move)
	var/atom/movable/movable_target = target
	if(isturf(movable_target.loc))
		var/turf/turf_loc = movable_target.loc
		turf_loc.liquid_height += height_applied
		turf_loc.reasses_liquids()

/datum/element/liquids_height/detach(atom/movable/target)
	. = ..()

	unregister_signal(target, list(SIGNAL_MOVED))
	var/atom/movable/movable_target = target
	if(isturf(movable_target.loc))
		var/turf/turf_loc = movable_target.loc
		turf_loc.liquid_height -= height_applied
		turf_loc.reasses_liquids()

/datum/element/liquids_height/proc/on_target_move(atom/movable/source, atom/OldLoc, Dir, Forced = FALSE)

	if(isturf(OldLoc))
		var/turf/old_turf = OldLoc
		old_turf.liquid_height += height_applied
		old_turf.reasses_liquids()
	if(isturf(source.loc))
		var/turf/new_turf = source.loc
		new_turf.liquid_height -= height_applied
		new_turf.reasses_liquids()
