/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls/riveted.dmi'
	icon_state = "riveted0"
	opacity = 1
	density = 1
	plane = DEFAULT_PLANE
	explosion_block = 1
	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 100 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 20.2 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 10 ELECTRONVOLT
	)

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0

/turf/unsimulated/wall/other
	icon_state = "r_wall"
