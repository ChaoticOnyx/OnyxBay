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

	/// Messages currently seen by this client
	var/list/seen_messages

	/// Whether typing indicators are enabled
	var/typing_indicators

	var/luck_general = 100
	var/luck_combat = 100
	var/luck_eng = 100
	var/luck_med = 100
	var/luck_rnd = 100

	/// Custom movement keys for this client
	var/list/movement_keys = list()
	/// Are we locking our movement input?
	var/movement_locked = FALSE
	/// A buffer of currently held keys.
	var/list/keys_held = list()
	/// A buffer for combinations such of modifiers + keys (ex: CtrlD, AltE, ShiftT). Format: `"key"` -> `"combo"` (ex: `"D"` -> `"CtrlD"`)
	var/list/key_combos_held = list()
	/*
	** These next two vars are to apply movement for keypresses and releases made while move delayed.
	** Because discarding that input makes the game less responsive.
	*/
	/// On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_add
	/// On next move, subtract this dir from the move that would otherwise be done
	var/next_move_dir_sub

	/// Movement dir of the most recently pressed movement key. Used in cardinal-only movement mode.
	var/last_move_dir_pressed

	/// Full-auto guns broke clicking and now we have to invent workarounds. What a life.
	var/mouse_down_last_time = 0
	var/mouse_click_last_time = 0
	var/mouse_click_opportunity_window = 2 // Must be enough for most users.
	var/atom/mouse_down_atom = null
