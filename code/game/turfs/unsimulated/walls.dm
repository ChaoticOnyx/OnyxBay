/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls/riveted.dmi'
	icon_state = "riveted0"
	opacity = 1
	density = 1
	plane = DEFAULT_PLANE
	explosion_block = 1
	rad_resist_type = /datum/rad_resist/wall

/turf/unsimulated/wall/Initialize(mapload, ...)
	. = ..()
	add_debris_element()

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon = 'icons/turf/walls.dmi'
	icon_state = "fakewindows"
	opacity = 0

/turf/unsimulated/wall/other
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "rgeneric"

/turf/unsimulated/wall/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)
