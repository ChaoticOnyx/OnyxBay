GLOBAL_LIST_EMPTY(IAA_active_jobbans_list)
GLOBAL_LIST_EMPTY(IAA_approved_list)

#define IAA_STATUS_PENDING          "PENDING"
#define IAA_STATUS_APPROVED         "APPROVED"
#define IAA_STATUS_DENIED           "DENIED"
#define IAA_STATUS_CANCELLED  	    "CANCELLED"

#define IAA_FAKE_ID_UPPER_LIMIT     16777215
#define IAA_BAN_DURATION            60 * 24 * 7
/proc/IAA_approve(key)
	key = ckey(key)
	var/DBQuery/query
	if (GLOB.IAA_approved_list[key])
		GLOB.IAA_approved_list[key]++
		query = dbcon.NewQuery("UPDATE erro_iaa_approved SET approvals = approvals + 1 where ckey = ?", key)
	else
		GLOB.IAA_approved_list[key] = 1
		query = dbcon.NewQuery("INSERT INTO erro_iaa_approved (`ckey`) VALUES (?)", key)
	query.Execute()
	return

/proc/IAA_disprove(key)
	key = ckey(key)
	GLOB.IAA_approved_list[key] = 0
	var/DBQuery/query = dbcon.NewQuery("DELETE FROM erro_iaa_approved WHERE ckey = ?", key)
	query.Execute()
	return

/proc/IAA_disprove_by_id(id)
	var/DBQuery/query = dbcon.NewQuery("SELECT iaa_ckey, other_ckeys FROM erro_iaa_jobban WHERE id = ?", id)
	query.Execute()
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
	var/DBQuery/query
	query = dbcon.NewQuery("UPDATE erro_iaa_jobban SET status = ?, resolve_time = Now(), resolve_comment = ?, resolve_ckey = ?, \
		expiration_time = DATE_ADD(Now(), INTERVAL ? MINUTE) where id = ?", approved ? IAA_STATUS_APPROVED : IAA_STATUS_DENIED, comment, ckey, IAA_BAN_DURATION, id)
	query.Execute()

	if (approved)
		query = dbcon.NewQuery("SELECT expiration_time FROM erro_iaa_jobban WHERE id = ?", id)
		query.Execute()
		query.NextRow()
		expiration_time = query.item[1]
		IAA_approve(src.ckey)
	else
		IAA_disprove_by_id(id)

/proc/IAA_jobban_cancel(id, comment, ckey)
	var/DBQuery/query = dbcon.NewQuery("SELECT status FROM erro_iaa_jobban WHERE id = ?", id)
	query.Execute()
	query.NextRow()
	ASSERT(query.item[1] == IAA_STATUS_APPROVED)
	query = dbcon.NewQuery("UPDATE erro_iaa_jobban SET status = ?, cancel_time = Now(), cancel_comment = ?, cancel_ckey = ? where id = ?", \
		IAA_STATUS_CANCELLED, comment, ckey, id)
	query.Execute()
	for (var/datum/IAA_brief_jobban_info/JB in GLOB.IAA_active_jobbans_list)
		if (JB.id == id)
			JB.status = IAA_STATUS_CANCELLED
	IAA_disprove_by_id(id)

/hook/startup/proc/IAA_jobbans_populate()
	IAAJ_populate()
	return 1

/proc/IAAJ_populate()
	if(!establish_db_connection())
		error("Database connection failed. Aborting IAA jobbans loading.")
		log_misc("Database connection failed. Aborting IAA jobbans loading.")
		return

	var/DBQuery/query
	query = dbcon.NewQuery("SELECT id, fakeid, ckey, iaa_ckey, job, status, expiration_time FROM erro_iaa_jobban \
		WHERE (status = '[IAA_STATUS_PENDING]' OR status = '[IAA_STATUS_APPROVED]' AND expiration_time > Now()) \
		[isnull(config.server_id) ? "" : "AND server_id = '[config.server_id]'"]")
	query.Execute()

	while (query.NextRow())
		var/datum/IAA_brief_jobban_info/JB
		JB.id              = query.item[1]
		JB.fakeid          = query.item[2]
		JB.ckey            = query.item[3]
		JB.iaa_ckey        = query.item[4]
		JB.job             = query.item[5]
		JB.status          = query.item[6]
		JB.expiration_time = query.item[7]

		GLOB.IAA_active_jobbans_list.Add(JB)

	query = dbcon.NewQuery("SELECT ckey, approvals from erro_iaa_approved")
	query.Execute()

	while (query.NextRow())
		GLOB.IAA_approved_list[query.item[1]] = query.item[2]

/proc/IAAJ_generate_fake_id()
	var/ret = rand(0, IAA_FAKE_ID_UPPER_LIMIT)
	var/DBQuery/query = dbcon.NewQuery("SELECT fakeid FROM erro_iaa_jobban where fakeid = ?", ret)
	if (query.RowCount())
		return IAAJ_generate_fake_id() //nigh impossible to get there, will be even more impossible to descend further into recursion
	return ret

/proc/IAAJ_insert_new(fakeid, ckey, iaa_ckey, other_ckeys, reason, job)
	var/datum/IAA_brief_jobban_info/JB
	JB.fakeid = fakeid
	JB.ckey = ckey
	JB.iaa_ckey = iaa_ckey
	JB.job = job
	JB.status = IAA_STATUS_PENDING

	var/DBQuery/query
	query = dbcon.NewQuery("INSERT INTO erro_iaa_jobban \
		(`fakeid`, `ckey`, `iaa_ckey`, `other_ckeys`, `reason`, `job`, `creation_time`, `status`) VALUES \
		(?, ?, ?, ?, ?, ?, Now(), ?)", fakeid, ckey, iaa_ckey, other_ckeys, reason, job, IAA_STATUS_PENDING)
	query.Execute()

	query = dbcon.NewQuery("SELECT id, creation_time FROM erro_iaa_jobban WHERE fakeid = ?", fakeid)
	query.Execute()
	query.NextRow() //tbh I have no real idea how to handle database faults so might as well let it crash right there if it happens
	JB.id = query.item[1]
	JB.expiration_time = query.item[2]
	GLOB.IAA_active_jobbans_list.Add(JB)
	if (IAA_is_trustworthy(iaa_ckey))
		message_admins("[iaa_ckey] is thrustworthy, complaint #[JB.id] was automatically approved.")
		JB.resolve()

#undef IAA_STATUS_PENDING
#undef IAA_STATIS_APPROVED
#undef IAA_STATUS_DENIED
#undef IAA_STATUS_CANCELLED