/datum/watchlist


/datum/watchlist/proc/Add(target_ckey, browse = 0)
	if(!establish_db_connection())
		return

	if (!target_ckey)
		var/new_ckey = ckey(input(usr, "Who would you like to add to the watchlist?", "Enter a ckey", null) as text)
		if (!new_ckey)
			return

		var/DBQuery/query_watchfind = sql_query({"
			SELECT
				ckey
			FROM
				erro_player
			WHERE
				ckey = $new_ckey
			"}, dbcon, list(new_ckey = new_ckey))

		if (!query_watchfind.NextRow())
			if (alert(usr, "[new_ckey] has not been seen before, are you sure you want to add them to the watchlist?", "Unknown ckey", "Yes", "No", "Cancel") != "Yes")
				return

		target_ckey = new_ckey

	if (Check(target_ckey))
		to_chat(usr, "<span class='redtext'>[target_ckey] is already on the watchlist.</span>")
		return

	var/reason = sanitize(input(usr, "Please State Reason", "Reason"))
	if (!reason)
		return

	var/adminckey = usr.ckey
	if (!adminckey)
		return

	sql_query({"
		INSERT INTO
			erro_watch
				(ckey,
				reason,
				adminckey,
				timestamp)
		VALUES
			($target_ckey,
			$reason,
			$adminckey,
			Now())
		"}, dbcon, list(target_ckey = target_ckey, reason = reason, adminckey = adminckey))

	reason = html_decode(reason)
	log_admin("[key_name(usr)] has added [target_ckey] to the watchlist - Reason: [reason]", notify_admin = TRUE)

	for(var/client/player in GLOB.clients)
		if (player.ckey == target_ckey)
			player.watchlist_warn = reason
			break

	if (browse)
		Show(target_ckey)


/datum/watchlist/proc/Check(target_ckey)
	if(!establish_db_connection())
		return

	var/DBQuery/query_watch = sql_query({"
		SELECT
			reason
		FROM
			erro_watch
		WHERE
			ckey = $target_ckey
		"}, dbcon, list(target_ckey = target_ckey))

	if (query_watch.NextRow())
		return html_decode(query_watch.item[1])
	else
		return null


/datum/watchlist/proc/Remove(target_ckey, browse = 0)
	if(!establish_db_connection())
		return

	sql_query({"
		DELETE FROM
			erro_watch
		WHERE
			ckey = $target_ckey
		"}, dbcon, list(target_ckey = target_ckey))

	log_admin("[key_name(usr)] has removed [target_ckey] from the watchlist", notify_admin = TRUE)

	for(var/client/player in GLOB.clients)
		if (player.ckey == target_ckey)
			player.watchlist_warn = null
			break

	if(browse)
		Show()


/datum/watchlist/proc/Edit(target_ckey, browse = 0)
	if(!establish_db_connection())
		return

	var/DBQuery/query_watchreason = sql_query({"
		SELECT
			reason
		FROM
			erro_watch
		WHERE
			ckey = $target_ckey
		"}, dbcon, list(target_ckey = target_ckey))

	if (query_watchreason.NextRow())
		var/watch_reason = query_watchreason.item[1]

		var/new_reason = sanitize(input(usr, "Input new reason", "New Reason", html_decode(watch_reason)))
		if (!new_reason)
			return

		var/admin_ckey = usr.ckey
		var/edit_text = "Edited by [admin_ckey] on [time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")] from<br>[watch_reason]<br>to<br>[new_reason]<hr>"
		sql_query({"
			UPDATE
				erro_watch
			SET
				reason = $new_reason,
				last_editor = $admin_ckey,
				edits = CONCAT(
					IFNULL(edits,''),
					$edit_text
				)
			WHERE
				ckey = $target_ckey
			"}, dbcon, list(new_reason = new_reason, admin_ckey = admin_ckey, edit_text = edit_text, target_ckey = target_ckey))

		watch_reason = html_decode(watch_reason)
		new_reason = html_decode(new_reason)
		log_admin("[key_name(usr)] has edited [target_ckey]'s watchlist reason from [watch_reason] to [new_reason]", notify_admin = TRUE)

		for(var/client/player in GLOB.clients)
			if (player.ckey == target_ckey)
				player.watchlist_warn = new_reason
				break

		if (browse)
			Show(target_ckey)


/datum/watchlist/proc/Show(search)
	if(!establish_db_connection())
		return

	var/output = "<meta charset=\"utf-8\">"
	output += "<form method='GET' name='search' action='?'>\
	<input type='hidden' name='_src_' value='holder'>\
	<input type='text' name='watchsearch' value='[search]'>\
	<input type='submit' value='Search'></form>"
	output += "<a href='?_src_=holder;watchshow=1'>\[Clear Search\]</a> <a href='?_src_=holder;watchaddbrowse=1'>\[Add Ckey\]</a>"
	output += "<hr style='background:#000000; border:0; height:3px'>"

	if(search)
		search = "^[search]"
	else
		search = "^."

	var/DBQuery/query_watchlist = sql_query({"
		SELECT
			ckey,
			reason,
			adminckey,
			timestamp,
			last_editor
		FROM
			erro_watch
		WHERE
			ckey REGEXP $search
		ORDER BY
			ckey
		"}, dbcon, list(search = search))

	while(query_watchlist.NextRow())
		var/ckey = query_watchlist.item[1]
		var/reason = query_watchlist.item[2]
		var/adminckey = query_watchlist.item[3]
		var/timestamp = query_watchlist.item[4]
		var/last_editor = query_watchlist.item[5]
		output += "<b>[ckey]</b> | Added by <b>[adminckey]</b> on <b>[timestamp]</b> <a href='?_src_=holder;watchremovebrowse=[ckey]'>\[Remove\]</a> <a href='?_src_=holder;watcheditbrowse=[ckey]'>\[Edit Reason\]</a>"
		if(last_editor)
			output += " <font size='2'>Last edit by [last_editor] <a href='?_src_=holder;watcheditlog=[ckey]'>(Click here to see edit log)</a></font>"
		output += "<br>[reason]<hr style='background:#000000; border:0; height:1px'>"

	show_browser(usr, output, "window=watchwin;size=900x500")

/datum/watchlist/proc/OnLogin(client/C)
	if (!C)
		return

	C.watchlist_warn = watchlist.Check(C.ckey)
	if (C.watchlist_warn)
		message_admins("<font color='red'><B>WATCHLIST: </B></font><span class='info'>[key_name_admin(C)] has just connected - Reason: [C.watchlist_warn]</span>")

	if (check_rights((R_ADMIN|R_MOD), 0, C))
		for(var/client/player in GLOB.clients)
			if (player.watchlist_warn)
				to_chat(C, "<span class=\"log_message\"><font color='red'><B>WATCHLIST: </B></font><span class='info'>[key_name_admin(player)] is playing - Reason: [player.watchlist_warn]</span></span>")

/datum/watchlist/proc/AdminTopicProcess(datum/admins/source, list/href_list)
	if(href_list["watchadd"])
		var/target_ckey = locate(href_list["watchadd"])
		Add(target_ckey)
		source.show_player_panel(usr.client.mob)

	else if(href_list["watchremove"])
		var/target_ckey = href_list["watchremove"]
		Remove(target_ckey)
		source.show_player_panel(usr.client.mob)

	else if(href_list["watchedit"])
		var/target_ckey = href_list["watchedit"]
		Edit(target_ckey)
		source.show_player_panel(usr.client.mob)

	else if(href_list["watchaddbrowse"])
		Add(null, 1)

	else if(href_list["watchremovebrowse"])
		var/target_ckey = href_list["watchremovebrowse"]
		Remove(target_ckey, 1)

	else if(href_list["watcheditbrowse"])
		var/target_ckey = href_list["watcheditbrowse"]
		Edit(target_ckey, 1)

	else if(href_list["watchsearch"])
		var/target_ckey = href_list["watchsearch"]
		Show(target_ckey)

	else if(href_list["watchshow"])
		Show()

	else if(href_list["watcheditlog"])
		if(!establish_db_connection())
			return

		var/target_ckey = href_list["watcheditlog"]

		var/DBQuery/query_watchedits = sql_query({"
			SELECT
				edits
			FROM
				erro_watch
			WHERE
				ckey = $target_ckey
			"}, dbcon, list(target_ckey = target_ckey))

		if(query_watchedits.NextRow())
			var/edit_log = query_watchedits.item[1]
			show_browser(usr, edit_log,"window=watchedits")
