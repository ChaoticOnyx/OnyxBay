/client
	// * Black magic things *
	parent_type = /datum

	// * Admin things *
	var/datum/admins/holder = null
	var/datum/admins/deadmin_holder = null
	var/adminobs = null
	var/adminhelped = 0
	var/watchlist_warn = null

	// * Other things *
	var/static/obj/screen/click_catcher/void
	var/datum/click_handler/click_handler

	var/datum/preferences/prefs = null
	var/species_ingame_whitelisted = FALSE

	var/datum/donator_info/donator_info = new

	///onyxchat chatoutput of the client
	var/datum/chatOutput/chatOutput

	/*
	As of byond 512, due to how broken preloading is, preload_rsc MUST be set to 1 at compile time if resource URLs are *not* in use,
	BUT you still want resource preloading enabled (from the server itself). If using resource URLs, it should be set to 0 and
	changed to a URL at runtime (see client_procs.dm for procs that do this automatically). More information about how goofy this broken setting works at
	http://www.byond.com/forum/post/1906517?page=2#comment23727144
	*/
	preload_rsc = 0

	// * Sound stuff *
	var/ambience_playing = null
	var/played = 0

	// * Security things *
	var/received_irc_pm = -99999

	//IRC admin that spoke with them last.
	var/irc_admin
	var/mute_irc = 0

	// Prevents people from being spammed about multikeying every time their mob changes.
	var/warned_about_multikeying = 0

	var/datum/eams_info/eams_info = new
	var/list/topiclimiter

	// comment out the line below when debugging locally to enable the options & messages menu
	//control_freak = 1

	// * Database related things *

	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/player_age = "Requires database"

	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_ip = "Requires database"

	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/related_accounts_cid = "Requires database"

	//used for initial centering of saywindow
	var/first_say = TRUE

	//For tracking shift key (world.time)
	var/shift_released_at = 0 
