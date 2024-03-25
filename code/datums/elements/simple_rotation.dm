/datum/element/simple_rotation
	element_flags = ELEMENT_DETACH

/datum/element/simple_rotation/attach(datum/target)
	. = ..()

	var/atom/target_atom = target
	if(!istype(target_atom))
		return ELEMENT_INCOMPATIBLE

	register_signal(target_atom, SIGNAL_ALT_CLICKED, nameof(.proc/on_alt_click))
	register_signal(target_atom, SIGNAL_CTRL_ALT_CLICKED, nameof(.proc/on_ctrl_alt_click))

	target_atom.verbs |= /atom/proc/rotate
	target_atom.verbs |= /atom/proc/rotate_counter

/datum/element/simple_rotation/detach(datum/source, ...)
	unregister_signal(source, SIGNAL_ALT_CLICKED)
	unregister_signal(source, SIGNAL_CTRL_ALT_CLICKED)

	var/atom/target_atom = source

	target_atom.verbs -= /atom/proc/rotate
	target_atom.verbs -= /atom/proc/rotate_counter

	return ..()

/datum/element/simple_rotation/proc/on_alt_click(atom/clicked, mob/user)
	clicked.rotate(user)

/datum/element/simple_rotation/proc/on_ctrl_alt_click(atom/clicked, mob/user)
	clicked.rotate_counter(user)

/atom/proc/can_rotate(mob/user)
	return !(!user || user.incapacitated() || !Adjacent(user))

/obj/can_rotate(mob/user)
	if(anchored && (obj_flags & OBJ_FLAG_ANCHOR_BLOCKS_ROTATION))
		show_splash_text(user, "unfasten it first!", "\The [src] is fastened to the floor therefore you can't rotate it!")
		return FALSE

	return ..(user)

/atom/proc/rotate(mob/user)
	set name = "Rotate Clockwise"
	set hidden = TRUE

	if(!can_rotate(user))
		return

	set_dir(turn(dir, -90))

/atom/proc/rotate_counter(mob/user)
	set name = "Rotate Counterclockwise"
	set hidden = TRUE

	if(!can_rotate(user))
		return

	set_dir(turn(dir, 90))
