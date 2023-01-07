/turf/unsimulated/floor/frozenground
	name = "frozen ground"
	icon = 'icons/turf/flooring/frozenground.dmi'
	icon_state = "frozen_ground"
	temperature = 243.15 // -30C
	footstep_sound = SFX_FOOTSTEP_SNOW

/turf/unsimulated/floor/frozenground/is_plating()
	return 1

/turf/unsimulated/floor/frozenground/Entered(atom/movable/A as mob|obj)
	..()
	if(A && A.loc == src)
		if (A.x <= TRANSITION_EDGE || A.x >= (world.maxx - TRANSITION_EDGE + 1) || A.y <= TRANSITION_EDGE || A.y >= (world.maxy - TRANSITION_EDGE + 1))
			A.touch_map_edge()

/turf/unsimulated/floor/frozenground/ice/shallow
	icon = 'icons/turf/ice.dmi'
	icon_state = "ice1"
