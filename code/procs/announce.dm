/var/datum/announcement/priority/priority_announcement = new(do_log = 0)
/var/datum/announcement/priority/command/command_announcement = new(do_log = 0, do_newscast = 1)
/var/datum/announcement/minor/minor_announcement = new(new_sound = 'sound/AI/commandreport.ogg',)

/datum/announcement
	var/title = "Attention"
	var/announcer = ""
	var/log = 0
	var/sound
	var/newscast = 0
	var/channel_name = "Announcements"
	var/announcement_type = "Announcement"

/datum/announcement/priority
	title = "Priority Announcement"
	announcement_type = "Priority Announcement"

/datum/announcement/priority/security
	title = "Security Announcement"
	announcement_type = "Security Announcement"

/datum/announcement/New(do_log = 0, new_sound = null, do_newscast = 0)
	sound = new_sound
	log = do_log
	newscast = do_newscast

/datum/announcement/priority/command/New(do_log = 1, new_sound = 'sound/misc/notice2.ogg', do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "[command_name()] Update"
	announcement_type = "[command_name()] Update"

/datum/announcement/proc/Announce(message as text, new_title = "", new_sound = sound, do_newscast = newscast, msg_sanitized = 0, zlevels = GLOB.using_map.contact_levels)
	if(!message)
		return
	var/message_title = new_title ? new_title : title

	if(!msg_sanitized)
		message = sanitize(message, extra = 0)
	message_title = sanitize(message_title)

	var/msg = FormMessage(message, message_title)
	for(var/mob/M in GLOB.player_list)
		if(should_recieve_announce(M, zlevels))
			M.playsound_local(M.loc, pick('sound/signals/anounce1.ogg', 'sound/signals/anounce2.ogg', 'sound/signals/anounce3.ogg'), 75)

			spawn (2)
				if(new_sound)
					M.playsound_local(M.loc, new_sound, 75)

			to_chat(M, msg)

	if(do_newscast)
		NewsCast(message, message_title)

	if(log)
		log_game("[key_name(usr)] has made \a [announcement_type]: [message_title] - [message] - [announcer]", notify_admin = TRUE)

proc/should_recieve_announce(mob/M, list/contact_levels)
	if (istype(M,/mob/new_player) || isdeaf(M))
		return 0
	if (M.z in (contact_levels | GLOB.using_map.admin_levels))
		return 1
	var/turf/loc_turf = get_turf(M.loc) // for mobs in lockers, sleepers, etc.
	if (!loc_turf)
		return 0
	if (loc_turf.z in (contact_levels | GLOB.using_map.admin_levels))
		return 1
	return 0

datum/announcement/proc/FormMessage(message as text, message_title as text)
	. = "<h2 class='alert'>[message_title]</h2>"
	. += "<br><span class='alert'>[message]</span>"
	if (announcer)
		. += "<br><span class='alert'> -[html_encode(announcer)]</span>"

datum/announcement/minor/FormMessage(message as text, message_title as text)
	. = "<b>[message]</b>"

datum/announcement/priority/FormMessage(message as text, message_title as text)
	. = "<h1 class='alert'>[message_title]</h1>"
	. += "<br><span class='alert'>[message]</span>"
	if(announcer)
		. += "<br><span class='alert'> -[html_encode(announcer)]</span>"
	. += "<br>"

datum/announcement/priority/command/FormMessage(message as text, message_title as text)
	. = "<h1 class='alert'>[command_name()] Update</h1>"
	if (message_title)
		. += "<br><h2 class='alert'>[message_title]</h2>"

	. += "<br><span class='alert'>[message]</span><br>"
	. += "<br>"

datum/announcement/priority/security/FormMessage(message as text, message_title as text)
	. = "<font size=4 color='red'>[message_title]</font>"
	. += "<br><font color='red'>[message]</font>"

datum/announcement/proc/NewsCast(message as text, message_title as text)
	if(!newscast)
		return

	var/datum/news_announcement/news = new
	news.channel_name = channel_name
	news.author = announcer
	news.message = message
	news.message_type = announcement_type
	news.can_be_redacted = 0
	announce_newscaster_news(news)

/proc/GetNameAndAssignmentFromId(obj/item/weapon/card/id/I)
	// Format currently matches that of newscaster feeds: Registered Name (Assigned Rank)
	return I.assignment ? "[I.registered_name] ([I.assignment])" : I.registered_name

/proc/level_seven_announcement()
	GLOB.using_map.level_x_biohazard_announcement(7)

/proc/ion_storm_announcement()
	command_announcement.Announce("It has come to our attention that the [station_name()] passed through an ion storm.  Please monitor all electronic equipment for malfunctions.", "Anomaly Alert")

/proc/AnnounceArrival(name, datum/job/job, var/datum/spawnpoint/spawnpoint = null, arrival_sound_volume = 75, captain_sound_volume = 20)
	if (GAME_STATE != RUNLEVEL_GAME)
		return

	var/rank = job.title

	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/signals/arrival1.ogg', arrival_sound_volume)

	if(rank == "AI")
		AnnounceArrivalSimple(name, rank, "has been downloaded to the empty core in AI Core", "Common")
		return

	if(rank in list("Cyborg", "Android", "Robot"))
		AnnounceArrivalSimple(name, rank, "A new [rank] has arrived", "Common")
		return

	if(rank == "Captain")
		AnnounceArrivalCaptain(name, captain_sound_volume)

	AnnounceArrivalSimple(name, rank, spawnpoint.msg, "Common")

	var/announce_freq = get_announcement_frequency(job)
	if("Common" != announce_freq)
		AnnounceArrivalSimple(name, rank, spawnpoint.msg, announce_freq)

/proc/get_announcement_computer(announcer = "Arrivals Announcement Computer")
	if(ai_list.len)
		var/list/mob/living/silicon/ai/valid_AIs = list()
		for(var/mob/living/silicon/ai/AI in ai_list)
			if(AI.stat != DEAD)
				valid_AIs.Add(AI)
		announcer = pick(valid_AIs)
	return announcer

/proc/AnnounceArrivalSimple(name, rank = "visitor", join_message = "has arrived on the [station_name()]", frequency)
	GLOB.global_announcer.autosay("[name], [rank], [join_message].", get_announcement_computer(), frequency)

/proc/AnnounceArrivalCaptain(name, captain_sound_volume)
	var/sound/announce_sound = sound('sound/misc/boatswain.ogg', volume=captain_sound_volume)
	captain_announcement.Announce("All hands, Captain [name] on deck!", new_sound=announce_sound)

/proc/get_announcement_frequency(datum/job/job)
	// During red alert all jobs are announced on main frequency.
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	if (security_state.current_security_level_is_same_or_higher_than(security_state.high_security_level))
		return "Common"

	if(job.department_flag & (COM | CIV | MSC))
		return "Common"
	if(job.department_flag & SUP)
		return "Supply"
	if(job.department_flag & SPT)
		return "Command"
	if(job.department_flag & SEC)
		return "Security"
	if(job.department_flag & ENG)
		return "Engineering"
	if(job.department_flag & MED)
		return "Medical"
	if(job.department_flag & SCI)
		return "Science"
	if(job.department_flag & SRV)
		return "Service"
	if(job.department_flag & EXP)
		return "Exploration"
	return "Common"
