//wrapper macros for easier grepping
#define DIRECT_OUTPUT(A, B) A << B
#define WRITE_FILE(file, text) DIRECT_OUTPUT(file, text)

#define PRINT_ATOM(A) "[A] ([A.x], [A.y], [A.z])"

// On Linux/Unix systems the line endings are LF, on windows it's CRLF, admins that don't use notepad++
// will get logs that are one big line if the system is Linux and they are using notepad.  This solves it by adding CR to every line ending
// in the logs.  ascii character 13 = CR

/var/global/log_end= world.system_type == UNIX ? ascii2text(13) : ""

/proc/log_to_dd(text)
	world.log << text
	if(config && config.log_world_output)
		log_debug("\[DD]: [text]")

/proc/error(msg)
	log_to_dd("\[[time_stamp()]]\[ERROR] [msg][log_end]")

/proc/log_ss(subsystem, text, log_to_dd = TRUE)
	if (!subsystem)
		subsystem = "UNKNOWN"
	var/msg = "[subsystem]: [text]"
	game_log("SS", msg)
	if (log_to_dd)
		log_to_dd("SS[subsystem]: [text]")

/proc/log_ss_init(text)
	game_log("SS", "[text]")

#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
//print a warning message to world.log
/proc/warning(msg)
	log_to_dd("\[[time_stamp()]]\[WARNING] [msg][log_end]")

//print a testing-mode debug message to world.log
/proc/testing(msg)
	log_to_dd("\[[time_stamp()]]\[TESTING] [msg][log_end]")

/proc/log_generic(type, message, location, log_to_common = TRUE, notify_admin = FALSE, req_pref = null)
	var/turf/T = get_turf(location)
	if(location && T)
		if(log_to_common)
			WRITE_FILE(GLOB.world_common_log, "\[[time_stamp()]] [game_id] [type]: [message] ([T.x],[T.y],[T.z])[log_end]")
		if(notify_admin)
			message += " (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)"
	else if(log_to_common)
		WRITE_FILE(GLOB.world_common_log, "\[[time_stamp()]] [game_id] [type]: [message][log_end]")

	var/rendered = "<span class=\"log_message\"><span class=\"prefix\">[type] LOG:</span> <span class=\"message\">[message]</span></span>"
	if(notify_admin)
		for(var/client/C in GLOB.admins)
			if(!req_pref || (C.get_preference_value(req_pref) == GLOB.PREF_SHOW))
				to_chat(C, rendered)

/proc/log_roundend(text)
	log_generic("ROUNDEND", text, null, config.log_game)

/proc/log_admin(text, location, notify_admin)
	log_generic("ADMIN", text, location, config.log_admin, notify_admin)

/proc/log_debug(text, location)
	log_generic("DEBUG", text, location, FALSE, TRUE, /datum/client_preference/staff/show_debug_logs)
	if(!config.log_debug || !GLOB.world_debug_log)
		return
	WRITE_FILE(GLOB.world_debug_log, "\[[time_stamp()]] DEBUG: [text][log_end]")

/proc/log_debug_verbose(text)
	if(!config.log_debug_verbose || !GLOB.world_debug_log)
		return
	WRITE_FILE(GLOB.world_debug_log, "\[[time_stamp()]] DEBUG VERBOSE: [text][log_end]")

/proc/log_game(text, location, notify_admin)
	log_generic("GAME", text, location, config.log_game, notify_admin)

/proc/log_vote(text)
	log_generic("VOTE", text, null, config.log_vote)

/proc/log_access(text, notify_admin)
	log_generic("ACCESS", text, null, config.log_vote, notify_admin)

/proc/log_say(text)
	log_generic("SAY", text, null, config.log_say)

/proc/log_ooc(text)
	log_generic("OOC", text, null, config.log_ooc)

/proc/log_whisper(text)
	log_generic("WHISPER", text, null, config.log_whisper)

/proc/log_emote(text)
	log_generic("EMOTE", text, null, config.log_emote)

/proc/log_attack(text, location, notify_admin)
	log_generic("ATTACK", text, location, config.log_attack, notify_admin, /datum/client_preference/staff/show_attack_logs)

/proc/log_adminsay(text)
	log_generic("ADMINSAY", text, null, config.log_adminchat)

/proc/log_adminwarn(text, location, notify_admin)
	log_generic("ADMINWARN", text, location, config.log_adminwarn, notify_admin)

/proc/log_pda(text)
	log_generic("PDA", text, null, config.log_pda)

