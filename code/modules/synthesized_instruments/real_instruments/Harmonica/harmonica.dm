/datum/sound_player/harmonica
	volume = 50
	range = 10

/obj/item/device/synthesized_instrument/harmonica
	name = "harmonica"
	desc = "If you see this, you should be in the prison."
	icon = 'icons/obj/musician.dmi'
	icon_state = "harmonica"
	force = 0
	path = /datum/instrument/harmonica
	sound_player = /datum/sound_player/harmonica

/obj/structure/synthesized_instrument/synthesizer/shouldStopPlaying(mob/user)
	return !(src && in_range(src, user))
