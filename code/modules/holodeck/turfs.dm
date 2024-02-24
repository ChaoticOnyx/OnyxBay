/turf/simulated/floor/holospace
	name = "\proper space"
	desc = "It's spa-a-ace!1!"

	icon_state = "0"
	icon = 'icons/turf/space.dmi'

/turf/simulated/floor/holospace/Initialize(mapload, ...)
	. = ..()
	icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
