	////////////
	//SECURITY//
	////////////
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?
#define MIN_CLIENT_VERSION	513		//Just an ambiguously low version for now, I don't want to suddenly stop people playing.
									//I would just like the code ready should it ever need to be used.

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
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	#if defined(TOPIC_DEBUGGING)
	log_debug("[src]'s Topic: [href] destined for [hsrc].")

	if(href_list["nano_err"]) //nano throwing errors
		log_debug("## NanoUI, Subject [src]: " + html_decode(href_list["nano_err"]))//NANO DEBUG HOOK


	#endif

	// asset_cache
	var/asset_cache_job = null
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = text2num(href_list["asset_cache_confirm_arrival"])

		//because we skip the limiter, we have to make sure this is a valid arrival and not somebody tricking us
		//	into letting append to a list without limit.
		if (!asset_cache_job || asset_cache_job > last_asset_job)
			return

		if (!(asset_cache_job in completed_asset_jobs))
			completed_asset_jobs += asset_cache_job
			return

	if (config.minutetopiclimit)
		var/minute = round(world.time, 600)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (minute != topiclimiter[CURRENT_MINUTE])
			topiclimiter[CURRENT_MINUTE] = minute
			topiclimiter[MINUTE_COUNT] = 0
		topiclimiter[MINUTE_COUNT] += 1
		if (topiclimiter[MINUTE_COUNT] > config.minutetopiclimit)
			var/msg = "Your previous action was ignored because you've done too many in a minute."
			if (minute != topiclimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				topiclimiter[ADMINSWARNED_AT] = minute
				msg += " Administrators have been informed."
				log_game("[key_name(src)] Has hit the per-minute topic limit of [config.minutetopiclimit] topic calls in a given game minute")
				message_admins("[key_name_admin(src)] Has hit the per-minute topic limit of [config.minutetopiclimit] topic calls in a given game minute")
			to_chat(src, "<span class='danger'>[msg]</span>")
			return

	if (config.secondtopiclimit)
		var/second = round(world.time, 10)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (second != topiclimiter[CURRENT_SECOND])
			topiclimiter[CURRENT_SECOND] = second
			topiclimiter[SECOND_COUNT] = 0
		topiclimiter[SECOND_COUNT] += 1
		if (topiclimiter[SECOND_COUNT] > config.secondtopiclimit)
			to_chat(src, "<span class='danger'>Your previous action was ignored because you've done too many in a second</span>")
			return

	//Logs all hrefs
	log_href("[src] (usr:[usr]) || [hsrc ? "[hsrc] " : ""][href]")

	// ask BYOND client to stop spamming us with assert arrival confirmations (see byond bug ID:2256651)
	if (asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, SPAN_DANGER("An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)"))
		src << browse("...", "window=asset_cache_browser")

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		world.log << "Attempted use of scripts within a topic call, by [src]"
		message_admins("Attempted use of scripts within a topic call, by [src]")
		//qdel(usr)
		return

	//Admin PM
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
			to_chat(usr, "<span class='warning'>You are no longer able to use this, it's been more then 10 minutes since an admin on IRC has responded to you</span>")
			return
		if(mute_irc)
			to_chat(usr, "<span class='warning'You cannot use this as your client has been muted from sending messages to the admins on IRC</span>")
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
		if("prefs")		return prefs.process_link(usr,href_list)
		if("vars")		return view_var_Topic(href,href_list,hsrc)
		if("chat")		return chatOutput.Topic(href, href_list)

	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])

	..()	//redirect to hsrc.Topic()

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
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
	TopicData = null							//Prevent calls to client.Topic from connect

	// Load onyxchat
	chatOutput = new(src)

	if(!(connection in list("seeker", "web")))					//Invalid connection type.
		return null

	if(!config.guests_allowed && IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		qdel(src)
		return

	// Change the way they should download resources.
	if(config.resource_urls && config.resource_urls.len)
		src.preload_rsc = pick(config.resource_urls)
	else src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	DIRECT_OUTPUT(src, "<span class='warning'>If the title screen is black and chat is broken, resources are still downloading. Please be patient until the title screen appears.</span>")
	GLOB.clients += src
	GLOB.ckey_directory[ckey] = src


	//Admin Authorisation
	var/datum/admins/admin_datum = admin_datums[ckey]
	if(admin_datum)
		if(admin_datum in GLOB.deadmined_list)
			deadmin_holder = admin_datum
			verbs |= /client/proc/readmin_self
		else
			holder = admin_datum
			GLOB.admins += src
		admin_datum.owner = src

	else if((config.panic_bunker != 0) && (get_player_age(ckey) < config.panic_bunker))
		var/player_age = get_player_age(ckey)
		if(config.panic_address && TopicData != "redirect")
			log_access("Panic Bunker: ([key] | age [player_age]) - attempted to connect. Redirected to [config.panic_server_name ? config.panic_server_name : config.panic_address]")
			message_admins("<span class='adminnotice'>Panic Bunker: ([key] | age [player_age]) - attempted to connect. Redirected to [config.panic_server_name ? config.panic_server_name : config.panic_address]</span>")
			to_chat(src, "<span class='notice'>Server is already full. Sending you to [config.panic_server_name ? config.panic_server_name : config.panic_address].</span>")
			winset(src, null, "command=.options")
			src << link("[config.panic_address]?redirect")
		else
			log_access("Panic Bunker: ([key] | age [player_age]) - attempted to connect. Redirecting is not configured.")
			message_admins("<span class='adminnotice'>Panic Bunker: ([key] | age [player_age]) - Redirecting is not configured.</span>")
		qdel(src)
		return

	// Load EAMS data
	SSeams.CollectDataForClient(src)

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = SScharacter_setup.preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning
	apply_fps(prefs.clientfps)

	. = ..()	//calls mob.Login()

	if(byond_version < MIN_CLIENT_VERSION)
		src << "<b><center><font size='5' color='red'>Your <font color='blue'>BYOND</font> version is too out of date!</font><br>\
		<font size='3'>Please update it to [MIN_CLIENT_VERSION].</font></center>"
		qdel(src)
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

	if(prefs.lastchangelog != changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		to_chat(src, "<span class='info'>You have unread updates in the changelog.</span>")
		if(config.aggressive_changelog)
			src.changes()

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, "<span class='warning'>Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you.</span>")

	chatOutput.start()

	// Change position only if it not default
	if (get_preference_value(/datum/client_preference/chat_position) == GLOB.PREF_YES)
		update_chat_position(TRUE)

	if(get_preference_value(/datum/client_preference/fullscreen_mode) != GLOB.PREF_NO)
		toggle_fullscreen(get_preference_value(/datum/client_preference/fullscreen_mode))

	if(config.player_limit && is_player_rejected_by_player_limit(usr, ckey))
		if(config.panic_address && TopicData != "redirect")
			DIRECT_OUTPUT(src, SPAN_WARNING("<h1>This server is currently full and not accepting new connections. Sending you to [config.panic_server_name ? config.panic_server_name : config.panic_address]</h1>"))
			winset(src, null, "command=.options")
			src << link("[config.panic_address]?redirect")

		else
			DIRECT_OUTPUT(src, SPAN_WARNING("<h1>This server is currently full and not accepting new connections.</h1>"))

		log_admin("[ckey] tried to join but the server is full (player_limit=[config.player_limit])")
		qdel(src)
		return

/*	if(holder)
		src.control_freak = 0 //Devs need 0 for profiler access
*/
	//////////////
	//DISCONNECT//
	//////////////
/client/Del()
	ticket_panels -= src
	if(holder)
		holder.owner = null
		GLOB.admins -= src
	GLOB.ckey_directory -= ckey
	GLOB.clients -= src
	return ..()

/client/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

// here because it's similar to below

// Returns null if no DB connection can be established, or -1 if the requested key was not found in the database

/proc/get_player_age(key)
	establish_db_connection()
	if(!dbcon.IsConnected())
		return null

	var/sql_ckey = sql_sanitize_text(ckey(key))

	var/DBQuery/query = dbcon.NewQuery("SELECT datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()

	if(query.NextRow())
		return text2num(query.item[1])
	else
		return -1

/proc/is_player_rejected_by_player_limit(mob/user, ckey)
	if(ckey in admin_datums)
		return FALSE
	if(GLOB.clients.len >= config.player_limit)
		if(config.hard_player_limit && GLOB.clients.len <= config.hard_player_limit && user && (user in GLOB.living_mob_list_))
			return FALSE
		return TRUE
	return FALSE

/client/proc/log_client_to_db()

	if ( IsGuestKey(src.key) )
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/sql_ckey = sql_sanitize_text(src.ckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()
	var/sql_id = 0
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		break

	var/DBQuery/query_ip = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE ip = '[address]'")
	query_ip.Execute()
	related_accounts_ip = ""
	while(query_ip.NextRow())
		related_accounts_ip += "[query_ip.item[1]], "
		break

	var/DBQuery/query_cid = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE computerid = '[computer_id]'")
	query_cid.Execute()
	related_accounts_cid = ""
	while(query_cid.NextRow())
		related_accounts_cid += "[query_cid.item[1]], "
		break

	watchlist.OnLogin(src)

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/admin_rank = "Player"
	if(src.holder)
		admin_rank = src.holder.rank

	var/sql_ip = sql_sanitize_text(src.address)
	var/sql_computerid = sql_sanitize_text(src.computer_id)
	var/sql_admin_rank = sql_sanitize_text(admin_rank)


	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update = dbcon.NewQuery("UPDATE erro_player SET lastseen = Now(), ip = '[sql_ip]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		query_update.Execute()
	else
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO erro_player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_ip]', '[sql_computerid]', '[sql_admin_rank]')")
		query_insert.Execute()

	//Logging player access
	var/serverip = "[world.internet_address]:[world.port]"
	var/DBQuery/query_accesslog = dbcon.NewQuery("INSERT INTO `erro_connection_log`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[serverip]','[sql_ckey]','[sql_ip]','[sql_computerid]');")
	query_accesslog.Execute()


#undef UPLOAD_LIMIT
#undef MIN_CLIENT_VERSION

//checks if a client is afk
//3000 frames = 5 minutes
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
	sleep(1)

//send resources to the client. It's here in its own proc so we can move it around easiliy if need be
/client/proc/send_resources()

	getFiles(
		'html/search.js',
		'html/panels.css',
		'html/spacemag.css',
		'html/images/loading.gif',
		'html/images/ntlogo.png',
		'html/images/bluentlogo.png',
		'html/images/sollogo.png',
		'html/images/terralogo.png',
		'html/images/talisman.png'
		)

	spawn (10) //removing this spawn causes all clients to not get verbs.
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
			if (!D.send_slow(src)) //Precache the client with all other assets slowly, so as to not block other browse() calls
				return

mob/proc/MayRespawn()
	return 0

client/proc/MayRespawn()
	if(mob)
		return mob.MayRespawn()

	// Something went wrong, client is usually kicked or transfered to a new mob at this point
	return 0

client/verb/character_setup()
	set name = "Character Setup"
	set category = "OOC"
	if(prefs)
		prefs.ShowChoices(usr)

/client/proc/apply_fps(client_fps)
	if(world.byond_version >= 511 && byond_version >= 511 && client_fps >= CLIENT_MIN_FPS && client_fps <= CLIENT_MAX_FPS)
		vars["fps"] = prefs.clientfps

/client/proc/update_chat_position(use_alternative)
	var/input_height = 0
	input_height = winget(src, "input", "size")
	input_height = text2num(splittext(input_height, "x")[2])

	// Hell

	if (use_alternative == TRUE)
		winset(src, "input_alt", "is-visible=true;is-disabled=false;is-default=true")
		winset(src, "hotkey_toggle_alt", "is-visible=true;is-disabled=false;is-default=true")
		winset(src, "saybutton_alt", "is-visible=true;is-disabled=false;is-default=true")

		winset(src, "input", "is-visible=false;is-disabled=true;is-default=false")
		winset(src, "hotkey_toggle", "is-visible=false;is-disabled=true;is-default=false")
		winset(src, "saybutton", "is-visible=false;is-disabled=true;is-default=false")

		var/current_size = splittext(winget(src, "outputwindow.output", "size"), "x")
		var/new_size = "[current_size[1]]x[text2num(current_size[2]) - input_height]"
		winset(src, "outputwindow.output", "size=[new_size]")
		winset(src, "outputwindow.browseroutput", "size=[new_size]")

		current_size = splittext(winget(src, "mainwindow.mainvsplit", "size"), "x")
		new_size = "[current_size[1]]x[text2num(current_size[2]) + input_height]"
		winset(src, "mainwindow.mainvsplit", "size=[new_size]")
	else
		winset(src, "input_alt", "is-visible=false;is-disabled=true;is-default=false")
		winset(src, "hotkey_toggle_alt", "is-visible=false;is-disabled=true;is-default=false")
		winset(src, "saybutton_alt", "is-visible=false;is-disabled=true;is-default=false")

		winset(src, "input", "is-visible=true;is-disabled=false;is-default=true")
		winset(src, "hotkey_toggle", "is-visible=true;is-disabled=false;is-default=true")
		winset(src, "saybutton", "is-visible=true;is-disabled=false;is-default=true")

		var/current_size = splittext(winget(src, "outputwindow.output", "size"), "x")
		var/new_size = "[current_size[1]]x[text2num(current_size[2]) + input_height]"
		winset(src, "outputwindow.output", "size=[new_size]")
		winset(src, "outputwindow.browseroutput", "size=[new_size]")

		current_size = splittext(winget(src, "mainwindow.mainvsplit", "size"), "x")
		new_size = "[current_size[1]]x[text2num(current_size[2]) - input_height]"
		winset(src, "mainwindow.mainvsplit", "size=[new_size]")
	fit_viewport()

/client/proc/toggle_fullscreen(new_value)
	if((new_value == GLOB.PREF_BASIC) || (new_value == GLOB.PREF_FULL))
		winset(src, "mainwindow", "is-maximized=false;can-resize=false;titlebar=false")
		if(new_value == GLOB.PREF_FULL)
			winset(src, "mainwindow", "menu=null;statusbar=false")
		winset(src, "mainwindow.mainvsplit", "pos=0x0")
	else
		winset(src, "mainwindow", "is-maximized=false;can-resize=true;titlebar=true")
		winset(src, "mainwindow", "menu=menu;statusbar=true")
		winset(src, "mainwindow.mainvsplit", "pos=3x0")
	winset(src, "mainwindow", "is-maximized=true")
	fit_viewport()

/client/verb/fit_viewport()
	set name = "Fit Viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/sizes = params2list(winget(src, "mainwindow.mainvsplit;mapwindow", "size"))
	var/map_size = splittext(sizes["mapwindow.size"], "x")
	var/height = text2num(map_size[2])
	var/desired_width = round(height * aspect_ratio)
	if (text2num(map_size[1]) == desired_width)
		// Nothing to do
		return

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
