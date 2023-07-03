SUBSYSTEM_DEF(announce)
	name = "Announce"
	init_order = SS_INIT_ANNOUNCERS
	flags = SS_NO_FIRE

	var/list/announcers = list()
	var/list/announces = list()

/datum/controller/subsystem/announce/Initialize()
	for(var/type in subtypesof(/datum/announcer))
		announcers += new type()

	for(var/type in subtypesof(/datum/announce))
		announces[type] = new type()

	. = ..()

/datum/controller/subsystem/announce/proc/play_announce(
		announce_type, text_override = null, title_override = null, sender_override = null,
		sound_override = null, do_newscast = TRUE, msg_sanitized = FALSE,
		zlevels = GLOB.using_map.get_levels_with_trait(ZTRAIT_CONTACT))
	var/datum/announce/A = announces[announce_type]

	ASSERT(A != null)

	var/text = text_override || A.text
	var/title = title_override || A.title
	var/sender = sender_override || A.sender

	// TODO: ADD PREFERENCE CHECK HERE
	var/datum/announcer/AN = announcers[1]

	ASSERT(AN != null)

	var/sound_path = AN.sounds[A.type] || A.sound

	__announce(text, title, sender, sound_path, msg_sanitized, do_newscast, zlevels)

/datum/controller/subsystem/announce/proc/play_station_announce(
		announce_type, text_override = null, title_override = null, sender_override = null,
		sound_override = null, do_newscast = TRUE, msg_sanitized = FALSE)
	var/list/zlevels = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)
	play_announce(announce_type, text_override, title_override, sender_override, sound_override, do_newscast, msg_sanitized, zlevels)

/datum/controller/subsystem/announce/proc/announce_arrival(name, datum/job/job, datum/spawnpoint/spawnpoint = null, arrival_sound_volume = 75)
	if (GAME_STATE != RUNLEVEL_GAME)
		return

	var/rank = job.title

	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/signals/arrival1.ogg', arrival_sound_volume)

	if(rank == "AI")
		__announce_arrival_simple(name, rank, "has been downloaded to the empty core in AI Core", "Common")
		return

	if(rank in list("Cyborg", "Android", "Robot"))
		__announce_arrival_simple(name, rank, "A new [rank] has arrived", "Common")
		return

	if(rank == "Captain")
		play_station_announce(/datum/announce/captain_arrival, "All hands, Captain [name] on deck!")

	__announce_arrival_simple(name, rank, spawnpoint.msg, "Common")

	var/announce_freq = get_announcement_frequency(job)

	if("Common" != announce_freq)
		__announce_arrival_simple(name, rank, spawnpoint.msg, announce_freq)

/datum/controller/subsystem/announce/proc/__announce_arrival_simple(name, rank = "visitor", join_message = "has arrived on the [station_name()]", frequency)
	GLOB.global_announcer.autosay("[name], [rank], [join_message].", get_announcement_computer(), frequency)

/datum/controller/subsystem/announce/proc/__announce(text, title, sender, sound, msg_sanitized, do_newscast, zlevels)
	var/has_text = (text && title)
	var/message = null

	ASSERT(has_text || sound)

	if(has_text)
		if(!msg_sanitized)
			text = sanitize(text, extra = 0)
		title = sanitize(title)

		message = __form_message(text, title, sender)
	for(var/mob/M in GLOB.player_list)
		if(should_recieve_announce(M, zlevels))
			M.playsound_local(M.loc, pick('sound/signals/anounce1.ogg', 'sound/signals/anounce2.ogg', 'sound/signals/anounce3.ogg'), 75)

			if(sound)
				spawn(2)
					M.playsound_local(M.loc, sound, 75)

			if(has_text)
				to_chat(M, message)

	if(has_text && do_newscast)
		__newscast(text, title)

	var/log_msg = "[key_name(usr)] has made an announce: [title] - [text] - [sender]"
	log_game(log_msg, notify_admin = TRUE)
	log_story("GAME", log_msg)

/datum/controller/subsystem/announce/proc/__newscast(text, title, sender)
	var/datum/news_announcement/news = new
	news.channel_name = "Announcements"
	news.author = sender
	news.message = text
	news.message_type = "Announcement"
	news.can_be_redacted = FALSE
	announce_newscaster_news(news)

/datum/controller/subsystem/announce/proc/__form_message(text, title, sender)
	text = replacetext(text, "%STATION_NAME%", station_name())
	title = replacetext(title, "%STATION_NAME%", station_name())

	. = "<h2 class='alert'>[title]</h2>"
	. += "<br><span class='alert'>[text]</span>"
	if (sender)
		. += "<br><span class='alert'> -[html_encode(sender)]</span>"
