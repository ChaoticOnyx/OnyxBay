/proc/check_whitelist(ckey)
	if(!establish_old_db_connection())
		error("Failed to connect to database in check_whitelist().")
		log_misc("Failed to connect to database in check_whitelist().")
		return FALSE
	var/DBQuery/query = sql_query("SELECT * FROM erro_whitelist WHERE ckey='[lowertext(ckey)]'", dbcon_old)
	while(query.NextRow())
		return TRUE
	return FALSE

/proc/check_job_whitelist(ckey, rank)
	if(!establish_old_db_connection())
		error("Failed to connect to database in check_job_whitelist().")
		log_misc("Failed to connect to database in check_job_whitelist().")
		return FALSE
	var/DBQuery/query = sql_query("SELECT * FROM erro_job_whitelist WHERE ckey='[lowertext(ckey)]' and job='[rank]'", dbcon_old)
	while(query.NextRow())
		return TRUE
	return FALSE


/var/list/alien_whitelist = list()

/hook/startup/proc/loadAlienWhitelist()
	if(config.whitelist.enable_alien_whitelist)
		load_alienwhitelist()

	return 1

/proc/load_alienwhitelist()
	if(!establish_old_db_connection())
		error("Failed to connect to database in load_alienwhitelist().")
		log_misc("Failed to connect to database in load_alienwhitelist().")
		return FALSE
	var/DBQuery/query = sql_query("SELECT * FROM whitelist", dbcon_old)
	while(query.NextRow())
		var/list/row = query.GetRowData()
		if(alien_whitelist[row["ckey"]])
			var/list/A = alien_whitelist[row["ckey"]]
			A.Add(row["race"])
		else
			alien_whitelist[row["ckey"]] = list(row["race"])
	return TRUE

/proc/is_species_whitelisted(mob/M, species_name)
	var/datum/species/S = all_species[species_name]
	return is_alien_whitelisted(M, S)

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, species)
	if(!M || !species)
		return 0
	if(!config.whitelist.enable_alien_whitelist)
		return 1

	var/client/C = M.client
	if (C && SpeciesIngameWhitelist_CheckPlayer(C))
		return TRUE

	if(istype(species,/datum/language))
		var/datum/language/L = species
		if(!(L.language_flags & (WHITELISTED|RESTRICTED)))
			return 1
		return whitelist_lookup(L.name, M.ckey)

	if(istype(species,/datum/species))
		var/datum/species/S = species
		if(!(S.spawn_flags & (SPECIES_IS_WHITELISTED|SPECIES_IS_RESTRICTED)))
			return 1
		return whitelist_lookup(S.name, M.ckey)

	return 0

/proc/whitelist_lookup(item, ckey)
	if(!alien_whitelist)
		return 0

	if(!(ckey in alien_whitelist))
		return 0;
	var/list/whitelisted = alien_whitelist[ckey]
	if(lowertext(item) in whitelisted)
		return 1

	return 0
