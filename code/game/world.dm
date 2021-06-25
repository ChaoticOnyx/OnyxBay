#define REBOOT_HARD 1
#define REBOOT_REALLY_HARD 2

var/server_name = "OnyxBay"

/var/game_id = null
/hook/global_init/proc/generate_gameid()
	if(game_id != null)
		return
	game_id = ""

	var/list/c = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	var/l = c.len

	var/t = world.timeofday
	for(var/_ = 1 to 4)
		game_id = "[c[(t % l) + 1]][game_id]"
		t = round(t / l)
	game_id = "-[game_id]"
	t = round(world.realtime / (10 * 60 * 60 * 24))
	for(var/_ = 1 to 3)
		game_id = "[c[(t % l) + 1]][game_id]"
		t = round(t / l)
	return 1

// Find mobs matching a given string
//
// search_string: the string to search for, in params format; for example, "some_key;mob_name"
// restrict_type: A mob type to restrict the search to, or null to not restrict
//
// Partial matches will be found, but exact matches will be preferred by the search
//
// Returns: A possibly-empty list of the strongest matches
/proc/text_find_mobs(search_string, restrict_type = null)
	var/list/search = params2list(search_string)
	var/list/ckeysearch = list()
	for(var/text in search)
		ckeysearch += ckey(text)

	var/list/match = list()

	for(var/mob/M in SSmobs.mob_list)
		if(restrict_type && !istype(M, restrict_type))
			continue
		var/strings = list(M.name, M.ckey)
		if(M.mind)
			strings += M.mind.assigned_role
			strings += M.mind.special_role
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species)
				strings += H.species.name
		for(var/text in strings)
			if(ckey(text) in ckeysearch)
				match[M] += 10 // an exact match is far better than a partial one
			else
				for(var/searchstr in search)
					if(findtext(text, searchstr))
						match[M] += 1

	var/maxstrength = 0
	for(var/mob/M in match)
		maxstrength = max(match[M], maxstrength)
	for(var/mob/M in match)
		if(match[M] < maxstrength)
			match -= M

	return match

#define RECOMMENDED_VERSION 511
/world/New()
	SetupLogs()

	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently

	if(byond_version < RECOMMENDED_VERSION)
		to_world_log("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")

	load_configuration()

	if(config.server_port)
		var/port = OpenPort(config.server_port)
		to_world_log(port ? "Changed port to [port]" : "Failed to change port")

	//set window title
	if(config.subserver_name)
		var/subserver_name = uppertext(copytext(config.subserver_name, 1, 2)) + copytext(config.subserver_name, 2)
		name = "[server_name]: [subserver_name] - [GLOB.using_map.full_name]"
	else
		name = "[server_name] - [GLOB.using_map.full_name]"

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	watchlist = new /datum/watchlist

	var/list/lobby_music_tracks = subtypesof(/lobby_music)
	var/lobby_music_type = /lobby_music
	if(lobby_music_tracks.len)
		lobby_music_type = pick(lobby_music_tracks)
	GLOB.lobby_music = new lobby_music_type()

	callHook("startup")
	//Emergency Fix
	load_mods()
	//end-emergency fix

	. = ..()

#ifdef UNIT_TEST
	log_unit_test("Unit Tests Enabled. This will destroy the world when testing is complete.")
	load_unit_test_changes()
#endif
	Master.Initialize(10, FALSE)

	webhook_send_roundstatus("lobby", "[config.server_id]")

#undef RECOMMENDED_VERSION

