/datum/sound_player/saxophone
	volume = 50
	range = 10

/obj/item/device/synthesized_instrument/saxophone
	name = "saxophone"
	desc = "Curved metal stick with tube and multiple holes. Blow into it to make some music."
	icon = 'icons/obj/musician.dmi'
	icon_state = "saxophone"
	force = 3
	path = /datum/instrument/brass
	sound_player = /datum/sound_player/saxophone

/obj/structure/synthesized_instrument/synthesizer/shouldStopPlaying(mob/user)
	return !(src && in_range(src, user))
