/datum/admins/proc/DB_ban_record(bantype, mob/banned_mob, duration = -1, reason, job = "", rounds = 0, banckey = null, banip = null, bancid = null, ban_everywhere = FALSE)
	if(!src || !src.owner)
		return
	_DB_ban_record(src.owner.ckey, src.owner.computer_id, src.owner.address, bantype, banned_mob, duration, reason, job, rounds, banckey, banip, bancid, ban_everywhere)

//Either pass the mob you wish to ban in the 'banned_mob' attribute, or the banckey, banip and bancid variables. If both are passed, the mob takes priority! If a mob is not passed, banckey is the minimum that needs to be passed! banip and bancid are optional.
/proc/_DB_ban_record(var/a_ckey, var/a_computerid, a_ip, bantype, mob/banned_mob, duration = -1, reason, job = "", rounds = 0, banckey = null, banip = null, bancid = null, ban_everywhere = FALSE)

	if(usr)
		if(!check_rights(R_MOD,0) && !check_rights(R_BAN))	return

	if(!establish_db_connection())
		return 0

	var/serverip = "[world.internet_address]:[world.port]"
	var/bantype_pass = 0
	var/bantype_str
	switch(bantype)
		if(BANTYPE_PERMA)
			bantype_str = "PERMABAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_TEMP)
			bantype_str = "TEMPBAN"
			bantype_pass = 1
		if(BANTYPE_JOB_PERMA)
			bantype_str = "JOB_PERMABAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_JOB_TEMP)
			bantype_str = "JOB_TEMPBAN"
			bantype_pass = 1
	if( !bantype_pass ) return 0
	if( !istext(reason) ) return 0
	if( !isnum(duration) ) return 0

	var/ckey
	var/computerid
	var/ip

	if(ismob(banned_mob))
		ckey = banned_mob.ckey
		if(banned_mob.client)
			computerid = banned_mob.client.computer_id
			ip = banned_mob.client.address
	else if(banckey)
		ckey = ckey(banckey)
		computerid = bancid
		ip = banip

	var/who
	for(var/client/C in GLOB.clients)
		if(!who)
			who = "[C]"
		else
			who += ", [C]"

	var/adminwho
	for(var/client/C in GLOB.admins)
		if(!adminwho)
			adminwho = "[C]"
		else
			adminwho += ", [C]"

	if(isnull(config.server_id))
		sql_query({"
			INSERT INTO
				erro_ban
			VALUES
				(null,
				Now(),
				$serverip,
				$bantype_str,
				$reason,
				$job,
				$duration,
				$rounds,
				Now() + INTERVAL $duration MINUTE,
				$ckey,
				$computerid,
				$ip,
				$a_ckey,
				$a_computerid,
				$a_ip,
				$who,
				$adminwho,
				'', null, null, null, null, null, null, null)
			"}, dbcon, list(serverip = serverip, bantype_str = bantype_str, reason = reason, job = job,
				duration = duration ? duration : 0,
				rounds = rounds ? "[rounds]" : "0", ckey = ckey,
				computerid = computerid ? computerid : "",
				ip = ip ? ip : "", a_ckey = a_ckey,
				a_computerid = a_computerid ? a_computerid : "",
				a_ip = a_ip ? a_ip : "",
				who = who, adminwho = adminwho))
	else
		if(ban_everywhere)
			sql_query({"
				INSERT INTO
					erro_ban
				VALUES
					(null,
					Now(),
					$serverip,
					$bantype_str,
					$reason,
					$job,
					$duration,
					$rounds,
					Now() + INTERVAL $duration MINUTE,
					$ckey,
					$computerid,
					$ip,
					$a_ckey,
					$a_computerid,
					$a_ip,
					$who,
					$adminwho,
					'', null, null, null, null, null, null, 'main'),

					(null,
					Now(),
					$serverip,
					$bantype_str,
					$reason,
					$job,
					$duration,
					$rounds,
					Now() + INTERVAL $duration MINUTE,
					$ckey,
					$computerid,
					$ip,
					$a_ckey,
					$a_computerid,
					$a_ip,
					$who,
					$adminwho,
					'', null, null, null, null, null, null, 'beginners'),

					(null,
					Now(),
					$serverip,
					$bantype_str,
					$reason,
					$job,
					$duration,
					$rounds,
					Now() + INTERVAL $duration MINUTE,
					$ckey,
					$computerid,
					$ip,
					$a_ckey,
					$a_computerid,
					$a_ip,
					$who,
					$adminwho,
					'', null, null, null, null, null, null, 'main'),

					(null,
					Now(),
					$serverip,
					$bantype_str,
					$reason,
					$job,
					$duration,
					$rounds,
					Now() + INTERVAL $duration MINUTE,
					$ckey,
					$computerid,
					$ip,
					$a_ckey,
					$a_computerid,
					$a_ip,
					$who,
					$adminwho,
					'', null, null, null, null, null, null, 'light')
				"}, dbcon, list(serverip = serverip, bantype_str = bantype_str, reason = reason, job = job,
					duration = duration ? duration : 0,
					rounds = rounds ? "[rounds]" : "0", ckey = ckey,
					computerid = computerid ? computerid : "", ip = ip, a_ckey = a_ckey,
					a_computerid = a_computerid ? a_computerid : "",
					a_ip = a_ip ? a_ip : "", who = who, adminwho = adminwho))

		else
			sql_query({"
				INSERT INTO
					erro_ban
				VALUES
					(null,
					Now(),
					$serverip,
					$bantype_str,
					$reason,
					$job,
					$duration,
					$rounds,
					Now() + INTERVAL $duration MINUTE,
					$ckey,
					$computerid,
					$ip,
					$a_ckey,
					$a_computer_id,
					$a_ip,
					$who,
					$adminwho,
					'', null, null, null, null, null, null, $server_id)
				"}, dbcon, list(serverip = serverip, bantype_str = bantype_str, reason = reason, job = job,
				duration = duration ? duration : 0,
				rounds = rounds ? "[rounds]" : "0", ckey = ckey,
				computerid = computerid ? computerid : "",
				ip = ip ? ip : "", a_ckey = a_ckey,
				a_computer_id = a_computerid ? a_computerid : "",
				a_ip = a_ip ? a_ip : "", who = who, adminwho = adminwho, server_id = config.server_id))

	var/setter = a_ckey
	if(usr)
		to_chat(usr, "<span class='notice'>Ban saved to database.</span>", confidential = TRUE)
		setter = key_name_admin(usr)
	message_admins("[setter] has added a [(ban_everywhere)?"Onyx wide":""] [bantype_str] for [ckey] [(job)?"([job])":""] [(duration > 0)?"([duration] minutes)":""] with the reason: \"[reason]\" to the ban database.",1)
	if(ismob(banned_mob) && banned_mob.client)
		var/rendered_text = uppertext("You have been [(duration > 0) ? "temporarily ([duration] minutes)" : "permanently"] banned with the reason: ")
		rendered_text = rendered_text + "\n\"[reason]\"."
		rendered_text = "<font size='12' color='red'><b>[rendered_text]</b></font>"
		to_chat(banned_mob, rendered_text, MESSAGE_TYPE_SYSTEM)
	return 1

