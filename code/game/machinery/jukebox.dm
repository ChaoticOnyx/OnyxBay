//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32
#define RICKROLL_PROBABILITY 1

/datum/track
	var/title
	var/sound

/datum/track/New(title, audio)
	src.title = title
	src.sound = audio

/datum/track/proc/GetTrack()
	if(ispath(sound, /lobby_music))
		var/lobby_music/music_track = decls_repository.get_decl(sound)
		return music_track.song
	return sound // Allows admins to continue their adminbus simply by overriding the track var

/obj/machinery/media/jukebox
	name = "space jukebox"
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox-nopower"
	var/state_base = "jukebox"
	anchored = 1
	density = 1
	power_channel = EQUIP
	idle_power_usage = 10
	active_power_usage = 100
	clicksound = 'sound/machines/buttonbeep.ogg'

	var/playing = 0
	var/volume = 20

	var/sound_id
	var/datum/sound_token/sound_token

	var/obj/item/music_tape/tape

	var/datum/track/current_track
	var/list/datum/track/tracks

	var/datum/track/rickroll = new("Never Gonna Give You Up", 'sound/music/rickroll.ogg')
	var/rickrolling = FALSE
	var/spamcheck = FALSE

/obj/machinery/media/jukebox/Initialize()
	. = ..()
	tracks = setup_music_tracks(tracks)
	update_icon()
	sound_id = "[/obj/machinery/media/jukebox]_[sequential_id(/obj/machinery/media/jukebox)]"

/obj/machinery/media/jukebox/Destroy()
	StopPlaying()
	QDEL_NULL_LIST(tracks)
	current_track = null
	QDEL_NULL(tape)
	. = ..()

/obj/machinery/media/jukebox/powered()
	return anchored && ..()

/obj/machinery/media/jukebox/power_change()
	. = ..()
	if(stat & (NOPOWER|BROKEN) && playing)
		StopPlaying()

/obj/machinery/media/jukebox/update_icon()
	overlays.Cut()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		if(stat & BROKEN)
			icon_state = "[state_base]-broken"
		else
			icon_state = "[state_base]-nopower"
		return
	icon_state = state_base
	if(playing)
		if(emagged)
			overlays += "[state_base]-emagged"
		else
			overlays += "[state_base]-running"

/obj/machinery/media/jukebox/interact(mob/user)
	if(!anchored)
		to_chat(usr, SPAN_WARNING("You must secure \the [src] first."))
		return

	if(stat & (NOPOWER|BROKEN))
		to_chat(usr, "\The [src] doesn't appear to function.")
		return

	if(rickrolling)
		to_chat(usr, "You notice a sinked button on a [src]")

	ui_interact(user)

/obj/machinery/media/jukebox/CanUseTopic(user, state)
	if(!anchored || inoperable())
		return STATUS_CLOSE
	return ..()

/obj/machinery/media/jukebox/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/juke_tracks = new
	for(var/datum/track/T in tracks)
		juke_tracks.Add(list(list("track"=T.title)))

	var/list/data = list(
		"current_track" = current_track != null ? current_track.title : "No track selected",
		"playing" = playing,
		"tracks" = juke_tracks,
		"volume" = volume,
		"tape" = tape
	)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "jukebox.tmpl", "Your Media Library", 340, 440)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/media/jukebox/OnTopic(mob/user, list/href_list, state)
	if (href_list["title"])
		if(!rickrolling)
			for(var/datum/track/T in tracks)
				if(T.title == href_list["title"])
					current_track = T
					StartPlaying()
					break

	if (href_list["stop"])
		if(!rickrolling)
			StopPlaying()

	if (href_list["play"])
		if(emagged)
			emag_play()
		else if(!current_track)
			to_chat(usr, "No track selected.")
		else
			if(!rickrolling)
				StartPlaying()

	if (href_list["volume"])
		AdjustVolume(text2num(href_list["volume"]))

	if(!spamcheck)
		spamcheck = TRUE
		spawn(30)
			spamcheck = FALSE

	return TOPIC_REFRESH

