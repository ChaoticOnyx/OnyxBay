/turf/floor/holospace
	name = "\proper space"
	desc = "It's spa-a-ace!1!"

	icon_state = "0"
	icon = 'icons/turf/space.dmi'

/turf/floor/holospace/Initialize(mapload, ...)
	. = ..()
	icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
