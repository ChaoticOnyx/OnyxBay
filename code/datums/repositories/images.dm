/*
*	This repository is intended for images that are never altered after creation
*/

/var/repository/images/image_repository = new()

/repository/images
	var/list/image_cache_for_atoms
	var/list/image_cache_for_overlays

/repository/images/New()
	..()
	image_cache_for_atoms = list()
	image_cache_for_overlays = list()

// Returns an image bound to the given atom and which is typically applied to client.images.
/repository/images/proc/atom_image(atom/holder, icon, icon_state, plane = FLOAT_PLANE, layer = FLOAT_LAYER)
	var/atom_cache_list = image_cache_for_atoms[holder]
	if(!atom_cache_list)
		atom_cache_list = list()
		image_cache_for_atoms[holder] = atom_cache_list
		register_signal(holder, SIGNAL_QDELETING, /repository/images/proc/atom_destroyed)

	var/cache_key = "[icon]-[icon_state]-[plane]-[layer]"
	. = atom_cache_list[cache_key]
	if(!.)
		var/image/I = image(icon, holder, icon_state)
		I.plane = plane
		I.layer = layer
		atom_cache_list[cache_key] = I
		return I

/repository/images/proc/atom_destroyed(atom/destroyed)
	var/list/atom_cache_list = image_cache_for_atoms[destroyed]
	for(var/img in atom_cache_list)
		qdel(atom_cache_list[img])
	atom_cache_list.Cut()
	image_cache_for_atoms -= destroyed

	unregister_signal(destroyed, SIGNAL_QDELETING)

// Returns an image not bound to anything and which is typically applied as an overlay/underlay.
/repository/images/proc/overlay_image(icon, icon_state, alpha, appearance_flags, color, dir, plane = FLOAT_PLANE, layer = FLOAT_LAYER)
	var/cache_key = "[icon]-[icon_state]-[alpha]-[appearance_flags]-[color]-[dir]-[plane]-[layer]"
	. = image_cache_for_overlays[cache_key]
	if(!.)
		var/image/I = image(icon = icon, icon_state = icon_state, dir = dir)
		I.alpha = alpha
		I.appearance_flags = DEFAULT_APPEARANCE_FLAGS | appearance_flags
		I.plane = plane
		I.layer = layer
		image_cache_for_overlays[cache_key] = I
		return I
