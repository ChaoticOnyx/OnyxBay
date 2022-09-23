GLOBAL_LIST_EMPTY(map_ent_vars)

/obj/map_ent
	name = "map_ent"
	invisibility = 101
	icon = 'icons/misc/map_ent.dmi'
	icon_state = "noop"

	var/ev_activate_at_startup = FALSE

/obj/map_ent/Initialize(...)
	. = ..()

	if(ev_activate_at_startup)
		activate()

/obj/map_ent/proc/activate()
	return
