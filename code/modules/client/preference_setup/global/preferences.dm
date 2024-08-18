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
GLOBAL_VAR_CONST(PREF_STRETCH, "Stretch to Fit")
GLOBAL_VAR_CONST(PREF_X1, "x1")
GLOBAL_VAR_CONST(PREF_X15, "x1.5")
GLOBAL_VAR_CONST(PREF_X2, "x2")
GLOBAL_VAR_CONST(PREF_X25, "x2.5")
GLOBAL_VAR_CONST(PREF_X3, "x3")
GLOBAL_VAR_CONST(PREF_NORMAL, "Normal")
GLOBAL_VAR_CONST(PREF_DISTORT, "Distort")
GLOBAL_VAR_CONST(PREF_BLUR, "Blur")
GLOBAL_VAR_CONST(PREF_MODERN, "Modern")
GLOBAL_VAR_CONST(PREF_LEGACY, "Legacy")
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
GLOBAL_VAR_CONST(PREF_LOW, "Low")
GLOBAL_VAR_CONST(PREF_MED, "Medium")
GLOBAL_VAR_CONST(PREF_HIGH, "High")
GLOBAL_VAR_CONST(PREF_AS_GHOST, "Only as ghost")
GLOBAL_VAR_CONST(PREF_AS_LIVING, "Only when alive")
GLOBAL_VAR_CONST(PREF_DARKNESS_VISIBLE, "Fully visible")
GLOBAL_VAR_CONST(PREF_DARKNESS_MOSTLY_VISIBLE, "Mostly visible")
GLOBAL_VAR_CONST(PREF_DARKNESS_BARELY_VISIBLE, "Barely visible")
GLOBAL_VAR_CONST(PREF_DARKNESS_INVISIBLE, "Invisible")
GLOBAL_VAR_CONST(PREF_SPLASH_MAPTEXT, "Maptext only")
GLOBAL_VAR_CONST(PREF_SPLASH_CHAT, "Chat only")
GLOBAL_VAR_CONST(PREF_SPLASH_BOTH, "Maptext and chat")

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

/datum/client_preference/become_midround_antag
	description = "Become Midround Antag"
	key = "GAME_MIDROUND_ANTAG"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO, GLOB.PREF_AS_GHOST, GLOB.PREF_AS_LIVING)
	default_value = GLOB.PREF_YES

/datum/client_preference/runechat
	description = "Show Runechat (Above-Head-Speech)"
	key = "CHAT_RUNECHAT"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	default_value = GLOB.PREF_YES

/datum/client_preference/splashes
	description = "Show Splashes (Runechat-Like-Popups)"
	key = "CHAT_SPLASHES"
	default_value = GLOB.PREF_SPLASH_BOTH
	options = list(GLOB.PREF_SPLASH_BOTH, GLOB.PREF_SPLASH_MAPTEXT, GLOB.PREF_SPLASH_CHAT)

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

/datum/client_preference/announcer
	description = "Announcer"
	key = "SOUND_ANNOUNCER"
	category = PREF_CATEGORY_AUDIO
	default_value = GLOB.PREF_ANNOUNCER_DEFAULT
	options = list(
		GLOB.PREF_ANNOUNCER_DEFAULT,
		GLOB.PREF_ANNOUNCER_VGSTATION,
		GLOB.PREF_ANNOUNCER_BAYSTATION12,
		GLOB.PREF_ANNOUNCER_BAYSTATION12_TORCH,
		GLOB.PREF_ANNOUNCER_TGSTATION
	)

/datum/client_preference/announcer/changed(mob/preference_mob, new_value)
	if(!preference_mob.client)
		return

	if(!SSannounce.is_announcer_available(preference_mob, new_value))
		to_chat(preference_mob, SPAN_WARNING("Selected announcer is not available due to a low patron tier, default announcer will be used instead."))

/datum/client_preference/language_display
	description = "Display Language Names"
	key = "LANGUAGE_DISPLAY"
	category = PREF_CATEGORY_CHAT
	options = list(GLOB.PREF_FULL, GLOB.PREF_SHORTHAND, GLOB.PREF_OFF)

/datum/client_preference/show_typing_indicator
	description ="Typing indicator"
	key = "SHOW_TYPING"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)

