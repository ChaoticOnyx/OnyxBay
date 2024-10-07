/datum/sound_player/recorder
	volume = 50
	range = 10

/obj/item/device/synthesized_instrument/recorder
	name = "recorder"
	desc = "Wooden stick with holes. Blow into it to make some music."
	icon = 'icons/obj/musician.dmi'
	icon_state = "recorder"
	force = 0
	path = /datum/instrument
	sound_player = /datum/sound_player/recorder

/obj/structure/synthesized_instrument/synthesizer/shouldStopPlaying(mob/user)
	return !(src && in_range(src, user))