/datum/admins/proc/DB_ban_unban(ckey, bantype, job = "")
	if(!establish_db_connection())
		return

	if(!check_rights(R_BAN))
		return

	var/bantype_str
	if(bantype)
		var/bantype_pass = 0
		switch(bantype)
			if(BANTYPE_PERMA)
				bantype_str = "PERMABAN"
				bantype_pass = 1
			if(BANTYPE_TEMP)
				bantype_str = "TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_JOB_PERMA)
				bantype_str = "JOB_PERMABAN"
				bantype_pass = 1
			if(BANTYPE_JOB_TEMP)
				bantype_str = "JOB_TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_ANY_FULLBAN)
				bantype_str = "ANY"
				bantype_pass = 1
		if( !bantype_pass ) return

	var/bantype_sql
	if(bantype_str == "ANY")
		bantype_sql = "(bantype = 'PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now() ) )"
	else
		bantype_sql = "bantype = $bantype_str"

	var/ban_id
	var/ban_number = 0 //failsafe

	var/DBQuery/query = sql_query({"
		SELECT
			id
		FROM
			erro_ban
		WHERE
			ckey = $ckey
			AND
			[bantype_sql]
			AND
				(unbanned is null
				OR
				unbanned = false)
			[isnull(config.server_id) ? "" : " AND server_id = $server_id"]
			[job ? " AND job = $job" : ""]
		"}, dbcon, list(ckey = ckey, bantype_str = bantype_str, server_id = config.server_id, job = job))

	while(query.NextRow())
		ban_id = query.item[1]
		ban_number++;

	if(ban_number == 0)
		to_chat(usr, "<span class='warning'>Database update failed due to no bans fitting the search criteria. If this is not a legacy ban you should contact the database admin.</span>", confidential = TRUE)
		return

	if(ban_number > 1)
		to_chat(usr, "<span class='warning'>Database update failed due to multiple bans fitting the search criteria. Note down the ckey, job and current time and contact the database admin.</span>", confidential = TRUE)
		return

	if(istext(ban_id))
		ban_id = text2num(ban_id)
	if(!isnum(ban_id))
		to_chat(usr, "<span class='warning'>Database update failed due to a ban ID mismatch. Contact the database admin.</span>", confidential = TRUE)
		return

	DB_ban_unban_by_id(ban_id)

/datum/admins/proc/DB_ban_edit(banid = null, param = null)
	if(!establish_db_connection())
		return

	if(!check_rights(R_BAN))	return

	if(!isnum(banid) || !istext(param))
		to_chat(usr, "Cancelled", confidential = TRUE)
		return

	var/DBQuery/query
	if(isnull(config.server_id))
		query = sql_query("SELECT ckey, duration, reason FROM erro_ban WHERE id = $banid", dbcon, list(banid = banid))
	else
		query = sql_query("SELECT ckey, duration, reason, server_id FROM erro_ban WHERE id = $banid", dbcon, list(banid = banid))

	var/eckey = usr.ckey	//Editing admin ckey
	var/pckey				//(banned) Player ckey
	var/duration			//Old duration
	var/reason				//Old reason
	var/serverid			//Server where ckey was banned

	if(query.NextRow())
		pckey = query.item[1]
		duration = query.item[2]
		reason = query.item[3]
		if(!isnull(config.server_id))
			serverid = query.item[4]
	else
		to_chat(usr, "Invalid ban id. Contact the database admin", confidential = TRUE)
		return
	var/value

	switch(param)
		if("reason")
			if(!value)
				value = sanitize(input("Insert the new reason for [pckey]'s ban", "New Reason", "[reason]", null) as null|text)
				if(!value)
					to_chat(usr, "Cancelled", confidential = TRUE)
					return

			sql_query({"
				UPDATE
					erro_ban
				SET
					reason = $value,
					edits = CONCAT
						(edits,
						'- $eckey changed ban reason from <cite><b>\"$reason\"</b></cite> to <cite><b>\"$value\"</b></cite><BR>')
				WHERE
					id = $banid
				"}, dbcon, list(value = value, eckey = eckey, reason = reason, banid = banid))
			if(serverid)
				message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s on [serverid] server. Reason set from [reason] to [value]",1)
			else
				message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s reason from [reason] to [value]",1)
		if("duration")
			if(!value)
				value = input("Insert the new duration (in minutes) for [pckey]'s ban", "New Duration", "[duration]", null) as null|num
				if(!isnum(value) || !value)
					to_chat(usr, "Cancelled")
					return

			sql_query({"
				UPDATE
					erro_ban
				SET
					duration = $value,
					edits = CONCAT
						(edits,
						'- $eckey changed ban duration from $duration to $value<br>'),
					expiration_time = DATE_ADD
						(bantime,
						INTERVAL $value MINUTE)
				WHERE
					id = $banid
				"}, dbcon, list(value = value, eckey = eckey, duration = duration, banid = banid))
			if(serverid)
				message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s duration from [duration] to [value]",1)
			else
				message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s on [serverid] server. Duration set from [duration] to [value]",1)
		if("unban")
			if(alert("Unban [pckey]?", "Unban?", "Yes", "No") == "Yes")
				DB_ban_unban_by_id(banid)
				return
			else
				to_chat(usr, "Cancelled", confidential = TRUE)
				return
		else
			to_chat(usr, "Cancelled", confidential = TRUE)
			return

/datum/admins/proc/DB_ban_unban_by_id(id)
	if(!establish_db_connection())
		return

	if(!check_rights(R_BAN))	return

	var/sql
	if(isnull(config.server_id))
		sql = "SELECT ckey FROM erro_ban WHERE id = $id"
	else
		sql = "SELECT ckey, server_id FROM erro_ban WHERE id = $id"

	var/ban_number = 0 //failsafe

	var/pckey
	var/serverid
	var/DBQuery/query = sql_query(sql, dbcon, list(id = id))
	while(query.NextRow())
		pckey = query.item[1]
		if(!isnull(config.server_id))
			serverid = query.item[2]
		ban_number++;

	if(ban_number == 0)
		to_chat(usr, "<span class='warning'>Database update failed due to a ban id not being present in the database.</span>", confidential = TRUE)
		return

	if(ban_number > 1)
		to_chat(usr, "<span class='warning'>Database update failed due to multiple bans having the same ID. Contact the database admin.</span>", confidential = TRUE)
		return

	if(!src.owner || !istype(src.owner, /client))
		return

	var/unban_ckey = src.owner.ckey
	var/unban_computerid = src.owner.computer_id
	var/unban_ip = src.owner.address

	sql_query({"
		UPDATE
			erro_ban
		SET
			unbanned = 1,
			unbanned_datetime = Now(),
			unbanned_ckey = $unban_ckey,
			unbanned_computerid = $unbancid,
			unbanned_ip = $unbanip
		WHERE
			id = $id
		"}, dbcon, list(unban_ckey = unban_ckey, unbancid = unban_computerid, unbanip = unban_ip, id = id))

	if(serverid)
		message_admins("[key_name_admin(usr)] has lifted [pckey]'s ban of [serverid] server.", 1)
	else
		message_admins("[key_name_admin(usr)] has lifted [pckey]'s ban.", 1)

/client/proc/DB_ban_panel()
	set category = "Admin"
	set name = "Banning Panel"
	set desc = "Edit admin permissions"

	if(!holder)
		return

	holder.DB_ban_panel()


/datum/admins/proc/DB_ban_panel(playerckey = null, adminckey = null, playerip = null, playercid = null, dbbantype = null, match = null)
	if(!usr.client)
		return

	if(!check_rights(R_BAN))	return

	if(!establish_db_connection())
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>", confidential = TRUE)
		return

	var/output = "<!doctype html><html lang=\"ru\"><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta charset=\"utf-8\"><title>Ban panel</title><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><link rel=\"stylesheet\" href=\"https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css\"><link href=\"css/bootstrap-ie8.css\" rel=\"stylesheet\"><script src=\"https://cdn.jsdelivr.net/g/html5shiv@3.7.3\"></script><style>label{font-size: 16px;}h3{font-size: 20px;}</style></head><div class=\"container\"><h3>Add custom ban<small class=\"text-muted\"> use only when you can't ban through any other method</small></h3>"

	output += "<form method='GET' action='?src=\ref[src]'><input type='hidden' name='src' value='\ref[src]'>"

	output += "<table width='100%'><tr><td width='50%'><div class=\"form-group\"><label for=\"dbbanaddtype\">Ban type</label><select name='dbbanaddtype' class=\"form-control form-control-sm\" id=\"dbbanaddtype\"><option value=''>--</option><option value='1'>PERMABAN</option><option value='2'>TEMPBAN</option><option value='3'>JOB PERMABAN</option><option value='4'>JOB TEMPBAN</option></select></div></td><td width='50%'><div class=\"form-group\"><label for=\"dbbanaddckey\">Ckey</label><input type='text' name='dbbanaddckey'class=\"form-control form-control-sm\" id=\"dbbanaddckey\"></div></td></tr><tr><td width='50%'><div class=\"form-group\"><label for=\"dbbanaddip\">IP</label><input type='text' name='dbbanaddip'class=\"form-control form-control-sm\" id=\"dbbanaddip\"></div></td><td width='50%'><div class=\"form-group\"><label for=\"dbbanaddcid\">CID</label><input type='text' name='dbbanaddcid'class=\"form-control form-control-sm\" id=\"dbbanaddcid\"></div></td></tr><tr><td width='50%'><div class=\"form-group\"><label for=\"dbbaddduration\">Duration</label><input type='text'name='dbbaddduration' class=\"form-control form-control-sm\" id=\"dbbaddduration\"></div></td><td width='50%'><div class=\"form-group\"><label for=\"dbbanaddjob\">Ban job</label><select name='dbbanaddjob'class=\"form-control form-control-sm\" id=\"dbbanaddjob\"><option value=''>--</option>"

	for(var/j in list("OOC", "LOOC", "AHelp", "Species", "Male", "Female", "Appearance", "Name")) // new bans
		output += "<option value='[j]'>[j]</option>"
	for(var/j in get_all_jobs())
		output += "<option value='[j]'>[j]</option>"
	for(var/j in GLOB.nonhuman_positions)
		output += "<option value='[j]'>[j]</option>"
	var/list/bantypes = list("traitor","changeling","vampire","operative","revolutionary","cultist","wizard") //For legacy bans.
	var/list/all_antag_types = GLOB.all_antag_types_
	for(var/antag_type in all_antag_types) // Grab other bans.
		var/datum/antagonist/antag = all_antag_types[antag_type]
		bantypes |= antag.id
	for(var/j in bantypes)
		output += "<option value='[j]'>[j]</option>"
	output += "</select></div></td></tr></table><div class=\"form-group\"><label for=\"dbbanreason\">Reason</label><textarea name='dbbanreason' cols='50' class=\"form-control\" id=\"dbbanreason\" rows=\"3\"></textarea><br><div class=\"row\"><div class=\"col-lg-3\" style=\"padding-top: 0.45rem;\"><div class=\"custom-control custom-switch\"><input type=\"checkbox\" class=\"custom-control-input\" value='0' name=\"dbbaneverywhere\" id=\"dbbaneverywhere\"><label class=\"custom-control-label\" for=\"dbbaneverywhere\">Ban everywhere</label></div></div><div class=\"col-lg-3\"><input type='submit' class=\"btn btn-danger\" value='Add ban'></div></div></div></form>"
	output += "<form method='GET' action='?src=\ref[src]'>"
	output += "<table width='90%'><tr><td colspan='2' align='left'><h3>Search<small class=\"text-muted\"> this search shows only last 100 bans</small>"
	output += "<input type='hidden' name='src' value='\ref[src]'>"
	output += "</h3></td></tr><tr><td width='50%'><div class=\"form-group\"><label for=\"dbsearchbantype\">Ban type</label><select name='dbsearchbantype' class=\"form-control form-control-sm\" id=\"dbsearchbantype\"><option value=''>--</option><option value='1'>PERMABAN</option><option value='2'>TEMPBAN</option><option value='3'>JOB PERMABAN</option><option value='4'>JOB TEMPBAN</option></select></div></td><td width='50%'><div class=\"form-group\"><label for=\"dbsearchckey\">Ckey</label><input type='text' name='dbsearchckey'class=\"form-control form-control-sm\" id=\"dbsearchckey\"></div></td></tr><tr><td width='50%'><div class=\"form-group\"><label for=\"dbsearchip\">IP</label><input type='text' name='dbsearchip'class=\"form-control form-control-sm\" id=\"dbsearchip\"></div></td><td width='50%'><div class=\"form-group\"><label for=\"dbsearchcid\">CID</label><input type='text' name='dbsearchcid'class=\"form-control form-control-sm\" id=\"dbsearchcid\"></div></td></tr><tr><td width='50%'><div class=\"form-group\"><label for=\"dbsearchadmin\">Admin ckey</label><input type='text'name='dbsearchadmin' class=\"form-control form-control-sm\" id=\"dbsearchadmin\"></div></td><td class=\"col-lg-6\"><div class=\"custom-control custom-switch\" style=\"padding-top: 0.7rem;\">"
	output += "<input type=\"checkbox\" id=\"dbmatch\" value='0' name='dbmatch'>"
	output += "<labelclass=\"custom-control-label\" for=\"dbmatch\">Match (min. 3 characters for key or ip. 7 for cid)</label></div></td></tr></table><div class=\"form-group\"><input type='submit' class=\"btn btn-primary\" value='Search'></div></table></form><p><small>Please note that all jobban bans or unbans are in-effect the following round</small></p></div>"

	if(adminckey || playerckey || playerip || playercid || dbbantype)

		adminckey = ckey(adminckey)
		playerckey = ckey(playerckey)
		if(adminckey || playerckey || playerip || playercid || dbbantype)

			var/blcolor = "#ffeeee" //banned light
			var/bdcolor = "#ffdddd" //banned dark
			var/ulcolor = "#eeffee" //unbanned light
			var/udcolor = "#ddffdd" //unbanned dark
			var/alcolor = "#eeeeff" // auto-unbanned light
			var/adcolor = "#ddddff" // auto-unbanned dark

			output += "<div class=\"container\"><table class=\"table table-hover\" cellpadding='5' cellspacing='0' align='center'>"
			output += "<tr>"
			output += "<th width='25%'><b>TYPE</b></th>"
			output += "<th width='20%'><b>CKEY</b></th>"
			output += "<th width='20%'><b>TIME APPLIED</b></th>"
			output += "<th width='20%'><b>ADMIN</b></th>"
			output += "<th width='15%'><b>OPTIONS</b></th>"
			output += "</tr>"

			var/adminsearch = ""
			var/playersearch = ""
			var/ipsearch = ""
			var/cidsearch = ""
			var/bantypesearch = ""

			if(dbbantype)
				bantypesearch = "AND bantype = "

				switch(dbbantype)
					if(BANTYPE_TEMP)
						bantypesearch += "'TEMPBAN' "
					if(BANTYPE_JOB_PERMA)
						bantypesearch += "'JOB_PERMABAN' "
					if(BANTYPE_JOB_TEMP)
						bantypesearch += "'JOB_TEMPBAN' "
					else
						bantypesearch += "'PERMABAN' "

			var/DBQuery/select_query
			var/list/query_arg_list

			if(!match)
				if(adminckey)
					adminsearch = "AND a_ckey = $adminckey "
				if(playerckey)
					playersearch = "AND ckey = $playerckey "
				if(playerip)
					ipsearch  = "AND ip = $playerip "
				if(playercid)
					cidsearch  = "AND computerid = $playercid "
				query_arg_list = list(playerckey = playerckey, adminckey = adminckey, playerip = playerip, playercid = playercid)

			else
				if(adminckey && length(adminckey) >= 3)
					adminsearch = "AND a_ckey LIKE $adminckey "
				if(playerckey && length(playerckey) >= 3)
					playersearch = "AND ckey LIKE $playerckey "
				if(playerip && length(playerip) >= 3)
					ipsearch  = "AND ip LIKE $playerip "
				if(playercid && length(playercid) >= 7)
					cidsearch  = "AND computerid LIKE $playercid "
				query_arg_list = list(playerckey = "%" + playerckey + "%", adminckey = "%" + adminckey + "%", playerip = "%" + playerip + "%", playercid = "%" + playercid + "%")

			select_query = sql_query({"
				SELECT
					id,
					bantime,
					bantype,
					reason,
					job,
					duration,
					expiration_time,
					ckey,
					a_ckey,
					unbanned,
					unbanned_ckey,
					unbanned_datetime,
					edits,
					ip,
					computerid,
					server_id
				FROM
					erro_ban
				WHERE
					1
					[playersearch]
					[adminsearch]
					[ipsearch]
					[cidsearch]
					[bantypesearch]
				ORDER BY
					bantime
				DESC LIMIT
					100
				"}, dbcon, query_arg_list)

			var/now = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss") // MUST BE the same format as SQL gives us the dates in, and MUST be least to most specific (i.e. year, month, day not day, month, year)

			while(select_query.NextRow())
				var/banid = select_query.item[1]
				var/bantime = select_query.item[2]
				var/bantype  = select_query.item[3]
				var/reason = select_query.item[4]
				var/job = select_query.item[5]
				var/duration = select_query.item[6]
				var/expiration = select_query.item[7]
				var/ckey = select_query.item[8]
				var/ackey = select_query.item[9]
				var/unbanned = select_query.item[10]
				var/unbanckey = select_query.item[11]
				var/unbantime = select_query.item[12]
				var/edits = select_query.item[13]
				var/ip = select_query.item[14]
				var/cid = select_query.item[15]
				var/server_id
				if(!isnull(config.server_id))
					server_id = select_query.item[16]

				// true if this ban has expired
				var/auto = (bantype in list("TEMPBAN", "JOB_TEMPBAN")) && now > expiration // oh how I love ISO 8601 (ish) date strings

				var/lcolor = blcolor
				var/dcolor = bdcolor
				if(unbanned)
					lcolor = ulcolor
					dcolor = udcolor
				else if(auto)
					lcolor = alcolor
					dcolor = adcolor

				var/typedesc =""
				switch(bantype)
					if("PERMABAN")
						typedesc = "<font color='red'><b>PERMABAN</b></font>"
					if("TEMPBAN")
						typedesc = "<b>TEMPBAN</b><br><font size='2'>([duration] minutes) [(unbanned || auto) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=duration;dbbanid=[banid]\">Edit</a>)"]<br>Expires [expiration]</font>"
					if("JOB_PERMABAN")
						typedesc = "<b>JOBBAN</b><br><font size='2'>([job])</font>"
					if("JOB_TEMPBAN")
						typedesc = "<b>TEMP JOBBAN</b><br><font size='2'>([job])<br>([duration] minutes<br>Expires [expiration]</font>"

				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center'>[typedesc]</td>"
				output += "<td align='center'><b>[ckey]</b></td>"
				output += "<td align='center'>[bantime]</td>"
				output += "<td align='center'><b>[ackey]</b></td>"
				output += "<td align='center'>[(unbanned || auto) ? "" : "<b><a href=\"byond://?src=\ref[src];dbbanedit=unban;dbbanid=[banid]\">Unban</a></b>"]</td>"
				output += "</tr>"
				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center' colspan='2' bgcolor=''><b>IP:</b> [ip]</td>"
				output += "<td align='center' colspan='2' bgcolor=''><b>CIP:</b> [cid]</td>"
				if(!isnull(server_id))
					output += "<td align='center' colspan='1' bgcolor=''><b>SERVER:</b> [server_id]</td>"
				output += "</tr>"
				output += "<tr bgcolor='[lcolor]'>"
				if(!isnull(server_id))
					output += "<td align='center' colspan='5'><b>Reason: [(unbanned || auto) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=reason;dbbanid=[banid];dbserverid=[server_id]\">Edit</a>)"]</b> <cite>\"[reason]\"</cite></td>"
				else
					output += "<td align='center' colspan='5'><b>Reason: [(unbanned || auto) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=reason;dbbanid=[banid]\">Edit</a>)"]</b> <cite>\"[reason]\"</cite></td>"

				output += "</tr>"
				if(edits)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5'><b>EDITS</b></td>"
					output += "</tr>"
					output += "<tr bgcolor='[lcolor]'>"
					output += "<td align='center' colspan='5'><font size='2'>[edits]</font></td>"
					output += "</tr>"
				if(unbanned)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5' bgcolor=''><b>UNBANNED by admin [unbanckey] on [unbantime]</b></td>"
					output += "</tr>"
				else if(auto)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5' bgcolor=''><b>EXPIRED at [expiration]</b></td>"
					output += "</tr>"
				output += "<tr>"
				output += "<td colspan='5' bgcolor='white'>&nbsp</td>"
				output += "</tr>"

			output += "</table></div>"

	show_browser(usr, output,"window=lookupbans;size=900x700")
