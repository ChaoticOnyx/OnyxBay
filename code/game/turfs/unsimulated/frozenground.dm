/turf/unsimulated/floor/frozenground
	name = "frozen ground"
	icon = 'icons/turf/flooring/frozenground.dmi'
	icon_state = "frozen_ground"
	temperature = -30 CELSIUS
	footstep_sound = SFX_FOOTSTEP_SNOW

/turf/unsimulated/floor/frozenground/is_plating()
	return 1

/turf/unsimulated/floor/frozenground/ice/shallow
	icon = 'icons/turf/ice.dmi'
	icon_state = "ice1"