/datum/client_preference/show_typing_indicator/changed(mob/preference_mob, new_value)
	preference_mob?.client.typing_indicators = new_value

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

/datum/client_preference/tgui_input
	description = "TGUI Input"
	key = "TGUI_INPUT"
	category = PREF_CATEGORY_TGUI
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)

/datum/client_preference/tgui_input_large
	description = "TGUI Input Large Buttons"
	key = "TGUI_INPUT_BUTTONS"
	category = PREF_CATEGORY_TGUI
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)

/datum/client_preference/tgui_input_swapped
	description = "TGUI Input Swapped Buttons"
	key = "TGUI_INPUT_SWAPPED"
	category = PREF_CATEGORY_TGUI
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)

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
	if(preference_mob?.client)
		var/atom/movable/renderer/R = preference_mob.renderers[GAME_RENDERER]
		R.GraphicsUpdate()

/datum/client_preference/graphics_quality
	description = "Effects Quality"
	key = "GRAPHICS_QUALITY"
	options = list(GLOB.PREF_LOW, GLOB.PREF_MED, GLOB.PREF_HIGH)
	category = PREF_CATEGORY_GRAPHICS
	default_value = GLOB.PREF_HIGH

/datum/client_preference/graphics_quality/changed(mob/preference_mob, new_value)
	if(isnull(preference_mob.client))
		return

	var/atom/movable/renderer/R = preference_mob.renderers[TEMPERATURE_EFFECT_RENDERER]
	R.GraphicsUpdate()

/datum/client_preference/pixel_size
	description = "Pixel Size"
	key = "PIXEL_SIZE"
	category = PREF_CATEGORY_GRAPHICS
	options = list(GLOB.PREF_STRETCH, GLOB.PREF_X1, GLOB.PREF_X15, GLOB.PREF_X2, GLOB.PREF_X25, GLOB.PREF_X3)
	default_value = GLOB.PREF_STRETCH

/datum/client_preference/pixel_size/changed(mob/preference_mob, new_value)
	preference_mob?.client.view_size.set_zoom()

/datum/client_preference/scaling_method
	description = "Scaling Method"
	key = "SCALING_METHOD"
	category = PREF_CATEGORY_GRAPHICS
	options = list(GLOB.PREF_NORMAL, GLOB.PREF_DISTORT, GLOB.PREF_BLUR)
	default_value = GLOB.PREF_NORMAL

/datum/client_preference/scaling_method/changed(mob/preference_mob, new_value)
	preference_mob?.client.view_size.set_zoom_mode()

/datum/client_preference/auto_fit
	description = "Auto-fit Viewport"
	key = "AUTOFIT"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)

/datum/client_preference/auto_fit/changed(mob/preference_mob, new_value)
	preference_mob?.client.attempt_fit_viewport()

/datum/client_preference/widescreen
	description = "Widescreen"
	key = "WIDESCREEN"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)

/datum/client_preference/widescreen/changed(mob/preference_mob, new_value)
	preference_mob?.client.view_size.set_default(get_screen_size(new_value == GLOB.PREF_YES))

/datum/client_preference/fullscreen_mode
	description = "Fullscreen Mode"
	key = "FULLSCREEN"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_BASIC, GLOB.PREF_FULL, GLOB.PREF_NO)
	default_value = GLOB.PREF_NO

/datum/client_preference/fullscreen_mode/changed(mob/preference_mob, new_value)
	if(preference_mob.client)
		preference_mob.client.toggle_fullscreen(new_value)

/datum/client_preference/statusbar
	description = "Show Statusbar"
	key = "STATUSBAR"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)

/datum/client_preference/statusbar/changed(mob/preference_mob, new_value)
	winset(preference_mob, "statusbar", "is-visible=[new_value == GLOB.PREF_YES]")

/datum/client_preference/legacy_input
	description = "Oldschool™ Input Position"
	key = "INPUT_POSITION"
	category = PREF_CATEGORY_UI
	options = list(GLOB.PREF_MODERN, GLOB.PREF_LEGACY)
	default_value = GLOB.PREF_MODERN

/datum/client_preference/legacy_input/changed(mob/preference_mob, new_value)
	preference_mob?.client?.update_chat_position(new_value)

