/obj/item/clothing/ears/headphones
	name = "headphones"
	desc = "It's probably not in accordance with corporate policy to listen to music on the job... but fuck it."
	icon_state = "headphones_empty"
	item_state = "headphones_off"
	slot_flags = SLOT_EARS | SLOT_TWOEARS
	ear_protection = 0
	can_be_wrung_out = FALSE
	var/index = 1
	var/headphones_on = 0
	var/obj/item/music_tape/tape
	var/list/datum/track/tracks = list()
	var/datum/track/current_track
	var/playing = 0
	var/datum/sound_token/sound_token
	var/sound_id
	var/volume = 20

/obj/item/clothing/ears/headphones/Initialize()
	. = ..()

	sound_id = "[/obj/item/clothing/ears/headphones]_[sequential_id(/obj/item/clothing/ears/headphones)]"

/obj/item/clothing/ears/headphones/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/music_tape))
		var/obj/item/music_tape/D = W
		if(tape)
			to_chat(user, SPAN_NOTICE("There is already \a [tape] inside."))
			return

		if(!user.drop(D, src))
			return
		tape = D
		to_chat(user, SPAN_NOTICE("You insert \a [D] into \the [src]."))
		update_icon()
		if(istype(tape, /obj/item/music_tape/random))
			tracks += tape.tracks
		else
			tracks += tape.track
		return

	return ..()

/obj/item/clothing/ears/headphones/on_update_icon()
	if(!playing && !tape)
		icon_state = "headphones_empty"
		item_state = "headphones_off"
	else if(!playing && tape)
		icon_state = "headphones_off"
		item_state = "headphones_off"
	else if(playing)
		icon_state = "headphones_on"
		item_state = "headphones_on"
	update_clothing_icon()

/obj/item/clothing/ears/headphones/equipped()
	StopPlaying()
	update_icon()
	return ..()

/obj/item/clothing/ears/headphones/dropped()
	StopPlaying()
	update_icon()
	return ..()

/obj/item/clothing/ears/headphones/proc/StopPlaying()
	playing = 0
	QDEL_NULL(sound_token)
	update_icon()
	var/mob/living/carbon/M = usr
	M.remove_a_modifier_of_type(/datum/modifier/trait/headphones_volume)

/obj/item/clothing/ears/headphones/proc/StartPlaying()
	if(!tape)
		to_chat(usr, SPAN_NOTICE("There is no tape in \the [src]!"))
	else
		StopPlaying()
		current_track = tracks[index]
		sound_token = GLOB.sound_player.PlayLoopingSound(usr, sound_id, current_track.GetTrack(), volume = volume, range = 0, falloff = 3, prefer_mute = TRUE, preference = /datum/client_preference/play_jukeboxes, streaming = TRUE)
		playing = 1
		DeafFromMusic()
		update_icon()

/obj/item/clothing/ears/headphones/verb/on_off()
	set name = "Start/Stop"
	set category = "Object"

	if(playing)
		StopPlaying()
	else
		StartPlaying()

/obj/item/clothing/ears/headphones/proc/DeafFromMusic()
	if(!playing)
		return
	var/mob/living/carbon/M = usr
	M.add_modifier(/datum/modifier/trait/headphones_volume)
	var/datum/modifier/trait/headphones_volume/headphones_volume = locate(/datum/modifier/trait/headphones_volume) in M.modifiers

	if(volume < 55)
		headphones_volume?.volume_status = LOW_VOLUME //We all hear
		ear_protection = 0.0
	if(volume >= 55 && volume < 80)
		headphones_volume?.volume_status = MID_VOLUME //Sometimes we don't hear something
		ear_protection = 0.0
	else if(volume >= 80)
		headphones_volume?.volume_status = HIGH_VOLUME //We only hear music
		ear_protection = 0.5

/obj/item/clothing/ears/headphones/verb/set_volume()
	set name = "Set Volume"
	set category = "Object"

	volume = input("Select the volume") as null|num

	if(playing)
		sound_token.SetVolume(volume)
		DeafFromMusic()

/obj/item/clothing/ears/headphones/verb/next()
	set name = "Next track"
	set category = "Object"

	if(index == length(tracks))
		index = 1
	else
		index += 1

	StopPlaying()
	StartPlaying()

/obj/item/clothing/ears/headphones/verb/previous()
	set name = "Previous track"
	set category = "Object"

	if(index <= 1)
		index = length(tracks)
	else
		index -= 1

	StopPlaying()
	StartPlaying()

/obj/item/clothing/ears/headphones/verb/eject()
	set name = "Eject Tape"
	set category = "Object"

	if(!tape)
		to_chat(usr, SPAN_NOTICE("There is no tape in \the [src]!"))
	else
		StopPlaying()
		current_track = null
		tracks = list()

		usr.pick_or_drop(tape, loc)

		to_chat(usr, SPAN_NOTICE("You eject \a [tape] from \the [src]."))
		tape = null
		update_icon()
