/// This component behaves similar to connect_loc_behalf, but it's nested and hooks a signal onto all MOVABLES containing this atom.
/datum/component/connect_containers
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections
	/**
	 * The atom the component is tracking. The component will delete itself if the tracked is deleted.
	 * Signals will also be updated whenever it moves.
	 */
	var/atom/movable/tracked

/datum/component/connect_containers/Initialize(atom/movable/tracked, list/connections)
	. = ..()
	if (!ismovable(tracked))
		return COMPONENT_INCOMPATIBLE

	src.connections = connections
	set_tracked(tracked)

/datum/component/connect_containers/Destroy()
	set_tracked(null)
	return ..()

/datum/component/connect_containers/inherit_component(datum/component/component, original, atom/movable/tracked, list/connections)
	// Not equivalent. Checks if they are not the same list via shallow comparison.
	if(!compare_list(src.connections, connections))
		util_crash_with("connect_containers component attached to [parent] tried to inherit another connect_containers component with different connections")
		return

	if(src.tracked != tracked)
		set_tracked(tracked)

/datum/component/connect_containers/proc/set_tracked(atom/movable/new_tracked)
	if(tracked)
		unregister_signal(tracked, list(SIGNAL_MOVED, SIGNAL_QDELETING))
		unregister_signals(tracked.loc)
	tracked = new_tracked
	if(!tracked)
		return
	register_signal(tracked, SIGNAL_MOVED, nameof(.proc/on_moved))
	register_signal(tracked, SIGNAL_QDELETING, nameof(.proc/handle_tracked_qdel))
	update_signals(tracked)

/datum/component/connect_containers/proc/handle_tracked_qdel()
	qdel_self()

/datum/component/connect_containers/proc/update_signals(atom/movable/listener)
	if(!ismovable(listener.loc))
		return

	for(var/atom/movable/container as anything in get_nested_locs(listener))
		register_signal(container, SIGNAL_MOVED, nameof(.proc/on_moved))
		for(var/signal in connections)
			parent.register_signal(container, signal, connections[signal])

/datum/component/connect_containers/proc/unregister_signals(atom/movable/location)
	if(!ismovable(location))
		return

	for(var/atom/movable/target as anything in (get_nested_locs(location) + location))
		unregister_signal(target, SIGNAL_MOVED)
		parent.unregister_signal(target, connections)

/datum/component/connect_containers/proc/on_moved(atom/movable/listener, atom/old_loc)
	SIGNAL_HANDLER
	unregister_signals(old_loc)
	update_signals(listener)
