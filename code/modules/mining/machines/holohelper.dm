#define HOLOHELPER_DECAY_TIME 10 SECONDS

/obj/effect/holodir_helper
	icon = 'icons/effects/holo_dirs.dmi'
	icon_state = "holo-arrows"
	pixel_y = -16
	pixel_x = -16
	alpha = 210

/obj/effect/holodir_helper/Initialize(loc, atom/movable/parent_machine)
	. = ..()
	if(parent_machine)
		dir = parent_machine.dir
		register_signal(parent_machine, SIGNAL_DIR_SET, nameof(.proc/on_machinery_rotated))
		register_signal(parent_machine, SIGNAL_QDELETING, nameof(/datum.proc/qdel_self))
		update_icon()
		QDEL_IN(src, HOLOHELPER_DECAY_TIME)
	else
		return INITIALIZE_HINT_QDEL

/obj/effect/holodir_helper/on_update_icon()
	set_light(1, 0, 3, 3.5,  "#0090F8")
	AddOverlays(emissive_appearance(icon, "[icon_state]_ea"))

/obj/effect/holodir_helper/proc/on_machinery_rotated(atom, old_dir, dir)
	src.dir = dir

#undef HOLOHELPER_DECAY_TIME
