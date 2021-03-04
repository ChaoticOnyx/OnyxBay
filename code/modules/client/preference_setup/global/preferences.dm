GLOBAL_VAR_CONST(PREF_YES, "Yes")
GLOBAL_VAR_CONST(PREF_NO, "No")
GLOBAL_VAR_CONST(PREF_ALL_SPEECH, "All Speech")
GLOBAL_VAR_CONST(PREF_NEARBY, "Nearby")
GLOBAL_VAR_CONST(PREF_ALL_EMOTES, "All Emotes")
GLOBAL_VAR_CONST(PREF_ALL_CHATTER, "All Chatter")
GLOBAL_VAR_CONST(PREF_SHORT, "Short")
GLOBAL_VAR_CONST(PREF_LONG, "Long")
GLOBAL_VAR_CONST(PREF_SHOW, "Show")
GLOBAL_VAR_CONST(PREF_HIDE, "Hide")
GLOBAL_VAR_CONST(PREF_FANCY, "Fancy")
GLOBAL_VAR_CONST(PREF_PLAIN, "Plain")
GLOBAL_VAR_CONST(PREF_PRIMARY, "Primary")
GLOBAL_VAR_CONST(PREF_ALL, "All")
GLOBAL_VAR_CONST(PREF_OFF, "Off")
GLOBAL_VAR_CONST(PREF_BASIC, "Basic")
GLOBAL_VAR_CONST(PREF_FULL, "Full")
GLOBAL_VAR_CONST(PREF_MIDDLE_CLICK, "middle click")
GLOBAL_VAR_CONST(PREF_ALT_CLICK, "alt click")
GLOBAL_VAR_CONST(PREF_CTRL_CLICK, "ctrl click")
GLOBAL_VAR_CONST(PREF_CTRL_SHIFT_CLICK, "ctrl shift click")
GLOBAL_VAR_CONST(PREF_HEAR, "Hear")
GLOBAL_VAR_CONST(PREF_SILENT, "Silent")
GLOBAL_VAR_CONST(PREF_SHORTHAND, "Shorthand")

/proc/get_client_preferences()
	var/static/list/client_preferences
	if(!client_preferences)
		client_preferences = list()
		for(var/ct in subtypesof(/datum/client_preference))
			var/datum/client_preference/client_type = ct
			if(initial(client_type.description))
				client_preferences += new client_type()
	return client_preferences

/proc/get_client_preference(datum/client_preference/preference)
	if(istype(preference))
		return preference
	if(ispath(preference))
		return get_client_preference_by_type(preference)
	return get_client_preference_by_key(preference)

/proc/get_client_preference_by_key(preference)
	var/static/list/client_preferences_by_key
	if(!client_preferences_by_key)
		client_preferences_by_key = list()
		for(var/ct in get_client_preferences())
			var/datum/client_preference/client_pref = ct
			client_preferences_by_key[client_pref.key] = client_pref
	return client_preferences_by_key[preference]

/proc/get_client_preference_by_type(preference)
	var/static/list/client_preferences_by_type
	if(!client_preferences_by_type)
		client_preferences_by_type = list()
		for(var/ct in get_client_preferences())
			var/datum/client_preference/client_pref = ct
			client_preferences_by_type[client_pref.type] = client_pref
	return client_preferences_by_type[preference]

/datum/client_preference
	var/description
	var/key
	var/list/options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	var/default_value

/datum/client_preference/New()
	. = ..()

	if(!default_value)
		default_value = options[1]

/datum/client_preference/proc/may_set(client/given_client)
	return TRUE

/datum/client_preference/proc/changed(mob/preference_mob, new_value)
	return

/datum/client_preference/proc/get_options(client/given_client)
	return options

/datum/client_preference/proc/get_default_value(client/given_client)
	return default_value

/*********************
* Player Preferences *
*********************/
/datum/client_preference/play_admin_midis
	description ="Play admin midis"
	key = "SOUND_MIDI"

