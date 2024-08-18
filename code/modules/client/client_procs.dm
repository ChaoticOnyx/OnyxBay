	////////////
	//SECURITY//
	////////////
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?

#define LIMITER_SIZE	5
#define CURRENT_SECOND	1
#define SECOND_COUNT	2
#define CURRENT_MINUTE	3
#define MINUTE_COUNT	4
#define ADMINSWARNED_AT	5

//#define TOPIC_DEBUGGING 1

	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	// stops us calling Topic for somebody else's client. Also helps prevent usr = null
		return

	#if defined(TOPIC_DEBUGGING)
	log_debug("[src]'s Topic: [href] destined for [hsrc].")

	if(href_list["nano_err"]) // nano throwing errors
		log_debug("## NanoUI, Subject [src]: " + html_decode(href_list["nano_err"]))// NANO DEBUG HOOK


	#endif

	// asset_cache
	var/asset_cache_job = null
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = text2num(href_list["asset_cache_confirm_arrival"])

		// because we skip the limiter, we have to make sure this is a valid arrival and not somebody tricking us
		// into letting append to a list without limit.
		if(!asset_cache_job || asset_cache_job > last_asset_job)
			return

		if(!(asset_cache_job in completed_asset_jobs))
			completed_asset_jobs += asset_cache_job
			return

	if(config.general.minute_topic_limit)
		var/minute = round(world.time, 600)
		if(!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if(minute != topiclimiter[CURRENT_MINUTE])
			topiclimiter[CURRENT_MINUTE] = minute
			topiclimiter[MINUTE_COUNT] = 0
		topiclimiter[MINUTE_COUNT] += 1
		if(topiclimiter[MINUTE_COUNT] > config.general.minute_topic_limit)
			var/msg = "Your previous action was ignored because you've done too many in a minute."
			if(minute != topiclimiter[ADMINSWARNED_AT]) // only one admin message per-minute. (if they spam the admins can just boot/ban them)
				topiclimiter[ADMINSWARNED_AT] = minute
				msg += " Administrators have been informed."
				log_game("[key_name(src)] Has hit the per-minute topic limit of [config.general.minute_topic_limit] topic calls in a given game minute")
				message_admins("[key_name_admin(src)] Has hit the per-minute topic limit of [config.general.minute_topic_limit] topic calls in a given game minute")
			to_chat(src, SPAN("danger", "[msg]"))
			return

	if(config.general.second_topic_limit)
		var/second = round(world.time, 10)
		if(!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if(second != topiclimiter[CURRENT_SECOND])
			topiclimiter[CURRENT_SECOND] = second
			topiclimiter[SECOND_COUNT] = 0
		topiclimiter[SECOND_COUNT] += 1
		if(topiclimiter[SECOND_COUNT] > config.general.second_topic_limit)
			to_chat(src, SPAN("danger", "Your previous action was ignored because you've done too many in a second."))
			return

	// Logs all hrefs
	log_href("[src] (usr:[usr]) || [hsrc ? "[hsrc] " : ""][href]")

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return

	// ask BYOND client to stop spamming us with assert arrival confirmations (see byond bug ID:2256651)
	if(asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, SPAN("danger", "An error has been detected in how your client is receiving resources. Attempting to correct... (If you keep seeing these messages you might want to close byond and reconnect)"))
		show_browser(src, "...", "window=asset_cache_browser")

	// search the href for script injection
	if(findtext(href, "<script", 1, 0))
		to_world_log("Attempted use of scripts within a topic call, by [src]")
		message_admins("Attempted use of scripts within a topic call, by [src]")
		//qdel(usr)
		return

	// Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		var/datum/ticket/ticket = locate(href_list["ticket"])

		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		cmd_admin_pm(C, null, ticket)
		return

	if(href_list["irc_msg"])
		if(!holder && received_irc_pm < world.time - 6000) //Worse they can do is spam IRC for 10 minutes
			to_chat(usr, SPAN("warning", "You are no longer able to use this, it's been more then 10 minutes since an admin on IRC has responded to you."))
			return
		if(mute_irc)
			to_chat(usr, SPAN("warning", "You cannot use this as your client has been muted from sending messages to the admins on IRC."))
			return
		cmd_admin_irc_pm(href_list["irc_msg"])
		return

	if(href_list["close_ticket"])
		var/datum/ticket/ticket = locate(href_list["close_ticket"])

		if(isnull(ticket))
			return

		ticket.close(client_repository.get_lite_client(usr.client))

	switch(href_list["_src_"])
		if("holder")	hsrc = holder
		if("usr")		hsrc = mob
		if("prefs")		return prefs.process_link(usr, href_list)
		if("vars")		return view_var_Topic(href, href_list, hsrc)

	switch(href_list["action"])
		if("openLink")
			send_link(src, href_list["link"])

	..()	// redirect to hsrc.Topic()

// This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return 0
/*	// Don't need this at the moment. But it's here if it's needed later.
	// Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>")
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	TopicData = null							// Prevent calls to client.Topic from connect

	if(!(connection in list("seeker", "web")))					// Invalid connection type.
		return null

	if(!config.game.guests_allowed && IsGuestKey(key))
		alert(src, "This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.", "Guest", "OK")
		qdel(src)
		return

	DIRECT_OUTPUT(src, SPAN("warning", "If the title screen is black and chat is broken, resources are still downloading. Please be patient until the title screen appears."))
	GLOB.clients += src
	GLOB.ckey_directory[ckey] = src

	// Instantiate tgui panel
	tgui_panel = new(src)

	// Admin Authorisation
	var/datum/admins/admin_datum = admin_datums[ckey]
	if(admin_datum)
		if(admin_datum in GLOB.deadmined_list)
			deadmin_holder = admin_datum
			src.verbs |= /client/proc/readmin_self
		else
			holder = admin_datum
			GLOB.admins += src
		admin_datum.owner = src
	else if(config.admin.promote_localhost)
		var/static/localhost_addresses = list("127.0.0.1", "::1")

		if(isnull(address) || (address in localhost_addresses))
			var/datum/admins/A = new /datum/admins("Host", R_ALL, ckey)

			A.associate(src)

	else if((config.multiaccount.panic_bunker != 0) && (get_player_age(ckey) < config.multiaccount.panic_bunker))
		var/player_age = get_player_age(ckey)
		if(config.multiaccount.panic_server_address && TopicData != "redirect")
			log_access("Panic Bunker: ([key_name(key, include_name = FALSE)] | age [player_age]) - attempted to connect. Redirected to [config.multiaccount.panic_server_name ? config.multiaccount.panic_server_name : config.multiaccount.panic_server_address]")
			message_admins(SPAN("adminnotice", "Panic Bunker: ([key] | age [player_age]) - attempted to connect. Redirected to [config.multiaccount.panic_server_name ? config.multiaccount.panic_server_name : config.multiaccount.panic_server_address]"))
			to_chat(src, SPAN("notice", "Server is already full. Sending you to [config.multiaccount.panic_server_name ? config.multiaccount.panic_server_name : config.multiaccount.panic_server_address]."))
			winset(src, null, "command=.options")
			send_link(src, "[config.multiaccount.panic_server_address]?redirect")
		else
			log_access("Panic Bunker: ([key_name(key, include_name = FALSE)] | age [player_age]) - attempted to connect. Redirecting is not configured.")
			message_admins("<span class='adminnotice'>Panic Bunker: ([key] | age [player_age]) - Redirecting is not configured.</span>")
		qdel(src)
		return

	// Load EAMS data
	SSeams.CollectDataForClient(src)

	setup_preferences()
	view_size = new(src, get_screen_size(TRUE))

	. = ..()	// calls mob.Login()

	if(byond_version < config.general.client_min_major_version || byond_build < config.general.client_min_minor_version || (byond_build in config.general.client_blacklisted_minor_versions))
		to_chat(src, "<b><center><font size='5' color='red'>Your <font color='blue'>BYOND</font> version is [(byond_build in config.general.client_blacklisted_minor_versions) ? "blacklisted" : "too out of date!"]</font><br>\
		<font size='3'>Please update it to [config.general.client_min_major_version].[config.general.client_recommended_minor_version].</font>\
		<font size='3'>You can use this link: https://secure.byond.com/download/build/515/</font></center>")
		QDEL_IN(src, 1)
		return

	GLOB.using_map.map_info(src)

	if(custom_event_msg && custom_event_msg != "")
		to_chat(src, "<h1 class='alert'>Custom Event</h1>")
		to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
		to_chat(src, "<span class='alert'>[custom_event_msg]</span>")
		to_chat(src, "<br>")


	if(holder)
		add_admin_verbs()
		admin_memo_show()

	// Forcibly enable hardware-accelerated graphics, as we need them for the lighting overlays.
	// (but turn them off first, since sometimes BYOND doesn't turn them on properly otherwise)
	spawn(5) // And wait a half-second, since it sounds like you can do this too fast.
		if(src)
			winset(src, null, "command=\".configure graphics-hwmode off\"")
			sleep(2) // wait a bit more, possibly fixes hardware mode not re-activating right
			winset(src, null, "command=\".configure graphics-hwmode on\"")

	log_client_to_db()
	SSdonations.log_client_to_db(src)
	SSdonations.update_donator(src)
	SSdonations.update_donator_items(src)

	send_resources()

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, SPAN("warning", "Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you."))

	if(prefs && !istype(mob, world.mob))
		prefs.apply_post_login_preferences(src)

	settings = new(src)

	if(config.general.player_limit && is_player_rejected_by_player_limit(usr, ckey))
		if(config.multiaccount.panic_server_address && TopicData != "redirect")
			DIRECT_OUTPUT(src, SPAN("warning", "<h1>This server is currently full and not accepting new connections. Sending you to [config.multiaccount.panic_server_name ? config.multiaccount.panic_server_name : config.multiaccount.panic_server_address]</h1>"))
			winset(src, null, "command=.options")
			send_link(src, "[config.multiaccount.panic_server_address]?redirect")

		else
			DIRECT_OUTPUT(src, SPAN_WARNING("<h1>This server is currently full and not accepting new connections.</h1>"))

		log_admin("[ckey] tried to join but the server is full (player_limit=[config.general.player_limit])")
		qdel(src)
		return

	load_luck()
	//////////////
	//DISCONNECT//
	//////////////

/client/Del()
	if(!gc_destroyed)
		Destroy()
	return ..()

/client/Destroy()
	ticket_panels -= src
	if(holder)
		holder.owner = null
		GLOB.admins -= src
	GLOB.ckey_directory -= ckey
	GLOB.clients -= src
	..()
	return QDEL_HINT_HARDDEL_NOW

// here because it's similar to below

// Returns null if no DB connection can be established, or -1 if the requested key was not found in the database

/proc/get_player_age(key)
	if(!establish_db_connection())
		return null

	var/DBQuery/query = sql_query("SELECT datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = $ckey", dbcon, list(ckey = ckey(key)))

	if(query.NextRow())
		return text2num(query.item[1])
	else
		return -1

/proc/is_player_rejected_by_player_limit(mob/user, ckey)
	if(ckey in admin_datums)
		return FALSE
	if(GLOB.clients.len >= config.general.player_limit)
		if(config.general.hard_player_limit && GLOB.clients.len <= config.general.hard_player_limit && user && (user in GLOB.living_mob_list_))
			return FALSE
		return TRUE
	return FALSE

/client/proc/log_client_to_db()
	if(IsGuestKey(src.key))
		return

	if(!establish_db_connection())
		return

	var/DBQuery/query = sql_query("SELECT id, datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = $ckey", dbcon, list(ckey = ckey))
	var/id = 0
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	while(query.NextRow())
		id = query.item[1]
		player_age = text2num(query.item[2])
		break

	var/DBQuery/query_ip = sql_query("SELECT ckey FROM erro_player WHERE ip = $address", dbcon, list(address = address || "127.0.0.1"))
	related_accounts_ip = ""
	while(query_ip.NextRow())
		related_accounts_ip += "[query_ip.item[1]], "
		break

	var/DBQuery/query_cid = sql_query("SELECT ckey FROM erro_player WHERE computerid = $computer_id", dbcon, list(computer_id = computer_id))
	related_accounts_cid = ""
	while(query_cid.NextRow())
		related_accounts_cid += "[query_cid.item[1]], "
		break

	watchlist.OnLogin(src)

	// Just the standard check to see if it's actually a number
	if(id)
		if(istext(id))
			id = text2num(id)
		if(!isnum(id))
			return

	var/admin_rank = "Player"
	if(src.holder)
		admin_rank = src.holder.rank

	if(id)
		// Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		sql_query("UPDATE erro_player SET lastseen = Now(), ip = $address, computerid = $computer_id, lastadminrank = $admin_rank WHERE id = $id", dbcon, list(address = address || "127.0.0.1", computer_id = computer_id, admin_rank = admin_rank, id = id))
	else
		// New player!! Need to insert all the stuff
		sql_query("INSERT INTO erro_player VALUES (null, $ckey, Now(), Now(), $address, $computer_id, $admin_rank)", dbcon, list(ckey = ckey, address = address || "127.0.0.1", computer_id = computer_id, admin_rank = admin_rank))

	sql_query("INSERT INTO connection(datetime, ckey, ip, computerid) VALUES (Now(), $ckey, $address, $computer_id)", dbcon, list(ckey = ckey, address = address || "127.0.0.1", computer_id = computer_id))


#undef UPLOAD_LIMIT

// checks if a client is afk
// 3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)	return inactivity
	return 0

/client/proc/inactivity2text()
	var/seconds = inactivity/10
	return "[round(seconds / 60)] minute\s, [seconds % 60] second\s"

// Byond seemingly calls stat, each tick.
// Calling things each tick can get expensive real quick.
// So we slow this down a little.
// See: http://www.byond.com/docs/ref/info.html#/client/proc/Stat
/client/Stat()
	if(!usr)
		return
	// Add always-visible stat panel calls here, to define a consistent display order.
	statpanel("Status")

	. = ..()
	stoplag(1)

// send resources to the client. It's here in its own proc so we can move it around easiliy if need be
/client/proc/send_resources()

	getFiles(
		'html/images/ntlogo.png',
		'html/images/ntlogo_hand.png',
		'html/images/bluentlogo.png',
		'html/images/bluentlogo_hand.png',
		'html/images/stamp_images/stamp-cap.png',
		'html/images/stamp_images/stamp-clown.png',
		'html/images/stamp_images/stamp-deny.png',
		'html/images/stamp_images/stamp-ok.png',
		'html/images/stamp_images/stamp-void.png',
		'html/images/stamp_images/stamp-hop.png',
		'html/images/stamp_images/stamp-cmo.png',
		'html/images/stamp_images/stamp-ce.png',
		'html/images/stamp_images/stamp-hos.png',
		'html/images/stamp_images/stamp-rd.png',
		'html/images/stamp_images/stamp-qm.png',
		'html/images/stamp_images/stamp-law.png',
		'html/images/stamp_images/stamp-chap.png',
		'html/images/stamp_images/stamp-mime.png',
		'html/images/stamp_images/stamp-cent.png',
		'html/images/stamp_images/stamp-syndicate.png',
		'html/images/stamp_images/stamp-cargo.png',
		'html/images/stamp_images/stamp-intaff.png',
		'html/images/stamp_images/stamp-ward.png',
		'html/search.js',
		'html/panels.css',
		'html/spacemag.css',
		'html/images/loading.gif',
		'html/images/talisman.png',
		'html/images/line_hand.png',
		'html/images/borders_hand.png',
		'html/good_vibes/good_vibes.woff'
	)

	spawn (10) // removing this spawn causes all clients to not get verbs.
		if(!src) // client disconnected
			return

		var/list/priority_assets = list()
		var/list/other_assets = list()

		for(var/type in subtypesof(/datum/asset))
			get_asset_datum(type)

		for(var/asset_type in asset_datums)
			var/datum/asset/D = asset_datums[asset_type]
			if(D.isTrivial)
				other_assets += D
			else
				priority_assets += D

		for(var/datum/asset/D in (priority_assets + other_assets))
			if (!D.send_slow(src)) // Precache the client with all other assets slowly, so as to not block other browse() calls
				return

/mob/proc/MayRespawn()
	return 0

/client/proc/MayRespawn()
	if(mob)
		return mob.MayRespawn()

	// Something went wrong, client is usually kicked or transfered to a new mob at this point
	return 0

/client/verb/character_setup()
	set name = "Character Setup"
	set category = "OOC"
	if(prefs)
		prefs.open_setup_window(usr)

/client/proc/apply_fps(client_fps)
	if(world.byond_version >= 511 && byond_version >= 511 && client_fps >= CLIENT_MIN_FPS && client_fps <= CLIENT_MAX_FPS)
		fps = client_fps

#define VERTICAL_INPUT_MARGIN 9

/**
 * Manages `input` and `input_alt` visibility, due to skin limitations this proc is extreely
 * snowflake, thus be sure to change `VERTICAL_INPUT_MARGIN` when moving it's elements
 * inside `skin.dmf`.
 *
 * Known bugs:
 * - Doesn't mount instantly due to user prefs loading.
 * - Doesn't display typing indicator 'cause code copypasta is bad.
 */
/client/proc/update_chat_position(new_position)
	var/alternate = winget(src, "input", "is-default") == "false"

	if(!alternate && new_position == GLOB.PREF_LEGACY)
		var/list/game_size = splittext(winget(src, "mainvsplit", "size"), "x")
		var/list/input_size = splittext(winget(src, "input_alt", "size"), "x")

		winset(src, "mainvsplit", "size=[game_size[1]]x[text2num(game_size[2]) - text2num(input_size[2]) - VERTICAL_INPUT_MARGIN]")

		var/list/chat_size = splittext(winget(src, "outputwindow", "size"), "x")

		winset(src, "browseroutput", "size=[chat_size[1]]x[chat_size[2]]")
		winset(src, "output", "size=[chat_size[1]]x[chat_size[2]]")

		winset(src, "input_alt", "is-visible=true;is-disabled=false;is-default=true")
		winset(src, "saybutton_alt", "is-visible=true;is-disabled=false;is-default=true")
		winset(src, "hotkey_toggle_alt", "is-visible=true;is-disabled=false;is-default=true")

		winset(src, "input", "is-visible=false;is-disabled=true;is-default=false")
		winset(src, "saybutton", "is-visible=false;is-disabled=true;is-default=false")
		winset(src, "hotkey_toggle", "is-visible=false;is-disabled=true;is-default=false")

	else if(alternate && new_position == GLOB.PREF_MODERN)
		var/list/game_size = splittext(winget(src, "mainvsplit", "size"), "x")
		var/list/alt_input_size = splittext(winget(src, "input_alt", "size"), "x")

		winset(src, "mainvsplit", "size=[game_size[1]]x[text2num(game_size[2]) + text2num(alt_input_size[2]) + 9]")

		var/list/chat_size = splittext(winget(src, "outputwindow", "size"), "x")
		var/list/input_size = splittext(winget(src, "input", "size"), "x")

		var/output_height = text2num(chat_size[2]) - text2num(input_size[2]) - VERTICAL_INPUT_MARGIN

		winset(src, "browseroutput", "size=[chat_size[1]]x[output_height]")
		winset(src, "output", "size=[chat_size[1]]x[output_height]")

		winset(src, "input_alt", "is-visible=false;is-disabled=true;is-default=false")
		winset(src, "saybutton_alt", "is-visible=false;is-disabled=true;is-default=false")
		winset(src, "hotkey_toggle_alt", "is-visible=false;is-disabled=true;is-default=false")

		winset(src, "input", "is-visible=true;is-disabled=false;is-default=true")
		winset(src, "saybutton", "is-visible=true;is-disabled=false;is-default=true")
		winset(src, "hotkey_toggle", "is-visible=true;is-disabled=false;is-default=true")

#undef VERTICAL_INPUT_MARGIN

/client/proc/toggle_fullscreen(new_value)
	if((new_value == GLOB.PREF_BASIC) || (new_value == GLOB.PREF_FULL))
		winset(src, "mainwindow", "is-maximized=false;can-resize=false;titlebar=false")
		if(new_value == GLOB.PREF_FULL)
			winset(src, "mainwindow", "menu=null;")
	else
		winset(src, "mainwindow", "is-maximized=false;can-resize=true;titlebar=true")
		winset(src, "mainwindow", "menu=menu;")
	winset(src, "mainwindow", "is-maximized=true")

/client/proc/attempt_fit_viewport()
	if(get_preference_value("AUTOFIT") != GLOB.PREF_YES)
		return

	fit_viewport()

/client/verb/fit_viewport()
	set name = "Fit Viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = get_view_size(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/sizes = params2list(winget(src, "mainwindow.mainvsplit;mapwindow", "size"))
	var/map_size = splittext(sizes["mapwindow.size"], "x")
	if(!length(map_size))
		return // Something's broken. Happens when a client connects multiple times at once.
	var/height = text2num(map_size[2])
	var/desired_width = round(height * aspect_ratio)
	if(text2num(map_size[1]) == desired_width)
		return // Nothing to do

	var/split_size = splittext(sizes["mainwindow.mainvsplit.size"], "x")
	var/split_width = text2num(split_size[1])

	// Calculate and apply a best estimate
	// +4 pixels are for the width of the splitter's handle
	var/pct = 100 * (desired_width + 4) / split_width
	winset(src, "mainwindow.mainvsplit", "splitter=[pct]")

	// Apply an ever-lowering offset until we finish or fail
	var/delta
	for(var/safety in 1 to 10)
		var/after_size = winget(src, "mapwindow", "size")
		map_size = splittext(after_size, "x")
		var/got_width = text2num(map_size[1])

		if (got_width == desired_width)
			// success
			return
		else if (isnull(delta))
			// calculate a probable delta value based on the difference
			delta = 100 * (desired_width - got_width) / split_width
		else if ((delta > 0 && got_width > desired_width) || (delta < 0 && got_width < desired_width))
			// if we overshot, halve the delta and reverse direction
			delta = -delta/2

		pct += delta
		winset(src, "mainwindow.mainvsplit", "splitter=[pct]")

/client/verb/release_shift()
	set name = ".release_shift"

	shift_released_at = world.time

/client/proc/setup_preferences(initialization = FALSE)
	// This proc will be called twice if SScharacter_setup is not initialized,
	// so, don't create prefs again.
	if(!prefs)
		// preferences datum - also holds 	some persistant data for the client (because we may as well keep these datums to a minimum)
		prefs = new /datum/preferences(src)
		prefs.last_ip = address				// these are gonna be used for banning
		prefs.last_id = computer_id			// these are gonna be used for banning
		apply_fps(prefs.clientfps ? prefs.clientfps : config.general.client_fps)

	if(initialization || SScharacter_setup.initialized)
		prefs.setup()
	else
		SScharacter_setup.queue_client(src)

/client/proc/play_ambience_music(file_path)
	if(get_preference_value(/datum/client_preference/play_ambience_music) == GLOB.PREF_NO)
		return

	var/sound/S = sound(file_path, FALSE, FALSE, SOUND_CHANNEL_AMBIENT_MUSIC, VOLUME_AMBIENT_MUSIC)
	S.echo = 0
	S.environment = -1

	last_time_ambient_music_played = world.time
	DIRECT_OUTPUT(src, S)

/client/proc/is_ambience_music_playing()
	var/list/sounds = SoundQuery()

	for(var/sound/S in sounds)
		if(S.channel == SOUND_CHANNEL_AMBIENT_MUSIC)
			return TRUE

	return FALSE

/client/proc/change_view(new_view)
	if(isnull(new_view))
		CRASH("change_view was called without an argument")

	view = new_view
	attempt_fit_viewport()
	/**
	 * We create view in 'client/New()' BEFORE client is actually logged in his mob
	 * Otherwise apply_post_login_preferences() crashes due to view being not initialized.
	 */
	mob?.reload_fullscreen()

/client/MouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	var/mob/living/M = mob
	if(istype(M))
		M.OnMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params)

/client/MouseUp(object, location, control, params)
	. = ..()
	var/mob/living/M = mob
	if(istype(M))
		M.OnMouseUp(object, location, control, params)

/client/MouseDown(object, location, control, params)
	. = ..()
	var/mob/living/M = mob
	if(istype(M) && !M.in_throw_mode)
		M.OnMouseDown(object, location, control, params)

/client/proc/get_luck_for_type(luck_type)
	switch(luck_type)
		if(LUCK_CHECK_GENERAL)
			return luck_general

		if(LUCK_CHECK_COMBAT)
			return luck_combat

		if(LUCK_CHECK_ENG)
			return luck_eng

		if(LUCK_CHECK_MED)
			return luck_med

		if(LUCK_CHECK_RND)
			return luck_rnd

/client/proc/load_luck()
	if(!establish_db_connection())
		error("Ban database connection failure.")
		log_misc("Ban database connection failure.")
		return

	var/DBQuery/query = sql_query({"
			SELECT
				luck_level,
				luck_type
			FROM
				erro_ban
			WHERE
				(ckey = $ckeytext)
				AND
				(
					bantype = 'LUCK_PERMABAN'
					OR
					bantype = 'LUCK_TEMPBAN'
				)
				AND
				isnull(unbanned)
				[isnull(config.general.server_id) ? "" : " AND server_id = $server_id"]
			"}, dbcon, list(ckeytext = src.ckey, server_id = config.general.server_id))

	while(query.NextRow())
		var/luck_level =  text2num(query.item[1])
		var/luck_type = query.item[2]
		switch(luck_type)
			if(LUCK_CHECK_GENERAL)
				luck_general =luck_level
			if(LUCK_CHECK_COMBAT)
				luck_combat = luck_level
			if(LUCK_CHECK_ENG)
				luck_eng = luck_level
			if(LUCK_CHECK_MED)
				luck_med = luck_level
			if(LUCK_CHECK_RND)
				luck_rnd = luck_level



/client/proc/write_luck(lucktype, luck_level, duration=-1, admin, reason)
	if(!establish_db_connection())
		error("Ban database connection failure.")
		log_misc("Ban database connection failure.")
		return

	var/datum/admins/admin_datum = admin
	var/bantype = BANTYPE_PERMA_LUCKBAN
	if(duration!=-1)
		bantype = BANTYPE_TEMP_LUCKBAN

	admin_datum.DB_ban_record(bantype,src.mob,duration,reason,null,TRUE,src.ckey,null,src.computer_id,luck_level,lucktype)
	load_luck()

/client/proc/update_luck()
	if(!establish_db_connection())
		error("Ban database connection failure.")
		log_misc("Ban database connection failure.")
		return

	var/DBQuery/query = sql_query({"
			SELECT
				id,
				duration,
				rounds
			FROM
				erro_ban
			WHERE
				(ckey = $ckeytext)
				AND
				bantype = 'LUCK_TEMPBAN'
				AND
				isnull(unbanned)
				[isnull(config.general.server_id) ? "" : " AND server_id = $server_id"]
			"}, dbcon, list(ckeytext = src.ckey, server_id = config.general.server_id))

	while(query.NextRow())
		var/id = text2num(query.item[1])
		var/duration = text2num(query.item[2])
		var/isRounds = text2num(query.item[3])
		if(!isRounds)
			return
		if(duration>1)
			sql_query({"
				UPDATE
					erro_ban
				SET
					duration = $duration
				WHERE
					id = $id
					AND
					ckey = $ckeytext
					AND
					bantype = 'LUCK_TEMPBAN'
					AND
					isnull(unbanned)
					[isnull(config.general.server_id) ? "" : " AND server_id = $server_id"]
				"}, dbcon, list(id = id, duration = duration-1, ckeytext = src.ckey, server_id = config.general.server_id))
		else
			sql_query({"
				UPDATE
					erro_ban
				SET
					unbanned = 1,
					unbanned_reason = 'Expired',
					unbanned_datetime = Now()
				WHERE
					id = $id
					AND
					ckey = $ckeytext
					AND
					bantype = 'LUCK_TEMPBAN'
					AND
					isnull(unbanned)
					[isnull(config.general.server_id) ? "" : " AND server_id = $server_id"]
				"}, dbcon, list(id = id, ckeytext = src.ckey, server_id = config.general.server_id))
