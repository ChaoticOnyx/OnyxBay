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
GLOBAL_VAR_CONST(PREF_SHIFT_MIDDLE_CLICK, "shift middle click")
GLOBAL_VAR_CONST(PREF_ALT_CLICK, "alt click")
GLOBAL_VAR_CONST(PREF_CTRL_CLICK, "ctrl click")
GLOBAL_VAR_CONST(PREF_CTRL_SHIFT_CLICK, "ctrl shift click")
GLOBAL_VAR_CONST(PREF_HEAR, "Hear")
GLOBAL_VAR_CONST(PREF_SILENT, "Silent")
GLOBAL_VAR_CONST(PREF_SHORTHAND, "Shorthand")
GLOBAL_VAR_CONST(PREF_WHITE, "White")
GLOBAL_VAR_CONST(PREF_DARK, "Dark")

var/global/list/_client_preferences
var/global/list/_client_preferences_by_key
var/global/list/_client_preferences_by_type

/proc/get_client_preferences()
	if(!_client_preferences)
		_client_preferences = list()
		for(var/ct in subtypesof(/datum/client_preference))
			var/datum/client_preference/client_type = ct
			if(initial(client_type.description))
				_client_preferences += new client_type()
	return _client_preferences

/proc/get_client_preference(datum/client_preference/preference)
	if(istype(preference))
		return preference
	if(ispath(preference))
		return get_client_preference_by_type(preference)
	return get_client_preference_by_key(preference)

/proc/get_client_preference_by_key(preference)
	if(!_client_preferences_by_key)
		_client_preferences_by_key = list()
		for(var/ct in get_client_preferences())
			var/datum/client_preference/client_pref = ct
			_client_preferences_by_key[client_pref.key] = client_pref
	return _client_preferences_by_key[preference]

/proc/get_client_preference_by_type(preference)
	if(!_client_preferences_by_type)
		_client_preferences_by_type = list()
		for(var/ct in get_client_preferences())
			var/datum/client_preference/client_pref = ct
			_client_preferences_by_type[client_pref.type] = client_pref
	return _client_preferences_by_type[preference]

/datum/client_preference
	var/description
	var/key
	var/category = PREF_CATEGORY_MISC
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
/datum/client_preference/runechat
	description = "Show Runechat (Above-Head-Speech)"
	key = "CHAT_RUNECHAT"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	default_value = GLOB.PREF_YES

/datum/client_preference/play_admin_midis
	description ="Play admin midis"
	key = "SOUND_MIDI"
	category = PREF_CATEGORY_AUDIO

/datum/client_preference/play_lobby_music
	description ="Play lobby music"
	key = "SOUND_LOBBY"
	category = PREF_CATEGORY_AUDIO

/datum/client_preference/play_lobby_music/changed(mob/preference_mob, new_value)
	if(new_value == GLOB.PREF_YES)
		if(isnewplayer(preference_mob) && preference_mob.client)
			GLOB.lobby_music.play_to(preference_mob.client)
	else
		sound_to(preference_mob.client, sound(null, repeat = 0, wait = 0, volume = 85, channel = 1))

/datum/client_preference/play_ambiance
	description ="Play ambience"
	key = "SOUND_AMBIENCE"
	category = PREF_CATEGORY_AUDIO

/datum/client_preference/play_ambiance/changed(mob/preference_mob, new_value)
	if(new_value == GLOB.PREF_NO)
		sound_to(preference_mob, sound(null, repeat = 0, wait = 0, volume = 0, channel = 1))

/datum/client_preference/play_ambience_music
	description = "Play ambience music"
	key = "SOUND_AMBIENCE_MUSIC"
	category = PREF_CATEGORY_AUDIO

/datum/client_preference/play_ambience_music/changed(mob/preference_mob, new_value)
	if(new_value == GLOB.PREF_NO)
		preference_mob.client?.last_time_ambient_music_played = 0
		sound_to(preference_mob, sound(null, repeat = 0, wait = 0, volume = 0, channel = SOUND_CHANNEL_AMBIENT_MUSIC))