/datum/client_preference/play_lobby_music
	description ="Play lobby music"
	key = "SOUND_LOBBY"

/datum/client_preference/play_lobby_music/changed(mob/preference_mob, new_value)
	if(new_value == GLOB.PREF_YES)
		GLOB.using_map.lobby_music.play_to(preference_mob)
	else
		sound_to(preference_mob, sound(null, repeat = 0, wait = 0, volume = 85, channel = 1))

/datum/client_preference/play_ambiance
	description ="Play ambience"
	key = "SOUND_AMBIENCE"

/datum/client_preference/play_ambiance/changed(mob/preference_mob, new_value)
	if(new_value == GLOB.PREF_NO)
		sound_to(preference_mob, sound(null, repeat = 0, wait = 0, volume = 0, channel = 1))
		sound_to(preference_mob, sound(null, repeat = 0, wait = 0, volume = 0, channel = 2))

/datum/client_preference/play_jukeboxes
	description ="Play jukeboxes"
	key = "SOUND_JUKEBOXES"

/datum/client_preference/play_instruments
	description ="Play instruments"
	key = "SOUND_INSTRUMENTS"

/datum/client_preference/play_hitmarker
	description ="Hitmarker Sound"
	key = "SOUND_HITMARKER"

/datum/client_preference/ghost_ears
	description ="Ghost ears"
	key = "CHAT_GHOSTEARS"
	options = list(GLOB.PREF_ALL_SPEECH, GLOB.PREF_NEARBY)

/datum/client_preference/ghost_sight
	description ="Ghost sight"
	key = "CHAT_GHOSTSIGHT"
	options = list(GLOB.PREF_ALL_EMOTES, GLOB.PREF_NEARBY)

/datum/client_preference/ghost_radio
	description ="Ghost radio"
	key = "CHAT_GHOSTRADIO"
	options = list(GLOB.PREF_ALL_CHATTER, GLOB.PREF_NEARBY)

/datum/client_preference/language_display
	description = "Display Language Names"
	key = "LANGUAGE_DISPLAY"
	options = list(GLOB.PREF_FULL, GLOB.PREF_SHORTHAND, GLOB.PREF_OFF)

/datum/client_preference/ghost_follow_link_length
	description ="Ghost Follow Links"
	key = "CHAT_GHOSTFOLLOWLINKLENGTH"
	options = list(GLOB.PREF_SHORT, GLOB.PREF_LONG)

/datum/client_preference/chat_tags
	description ="Chat tags"
	key = "CHAT_SHOWICONS"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/show_typing_indicator
	description ="Typing indicator"
	key = "SHOW_TYPING"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/show_typing_indicator/changed(mob/preference_mob, new_value)
	if(new_value == GLOB.PREF_HIDE)
		QDEL_NULL(preference_mob.typing_indicator)

/datum/client_preference/show_ooc
	description ="OOC chat"
	key = "CHAT_OOC"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/show_discord_ooc
	description ="Discord OOC chat"
	key = "CHAT_DISCORD_OOC"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/show_aooc
	description ="AOOC chat"
	key = "CHAT_AOOC"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/show_looc
	description ="LOOC chat"
	key = "CHAT_LOOC"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/show_dsay
	description ="Dead chat"
	key = "CHAT_DEAD"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/show_progress_bar
	description ="Progress Bar"
	key = "SHOW_PROGRESS"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/hardsuit_activation
	description = "Hardsuit Module Activation Key"
	key = "HARDSUIT_ACTIVATION"
	options = list(GLOB.PREF_MIDDLE_CLICK, GLOB.PREF_CTRL_CLICK, GLOB.PREF_ALT_CLICK, GLOB.PREF_CTRL_SHIFT_CLICK)

/datum/client_preference/tgui_style
	description ="tgui Style"
	key = "TGUI_FANCY"
	options = list(GLOB.PREF_FANCY, GLOB.PREF_PLAIN)

/datum/client_preference/tgui_monitor
	description ="tgui Monitor"
	key = "TGUI_MONITOR"
	options = list(GLOB.PREF_PRIMARY, GLOB.PREF_ALL)

