/proc/load_sql_config(filename)  // -- TLE
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if ("address")
				sqladdress = value
			if ("port")
				sqlport = value
			if ("database")
				sqldb = value
			if ("login")
				sqllogin = value
			if ("password")
				sqlpass = value
			if ("feedback_database")
				sql_feedback_db = value
			if ("feedback_login")
				sql_feedback_login = value
			if ("feedback_password")
				sql_feedback_pass = value
			if ("enable_stat_tracking")
				sqllogging = TRUE
			if ("donation_address")
				sqldonaddress = value
			if ("donation_port")
				sqldonport = value
			if ("donation_database")
				sqldondb = value
			if ("donation_login")
				sqldonlogin = value
			if ("donation_password")
				sqldonpass = value
			else
				log_misc("Unknown setting in configuration: '[name]'")

/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	for (var/game_mode in gamemode_cache)
		var/datum/game_mode/M = gamemode_cache[game_mode]
		if (M?.config_tag == mode_name)
			return M

/datum/configuration/proc/load_event(filename)
	var/event_info = file2text(filename)

	if (event_info)
		custom_event_msg = event_info
