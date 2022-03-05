#define WHITELIST_MODE 0
#define ALLOW_ALL_MODE 1
SUBSYSTEM_DEF(redeye)
	// Red Eye Identification System
	// Yeah, this is "rice" translated from German
	name = "REIS"
	priority = SS_PRIORITY_REDEYE
	wait = 1

	// assoc list key - ckey, value - list of identifiers list("ip"=ip, "computer_id"=id)
	var/list/ckey_identifiers = list()
	// there we will contain ckey of players that allowed to use REIS
	var/list/listener_ckeys = list()

	var/mode = WHITELIST_MODE

	var/legal_codes = list(200, 301, 302)
	var/fired_by_byond = FALSE
	var/datum/browser/redeye_menu

/datum/controller/subsystem/redeye/Initialize()
	. = ..()
	// TODO [v]: read json file (data folder) that contains saved listener_ckeys
	if(fexists("data/redeye_ckeys.json"))
		listener_ckeys = json_decode(file2text("data/redeye_ckeys.json"))
	update_identifiers()
	check_byond()
	if(fired_by_byond || config.redeye_auth)
		remove_guests()

/datum/controller/subsystem/redeye/proc/remove_guests()
	for(var/client/C in GLOB.clients)
		if(IsGuestKey(C.key))
			var/url = winget(C, null, "url")
			//special javascript to make them reconnect under a new window.
			C << browse({"<a id='link' href="byond://[url]">byond://[url]</a><script type="text/javascript">document.getElementById("link").click();window.location="byond://winset?command=.quit"</script>"}, "border=0;titlebar=0;size=1x1;window=redirect")
			to_chat(C, {"<a href="byond://[url]">You will be automatically taken to the game, if not, click here to be taken manually</a>"})
			spawn(5 SECONDS)
				if(C)
					qdel(C)

/datum/controller/subsystem/redeye/Shutdown()
	text2file(json_encode(listener_ckeys), "data/redeye_ckeys.json")

/datum/controller/subsystem/redeye/proc/identify_client(list/client_data)
	var/client/C = client_data["client"]
	var/computer_id = C ? C.computer_id : client_data["comp_id"]
	var/ip_address = C ? C.address : client_data["ip_addr"]
	if(!computer_id && !ip_address)
		return FALSE
	for(var/ckey in ckey_identifiers)
		if(!(ckey in listener_ckeys) && mode == WHITELIST_MODE)
			return
		for(var/list/identifiers in ckey_identifiers[ckey])
			if(identifiers["id"] == computer_id && identifiers["ip_addr"] == ip_address)
				if(C)
					var/mob/M = get_mob_by_key(C.key)
					C.key = ckey
					M?.ckey = ckey
				return ckey
	return FALSE

/datum/controller/subsystem/redeye/proc/check_byond()
	var/list/byond_request = world.Export("http://www.byond.com")

	if((!byond_request || !(byond_request["STATUS"] in legal_codes)) && !fired_by_byond)
		if(!fired_by_byond)
			log_and_message_admins(SPAN_DANGER("Alert. \The [name] report BYOND website response code is not in legal code list, received status - [byond_request ? byond_request["STATUS"] : "undefined code"]. \The [name] is now active."))
			update_identifiers()
			fired_by_byond = TRUE
	else
		if(fired_by_byond && !config.redeye_auth)
			log_and_message_admins(SPAN_NOTICE("It's appears connection to BYOND is now up, \the [name] is inactive."))
			fired_by_byond = FALSE
	addtimer(CALLBACK(src, .proc/check_byond), 10 SECONDS)

/datum/controller/subsystem/redeye/proc/update_identifiers(new_ckey)
	if(new_ckey)
		if(!(new_ckey in listener_ckeys))
			listener_ckeys.Add(new_ckey)
	else
		// clear ckey indentifiers to save time for identification ppl
		ckey_identifiers = null
	var/DBQuery/query = sql_query("SELECT ckey, ip, computerid FROM erro_player[new_ckey ? " WHERE ckey = $ckey" : ""]", dbcon, list(ckey = new_ckey))
	while(query.NextRow())
		var/ckey = query.item[1]
		var/ip_addr = query.item[2]
		var/computer_id = query.item[3]
		if(!(ckey && ip_addr && computer_id))
			continue
		if(!length(ckey_identifiers[ckey]))
			ckey_identifiers[ckey] = list()
		// BYOND add all contents of list if it's just list, we don't want that, so we need double list.
		ckey_identifiers[ckey] += list(list("id" = computer_id, "ip_addr" = ip_addr))

// ADMIN INTERACTIONS
/datum/controller/subsystem/redeye/Topic(href, href_list)
	var/mob/user = usr
	if(!ismob(user) && !is_admin(user))
		return
	if(href_list["ckey_add"])
		var/ckey = ckey(sanitizeName(input(user, "Enter a ckey for new participant.", "New participant") as null|text))
		if(ckey)
			update_identifiers(ckey)
	if(href_list["ckey_remove"])
		var/ckey = input(user, "Select ckey from participant list", "Remove participant") as null|anything in listener_ckeys
		ckey = ckey(sanitizeName(ckey))
		if(ckey)
			ckey_identifiers.Remove(ckey)
			listener_ckeys.Remove(ckey)
	if(href_list["toggle_mode"])
		if (mode == WHITELIST_MODE)
			mode = ALLOW_ALL_MODE
		else if (mode == ALLOW_ALL_MODE)
			mode = WHITELIST_MODE

		to_chat(user, "You change the REIS's identification rules to [mode ? "allow all players from db" :  "allow only players from whitelist"].")

	show_control_panel(user)

/datum/controller/subsystem/redeye/proc/show_control_panel(mob/user)
	if(!is_admin(user))
		return
	var/dat = "<a href='?src=\ref[src];toggle_mode=1'>Change access mode.</a><BR><a href='?src=\ref[src];ckey_add=1'>Add participant.</a><BR><a href='?src=\ref[src];ckey_remove=1'>Remove participant.</a>"
	dat += "<BR>Ckeys of participants in \the [name]:"
	for(var/key in listener_ckeys)
		var/mob/M = get_mob_by_key(key)
		dat += "<BR>[key]. Status: [M ? "online. Occupied by: [M]" : "offline"]."

	if(!redeye_menu || redeye_menu.user != user)
		redeye_menu = new /datum/browser(user, "[name]", "<B>[name] Admin Actions</B>", 400, 610)
		redeye_menu.set_content(dat)
	else
		redeye_menu.set_content(dat)
		redeye_menu.update()
	redeye_menu.open()
	return

#undef WHITELIST_MODE
#undef ALLOW_ALL_MODE