/datum/client_preference/browser_style
	description = "Fake NanoUI Browser Style"
	key = "BROWSER_STYLED"
	options = list(GLOB.PREF_FANCY, GLOB.PREF_PLAIN)

/datum/client_preference/ambient_occlusion
	description = "Toggle Ambient Occlusion"
	key = "AMBIENT_OCCLUSION"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)

/datum/client_preference/ambient_occlusion/changed(mob/preference_mob, new_value)
	if (preference_mob.client)
		preference_mob.UpdatePlanes()

/datum/client_preference/fullscreen_mode
	description = "Fullscreen Mode"
	key = "FULLSCREEN"
	options = list(GLOB.PREF_BASIC, GLOB.PREF_FULL, GLOB.PREF_NO)
	default_value = GLOB.PREF_NO

/datum/client_preference/fullscreen_mode/changed(mob/preference_mob, new_value)
	if(preference_mob.client)
		preference_mob.client.toggle_fullscreen(new_value)

/datum/client_preference/chat_position
	description = "Use Alternative Chat Position"
	key = "CHAT_ALT"
	default_value = GLOB.PREF_NO

/datum/client_preference/chat_position/changed(mob/preference_mob, new_value)
	if(preference_mob.client)
		preference_mob.client.update_chat_position(new_value == GLOB.PREF_YES)

/datum/client_preference/cinema_credits
	description = "Show Cinema-like Credits At Round-end"
	key = "SHOW_CREDITS"
	default_value = GLOB.PREF_NO

/datum/client_preference/ooc_name_color
	description = "OOC Name Color"
	key = "OOC_NAME_COLOR"

/datum/client_preference/ooc_name_color/may_set(client/given_client)
	return TRUE

/datum/client_preference/ooc_name_color/get_options(client/given_client)
	return PATREON_ALL_TIERS

/datum/client_preference/ooc_name_color/get_default_value(client/given_client)
	ASSERT(given_client)
	return given_client.donator_info.patron_type

/datum/client_preference/default_hotkey_mode
	description = "Default Hotkey Mode"
	key = "DEFAULT_HOTKEY_MODE"
	default_value = GLOB.PREF_NO


/********************
* General Staff Preferences *
********************/

/datum/client_preference/staff
	var/flags

/datum/client_preference/staff/may_set(client/given_client)
	if(ismob(given_client))
		var/mob/M = given_client
		given_client = M.client
	if(!given_client)
		return FALSE
	if(flags)
		return check_rights(flags, 0, given_client)
	else
		return given_client && given_client.holder

/datum/client_preference/staff/show_chat_prayers
	description = "Chat Prayers"
	key = "CHAT_PRAYER"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/staff/play_adminhelp_ping
	description = "Adminhelps"
	key = "SOUND_ADMINHELP"
	options = list(GLOB.PREF_HEAR, GLOB.PREF_SILENT)

/datum/client_preference/staff/show_rlooc
	description ="Remote LOOC chat"
	key = "CHAT_RLOOC"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/********************
* Admin Preferences *
********************/

/datum/client_preference/staff/show_attack_logs
	description = "Attack Log Messages"
	key = "CHAT_ATTACKLOGS"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)
	flags = R_ADMIN
	default_value = GLOB.PREF_HIDE

/********************
* Debug Preferences *
********************/

/datum/client_preference/staff/show_debug_logs
	description = "Debug Log Messages"
	key = "CHAT_DEBUGLOGS"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)
	default_value = GLOB.PREF_HIDE
	flags = R_ADMIN|R_DEBUG

/********************
* Misc Preferences *
********************/

/datum/client_preference/staff/govnozvuki
	description = "Admin Misc Sounds"
	key = "SOUND_PARASHA"
	flags = R_PERMISSIONS

/datum/client_preference/staff/advanced_who
	description = "Advanced Who"
	key = "ADVANCED_WHO"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	flags = R_INVESTIGATE
