var/list/admin_ranks = list()								//list of all ranks with associated rights

/hook/startup/proc/loadAdmins()
	load_admins()
	return 1

/proc/load_admins()
	//clear the datums references
	admin_datums.Cut()
	for(var/client/C in GLOB.admins)
		C.remove_admin_verbs()
		C.holder = null
	GLOB.admins.Cut()

	if(!establish_db_connection())
		error("Failed to connect to database in load_admins().")
		log_misc("Failed to connect to database in load_admins().")
		return

	var/DBQuery/query = sql_query({"
		SELECT
			ckey,
			`rank`,
			flags
		FROM
			erro_admin
		"}, dbcon)

	while(query.NextRow())
		var/ckey = query.item[1]
		var/rank = query.item[2]
		if(rank == "Removed")	continue	//This person was de-adminned. They are only in the admin list for archive purposes.

		var/rights = query.item[3]
		if(istext(rights))	rights = text2num(rights)
		var/datum/admins/D = new /datum/admins(rank, rights, ckey)

		//find the client for a ckey if they are connected and associate them with the new admin datum
		D.associate(GLOB.ckey_directory[ckey])
	if(!admin_datums)
		error("The database query in load_admins() resulted in no admins being added to the list.")
		log_misc("The database query in load_admins() resulted in no admins being added to the list.")
		return

	//Clear profile access
	for(var/A in world.GetConfig("admin"))
		world.SetConfig("APP/admin", A, null)

#ifdef TESTING
/client/verb/changerank(newrank in admin_ranks)
	if(holder)
		holder.rank = newrank
		holder.rights = admin_ranks[newrank]
	else
		holder = new /datum/admins(newrank,admin_ranks[newrank],ckey)
	remove_admin_verbs()
	holder.associate(src)

/client/verb/changerights(newrights as num)
	if(holder)
		holder.rights = newrights
	else
		holder = new /datum/admins("testing",newrights,ckey)
	remove_admin_verbs()
	holder.associate(src)

#endif
