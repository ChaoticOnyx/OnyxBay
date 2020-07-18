/obj/effect/decal/cleanable
	anchored = TRUE
	var/list/random_icon_states

/obj/effect/decal/cleanable/clean_blood(ignore = 0)
	if(!ignore)
		qdel(src)
		return
	..()

/obj/effect/decal/cleanable/Initialize()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	. = ..()
