GLOBAL_LIST_EMPTY(IAA_active_jobbans_list)
GLOBAL_LIST_EMPTY(IAA_approved_list)

#define IAA_STATUS_PENDING          "PENDING"
#define IAA_STATUS_APPROVED         "APPROVED"
#define IAA_STATUS_DENIED           "DENIED"
#define IAA_STATUS_CANCELLED        "CANCELLED"

#define IAA_FAKE_ID_UPPER_LIMIT     256 ** 3 - 1 //6 hex digits
#define IAA_BAN_DURATION_DAYS       7

/proc/IAA_approve(key)
	key = ckey(key)
	if (GLOB.IAA_approved_list[key])
		GLOB.IAA_approved_list[key]++
		sql_query({"
			UPDATE
				erro_iaa_approved
			SET
				approvals = approvals + 1
			WHERE
				ckey = $$
			"}, key)
	else
		GLOB.IAA_approved_list[key] = 1
		sql_query({"
			INSERT INTO
				erro_iaa_approved (
					`ckey`
				)
			VALUES
				($$)
			"}, key)
	return

/proc/IAA_disprove(key)
	key = ckey(key)
	GLOB.IAA_approved_list[key] = 0
	sql_query({"
		DELETE FROM
			erro_iaa_approved
		WHERE
			ckey = $$
		"}, key)
	return

/proc/IAA_disprove_by_id(id)
	var/DBQuery/query = sql_query({"
		SELECT
			iaa_ckey,
			other_ckeys
		FROM
			erro_iaa_jobban
		WHERE
			id = $$
		"}, id)
	query.NextRow()
	IAA_disprove(query.item[1])
	var/list/others = splittext(query.item[2], ", ")
	for (var/other in others)
		IAA_disprove(other)

/proc/IAA_is_trustworthy(key)
	key = ckey(key)
	return (GLOB.IAA_approved_list[key] >= 3)


/datum/IAA_brief_jobban_info
	var/id
	var/fakeid
	var/ckey
	var/iaa_ckey
	var/job
	var/status
	var/expiration_time

/datum/IAA_brief_jobban_info/proc/resolve(approved = TRUE, comment = "automatic_approval", ckey = "system")
	ASSERT(status == IAA_STATUS_PENDING)
	var/action = approved ? IAA_STATUS_APPROVED : IAA_STATUS_DENIED
	message_admins("IAA jobban <a href='?_src_=holder;iaaj_inspect=[id]'>[id] ([fakeid])</a> was [IAAJ_status_colorize(action, action)] by [ckey] ([comment])")
	log_admin("IAA jobban [id] ([fakeid]) was [action] by [ckey] ([comment])")
	var/DBQuery/query
	if (approved)
		query = sql_query({"
			UPDATE
				erro_iaa_jobban
			SET
				status = $status,
				resolve_time = Now(),
				resolve_comment = $comment,
				resolve_ckey = $ckey,
				expiration_time = DATE_ADD(Now(), INTERVAL $duration DAY)
			WHERE
				id = $id
			"}, list(
				status = action,
				comment = comment,
				ckey = ckey,
				duration = IAA_BAN_DURATION_DAYS,
				id = id))
	else
		query = sql_query({"
			UPDATE
				erro_iaa_jobban
			SET
				status = $status,
				resolve_time = Now(),
				resolve_comment = $comment,
				resolve_ckey = $ckey
			WHERE
				id = $id
			"}, list(
				status = action,
				comment = comment,
				ckey = ckey,
				id = id))
	if (approved)
		query = sql_query({"
			SELECT
				expiration_time
			FROM
				erro_iaa_jobban
			WHERE
				id = $$
			"}, id)
		query.NextRow()
		expiration_time = query.item[1]
		IAA_approve(src.ckey)
	else
		IAA_disprove_by_id(id)
	status = action
	if (status != IAA_STATUS_APPROVED)
		GLOB.IAA_active_jobbans_list -= src
		qdel(src)

/proc/IAAJ_cancel(id, comment, ckey)
	var/DBQuery/query = sql_query({"
		SELECT
			status,
			fakeid
		FROM
			erro_iaa_jobban
		WHERE
			id = $$
		"}, id)
	if (!query.NextRow())
		to_chat(usr, "No entry with such id")
		return
	ASSERT(query.item[1] == IAA_STATUS_APPROVED)
	var/fakeid = query.item[2]
	var/action = IAA_STATUS_CANCELLED
	message_admins("IAA jobban <a href='?_src_=holder;iaaj_inspect=[id]'>[id] ([fakeid])</a> was [IAAJ_status_colorize(action, action)] by [ckey] ([comment])")
	log_admin("IAA jobban [id] ([fakeid]) was [action] by [ckey] ([comment])")
	query = sql_query({"
		UPDATE
			erro_iaa_jobban
		SET
			status = $status,
			cancel_time = Now(),
			cancel_comment = $comment,
			cancel_ckey = $ckey
		WHERE
			id = $id"}, list(
		status = action,
		comment = comment,
		ckey = ckey,
		id = id))
	for (var/datum/IAA_brief_jobban_info/JB in GLOB.IAA_active_jobbans_list)
		if (JB.id == id)
			GLOB.IAA_active_jobbans_list -= JB
	IAA_disprove_by_id(id)

/hook/startup/proc/IAA_jobbans_populate()
	IAAJ_populate()
	return 1

/proc/IAAJ_populate()
	ASSERT(establish_db_connection())
	var/DBQuery/query
	query = sql_query({"
		SELECT
			id,
			fakeid,
			ckey,
			iaa_ckey,
			job,
			status,
			expiration_time
		FROM
			erro_iaa_jobban
		WHERE
			(status = '[IAA_STATUS_PENDING]'
			OR
			status = '[IAA_STATUS_APPROVED]'
			AND
			IFNULL(expiration_time, Now()) >= Now())
		"})
	while (query.NextRow())
		var/datum/IAA_brief_jobban_info/JB = new()
		JB.id              = query.item[1]
		JB.fakeid          = query.item[2]
		JB.ckey            = query.item[3]
		JB.iaa_ckey        = query.item[4]
		JB.job             = query.item[5]
		JB.status          = query.item[6]
		JB.expiration_time = query.item[7]

		GLOB.IAA_active_jobbans_list.Add(JB)

	query = sql_query({"
		SELECT
			ckey,
			approvals
		FROM
			erro_iaa_approved
		"})

	while (query.NextRow())
		GLOB.IAA_approved_list[query.item[1]] = query.item[2]

/proc/IAAJ_check_fakeid_available(fakeid)
	var/DBQuery/query = sql_query({"
		SELECT
			fakeid
		FROM
			erro_iaa_jobban
		WHERE
			fakeid = $$
		"}, fakeid)
	return !query.RowCount()

/proc/IAAJ_generate_fake_id()
	var/ret = num2hex(rand(0, IAA_FAKE_ID_UPPER_LIMIT), 6)
	if (IAAJ_check_fakeid_available(ret))
		return ret
	return IAAJ_generate_fake_id() //nigh impossible to get there, will be even more impossible to descend further into recursion

/proc/IAAJ_insert_new(fakeid, ckey, iaa_ckey, other_ckeys, reason, job)
	if (!IAAJ_check_fakeid_available(fakeid))
		message_admins("IAAJ fakeid collision. Possible re-send and/or duplicate?")
		return
	var/datum/IAA_brief_jobban_info/JB = new()
	JB.fakeid = fakeid
	JB.ckey = ckey
	JB.iaa_ckey = iaa_ckey
	JB.job = job
	JB.status = IAA_STATUS_PENDING

	var/DBQuery/query
	query = sql_query({"
		INSERT INTO
			erro_iaa_jobban (
				`fakeid`,
				`ckey`,
				`iaa_ckey`,
				`other_ckeys`,
				`reason`,
				`job`,
				`creation_time`,
				`status`
			)
			VALUES (
				$fakeid,
				$ckey,
				$iaa_ckey,
				$other_ckeys,
				$reason,
				$job,
				Now(),
				$status
			)
			"}, list(
			fakeid = fakeid,
			ckey = ckey,
			iaa_ckey = iaa_ckey,
			other_ckeys = other_ckeys,
			reason = reason,
			job = job,
			status = IAA_STATUS_PENDING))

	query = sql_query({"
		SELECT
			id,
			creation_time
		FROM
			erro_iaa_jobban
		WHERE
			fakeid = $$
		"}, fakeid)
	query.NextRow() //tbh I have no real idea how to handle database faults so might as well let it crash right there if it happens
	JB.id = query.item[1]
	JB.expiration_time = query.item[2]
	GLOB.IAA_active_jobbans_list.Add(JB)
	message_admins("Complaint <a href='?_src_=holder;iaaj_inspect=[JB.id]'>#[JB.id] ([JB.fakeid])</a> added into database.")
	log_admin("Complaint #[JB.id] ([JB.fakeid]) added into database.")
	if (IAA_is_trustworthy(iaa_ckey))
		message_admins("[iaa_ckey] is thrustworthy, complaint <a href='?_src_=holder;iaaj_inspect=[JB.id]'>#[JB.id] ([JB.fakeid])</a> was automatically approved.")
		JB.resolve()

/proc/IAAJ_status_colorize(status, text)
	var/color = COLOR_BLACK
	switch(status)
		if (IAA_STATUS_PENDING)
			color = COLOR_GRAY
		if (IAA_STATUS_APPROVED)
			color = COLOR_GREEN
		if (IAA_STATUS_DENIED)
			color = COLOR_RED
		if (IAA_STATUS_CANCELLED)
			color = COLOR_RED_GRAY
	return "<font color=[color]>[text]</font>"

/datum/admins/proc/IAAJ_list_active_bans()
	if(!check_rights(R_BAN))
		return

	var/dat = "<meta charset=\"utf-8\"><B>IAA active Jobans!</B><HR><table border>"
	dat += "<tr style=\"font-weight:bold\"> <td> ID </td> <td> Who from who by who </td> <td> Expiration date </td> <td> Status </td> </tr>"
	for (var/datum/IAA_brief_jobban_info/JB in GLOB.IAA_active_jobbans_list)
		dat += text("<tr><td><a href='?src=\ref[src];iaaj_inspect=[JB.id]'>[JB.id] ([JB.fakeid])</a></td> \
			<td>[JB.ckey] banned from [JB.job] by [JB.iaa_ckey]</td> \
			<td> [JB.expiration_time] </td> \
			<td> [IAAJ_status_colorize(JB.status, JB.status)] </td> \
			</tr>")
	dat += "</table>"
	usr << browse(dat, "window=iaaj_ban;size=400x400")

/datum/admins/proc/IAAJ_list_all_bans(startfrom = 0)
	var/const/results_per_page = 10
	if(!check_rights(R_BAN))
		return
	ASSERT(isnum(startfrom))
	if (startfrom < 0)
		startfrom = 0
	var/dat = "<meta charset=\"utf-8\"><B>IAA Jobans!</B><HR>"
	if (!isnull(startfrom))
		dat += "<a href = '?src=\ref[src];iaaj_page=[startfrom - 10]'> Previous page</a>"
	else
		dat += " Previous page"
	dat += "<a href = '?src=\ref[src];iaaj_page=[startfrom + 10]'> Next page</a><hr>"
	dat += "<table border>"
	dat += "<tr style=\"font-weight:bold\"> <td> ID </td> <td> Who from who by who </td> <td> Expiration date </td> <td> Status </td> </tr>"
	var/DBQuery/query
	query = sql_query({"
		SELECT
			id,
			fakeid,
			ckey,
			iaa_ckey,
			job, status,
			expiration_time
		FROM
			erro_iaa_jobban
		ORDER BY id DESC
		LIMIT [results_per_page]
		OFFSET [startfrom]
		"})

	while (query.NextRow())
		var/datum/IAA_brief_jobban_info/JB = new()
		JB.id              = query.item[1]
		JB.fakeid          = query.item[2]
		JB.ckey            = query.item[3]
		JB.iaa_ckey        = query.item[4]
		JB.job             = query.item[5]
		JB.status          = query.item[6]
		JB.expiration_time = query.item[7]
		dat += text("<tr><td><a href='?src=\ref[src];iaaj_inspect=[JB.id]'>[JB.id] ([JB.fakeid])</a></td> \
			<td>[JB.ckey] banned from [JB.job] by [JB.iaa_ckey]</td> \
			<td> [JB.expiration_time] </td> \
			<td> [IAAJ_status_colorize(JB.status, JB.status)] </td> \
			</tr>")
	dat += "</table>"
	usr << browse(dat, "window=iaaj_ban;size=400x400")

/datum/admins/proc/IAAJ_inspect_ban(id)
	if(!check_rights(R_BAN))
		return
	var/DBQuery/query
	query = sql_query({"
		SELECT
			id,
			fakeid,
			ckey,
			iaa_ckey,
			other_ckeys,
			reason,
			job,
			creation_time,
			resolve_time,
			resolve_comment,
			resolve_ckey,
			cancel_time,
			cancel_comment,
			cancel_ckey,
			status,
			expiration_time
		FROM
			erro_iaa_jobban
		WHERE
			id = $$
		"}, id)
	if (!query.NextRow())
		to_chat(usr, "No entry with such id")
		return
	var/fakeid            = query.item[ 2]
	var/ckey              = query.item[ 3]
	var/iaa_ckey          = query.item[ 4]
	var/other_ckeys       = query.item[ 5]
	var/reason            = query.item[ 6]
	var/job               = query.item[ 7]
	var/creation_time     = query.item[ 8] 
	var/resolve_time      = query.item[ 9]
	var/resolve_comment   = query.item[10]
	var/resolve_ckey      = query.item[11]
	var/cancel_time       = query.item[12]
	var/cancel_comment    = query.item[13]
	var/cancel_ckey       = query.item[14]
	var/status            = query.item[15]
	var/expiration_time   = query.item[16]
	var/dat = "<meta charset=\"utf-8\"><B>IAA jobban [id] ([fakeid])</B><HR>"
	dat += "[ckey] banned from [job]; initiated by [iaa_ckey], supported by [other_ckeys]<HR>"
	dat += "Status: [IAAJ_status_colorize(status, status)]"
	switch (status)
		if (IAA_STATUS_PENDING)
			dat += "<a href='?src=\ref[src];iaaj_resolve=[id]'> resolve </a>"
		if (IAA_STATUS_APPROVED)
			dat += "<a href='?src=\ref[src];iaaj_close=[id]'> close </a>"
	dat += "<HR>"
	dat += "Created at [creation_time] <BR>"
	if (resolve_time)
		dat += "Resolved ([resolve_time]) by [resolve_ckey]; comment: [resolve_comment] <BR>"
	if (cancel_time)
		dat += "Cancelled ([cancel_time]) by [cancel_ckey]; comment: [cancel_comment] <BR>"
	if (expiration_time)
		dat += "Expires at [expiration_time] <BR>"
	dat += "<HR>"
	dat += "Reason (everything below): <BR><BR> [reason]"
	usr << browse(dat, "window=iaaj_ban_inspect;size=400x400")
	return

/proc/IAAJ_AdminTopicProcess(datum/admins/source, list/href_list)
	if (href_list["iaaj_inspect"])
		source.IAAJ_inspect_ban(href_list["iaaj_inspect"])
		return

	if (href_list["iaaj_resolve"])
		var/id = href_list["iaaj_resolve"]
		var/datum/IAA_brief_jobban_info/chosen_JB
		for (var/datum/IAA_brief_jobban_info/JB in GLOB.IAA_active_jobbans_list)
			if (JB.id == id)
				chosen_JB = JB
				break
		if (!chosen_JB)
			to_chat(usr, SPAN_WARNING("Failed to find active jobban with such id!"))
			return
		var/action = input(usr, "Select action:", "Resolve IAA jobban", "Cancel") as anything in list("Approve", "Deny", "Cancel")
		switch(action)
			if ("Cancel")
			if ("Approve")
				var/comment = input(usr, "Enter comment:", "IAA approval comment") as text|null
				if (!comment)
					return
				chosen_JB.resolve(approved = TRUE, comment = comment, ckey = usr.ckey)
			if ("Deny")
				var/comment = input(usr, "Enter comment:", "IAA deny comment") as text|null
				if (!comment)
					return
				chosen_JB.resolve(approved = FALSE, comment = comment, ckey = usr.ckey)
		source.IAAJ_inspect_ban(id)
		return

	if (href_list["iaaj_close"])			
		var/id = href_list["iaaj_close"]
		var/comment = input(usr, "Enter comment:", "IAA closing comment") as text|null
		if (!comment)
			return
		IAAJ_cancel(id, comment, usr.ckey)
		source.IAAJ_inspect_ban(id)
		return


#undef IAA_STATUS_PENDING
#undef IAA_STATUS_APPROVED
#undef IAA_STATUS_DENIED
#undef IAA_STATUS_CANCELLED