var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	log_href("\"[T]\", from:[addr], master:[master][log_end]")

	var/input[] = params2list(T)
	var/key_valid = config.comms_password && input["key"] == config.comms_password

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in GLOB.player_list)
			if(M.client)
				n++
		return n

	else if (copytext(T,1,7) == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = PUBLIC_GAME_MODE
		s["respawn"] = config.abandon_allowed
		s["enter"] = config.enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null

		// This is dumb, but spacestation13.com's banners break if player count isn't the 8th field of the reply, so... this has to go here.
		s["players"] = 0
		s["stationtime"] = stationtime2text()
		s["roundduration"] = roundduration2text()
		s["map"] = GLOB.using_map.full_name

		var/active = 0
		var/list/players = list()
		var/list/admins = list()
		var/legacy = input["status"] != "2"
		for(var/client/C in GLOB.clients)
			if(C.holder)
				if(C.is_stealthed())
					continue	//so stealthmins aren't revealed by the hub
				admins[C.key] = C.holder.rank
			if(legacy)
				s["player[players.len]"] = C.key
			players += C.key
			if(istype(C.mob, /mob/living))
				active++

		s["players"] = players.len
		s["admins"] = admins.len
		if(!legacy)
			s["playerlist"] = list2params(players)
			s["adminlist"] = list2params(admins)
			s["active_players"] = active

		return list2params(s)

	else if(T == "manifest")
		var/list/positions = list()
		var/list/nano_crew_manifest = nano_crew_manifest()
		// We rebuild the list in the format external tools expect
		for(var/dept in nano_crew_manifest)
			var/list/dept_list = nano_crew_manifest[dept]
			if(dept_list.len > 0)
				positions[dept] = list()
				for(var/list/person in dept_list)
					positions[dept][person["name"]] = person["rank"]

		for(var/k in positions)
			positions[k] = list2params(positions[k]) // converts positions["heads"] = list("Bob"="Captain", "Bill"="CMO") into positions["heads"] = "Bob=Captain&Bill=CMO"

		return list2params(positions)

	else if(T == "revision")
		var/list/L = list()
		L["gameid"] = game_id
		L["dm_version"] = DM_VERSION // DreamMaker version compiled in
		L["dd_version"] = world.byond_version // DreamDaemon version running on

		if(revdata.revision)
			L["revision"] = revdata.revision
			L["branch"] = revdata.branch
			L["date"] = revdata.date
		else
			L["revision"] = "unknown"

		return list2params(L)

	else if(copytext(T,1,5) == "laws")
		if(input["key"] != config.comms_password)
			if(abs(world_topic_spam_protect_time - world.time) < 50)
				sleep(50)
				world_topic_spam_protect_time = world.time
				return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time

			return "Bad Key"

		var/list/match = text_find_mobs(input["laws"], /mob/living/silicon)

		if(!match.len)
			return "No matches"
		else if(match.len == 1)
			var/mob/living/silicon/S = match[1]
			var/info = list()
			info["name"] = S.name
			info["key"] = S.key

			if(!S.laws)
				info["laws"] = null
				return list2params(info)

			var/list/lawset_parts = list(
				"ion" = S.laws.ion_laws,
				"inherent" = S.laws.inherent_laws,
				"supplied" = S.laws.supplied_laws
			)

			for(var/law_type in lawset_parts)
				var/laws = list()
				for(var/datum/ai_law/L in lawset_parts[law_type])
					laws += L.law
				info[law_type] = list2params(laws)

			info["zero"] = S.laws.zeroth_law ? S.laws.zeroth_law.law : null

			return list2params(info)

		else
			var/list/ret = list()
			for(var/mob/M in match)
				ret[M.key] = M.name
			return list2params(ret)

	else if(copytext(T,1,5) == "info")
		if(input["key"] != config.comms_password)
			if(abs(world_topic_spam_protect_time - world.time) < 50)
				sleep(50)
				world_topic_spam_protect_time = world.time
				return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time

			return "Bad Key"

		var/list/match = text_find_mobs(input["info"])

		if(!match.len)
			return "No matches"
		else if(match.len == 1)
			var/mob/M = match[1]
			var/info = list()
			info["key"] = M.key
			info["name"] = M.name == M.real_name ? M.name : "[M.name] ([M.real_name])"
			info["role"] = M.mind ? (M.mind.assigned_role ? M.mind.assigned_role : "No role") : "No mind"
			var/turf/MT = get_turf(M)
			info["loc"] = M.loc ? "[M.loc]" : "null"
			info["turf"] = MT ? "[MT] @ [MT.x], [MT.y], [MT.z]" : "null"
			info["area"] = MT ? "[MT.loc]" : "null"
			info["antag"] = M.mind ? (M.mind.special_role ? M.mind.special_role : "Not antag") : "No mind"
			info["hasbeenrev"] = M.mind ? M.mind.has_been_rev : "No mind"
			info["stat"] = M.stat
			info["type"] = M.type
			if(isliving(M))
				var/mob/living/L = M
				info["damage"] = list2params(list(
							oxy = L.getOxyLoss(),
							tox = L.getToxLoss(),
							fire = L.getFireLoss(),
							brute = L.getBruteLoss(),
							clone = L.getCloneLoss(),
							brain = L.getBrainLoss()
						))
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					info["species"] = H.species.name
				else
					info["species"] = "non-human"
			else
				info["damage"] = "non-living"
				info["species"] = "non-human"
			info["gender"] = M.gender
			return list2params(info)
		else
			var/list/ret = list()
			for(var/mob/M in match)
				ret[M.key] = M.name
			return list2params(ret)

	else if("who" in input)
		var/result = "Current players:\n"
		var/num = 0
		for(var/client/C in GLOB.clients)
			if(C.holder)
				if(C.is_stealthed() && !key_valid)
					continue
			result += "\t [C]\n"
			num++
		result += "Total players: [num]"
		return result

	else if("adminwho" in input)
		var/result = "Current admins:\n"
		for(var/client/C in GLOB.clients)
			if(C.holder)
				if(!C.is_stealthed())
					result += "\t [C], [C.holder.rank]\n"
		return result

	else if ("ooc" in input)
		if(!key_valid)
			if(abs(world_topic_spam_protect_time - world.time) < 50)
				sleep(50)
				world_topic_spam_protect_time = world.time
				return "Bad Key (Throttled)"
			world_topic_spam_protect_time = world.time
			return "Bad Key"
		var/ckey = input["ckey"]
		var/message
		if(!input["isadmin"])  // le costil, remove when discord-bot will be fixed ~HonkyDonky
			message = html_encode(input["ooc"])
		else
			message = "<font color='#39034f'>" + strip_html_properly(input["ooc"]) + "</font>"
		if(!ckey||!message)
			return
		if(!config.vars["ooc_allowed"]&&!input["isadmin"])
			return "globally muted"
		if(jobban_keylist.Find("[ckey] - OOC"))
			return "banned from ooc"
		var/sent_message = "[create_text_tag("dooc", "Discord")] <EM>[ckey]:</EM> <span class='message linkify'>[message]</span>"
		for(var/client/target in GLOB.clients)
			if(!target)
				continue //sanity
			if(target.is_key_ignored(ckey) && !input["isadmin"]) // If we're ignored by this person, then do nothing.
				continue //if it shouldn't see then it doesn't
			to_chat(target, "<span class='ooc dooc'><span class='everyone'>[sent_message]</span></span>", type = MESSAGE_TYPE_DOOC)

	else if ("asay" in input)
		return "not supported" //simply no asay on bay

	else if("adminhelp" in input)
		if(!key_valid)
			if(abs(world_topic_spam_protect_time - world.time) < 50)
				sleep(50)
				world_topic_spam_protect_time = world.time
				return "Bad Key (Throttled)"
			world_topic_spam_protect_time = world.time
			return "Bad Key"

		var/client/C
		var/req_ckey = ckey(input["ckey"])

		for(var/client/K in GLOB.clients)
			if(K.ckey == req_ckey)
				C = K
				break
		if(!C)
			return "No client with that name on server"

		var/rank = "Discord Admin"
		var/response = html_encode(input["response"])

		var/message = "<font color='red'>[rank] PM from <b>[input["admin"]]</b>: [response]</font>"
		var/amessage =  "<span class='info'>[rank] PM from [input["admin"]] to <b>[key_name(C)]</b> : [response])]</span>"
		webhook_send_ahelp("[input["admin"]] -> [req_ckey]", response)

		sound_to(C, sound('sound/effects/adminhelp.ogg'))
		to_chat(C, message)

		for(var/client/A in GLOB.admins)
			if(A != C)
				to_chat(A, amessage)
		return "Message Successful"

	else if("OOC" in input)
		if(!key_valid)
			if(abs(world_topic_spam_protect_time - world.time) < 50)
				sleep(50)
				world_topic_spam_protect_time = world.time
				return "Bad Key (Throttled)"
			world_topic_spam_protect_time = world.time
			return "Bad Key"
		config.ooc_allowed = !(config.ooc_allowed)
		if (config.ooc_allowed)
			to_world("<B>The OOC channel has been globally enabled!</B>")
		else
			to_world("<B>The OOC channel has been globally disabled!</B>")
		log_and_message_admins("discord toggled OOC.")
		return config.ooc_allowed ? "ON" : "OFF"

	else if(copytext(T,1,6) == "notes")
		/*
			We got a request for notes from the IRC Bot
			expected output:
				1. notes = ckey of person the notes lookup is for
				2. validationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
		*/
		if(input["key"] != config.comms_password)
			if(abs(world_topic_spam_protect_time - world.time) < 50)
				sleep(50)
				world_topic_spam_protect_time = world.time
				return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time
			return "Bad Key"

		return show_player_info_irc(ckey(input["notes"]))

	else if(copytext(T,1,4) == "age")
		if(input["key"] != config.comms_password)
			if(abs(world_topic_spam_protect_time - world.time) < 50)
				sleep(50)
				world_topic_spam_protect_time = world.time
				return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time
			return "Bad Key"

		var/age = get_player_age(input["age"])
		if(isnum(age))
			if(age >= 0)
				return "[age]"
			else
				return "Ckey not found"
		else
			return "Database connection failed or not set up"

	else if(copytext(T,1,14) == "placepermaban")
		if(!config.ban_comms_password)
			return "Not enabled"
		if(input["bankey"] != config.ban_comms_password)
			if(abs(world_topic_spam_protect_time - world.time) < 50)
				sleep(50)
				world_topic_spam_protect_time = world.time
				return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time
			return "Bad Key"

		var/target = ckey(input["target"])

		var/client/C
		for(var/client/K in GLOB.clients)
			if(K.ckey == target)
				C = K
				break
		if(!C)
			return "No client with that name found on server"
		if(!C.mob)
			return "Client missing mob"

		if(!_DB_ban_record(input["id"], "0", "127.0.0.1", 1, C.mob, -1, input["reason"]))
			return "Save failed"
		ban_unban_log_save("[input["id"]] has permabanned [C.ckey]. - Reason: [input["reason"]] - This is a ban until appeal.")
		notes_add(target,"[input["id"]] has permabanned [C.ckey]. - Reason: [input["reason"]] - This is a ban until appeal.",input["id"])
		qdel(C)


/world/Reboot(reason, reboot_hardness = 0)
	// sound_to(world, sound('sound/AI/newroundsexy.ogg')

	if(reboot_hardness == REBOOT_REALLY_HARD)
		..(reason)
		return

	if(!reboot_hardness == REBOOT_HARD)
		Master.Shutdown()

	for(var/client/C in GLOB.clients)
		C?.tgui_panel?.send_roundrestart()

		if(config.server) //if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			send_link(C, "byond://[config.server]")

	if(config.wait_for_sigusr1_reboot && reason != 3)
		text2file("foo", "reboot_called")
		to_world("<span class=danger>World reboot waiting for external scripts. Please be patient.</span>")
		return

	game_log("World rebooted at [time_stamp()]")

	if(blackbox)
		blackbox.save_all_data_to_sql()

	..(reason)

/world/Del()
	callHook("shutdown")
	return ..()

/world/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	to_file(F, the_mode)

/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")
	load_regular_announcement()


/proc/load_configuration()
	config = new /datum/configuration()
	config.Initialize()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	config.load_event("config/custom_event.txt")

/hook/startup/proc/loadMods()
	world.load_mods()
	world.load_mentors() // no need to write another hook.
	return 1

/world/proc/load_mods()
	if(config.admin_legacy_system)
		var/text = file2text("config/moderators.txt")
		if (!text)
			error("Failed to load config/mods.txt")
		else
			var/list/lines = splittext(text, "\n")
			for(var/line in lines)
				if (!line)
					continue

				if (copytext(line, 1, 2) == ";")
					continue

				var/title = "Moderator"
				var/rights = admin_ranks[title]

				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins(title, rights, ckey)
				D.associate(GLOB.ckey_directory[ckey])

/world/proc/load_mentors()
	if(config.admin_legacy_system)
		var/text = file2text("config/mentors.txt")
		if (!text)
			error("Failed to load config/mentors.txt")
		else
			var/list/lines = splittext(text, "\n")
			for(var/line in lines)
				if (!line)
					continue
				if (copytext(line, 1, 2) == ";")
					continue

				var/title = "Mentor"
				var/rights = admin_ranks[title]

				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins(title, rights, ckey)
				D.associate(GLOB.ckey_directory[ckey])

/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		s += "<b>[config.server_name]</b>"

//	s += "<b>[station_name()]</b>";
//	s += " ("
//	s += "<a href=\"http://\">" //Change this to wherever you want the hub to link to.
//	s += "[game_version]"
//	s += "Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
//	s += "</a>"
//	s += ")"

	var/list/features = list()

	if(SSticker.master_mode)
		features += SSticker.master_mode
	else
		features += "<b>STARTING</b>"

	if (!config.enter_allowed)
		features += "closed"

	features += config.abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

	if (config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in GLOB.player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"


	if (config && config.hostedby)
		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [jointext(features, ", ")]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

#define WORLD_LOG_START(X) WRITE_FILE(GLOB.world_##X##_log, "\n\nStarting up round ID [game_id]. [time2text(world.realtime, "DD.MM.YY hh:mm")]\n---------------------")
#define WORLD_SETUP_LOG(X) GLOB.world_##X##_log = file("[log_directory]/[log_prefix][#X].log") ; WORLD_LOG_START(X)
#define WORLD_SETUP_LOG_DETAILED(X) GLOB.world_##X##_log = file("[log_directory_detailed]/[log_prefix_detailed][#X].log") ; WORLD_LOG_START(X)
#define WORLD_SETUP_DEMO(X) GLOB.world_##X##_log = file("[log_directory_detailed]/[log_prefix_detailed][#X].log")

/world/proc/SetupLogs()
	if (!game_id)
		crash_with("Unknown game_id!")

	var/log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM-Month")]"
	var/log_prefix = "[time2text(world.realtime, "DD.MM.YY")]_"

	GLOB.log_directory = log_directory // TODO: remove GLOB.log_directory, check initialize.log

	var/log_directory_detailed = "data/logs/[time2text(world.realtime, "YYYY/MM-Month")]/[time2text(world.realtime, "DD.MM.YY")]_detailed"
	var/log_prefix_detailed = "[time2text(world.realtime, "DD.MM.YY_hh.mm")]_[game_id]_"

	WORLD_SETUP_LOG_DETAILED(runtime)
	WORLD_SETUP_LOG_DETAILED(qdel)
	WORLD_SETUP_LOG_DETAILED(debug)
	WORLD_SETUP_LOG_DETAILED(hrefs)
	WORLD_SETUP_DEMO(demo)
	WORLD_SETUP_LOG(common)

#undef WORLD_SETUP_LOG_DETAILED
#undef WORLD_SETUP_LOG
#undef WORLD_LOG_START

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0
var/failed_don_db_connections = 0


/hook/startup/proc/connectDB()
	if(!config.sql_enabled)
		log_to_dd("SQL disabled. Your server will not use feedback database.")
	else if(!setup_database_connection())
		log_to_dd("Your server failed to establish a connection with the feedback database.")
	else
		log_to_dd("Feedback database connection established.")
	return TRUE

/proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		log_to_dd(dbcon.ErrorMsg())

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
/proc/establish_db_connection()
	if(!config.sql_enabled)
		return FALSE

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return FALSE

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return TRUE


/hook/startup/proc/connectOldDB()
	if(!config.sql_enabled)
		log_to_dd("SQL disabled. Your server configured to use legacy admin and ban system.")
	else if(!setup_old_database_connection())
		log_to_dd("Your server failed to establish a connection with the SQL database.")
	else
		log_to_dd("SQL database connection established.")
	return TRUE

//These two procs are for the old database, while it's being phased out. See the tgstation.sql file in the SQL folder for more information.
//If you don't know what any of this do, look at the same code above
/proc/setup_old_database_connection()

	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon_old)
		dbcon_old = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon_old.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon_old.IsConnected()
	if ( . )
		failed_old_db_connections = 0
	else
		failed_old_db_connections++
		to_world_log(dbcon.ErrorMsg())

	return .

/proc/establish_old_db_connection()
	if(!config.sql_enabled)
		return FALSE

	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return FALSE

	if(!dbcon_old || !dbcon_old.IsConnected())
		return setup_old_database_connection()
	else
		return TRUE


/hook/startup/proc/connectDonDB()
	if(!config.sql_enabled)
		log_to_dd("SQL disabled. Your server will not use Donations database.")
	else if(!setup_don_database_connection())
		log_to_dd("Your server failed to establish a connection with the Donations database.")
	else
		log_to_dd("Donations database connection established.")
	return TRUE

//If you don't know what any of this do, look at the same code above
proc/setup_don_database_connection()

	if(failed_don_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon_don)
		dbcon_don = new()

	var/user = sqldonlogin
	var/pass = sqldonpass
	var/db = sqldondb
	var/address = sqldonaddress
	var/port = sqldonport
	dbcon_don.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	log_debug("Connecting to donationsDB")

	. = dbcon_don.IsConnected()
	if ( . )
		failed_don_db_connections = 0
	else
		failed_don_db_connections++
		log_to_dd(dbcon.ErrorMsg())

	return .

/proc/establish_don_db_connection()
	if(!config.sql_enabled)
		return FALSE

	if(failed_don_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return FALSE

	if(!dbcon_don || !dbcon_don.IsConnected())
		return setup_don_database_connection()
	else
		return TRUE

#undef FAILED_DB_CONNECTION_CUTOFF