/datum/client_preference/cinema_credits
	description = "Show Cinema-like Credits At Round-end"
	key = "SHOW_CREDITS"
	default_value = GLOB.PREF_NO

/datum/client_preference/ooc_name_color
	description = "OOC Name Color"
	key = "OOC_NAME_COLOR"
	category = PREF_CATEGORY_CHAT

/datum/client_preference/ooc_name_color/may_set(client/given_client)
	return given_client.donator_info.patron_type != PATREON_NONE

/datum/client_preference/ooc_name_color/get_options(client/given_client)
	return given_client.donator_info.get_available_ooc_patreon_tiers()

/datum/client_preference/ooc_name_color/get_default_value(client/given_client)
	ASSERT(given_client)
	return given_client.donator_info.patron_type

/datum/client_preference/default_hotkey_mode
	description = "Default Hotkey Mode"
	key = "DEFAULT_HOTKEY_MODE"
	category = PREF_CATEGORY_CONTROL
	default_value = GLOB.PREF_NO

/********************
* Ghost Preferences *
********************/
/datum/client_preference/ghost_hud
	description = "Ghost HUD"
	key = "GHOST_SEEHUD"
	category = PREF_CATEGORY_GHOST
	default_value = GLOB.PREF_YES
	options = list(GLOB.PREF_NO, GLOB.PREF_YES)

/datum/client_preference/ghost_hud/changed(mob/preference_mob, new_value)
	if(isobserver(preference_mob))
		preference_mob?.hud_used?.show_hud()

/datum/client_preference/ghost_ears
	description = "Ghost ears"
	key = "CHAT_GHOSTEARS"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_ALL_SPEECH, GLOB.PREF_NEARBY)
	default_value = GLOB.PREF_NEARBY

/datum/client_preference/ghost_sight
	description = "Ghost sight"
	key = "CHAT_GHOSTSIGHT"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_ALL_EMOTES, GLOB.PREF_NEARBY)
	default_value = GLOB.PREF_NEARBY

/datum/client_preference/ghost_radio
	description = "Ghost radio"
	key = "CHAT_GHOSTRADIO"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_ALL_CHATTER, GLOB.PREF_NEARBY)
	default_value = GLOB.PREF_NEARBY

/datum/client_preference/ghost_follow_link_length
	description = "Ghost Follow Links"
	key = "CHAT_GHOSTFOLLOWLINKLENGTH"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_SHORT, GLOB.PREF_LONG)

/datum/client_preference/affects_ghost/changed(mob/preference_mob, new_value)
	var/mob/observer/ghost/preference_ghost = preference_mob
	if(istype(preference_ghost))
		preference_ghost.updateghostprefs()

/datum/client_preference/affects_ghost/ghost_anonymous_chat
	description = "Ghost anonymous chat"
	key = "CHAT_GHOSTANONSAY"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_NO, GLOB.PREF_YES)

/datum/client_preference/affects_ghost/ghost_see_ghosts
	description = "Ghost see ghosts"
	key = "GHOST_SEEGHOSTS"
	category = PREF_CATEGORY_GHOST
	default_value = GLOB.PREF_YES
	options = list(GLOB.PREF_NO, GLOB.PREF_YES)

/datum/client_preference/affects_ghost/ghost_inquisitiveness
	description = "Ghost inquisitiveness"
	key = "GHOST_INQUISITIVENESS"
	category = PREF_CATEGORY_GHOST
	default_value = GLOB.PREF_YES
	options = list(GLOB.PREF_NO, GLOB.PREF_YES)

/datum/client_preference/affects_ghost/ghost_lighting
	description = "Ghost lighting"
	key = "GHOST_DARKVISION"
	category = PREF_CATEGORY_GHOST
	options = list(GLOB.PREF_DARKNESS_VISIBLE, GLOB.PREF_DARKNESS_MOSTLY_VISIBLE, GLOB.PREF_DARKNESS_BARELY_VISIBLE, GLOB.PREF_DARKNESS_INVISIBLE)

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

/datum/client_preference/staff/show_events
	description ="Show Events"
	key = "SHOW_EVENTS"
	category = PREF_CATEGORY_STAFF
	default_value = GLOB.PREF_HIDE
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
