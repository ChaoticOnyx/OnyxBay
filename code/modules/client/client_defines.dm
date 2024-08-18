/client
	// * Black magic things *
	parent_type = /datum

	/// Client's view wrapper, use this instead of direct `view` modifications.
	var/datum/view/view_size

	// * Admin things *
	var/datum/admins/holder = null
	var/datum/admins/deadmin_holder = null
	var/adminobs = null
	var/adminhelped = 0
	var/watchlist_warn = null

	// * Other things *
	var/static/atom/movable/screen/click_catcher/catcher
	var/datum/click_handler/click_handler

	var/datum/preferences/prefs = null
	var/species_ingame_whitelisted = FALSE

	var/datum/donator_info/donator_info = new

	/*
	As of byond 512, due to how broken preloading is, preload_rsc MUST be set to 1 at compile time if resource URLs are *not* in use,
	BUT you still want resource preloading enabled (from the server itself). If using resource URLs, it should be set to 0 and
	changed to a URL at runtime (see client_procs.dm for procs that do this automatically). More information about how goofy this broken setting works at
	http://www.byond.com/forum/post/1906517?page=2#comment23727144
	*/
	preload_rsc = 1

	// * Sound stuff *
	var/ambience_playing = null
	var/played = 0
	// Start playing right from the start.
	var/last_time_ambient_music_played = -AMBIENT_MUSIC_COOLDOWN

	// * Security things *
	var/received_irc_pm = -99999

	// IRC admin that spoke with them last.
	var/irc_admin
	var/mute_irc = 0

	// Prevents people from being spammed about multikeying every time their mob changes.
	var/warned_about_multikeying = 0

	var/datum/eams_info/eams_info = new
	var/list/topiclimiter

	// * Database related things *

	// So admins know why it isn't working - Used to determine how old the account is - in days.
	var/player_age = "Requires database"

	// So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_ip = "Requires database"

	// So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/related_accounts_cid = "Requires database"

	// used for initial centering of saywindow
	var/first_say = TRUE

	// For tracking shift key (world.time)
	var/shift_released_at = 0

	/// Settings window.
	var/datum/player_settings/settings = null

	/// Messages currently seen by this client
	var/list/seen_messages

	/// Whether typing indicators are enabled
	var/typing_indicators

	var/luck_general = 100
	var/luck_combat = 100
	var/luck_eng = 100
	var/luck_med = 100
	var/luck_rnd = 100
