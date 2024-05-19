/// A datum that handles signals for tracking of movable atoms
/datum/movement_detector
	var/atom/movable/tracked
	var/datum/callback/listener

/datum/movement_detector/New(atom/movable/target, datum/callback/listener)
	if(target && listener)
		track(target, listener)

/datum/movement_detector/Destroy()
	untrack()
	tracked = null
	listener = null
	return ..()

/datum/movement_detector/proc/track(atom/movable/target, datum/callback/listener)
	untrack()
	tracked = target
	src.listener = listener

	while(ismovable(target))
		register_signal(target, SIGNAL_MOVED, nameof(.proc/move_react))
		target = target.loc

/datum/movement_detector/proc/untrack()
	if(!tracked)
		return

	var/atom/movable/target = tracked
	while(ismovable(target))
		unregister_signal(target, SIGNAL_MOVED)
		target = target.loc

/// This proc detects movement of the tracked atom/movable recursively
/datum/movement_detector/proc/move_react(atom/movable/mover, atom/oldloc, direction)
	var/turf/newturf = get_turf(tracked)

	if(oldloc && !isturf(oldloc))
		var/atom/target = oldloc
		while(ismovable(target))
			unregister_signal(target, SIGNAL_MOVED)
			target = target.loc

	if(tracked.loc != newturf)
		var/atom/target = mover.loc
		while(ismovable(target))
			register_signal(target, SIGNAL_MOVED, nameof(.proc/move_react), TRUE)
			target = target.loc

	listener.Invoke(tracked, mover, oldloc, direction)
