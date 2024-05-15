/turf/floor/frozenground
	name = "frozen ground"
	icon = 'icons/turf/flooring/frozenground.dmi'
	icon_state = "frozen_ground"
	temperature = -30 CELSIUS
	footstep_sound = SFX_FOOTSTEP_SNOW

/turf/floor/frozenground/is_plating()
	return 1

/turf/floor/frozenground/ice/shallow
	icon = 'icons/turf/ice.dmi'
	icon_state = "ice1"