/datum/client_preference/play_jukeboxes
	description ="Play jukeboxes"
	key = "SOUND_JUKEBOXES"
	category = PREF_CATEGORY_AUDIO

/datum/client_preference/give_wayfinding
	description = "Spawn with a wayfinder tracker"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO, GLOB.PREF_BASIC)
	default_value = GLOB.PREF_BASIC
	key = "WAYFINDING_POINTER"

/datum/client_preference/play_instruments
	description ="Play instruments"
	key = "SOUND_INSTRUMENTS"
	category = PREF_CATEGORY_AUDIO

/datum/client_preference/play_hitmarker
	description ="Hitmarker Sound"
	key = "SOUND_HITMARKER"
	category = PREF_CATEGORY_AUDIO

/datum/client_preference/ghost_ears
	description ="Ghost ears"
	key = "CHAT_GHOSTEARS"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_ALL_SPEECH, GLOB.PREF_NEARBY)

/datum/client_preference/ghost_sight
	description ="Ghost sight"
	key = "CHAT_GHOSTSIGHT"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_ALL_EMOTES, GLOB.PREF_NEARBY)

/datum/client_preference/ghost_radio
	description ="Ghost radio"
	key = "CHAT_GHOSTRADIO"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_ALL_CHATTER, GLOB.PREF_NEARBY)

/datum/client_preference/language_display
	description = "Display Language Names"
	key = "LANGUAGE_DISPLAY"
	category = PREF_CATEGORY_CHAT
	options = list(GLOB.PREF_FULL, GLOB.PREF_SHORTHAND, GLOB.PREF_OFF)

/datum/client_preference/ghost_follow_link_length
	description ="Ghost Follow Links"
	key = "CHAT_GHOSTFOLLOWLINKLENGTH"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_SHORT, GLOB.PREF_LONG)

/datum/client_preference/show_typing_indicator
	description ="Typing indicator"
	key = "SHOW_TYPING"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/show_typing_indicator/changed(mob/preference_mob, new_value)
	if(new_value == GLOB.PREF_HIDE)
		QDEL_NULL(preference_mob.typing_indicator)

/datum/client_preference/show_progress_bar
	description ="Progress Bar"
	key = "SHOW_PROGRESS"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/powersuit_activation
	description = "Powersuit Module Activation Key"
	key = "POWERSUIT_ACTIVATION"
	category = PREF_CATEGORY_CONTROL
	options = list(GLOB.PREF_MIDDLE_CLICK, GLOB.PREF_SHIFT_MIDDLE_CLICK, GLOB.PREF_CTRL_CLICK, GLOB.PREF_ALT_CLICK, GLOB.PREF_CTRL_SHIFT_CLICK)

/datum/client_preference/pointing
	description = "Point to Activation Key"
	key = "POINTING_ACTIVATION"
	category = PREF_CATEGORY_CONTROL
	default_value = GLOB.PREF_SHIFT_MIDDLE_CLICK
	options = list(GLOB.PREF_SHIFT_MIDDLE_CLICK, GLOB.PREF_MIDDLE_CLICK)

/datum/client_preference/special_ability_key
	description = "Special Ability Activation Key"
	key = "SPECIAL_ABILITY"
	category = PREF_CATEGORY_CONTROL
	options = list(GLOB.PREF_MIDDLE_CLICK, GLOB.PREF_CTRL_CLICK, GLOB.PREF_ALT_CLICK, GLOB.PREF_CTRL_SHIFT_CLICK)

/datum/client_preference/tgui_style
	description = "TGUI Style"
	key = "TGUI_FANCY"
	category = PREF_CATEGORY_TGUI
	options = list(GLOB.PREF_FANCY, GLOB.PREF_PLAIN)

