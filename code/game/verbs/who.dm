
/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/lines = list()

//for admins
	var/living = 0 //Currently alive and in the round (possibly unconscious, but not officially dead)
	var/dead = 0 //Have been in the round but are now deceased
	var/observers = 0 //Have never been in the round (thus observing)
	var/lobby = 0 //Are currently in the lobby
	var/living_antags = 0 //Are antagonists, and currently alive
	var/dead_antags = 0 //Are antagonists, and have finally met their match
	var/rights = check_rights(R_INVESTIGATE, FALSE)
	var/preference = try_get_preference_value("ADVANCED_WHO") == GLOB.PREF_YES

	if(rights && preference)
		for(var/client/C in GLOB.clients)
			var/entry
			if(C.mob)
				entry = "\t[C.key]"
			else
				entry = "\t[C.key] - <font color='red'><i>HAS NO MOB</i></font> (<A HREF='?_src_=holder;adminmoreinfo=\ref[C]'>?</A>)"
				lines += entry
				continue

			if(isghost(C.mob))
				entry += " - <font color='gray'><b>Observing</b></font> as <b>[C.mob.real_name]</b>"
			else if(isliving(C.mob))
				entry += " - <font color='green'><b>Playing</b></font> as <b>[C.mob.real_name]</b>"

			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <font color='#404040'><b>Unconscious</b></font>"
					living++
				if(DEAD)
					if(isghost(C.mob))
						var/mob/observer/ghost/O = C.mob
						if(O.started_as_observer)
							observers++
						else
							entry += " - <b>DEAD</b>"
							dead++
					else if(isnewplayer(C.mob))
						entry += " - <font color='#006400'><b>In lobby</b></font>"
						lobby++
					else
						entry += " - <b>DEAD</b>"
						dead++
				else
					living++

			if(C.mob.mind?.assigned_role)
				entry += " - [C.mob.mind.assigned_role]"

			if(isnum(C.player_age))
				var/age = C.player_age

				if(age <= 1)
					age = "<font color='#ff0000'><b>[age]</b></font>"
				else if(age < 10)
					age = "<font color='#ff8c00'><b>[age]</b></font>"

				entry += " - [age]"

			if(C.mob.mind?.special_role)
				entry += " - <b><font color='red'>[C.mob.mind.special_role]</font></b>"
				if(!C.mob.mind.current || C.mob.mind.current?.stat == DEAD)
					dead_antags++
				else
					living_antags++

			if(C.is_afk())
				entry += " - <b>AFK: [C.inactivity2text()]</b>"

			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"

			lines += entry
	else if(rights)
		for(var/client/C in GLOB.clients)
			if(C.mob)
				lines += "\t[C.key] (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>) "
			else
				lines += "\t[C.key] - <font color='red'><i>HAS NO MOB</i></font> (<A HREF='?_src_=holder;adminmoreinfo=\ref[C]'>?</A>)"
	else
		for(var/client/C in GLOB.clients)
			if(!C.is_stealthed())
				lines += C.key

	for(var/line in sortList(lines))
		msg += "[line]\n"

	if(rights && preference)
		msg += "<b><span class='notice'>Total Living: [living]</span> | Total Dead: [dead] | <span style='color:gray'>Observing: [observers]</span> | <font color = '#006400'>In Lobby: [lobby]</font> | <font color = 'purple'>Living Antags: [living_antags]</font> | <font color = 'red'>Dead Antags: [dead_antags]</font></b>\n"
		msg += "<b>Total Players: [length(lines)]</b>\n"
	else
		msg += "<b>Total Players: [length(lines)]</b>"
	to_chat(src, msg)

/client/verb/staffwho()
	set category = "Admin"
	set name = "Adminwho"

	var/list/msg = list()
	var/active_staff = 0
	var/total_staff = 0
	var/can_investigate = check_rights(R_INVESTIGATE, 0)

	for(var/client/C in GLOB.admins)
		var/line = list()
		if(!can_investigate && C.is_stealthed())
			continue
		total_staff++
		if(check_rights(R_ADMIN,0,C))
			line += "\t[C] is \an <b>["\improper[C.holder.rank]"]</b>"
		else
			line += "\t[C] is \an ["\improper[C.holder.rank]"]"
		if(!C.is_afk())
			active_staff++
		if(can_investigate)
			if(C.is_afk())
				line += " (AFK - [C.inactivity2text()])"
			if(isghost(C.mob))
				line += " - Observing"
			else if(istype(C.mob,/mob/new_player))
				line += " - Lobby"
			else
				line += " - Playing"
			if(C.is_stealthed())
				line += " (Stealthed)"
		line = jointext(line,null)
		if(check_rights(R_ADMIN,0,C))
			msg.Insert(1, line)
		else
			msg += line

	if(config.external.admin_irc)
		to_chat(src, "<span class='info'>Adminhelps are also sent to IRC. If no admins are available in game try anyway and an admin on IRC may see it and respond.</span>")
	to_chat(src, "<b>Current Staff ([active_staff]/[total_staff]):</b>")
	to_chat(src, jointext(msg,"\n"))
