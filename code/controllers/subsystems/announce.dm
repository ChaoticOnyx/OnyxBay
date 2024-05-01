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

/datum/controller/subsystem/announce/proc/announcer_by_type(type)
	for(var/datum/announcer/A in announcers)
		if(A.type == type)
			return A

	return null

/datum/controller/subsystem/announce/proc/announcer_by_pref(pref)
	var/datum/announcer/A = null

	if(pref == GLOB.PREF_ANNOUNCER_DEFAULT)
		A = announcer_by_type(DEFAULT_ANNOUNCER)
	else if(pref == GLOB.PREF_ANNOUNCER_VGSTATION)
		A = announcer_by_type(/datum/announcer/vgstation)
	else if(pref == GLOB.PREF_ANNOUNCER_BAYSTATION12)
		A = announcer_by_type(/datum/announcer/baystation12)
	else if(pref == GLOB.PREF_ANNOUNCER_BAYSTATION12_TORCH)
		A = announcer_by_type(/datum/announcer/baystation12_torch)
	else if(pref == GLOB.PREF_ANNOUNCER_TGSTATION)
		A = announcer_by_type(/datum/announcer/tgstation)

	ASSERT(!isnull(A))

	return A

/// player - mob or a client
/datum/controller/subsystem/announce/proc/get_announcer(player)
	var/client/C = player

	if(ismob(player))
		var/mob/M = player
		C = M.client

	ASSERT(!isnull(C) && istype(C))

	var/announcer_pref = C.get_preference_value(/datum/client_preference/announcer)
	var/datum/announcer/A = announcer_by_pref(announcer_pref)

	if(!is_announcer_available(player, A))
		return announcer_by_type(DEFAULT_ANNOUNCER)
	else
		return A

/// player - mob or a client
/// announcer - type, preference value or an instance.
/datum/controller/subsystem/announce/proc/is_announcer_available(player, announcer)
	var/client/C = player
	var/mob/M = player

	if(istype(M))
		C = M.client

	ASSERT(!isnull(C) && istype(C))

	var/datum/announcer/A = announcer

	if(ispath(announcer))
		A = announcer_by_type(announcer)
	else if(istext(announcer))
		A = announcer_by_pref(announcer)

	ASSERT(!isnull(A) && istype(A))

	return C.donator_info.patreon_tier_available(A.required_tier)

/datum/controller/subsystem/announce/proc/play_announce(
		announce_type, text_override = null, title_override = null, sender_override = null,
		sound_override = null, do_newscast = TRUE, msg_sanitized = FALSE,
		zlevels = GLOB.using_map.get_levels_with_trait(ZTRAIT_CONTACT))
	var/datum/announce/A = announces[announce_type]

	ASSERT(A != null)

	var/text = text_override || A.text
	var/title = title_override || A.title
	var/sender = sender_override || A.sender

	__announce(announce_type, text, title, sender, sound_override, msg_sanitized, do_newscast, zlevels)

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
	GLOB.global_announcer.autosay("[name], [rank], [join_message].", "Arrivals Announcement Computer", frequency)

/datum/controller/subsystem/announce/proc/__announce(announce_type, text, title, sender, sound_override, msg_sanitized, do_newscast, zlevels)
	var/message = null

	ASSERT(text && title)

	if(!msg_sanitized)
		text = sanitize(text, extra = 0)

	title = sanitize(title)
	message = __form_message(text, title, sender)

	for(var/mob/M in GLOB.player_list)
		var/client/C = M.client

		if(!C || !should_recieve_announce(M, zlevels))
			continue

		M.playsound_local(M.loc, pick('sound/signals/anounce1.ogg', 'sound/signals/anounce2.ogg', 'sound/signals/anounce3.ogg'), 75)

		var/datum/announcer/A = get_announcer(M)
		var/sound = sound_override || A.sounds[announce_type]

		if(sound)
			spawn(2)
				M.playsound_local(M.loc, sound, 75)

		to_chat(M, message)

	if(do_newscast)
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
