/**
 * This component hooks into a signal on a tracked client's mob and allows to make
 * batch signal subscriptions.
 * Works simmilar to `connect_loc`.
 */
/datum/component/connect_mob_behalf
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// An assoc list of signal -> procpath to register to the mob the client "owns".
	var/list/connections
	/// Reference to the master client.
	var/client/tracked
	/// Currently tracked mob.
	var/mob/tracked_mob

/datum/component/connect_mob_behalf/Initialize(client/tracked, list/connections)
	. = ..()
	if(!istype(tracked))
		return COMPONENT_INCOMPATIBLE

	src.connections = connections
	src.tracked = tracked

/datum/component/connect_mob_behalf/register_with_parent()
	register_signal(tracked, SIGNAL_QDELETING, nameof(.proc/on_tracked_qdel))
	update_signals()

/datum/component/connect_mob_behalf/unregister_from_parent()
	unregister_signals()
	unregister_signal(tracked, SIGNAL_QDELETING)

	tracked = null
	tracked_mob = null

/datum/component/connect_mob_behalf/proc/on_tracked_qdel()
	// This is signal handler, so it should have `SIGNAL_HANDLER`, but some fucker sleeps in `Entered.
	qdel(src)

/datum/component/connect_mob_behalf/proc/update_signals()
	unregister_signals()

	if(QDELETED(tracked?.mob))
		return

	tracked_mob = tracked.mob

	register_signal(tracked_mob, SIGNAL_LOGGED_OUT, nameof(.proc/on_logout))
	for(var/signal in connections)
		parent.register_signal(tracked_mob, signal, connections[signal])

/datum/component/connect_mob_behalf/proc/unregister_signals()
	if(isnull(tracked_mob))
		return

	parent.unregister_signal(tracked_mob, connections)
	unregister_signal(tracked_mob, SIGNAL_LOGGED_OUT)

	tracked_mob = null

/datum/component/connect_mob_behalf/proc/on_logout(mob/source)
	SIGNAL_HANDLER
	update_signals()
