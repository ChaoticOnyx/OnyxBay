//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

datum/track
	var/title
	var/sound

datum/track/New(var/title_name, var/audio)
	title = title_name
	sound = audio

/obj/machinery/media/jukebox
	name = "space jukebox"
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox-nopower"
	var/state_base = "jukebox"
	anchored = 1
	density = 1
	power_channel = EQUIP
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	clicksound = 'sound/machines/buttonbeep.ogg'

	var/playing = 0
	var/volume = 20

	var/sound_id
	var/datum/sound_token/sound_token

	var/datum/track/current_track
	var/list/datum/track/tracks = list(
		new/datum/track("Beyond", 'sound/ambience/ambispace.ogg'),
		new/datum/track("Clouds of Fire", 'sound/music/clouds.s3m'),
		new/datum/track("D`Bert", 'sound/music/title2.ogg'),
		new/datum/track("D`Fort", 'sound/ambience/song_game.ogg'),
		new/datum/track("Floating", 'sound/music/main.ogg'),
		new/datum/track("Endless Space", 'sound/music/space.ogg'),
		new/datum/track("Part A", 'sound/misc/TestLoop1.ogg'),
		new/datum/track("Scratch", 'sound/music/title1.ogg'),
		new/datum/track("Trai`Tor", 'sound/music/traitor.ogg'),
		new/datum/track("Lone Digger", 'sound/music/lonedigger.ogg'),
		new/datum/track("Undead Man Walkin`", 'sound/music/undeadwalking.ogg'),
		new/datum/track("Space Asshole", 'sound/music/spaceasshole.ogg'),
		new/datum/track("Reaper&Blues", 'sound/music/reapernblues.ogg'),
		new/datum/track("Rum", 'sound/music/rum.ogg'),
		new/datum/track("Don`t Remember", 'sound/music/dontremember.ogg'),
		new/datum/track("Winter", 'sound/music/winter.ogg'),
		new/datum/track("Winter`s Starfall", 'sound/music/starfall.ogg'),
		new/datum/track("Avariya", 'sound/music/avariya.ogg'),
	)


/obj/machinery/media/jukebox/New()
	..()
	update_icon()
	sound_id = "[type]_[sequential_id(type)]"

/obj/machinery/media/jukebox/Destroy()
	StopPlaying()
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
		to_chat(usr, "<span class='warning'>You must secure \the [src] first.</span>")
		return

	if(stat & (NOPOWER|BROKEN))
		to_chat(usr, "\The [src] doesn't appear to function.")
		return

	tg_ui_interact(user)

/obj/machinery/media/jukebox/ui_status(mob/user, datum/ui_state/state)
	if(!anchored || inoperable())
		return UI_CLOSE
	return ..()

/obj/machinery/media/jukebox/tg_ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = tg_default_state)
	ui = tgui_process.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "jukebox", "RetroBox - Space Style", 340, 440, master_ui, state)
		ui.open()

/obj/machinery/media/jukebox/ui_data()
	var/list/juke_tracks = new
	for(var/datum/track/T in tracks)
		juke_tracks.Add(T.title)

	var/list/data = list(
		"current_track" = current_track != null ? current_track.title : "No track selected",
		"playing" = playing,
		"tracks" = juke_tracks,
		"volume" = volume
	)

	return data

/obj/machinery/media/jukebox/ui_act(action, params)
	if(..())
		return TRUE
	switch(action)
		if("change_track")
			for(var/datum/track/T in tracks)
				if(T.title == params["title"])
					current_track = T
					StartPlaying()
					break
			. = TRUE
		if("stop")
			StopPlaying()
			. = TRUE
		if("play")
			if(emagged)
				emag_play()
			else if(!current_track)
				to_chat(usr, "No track selected.")
			else
				StartPlaying()
			. = TRUE
		if("volume")
			AdjustVolume(text2num(params["level"]))
			. = TRUE

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

/obj/machinery/media/jukebox/attack_hand(var/mob/user as mob)
	interact(user)

/obj/machinery/media/jukebox/proc/explode()
	walk_to(src,0)
	src.visible_message("<span class='danger'>\the [src] blows apart!</span>", 1)

	explosion(src.loc, 0, 0, 1, rand(1,2), 1)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	qdel(src)

/obj/machinery/media/jukebox/attackby(obj/item/W as obj, mob/user as mob)
	var/paid = 0
	var/handled = 0
	if (istype(W, /obj/item/weapon/spacecash/bundle))
		var/obj/item/weapon/spacecash/bundle/cashmoney = W
		if(300> cashmoney.worth)
			// This is not a status display message, since it's something the character themselves is meant to see BEFORE putting the money in
			to_chat(usr, "\icon[cashmoney] <span class='warning'>That is not enough money. You need T300.</span>")
			paid = 0
			handled = 1
			return

		if(jobban_isbanned(user, "JUKEBOX"))
			to_chat(user, "<span class='notice'>Oopsie! Seems like you are blacklisted from NT Music Premium for bad taste. You can't download new tracks from NTNet.</span>")
			return

		visible_message("<span class='info'>\The [usr] inserts some cash into \the [src].</span>")
		cashmoney.worth -= 300

		if(cashmoney.worth <= 0)
			usr.drop_from_inventory(cashmoney)
			qdel(cashmoney)
		else
			cashmoney.update_icon()
		paid = 1
		handled = 1

		if(paid)
			to_chat(user, "<span class='notice'>You pay with \the [W] and \the [src] is now able to play your song.</span>")
			var/newtitle = input("Type a title of the new track", "Track title", "Track") as text
			var/sound/S = input("Select a sound", "Sound", 'sound/effects/ghost.ogg') as sound
			tracks += new/datum/track(newtitle, S)
			GLOB.nanomanager.update_uis(src)
			return
		else if(handled)
			GLOB.nanomanager.update_uis(src)
			return // don't smack that machine with your 2 thalers

	if (istype(W, /obj/item/weapon/spacecash))
		attack_hand(user)
		return
	else if(isWrench(W))
		add_fingerprint(user)
		wrench_floor_bolts(user, 0)
		power_change()
		return
	else if(istype(W, /obj/item/weapon/coin))
		to_chat(user, "<span class='notice'>You need some modern cash to use \the [src]. No coins, tallers only.</span>")
		return
	return ..()

/obj/machinery/media/jukebox/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		emagged = 1
		StopPlaying()
		visible_message("<span class='danger'>\The [src] makes a fizzling sound.</span>")
		update_icon()
		return 1

/obj/machinery/media/jukebox/proc/StopPlaying()
	playing = 0
	update_use_power(1)
	update_icon()
	QDEL_NULL(sound_token)


/obj/machinery/media/jukebox/proc/StartPlaying()
	StopPlaying()
	if(!current_track)
		return

	// Jukeboxes cheat massively and actually don't share id. This is only done because it's music rather than ambient noise.
	sound_token = GLOB.sound_player.PlayLoopingSound(src, sound_id, current_track.sound, volume = volume, range = 7, falloff = 3, prefer_mute = TRUE, preference = /datum/client_preference/play_jukeboxes)

	playing = 1
	update_use_power(2)
	update_icon()

/obj/machinery/media/jukebox/proc/AdjustVolume(var/new_volume)
	volume = Clamp(new_volume, 0, 50)
	if(sound_token)
		sound_token.SetVolume(volume)