/proc/log_misc(text) //Replace with log_game ?
	log_generic("MISC", text)

/proc/log_DB(text, notify_admin)
	log_generic("DATABASE", text, notify_admin = notify_admin)

/proc/game_log(category, text)
	WRITE_FILE(GLOB.world_common_log, "\[[time_stamp()]\] [game_id] [category]: [text][log_end]")

/proc/log_unit_test(text)
	log_to_dd("\[[time_stamp()]]\[UNIT TEST] [text]")
	log_debug(text)

/proc/log_qdel(text)
	WRITE_FILE(GLOB.world_qdel_log, "\[[time_stamp()]]QDEL: [text]")

/proc/log_href(text)
	if(!config.log_hrefs)
		return
	WRITE_FILE(GLOB.world_hrefs_log, "\[[time_stamp()]] HREF: [text]")

/proc/log_href_exploit(atom/user)
	WRITE_FILE(GLOB.href_exploit_attempt_log, "HREF: [key_name(user)] has potentially attempted an href exploit.")
	message_admins("[key_name_admin(user)] has potentially attempted an href exploit.")

/proc/log_error(text)
	error(text)

/proc/log_warning(text)
	warning(text)

/proc/log_runtime(text)
	if (!GLOB.world_runtime_log)
		log_error("\[EARLY RUNTIME] [text]")
		return
	WRITE_FILE(GLOB.world_runtime_log, text)

/* ui logging */

/proc/log_tgui(text)
	log_debug(text)

//pretty print a direction bitflag, can be useful for debugging.
/proc/dir_text(dir)
	var/list/comps = list()
	if(dir & NORTH) comps += "NORTH"
	if(dir & SOUTH) comps += "SOUTH"
	if(dir & EAST) comps += "EAST"
	if(dir & WEST) comps += "WEST"
	if(dir & UP) comps += "UP"
	if(dir & DOWN) comps += "DOWN"

	return english_list(comps, nothing_text="0", and_text="|", comma_text="|")

//more or less a logging utility
/proc/key_name(whom, include_link = null, include_name = 1, highlight_special_characters = 1, datum/ticket/ticket = null)
	var/mob/M
	var/client/C
	var/key

	if(!whom)	return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
	else if(istype(whom, /datum/mind))
		var/datum/mind/D = whom
		key = D.key
		M = D.current
		if(D.current)
			C = D.current.client
	else if(istype(whom, /datum))
		var/datum/D = whom
		return "*invalid:[D.type]*"
	else
		return "*invalid*"

	. = ""

	if(key)
		if(include_link && C)
			. += "<a href='?priv_msg=\ref[C];ticket=\ref[ticket]'>"

		. += key

		if(include_link)
			if(C)	. += "</a>"
			else	. += " (DC)"
	else
		. += "*no key*"

	if(include_name && M)
		var/name

		if(M.real_name)
			name = M.real_name
		else if(M.name)
			name = M.name


		if(include_link && is_special_character(M) && highlight_special_characters)
			. += "/(<font color='#ffa500'>[name]</font>)" //Orange
		else
			. += "/([name])"

	return .

/proc/key_name_admin(whom, include_name = 1)
	return key_name(whom, 1, include_name)

// Helper procs for building detailed log lines
/datum/proc/get_log_info_line()
	return "[src] ([type]) ([any2ref(src)])"

/area/get_log_info_line()
	return "[..()] ([isnum(z) ? "[x],[y],[z]" : "0,0,0"])"

/turf/get_log_info_line()
	return "[..()] ([x],[y],[z]) ([loc ? loc.type : "NULL"])"

/atom/movable/get_log_info_line()
	var/turf/t = get_turf(src)
	return "[..()] ([t ? t : "NULL"]) ([t ? "[t.x],[t.y],[t.z]" : "0,0,0"]) ([t ? t.type : "NULL"])"

/mob/get_log_info_line()
	return ckey ? "[..()] ([ckey])" : ..()

/proc/log_info_line(datum/d)
	if(isnull(d))
		return "*null*"
	if(islist(d))
		var/list/L = list()
		for(var/e in d)
			L += log_info_line(e)
		return "\[[jointext(L, ", ")]\]" // We format the string ourselves, rather than use json_encode(), because it becomes difficult to read recursively escaped "
	if(!istype(d))
		return json_encode(d)
	return d.get_log_info_line()

/proc/report_progress(progress_message)
	admin_notice("<span class='boldannounce'>[progress_message]</span>", R_DEBUG)
	log_to_dd(progress_message)
