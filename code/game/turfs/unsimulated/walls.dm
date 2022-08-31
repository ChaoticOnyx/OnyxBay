/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1
	plane = DEFAULT_PLANE
	explosion_block = 1
	rad_resist = list(
		RADIATION_ALPHA_RAY = 1.0,
		RADIATION_BETA_RAY = 1.0,
		RADIATION_HAWKING_RAY = 0.9
	)

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/unsimulated/wall/abductor
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "alien1"
