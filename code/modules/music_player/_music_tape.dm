// Music tape code :3
/obj/item/music_tape
	name = "tape"
	desc = "Magnetic tape adapted to outdated but proven music formats such as ogg, midi and module files."
	icon = 'icons/obj/device.dmi'
	icon_state = "tape_white"
	item_state = "analyzer"
	w_class = ITEM_SIZE_TINY
	force = 1
	throwforce = 0

	matter = list(MATERIAL_PLASTIC = 20, MATERIAL_STEEL = 5, MATERIAL_GLASS= 5)

	var/random_color = TRUE
	var/ruined = 0

	var/datum/track/track

	var/list/datum/track/tracks
	var/uploader_ckey

<<<<<<< HEAD
	// Fuck those errors (code\game\machinery\jukebox.dm:209:error: tape.tracks: undefined var)
	var/list/datum/track/tracks
=======
>>>>>>> b59c14728c86b38eceddfbaebb18b39fb1d40204

/obj/item/music_tape/Initialize()
	. = ..()
	if(random_color)
		icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"

/obj/item/music_tape/update_icon()
	overlays.Cut()
	if(ruined)
		overlays += "ribbonoverlay"

/obj/item/music_tape/examine(mob/user)
	. = ..()
	if(track?.title)
		. += "\n[SPAN_NOTICE("It's labeled as \"[track.title]\".")]"

/obj/item/music_tape/attack_self(mob/user)
	if(!ruined)
		if(!do_after(user, 15, target = src) || ruined)
			return
		to_chat(user, SPAN_NOTICE("You pull out all the tape!"))
		ruin()

/obj/item/music_tape/attackby(obj/item/I, mob/user, params)
	if(ruined && (isScrewdriver(I) || istype(I, /obj/item/pen)))
		to_chat(user, SPAN_NOTICE("You start winding \the [src] back in..."))
		if(do_after(user, 120, target = src))
			to_chat(user, SPAN_NOTICE("You wound \the [src] back in."))
			fix()
		return

	if(istype(I, /obj/item/pen))
		if(loc == user && !user.incapacitated())
			var/new_name = input(user, "What would you like to label \the [src]?", "\improper [src] labeling", name) as null|text
			if(isnull(new_name) || new_name == name) return

			new_name = sanitizeSafe(new_name)

			if(new_name)
				to_chat(user, SPAN_NOTICE("You label \the [src] '[new_name]'."))
				track.title = "tape - \"[new_name]\""
				SetName("tape - \"[new_name]\"")
			else
				to_chat(user, SPAN_NOTICE("You scratch off the label."))
				track.title = "unknown"
				SetName("tape")
		return
	..()

/obj/item/music_tape/fire_act()
	ruin()

/obj/item/music_tape/proc/CanPlay()
	if(!track)
		return FALSE

	if(ruined)
		return FALSE

	return TRUE

/obj/item/music_tape/proc/ruin()
	ruined = TRUE
	update_icon()

/obj/item/music_tape/proc/fix()
	ruined = FALSE
	update_icon()

// Random music tapes for jukeboxes with multiple tracks
/obj/item/music_tape/random
<<<<<<< HEAD
	name = "random tape"
	desc = "Magnetic tape adapted to outdated but proven music formats such as ogg, midi and module files."
	icon = 'icons/obj/device.dmi'
	icon_state = "tape_white"
	item_state = "analyzer"
	w_class = ITEM_SIZE_TINY
	force = 1
	throwforce = 0

	matter = list(MATERIAL_PLASTIC = 20, MATERIAL_STEEL = 5, MATERIAL_GLASS= 5)

	random_color = FALSE

	//var/list/datum/track/tracks
=======
	name = "Random tape"
	random_color = FALSE
>>>>>>> b59c14728c86b38eceddfbaebb18b39fb1d40204
	var/list/tracklist

/obj/item/music_tape/random/Initialize()
	. = ..()
	tracks = setup_music_tracks(track, tracklist)

<<<<<<< HEAD
/obj/item/music_tape/random/proc/setup_music_tracks(list/tracks, list/globtracks, numtoadd)
	. = list()
	for(var/i=1 to numtoadd)
=======
/obj/item/music_tape/random/proc/setup_music_tracks(list/tracks, list/globtracks)
	. = list()
	for(var/i=1 to 5)
>>>>>>> b59c14728c86b38eceddfbaebb18b39fb1d40204
		var/track_name = pick(globtracks)
		. += new /datum/track(track_name, globtracks[track_name])
	. = uniquelist(.)
