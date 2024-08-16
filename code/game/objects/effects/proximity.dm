/datum/proximity_monitor
	///The atom we are tracking
	var/atom/host
	///The atom that will receive HasProximity calls.
	var/atom/hasprox_receiver
	///The range of the proximity monitor. Things moving wihin it will trigger HasProximity calls.
	var/current_range
	///If we don't check turfs in range if the host's loc isn't a turf
	var/ignore_if_not_on_turf
	///The signals of the connect range component, needed to monitor the turfs in range.
	var/static/list/loc_connections = list(
		SIGNAL_ENTERED = nameof(.proc/on_entered),
		SIGNAL_EXITED = nameof(.proc/on_uncrossed),
		SIGNAL_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = nameof(.proc/on_initialized),
	)

/datum/proximity_monitor/New(atom/_host, range, _ignore_if_not_on_turf = TRUE)
	ignore_if_not_on_turf = _ignore_if_not_on_turf
	current_range = range
	set_host(_host)

/datum/proximity_monitor/proc/set_host(atom/new_host, atom/new_receiver)
	if(new_host == host)
		return
	if(host) //No need to delete the connect range and containers comps. They'll be updated with the new tracked host.
		unregister_signal(host, list(SIGNAL_MOVED, SIGNAL_QDELETING))
	if(hasprox_receiver)
		unregister_signal(hasprox_receiver, SIGNAL_QDELETING)
	if(new_receiver)
		hasprox_receiver = new_receiver
		if(new_receiver != new_host)
			register_signal(new_receiver, SIGNAL_QDELETING, nameof(.proc/on_host_or_receiver_del))
	else if(hasprox_receiver == host) //Default case
		hasprox_receiver = new_host
	host = new_host
	register_signal(new_host, SIGNAL_QDELETING, nameof(.proc/on_host_or_receiver_del))
	var/static/list/containers_connections = list(SIGNAL_MOVED = nameof(.proc/on_moved), SIGNAL_Z_CHANGED = nameof(.proc/on_z_change))
	AddComponent(/datum/component/connect_containers, host, containers_connections)
	register_signal(host, SIGNAL_MOVED, nameof(.proc/on_moved), TRUE)
	register_signal(host, SIGNAL_Z_CHANGED, nameof(.proc/on_z_change), TRUE)
	set_range(current_range, TRUE)

/datum/proximity_monitor/proc/on_host_or_receiver_del(datum/source)
	qdel_self()

/datum/proximity_monitor/Destroy()
	host = null
	hasprox_receiver = null
	return ..()

/datum/proximity_monitor/proc/set_range(range, force_rebuild = FALSE)
	if(!force_rebuild && range == current_range)
		return FALSE
	. = TRUE
	current_range = range

	//If the connect_range component exists already, this will just update its range. No errors or duplicates.
	AddComponent(/datum/component/connect_range, host, loc_connections, range, !ignore_if_not_on_turf)

/datum/proximity_monitor/proc/on_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(source == host)
		hasprox_receiver?.HasProximity(host)

/datum/proximity_monitor/proc/on_z_change()
	SIGNAL_HANDLER
	return

/datum/proximity_monitor/proc/set_ignore_if_not_on_turf(does_ignore = TRUE)
	if(ignore_if_not_on_turf == does_ignore)
		return
	ignore_if_not_on_turf = does_ignore
	//Update the ignore_if_not_on_turf
	AddComponent(/datum/component/connect_range, host, loc_connections, current_range, ignore_if_not_on_turf)

/datum/proximity_monitor/proc/on_uncrossed()
	SIGNAL_HANDLER
	return //Used by the advanced subtype for effect fields.

/datum/proximity_monitor/proc/on_entered(atom/source, atom/movable/arrived, turf/old_loc)
	SIGNAL_HANDLER
	if(source != host)
		hasprox_receiver?.HasProximity(arrived)

/datum/proximity_monitor/proc/on_initialized(turf/location, atom/created, init_flags)
	SIGNAL_HANDLER
	if(location != host)
		hasprox_receiver?.HasProximity(created)
