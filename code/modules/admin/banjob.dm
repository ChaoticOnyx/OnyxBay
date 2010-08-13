var
	jobban_runonce	// Updates legacy bans with new info
	jobban_keylist[0]		//to store the keys & ranks

/proc/jobban_fullban(mob/M, rank)
	if (!M || !M.key || !M.client) return
	var/DBQuery/xquery = dbcon.NewQuery("INSERT INTO jobban VALUES ('[M.ckey]','[rank]')")
	if(!xquery.Execute())
		log_admin("[xquery.ErrorMsg()]")

/proc/jobban_isbanned(mob/M, rank)
	var/DBQuery/cquery = dbcon.NewQuery("SELECT `rank` FROM `jobban` WHERE ckey='[M.ckey]'")
	var/DBQuery/kquery = dbcon.NewQuery("SELECT `ckey` FROM `jobban` WHERE ckey='[M.ckey]'")
	var/list/keys = list()
	if(!kquery.Execute())
		log_admin("[kquery.ErrorMsg()]")
	else
		while(kquery.NextRow())
			keys = kquery.GetRowData()
	if(!cquery.Execute())
		log_admin("[cquery.ErrorMsg()]")
	else
		while(cquery.NextRow())
			var/list/column_data = cquery.GetRowData()
			for(var/P in keys)
				if(rank == column_data["rank"])
					return 1
	return 0
/*
/proc/jobban_loadbanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] >> jobban_keylist
	log_admin("Loading jobban_rank")
	S["runonce"] >> jobban_runonce
	if (!length(jobban_keylist))
		jobban_keylist=list()
		log_admin("jobban_keylist was empty")

/proc/jobban_savebanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] << jobban_keylist
*/
/proc/jobban_unban(mob/M, rank)
	var/DBQuery/xquery = dbcon.NewQuery("DELETE FROM jobban WHERE `ckey`='[M.ckey]' AND `rank`='[rank]'")
	if(!xquery.Execute())
		log_admin("[xquery.ErrorMsg()]")
/*
/proc/jobban_updatelegacybans()
	if(!jobban_runonce)
		log_admin("Updating jobbanfile!")
		// Updates bans.. Or fixes them. Either way.
		for(var/T in jobban_keylist)
			if(!T)	continue
		jobban_runonce++	//don't run this update again
*/
/*
/proc/jobban_remove(X)
	if(jobban_keylist.Find(X))
		jobban_keylist.Remove(X)
		jobban_savebanfile()
		return 1
	return 0
*/