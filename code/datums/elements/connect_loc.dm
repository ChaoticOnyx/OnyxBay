/// This element hooks a signal onto the loc the current object is on.
/// When the object moves, it will unhook the signal and rehook it to the new object.
/datum/element/connect_loc
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections

/datum/element/connect_loc/attach(atom/movable/listener, list/connections)
	. = ..()
	if (!istype(listener))
		return ELEMENT_INCOMPATIBLE

	src.connections = connections

	register_signal(listener, SIGNAL_MOVED, .proc/on_moved, override = TRUE)
	update_signals(listener)

/datum/element/connect_loc/detach(atom/movable/listener)
	. = ..()
	unregister_signals(listener, listener.loc)
	unregister_signal(listener, SIGNAL_MOVED)

/datum/element/connect_loc/proc/update_signals(atom/movable/listener)
	var/atom/listener_loc = listener.loc
	if(isnull(listener_loc))
		return

	for (var/signal in connections)
		//override=TRUE because more than one connect_loc element instance tracked object can be on the same loc
		listener.register_signal(listener_loc, signal, connections[signal], override=TRUE)

/datum/element/connect_loc/proc/unregister_signals(datum/listener, atom/old_loc)
	if(isnull(old_loc))
		return

	listener.unregister_signal(old_loc, connections)

/datum/element/connect_loc/proc/on_moved(atom/movable/listener, atom/old_loc)
	SHOULD_NOT_SLEEP(TRUE)
	unregister_signals(listener, old_loc)
	update_signals(listener)
