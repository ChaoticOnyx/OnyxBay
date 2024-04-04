/// Adds an image to a list of clients and then removes it.
/datum/flick_overlay
	var/image/image
	var/list/client/seeing_clients = list()

/datum/flick_overlay/New(image/image, list/client/show_to, time_to_live)
	. = ..()
	if(!image || !islist(show_to))
		qdel_self()

	src.image = image
	seeing_clients = show_to
	add_image_to_clients(image, seeing_clients)
	QDEL_IN(src, time_to_live)

/datum/flick_overlay/Destroy()
	remove_image_from_clients(image, seeing_clients)
	QDEL_NULL(image)
	seeing_clients.Cut()
	return ..()

// Adds the image to a list of clients.
/proc/add_image_to_clients(image/image_to_add, list/show_to)
	for(var/client/add_to as anything in show_to)
		LAZYADD(add_to?.images, image_to_add)

// Removes the image from a list of clients.
/proc/remove_image_from_clients(image/image_to_remove, list/hide_from)
	for(var/client/remove_from as anything in hide_from)
		LAZYREMOVE(remove_from?.images, image_to_remove)

// Adds an image to a list of clients
/proc/flick_overlay_global(image/image_to_show, list/show_to, duration)
	if(!show_to || !length(show_to) || !image_to_show)
		return

	new /datum/flick_overlay(image_to_show, show_to, duration)

// Flicks a certain overlay onto an atom, handling icon_state strings.
/atom/proc/flick_overlay(image_to_show, list/show_to, duration, layer)
	var/image/passed_image = istext(image_to_show) ? image(icon, src, image_to_show, layer) : image_to_show
	flick_overlay_global(passed_image, show_to, duration)

// Flicks a certain overlay to anyone who can view this atom.
/atom/proc/flick_overlay_in_view(image_to_show, duration)
	var/list/observers
	for(var/mob/observer as anything in viewers(src))
		if(observer.client)
			LAZYADD(observers, observer)

	flick_overlay(image_to_show, observers, duration)
