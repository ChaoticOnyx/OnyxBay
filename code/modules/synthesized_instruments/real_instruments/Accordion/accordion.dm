/datum/sound_player/accordion
	volume = 50
	range = 10

/obj/item/device/synthesized_instrument/accordion
	name = "accordion"
	desc = "Sretch and squeeze it to make music."
	icon = 'icons/obj/musician.dmi'
	icon_state = "accordion"
	force = 3
	path = /datum/instrument/accordion
	sound_player = /datum/sound_player/accordion

/obj/structure/synthesized_instrument/synthesizer/shouldStopPlaying(mob/user)
	return !(src && in_range(src, user))