/datum/client_preference/tgui_monitor
	description = "TGUI Monitor"
	key = "TGUI_MONITOR"
	category = PREF_CATEGORY_TGUI
	options = list(GLOB.PREF_PRIMARY, GLOB.PREF_ALL)

/datum/client_preference/tgui_theme
	description = "TGUI Theme"
	key = "TGUI_THEME"
	category = PREF_CATEGORY_TGUI
	options = list(GLOB.PREF_WHITE, GLOB.PREF_DARK)

/datum/client_preference/tgui_chat
	description = "TGUI Chat"
	key = "TGUI_CHAT"
	category = PREF_CATEGORY_TGUI
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)

/datum/client_preference/tgui_chat/changed(mob/preference_mob, new_value)
	if(preference_mob.client == null)
		return

	if(new_value == GLOB.PREF_YES)
		preference_mob.client.tgui_panel.initialize()
	else
		winset(preference_mob, "output", "on-show=&is-disabled=0&is-visible=1")
		winset(preference_mob, "browseroutput", "is-disabled=1;is-visible=0")

/datum/client_preference/browser_style
	description = "Fake NanoUI Browser Style"
	key = "BROWSER_STYLED"
	category = PREF_CATEGORY_UI
	default_value = GLOB.PREF_FANCY
	options = list(GLOB.PREF_FANCY, GLOB.PREF_PLAIN)

/datum/client_preference/ambient_occlusion
	description = "Toggle Ambient Occlusion"
	key = "AMBIENT_OCCLUSION"
	category = PREF_CATEGORY_GRAPHICS
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)

/datum/client_preference/ambient_occlusion/changed(mob/preference_mob, new_value)
	if (preference_mob.client)
		preference_mob.UpdatePlanes()

/datum/client_preference/fullscreen_mode
	description = "Fullscreen Mode"
	key = "FULLSCREEN"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_BASIC, GLOB.PREF_FULL, GLOB.PREF_NO)
	default_value = GLOB.PREF_NO

/datum/client_preference/fullscreen_mode/changed(mob/preference_mob, new_value)
	if(preference_mob.client)
		preference_mob.client.toggle_fullscreen(new_value)

/datum/client_preference/chat_position
	description = "Use Alternative Chat Position"
	key = "CHAT_ALT"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_NO, GLOB.PREF_YES)

/datum/client_preference/chat_position/changed(mob/preference_mob, new_value)
	if(preference_mob.client)
		preference_mob.client.update_chat_position()

/datum/client_preference/cinema_credits
	description = "Show Cinema-like Credits At Round-end"
	key = "SHOW_CREDITS"
	default_value = GLOB.PREF_NO

/datum/client_preference/ooc_name_color
	description = "OOC Name Color"
	key = "OOC_NAME_COLOR"
	category = PREF_CATEGORY_CHAT

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
	category = PREF_CATEGORY_CONTROL
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
	category = PREF_CATEGORY_STAFF
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/staff/play_adminhelp_ping
	description = "Adminhelps"
	key = "SOUND_ADMINHELP"
	category = PREF_CATEGORY_STAFF
	options = list(GLOB.PREF_HEAR, GLOB.PREF_SILENT)

/datum/client_preference/staff/show_rlooc
	description ="Remote LOOC chat"
	key = "CHAT_RLOOC"
	category = PREF_CATEGORY_STAFF
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/********************
* Misc Preferences *
********************/

/datum/client_preference/staff/govnozvuki
	description = "Admin Misc Sounds"
	key = "SOUND_PARASHA"
	category = PREF_CATEGORY_STAFF
	flags = R_PERMISSIONS

/datum/client_preference/staff/advanced_who
	description = "Advanced Who"
	key = "ADVANCED_WHO"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	category = PREF_CATEGORY_STAFF
	flags = R_INVESTIGATE

/datum/client_preference/staff/pray_sound
	description = "Play Pray Sound"
	key = "SOUND_PRAY"
	category = PREF_CATEGORY_STAFF
	flags = R_PERMISSIONS
