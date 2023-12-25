var/list/sounds_cache = list()

/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = 777)
	uploaded_sound.priority = 250

	sounds_cache += S

	if(alert("Do you ready?\nSong: [S]\nNow you can also play this sound using \"Play Server Sound\".", "Confirmation request" ,"Play", "Cancel") == "Cancel")
		return

	log_admin("[key_name(src)] played sound [S]", notify_admin = TRUE)
	for(var/mob/M in GLOB.player_list)
		if(M.get_preference_value(/datum/client_preference/play_admin_midis) == GLOB.PREF_YES)
			sound_to(M, uploaded_sound)

	feedback_add_details("admin_verb","PGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))	return

	log_admin("[key_name(src)] played a local sound [S]", location = src.mob, notify_admin = TRUE)
	playsound(src.mob, S, 50, 0, 0)
	feedback_add_details("admin_verb","PLS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_server_sound()
	set category = "Fun"
	set name = "Play Server Sound"

	if(!check_rights(R_SOUNDS))
		return

	var/list/sounds = getallfiles("sound/music/")
	sounds += sounds_cache

	var/melody = input("Select a sound from the server to play", "Server sound list") as null|anything in sounds
	if(!melody)
		return

	play_sound(melody)
	feedback_add_details("admin_verb","PSS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_web_sound()
	set category = "Admin.Fun"
	set name = "Play Internet Sound"
	if(!check_rights(R_SOUNDS))
		return

	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(src, span_boldwarning("Youtube-dl was not configured, action unavailable")) //Check config.txt for the INVOKE_YOUTUBEDL value
		return

	var/web_sound_input = input("Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound via youtube-dl") as text|null
	if(istext(web_sound_input))
		var/web_sound_url = ""
		var/stop_web_sounds = FALSE
		var/list/music_extra_data = list()
		if(length(web_sound_input))

			web_sound_input = trim(web_sound_input)
			if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
				to_chat(src, span_boldwarning("Non-http(s) URIs are not allowed."))
				to_chat(src, span_warning("For youtube-dl shortcuts like ytsearch: please use the appropriate full url from the website."))
				return
			var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
			var/list/output = world.shelleo("[ytdl] --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
			var/errorlevel = output[SHELLEO_ERRORLEVEL]
			var/stdout = output[SHELLEO_STDOUT]
			var/stderr = output[SHELLEO_STDERR]
			if(!errorlevel)
				var/list/data
				try
					data = json_decode(stdout)
				catch(var/exception/e)
					to_chat(src, span_boldwarning("Youtube-dl JSON parsing FAILED:"))
					to_chat(src, span_warning("[e]: [stdout]"))
					return

				if (data["url"])
					web_sound_url = data["url"]
					var/title = "[data["title"]]"
					var/webpage_url = title
					if (data["webpage_url"])
						webpage_url = "<a href=\"[data["webpage_url"]]\">[title]</a>"
					music_extra_data["start"] = data["start_time"]
					music_extra_data["end"] = data["end_time"]
					music_extra_data["link"] = data["webpage_url"]
					music_extra_data["title"] = data["title"]

					var/res = alert(usr, "Show the title of and link to this song to the players?\n[title]",, "No", "Yes", "Cancel")
					switch(res)
						if("Yes")
							to_chat(world, span_boldannounce("An admin played: [webpage_url]"))
						if("Cancel")
							return
					SSblackbox.record_feedback("nested tally", "played_url", 1, list("[ckey]", "[web_sound_input]"))
					log_admin("[key_name(src)] played web sound: [web_sound_input]")
					message_admins("[key_name(src)] played web sound: [web_sound_input]")
			else
				to_chat(src, span_boldwarning("Youtube-dl URL retrieval FAILED:"))
				to_chat(src, span_warning("[stderr]"))

		else //pressed ok with blank
			log_admin("[key_name(src)] stopped web sound")
			message_admins("[key_name(src)] stopped web sound")
			web_sound_url = null
			stop_web_sounds = TRUE

		if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
			to_chat(src, span_boldwarning("BLOCKED: Content URL not using http(s) protocol"))
			to_chat(src, span_warning("The media provider returned a content URL that isn't using the HTTP or HTTPS protocol"))
			return
		if(web_sound_url || stop_web_sounds)
			for(var/m in GLOB.player_list)
				var/mob/M = m
				var/client/C = M.client
				if(C.prefs.toggles & SOUND_MIDI)
					if(!stop_web_sounds)
						C.tgui_panel?.play_music(web_sound_url, music_extra_data)
					else
						C.tgui_panel?.stop_music()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Internet Sound")

/client/proc/manual_play_web_sound()
	set category = "Admin.Fun"
	set name = "Manual Play Internet Sound"
	if(!check_rights(R_SOUNDS))
		return

	var/web_sound_input = input("Enter content stream URL (must be a direct link)", "Play Internet Sound via direct URL") as text|null
	if(istext(web_sound_input))
		if(!length(web_sound_input))
			log_admin("[key_name(src)] stopped web sound")
			message_admins("[key_name(src)] stopped web sound")
			var/mob/M
			for(var/i in GLOB.player_list)
				M = i
				M?.client?.tgui_panel?.stop_music()
			return

		var/list/music_extra_data = list()
		web_sound_input = trim(web_sound_input)
		if(web_sound_input && (findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol)))
			to_chat(src, span_boldwarning("Non-http(s) URIs are not allowed."), confidential = TRUE)
			return

		var/list/explode = splittext(web_sound_input, "/") //if url=="https://fixthisshit.com/pogchamp.ogg"then title="pogchamp.ogg"
		var/title = "[explode[explode.len]]"

		if(!findtext(title, ".mp3") && !findtext(title, ".mp4")) // IE sucks.
			to_chat(src, span_warning("The format is not .mp3/.mp4, IE 8 and above can only support the .mp3/.mp4 format, the music might not play."), confidential = TRUE)

		if(length(title) > 50) //kev no.
			title = "Unknown.mp3"

		music_extra_data["title"] = title

		SSblackbox.record_feedback("nested tally", "played_url", 1, list("[ckey]", "[web_sound_input]"))
		log_admin("[key_name(src)] played web sound: [web_sound_input]")
		message_admins("[key_name(src)] played web sound: [web_sound_input]")

		for(var/m in GLOB.player_list)
			var/mob/M = m
			var/client/C = M.client
			if(C.prefs.toggles & SOUND_MIDI)
				C.tgui_panel?.play_music(web_sound_input, music_extra_data)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Manual Play Internet Sound")