/obj/machinery/media/jukebox/proc/emag_play()
	playsound(loc, 'sound/items/AirHorn.ogg', 100, 1)
	for(var/mob/living/carbon/M in ohearers(6, src))
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				continue
		M.sleeping = 0
		M.stuttering += 20
		M.ear_deaf += 30
		M.Weaken(3)
		if(prob(30))
			M.Stun(10)
			M.Paralyse(4)
		else
			M.make_jittery(400)
	spawn(15)
		explode()

/obj/machinery/media/jukebox/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/media/jukebox/attack_hand(mob/user as mob)
	interact(user)

/obj/machinery/media/jukebox/proc/explode()
	walk_to(src, 0)
	src.visible_message(SPAN_DANGER("\the [src] blows apart!"), 1)

	explosion(get_turf(src), 0, 0, 1, rand(1,2), 1)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(loc)
	qdel(src)

/obj/machinery/media/jukebox/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W))
		add_fingerprint(user)
		wrench_floor_bolts(user, 0)
		power_change()
		return
	else if(istype(W, /obj/item/music_tape))
		var/obj/item/music_tape/D = W
		if(tape)
			to_chat(user, SPAN_NOTICE("There is already \a [tape] inside."))
			return

		if(D.ruined)
			to_chat(user, SPAN_WARNING("\The [D] is ruined, you can't use it."))
			return

		if(user.drop_item())
			visible_message(SPAN_NOTICE("[usr] insert \a [tape] into \the [src]."))
			D.forceMove(src)
			tape = D
			tracks += tape.track
			verbs += /obj/machinery/media/jukebox/verb/eject
		return
	return ..()

/obj/machinery/media/jukebox/emag_act(remaining_charges, mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
		emagged = 1
		StopPlaying()
		visible_message(SPAN_DANGER("\The [src] makes a fizzling sound."))
		update_icon()
		return 1

/obj/machinery/media/jukebox/proc/StopPlaying()
	playing = 0
	update_use_power(POWER_USE_IDLE)
	update_icon()
	QDEL_NULL(sound_token)


/obj/machinery/media/jukebox/proc/StartPlaying()
	StopPlaying()
	if(!current_track)
		return

	if(!spamcheck && prob(RICKROLL_PROBABILITY))
		lock_rickroll()
	// Jukeboxes cheat massively and actually don't share id. This is only done because it's music rather than ambient noise.
	sound_token = GLOB.sound_player.PlayLoopingSound(src, sound_id, current_track.GetTrack(), volume = volume, range = 7, falloff = 3, prefer_mute = TRUE, preference = /datum/client_preference/play_jukeboxes, streaming = TRUE)

	playing = 1
	update_use_power(POWER_USE_ACTIVE)
	update_icon()

/obj/machinery/media/jukebox/proc/AdjustVolume(new_volume)
	volume = Clamp(new_volume, 0, 50)
	if(sound_token)
		sound_token.SetVolume(volume)

/obj/machinery/media/jukebox/proc/lock_rickroll(duration = 150)
	if(rickrolling)
		return
	current_track = rickroll
	rickrolling = TRUE
	spawn(duration)
		rickrolling = FALSE

/obj/machinery/media/jukebox/verb/eject()
	set name = "Eject"
	set category = "Object"
	set src in oview(1)

	if(!CanPhysicallyInteract(usr))
		return

	if(tape)
		StopPlaying()
		current_track = null
		for(var/datum/track/T in tracks)
			if(T == tape.track)
				tracks -= T

		if(!usr.put_in_hands(tape))
			tape.dropInto(loc)

		tape = null
		visible_message(SPAN_NOTICE("[usr] eject \a [tape] from \the [src]."))
		verbs -= /obj/machinery/media/jukebox/verb/eject
