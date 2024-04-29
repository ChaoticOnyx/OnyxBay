/**
 * Datum that holds and tracks info about a client's object. Mainly used for controlled
 * icon generation thus removing limitations present in previous stat panel version.
 */
/datum/object_window_info
	/// List of atoms to show to a client via the object tab.
	var/list/atoms_to_show = list()
	/// List of atom -> image string for objects we have had in the right click tab.
	var/list/atoms_to_images = list()
	/// List of atoms to turn into images for the object tab.
	var/list/atoms_to_imagify = list()
	/// Reference to a window owner.
	var/client/parent
	/// Whether window is currently tracking a turf.
	var/actively_tracking = FALSE

/datum/object_window_info/New(client/parent)
	. = ..()

	src.parent = parent

/datum/object_window_info/Destroy(force)
	atoms_to_show = null
	atoms_to_images = null
	atoms_to_imagify = null
	parent.obj_window = null
	parent = null
	STOP_PROCESSING(SSobj_tab_items, src)
	return ..()

/**
 * Takes an objects list, attempts to generate images and and notify client. Processes
 * until all entries were handled.
 */
/datum/object_window_info/Process()
	// Cache the datum access for sonic speed
	var/list/to_make = atoms_to_imagify
	var/list/newly_seen = atoms_to_images

	var/index = 0
	for(index in 1 to length(to_make))
		var/atom/thing = to_make[index]

		var/generated_string
		if(ismob(thing) || length(thing.overlays) > 2)
			generated_string = costly_icon2html(thing, parent, sourceonly = TRUE)
		else
			generated_string = icon2html(thing, parent, sourceonly = TRUE)

		newly_seen[thing] = generated_string

		if(TICK_CHECK)
			to_make.Cut(1, index + 1)
			index = 0
			break

	// If we've not cut yet, do it now
	if(index)
		to_make.Cut(1, index + 1)

	SSstatpanels.refresh_client_obj_view(parent)

	if(!length(to_make))
		return PROCESS_KILL

/datum/object_window_info/proc/start_turf_tracking()
	if(actively_tracking)
		stop_turf_tracking()

	var/static/list/connections = list(
		SIGNAL_MOVED = nameof(.proc/on_mob_move),
		SIGNAL_LOGGED_OUT = nameof(.proc/on_mob_logout),
	)

	AddComponent(/datum/component/connect_mob_behalf, parent, connections)
	actively_tracking = TRUE

/datum/object_window_info/proc/stop_turf_tracking()
	qdel(get_component(/datum/component/connect_mob_behalf))
	actively_tracking = FALSE

/datum/object_window_info/proc/on_mob_move(mob/source)
	// Some fucker sleeps in `Entered`, so it's impossible to use `SIGNAL_HANDLER` inhere.
	var/turf/listed = source.listed_turf
	if(isnull(listed) || !source.TurfAdjacent(listed))
		source.set_listed_turf(null)

/datum/object_window_info/proc/on_mob_logout(mob/source)
	// Sleepy in `Entered`, so no `SIGNAL_HANDLER`, bozo.
	on_mob_move(source)

/datum/object_window_info/proc/viewing_atom_deleted(atom/deleted)
	SIGNAL_HANDLER
	atoms_to_show -= deleted
	atoms_to_imagify -= deleted
	atoms_to_images -= deleted

/mob/proc/set_listed_turf(turf/new_turf)
	listed_turf = new_turf
	if(!client)
		return

	if(!client.obj_window)
		client.obj_window = new(client)

	if(listed_turf)
		client.stat_panel.send_message("create_listedturf", listed_turf.name)
		client.obj_window.start_turf_tracking()
	else
		client.stat_panel.send_message("remove_listedturf")
		client.obj_window.stop_turf_tracking()
