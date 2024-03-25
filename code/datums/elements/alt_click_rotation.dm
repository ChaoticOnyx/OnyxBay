/datum/element/alt_click_rotation
	element_flags = ELEMENT_DETACH

/datum/element/alt_click_rotation/attach(datum/target)
	. = ..()

	var/atom/target_atom = target
	if(!istype(target_atom))
		return ELEMENT_INCOMPATIBLE

	register_signal(target_atom, SIGNAL_ALT_CLICKED, nameof(.proc/on_alt_click))
	register_signal(target_atom, SIGNAL_CTRL_ALT_CLICKED, nameof(.proc/on_ctrl_alt_click))

	target_atom.verbs |= /atom/proc/rotate
	target_atom.verbs |= /atom/proc/rotate_counter

/datum/element/alt_click_rotation/detach(datum/source, ...)
	unregister_signal(source, SIGNAL_ALT_CLICKED)
	unregister_signal(source, SIGNAL_CTRL_ALT_CLICKED)

	var/atom/target_atom = source

	target_atom.verbs -= /atom/proc/rotate
	target_atom.verbs -= /atom/proc/rotate_counter

	return ..()

/datum/element/alt_click_rotation/proc/on_alt_click(atom/clicked, mob/user)
	clicked.rotate(user)

/datum/element/alt_click_rotation/proc/on_ctrl_alt_click(atom/clicked, mob/user)
	clicked.rotate_counter(user)

/atom/proc/rotate(mob/user)
	set name = "Rotate Clockwise"
	set hidden = TRUE

	if(!user || user.incapacitated() || !Adjacent(user))
		return

	set_dir(turn(dir, -90))

/atom/proc/rotate_counter(mob/user)
	set name = "Rotate Counterclockwise"
	set hidden = TRUE

	if(!user || user.incapacitated() || !Adjacent(user))
		return

	set_dir(turn(dir, 90))
