/proc/jobban_fullban(mob/M, rank,mob/bywho)
	if(M == bywho)
		bywho << "Adding job bans for yourself isn't possible."
		return
	var/input = input(usr, "Please enter the reason for the job ban", "Job banning", "")
	if(!input)
		bywho << "Job ban not added. Please retry and complete the reason field."
		return
	if (!M || !M.key || !M.client) return
	var/DBQuery/xquery = dbcon.NewQuery("INSERT INTO jobban VALUES ('[M.ckey]','[rank]')")
	var/DBQuery/yquery = dbcon.NewQuery("INSERT INTO jobbanlog (`ckey`,`targetckey`,`rank`,`why`) VALUES ('[bywho.ckey]','[M.ckey]','[rank]','[input]')")
	if(!xquery.Execute())
		log_admin("[xquery.ErrorMsg()]")
	if(!yquery.Execute())
		log_admin("[yquery.ErrorMsg()]")
	M << "\red You have been jobbanned from [rank], reason: [input]"

/proc/jobban_isbanned(mob/M, rank)
	var/DBQuery/cquery = dbcon.NewQuery("SELECT `rank` FROM `jobban` WHERE ckey='[M.ckey]'")
	var/list/ranks = list()
	if(!cquery.Execute())
		log_admin("[cquery.ErrorMsg()]")
	else
		while(cquery.NextRow())
			var/list/derp = cquery.GetRowData()
			ranks += derp["rank"]
	if(ranks.Find(rank))
		return 1
	else
		return 0

/proc/jobban_unban(mob/M, rank)
	var/DBQuery/xquery = dbcon.NewQuery("DELETE FROM jobban WHERE `ckey`='[M.ckey]' AND `rank`='[rank]'")
	var/DBQuery/yquery = dbcon.NewQuery("DELETE FROM jobbanlog WHERE `targetckey`='[M.ckey]' AND `rank`='[rank]'")
	if(!xquery.Execute())
		log_admin("[xquery.ErrorMsg()]")
	if(!yquery.Execute())
		log_admin("[yquery.ErrorMsg()]")
	log_admin("[key_name(usr)] unbanned [M.ckey] from [rank]")
	M << "\red You have been unjobbanned from [rank]."

/proc/jobban_remove(key, rank)
	var/DBQuery/xquery = dbcon.NewQuery("DELETE FROM jobban WHERE `ckey`='[key]' AND `rank`='[rank]'")
	var/DBQuery/yquery = dbcon.NewQuery("DELETE FROM jobbanlog WHERE `targetckey`='[key]' AND `rank`='[rank]'")
	if(!xquery.Execute())
		log_admin("[xquery.ErrorMsg()]")
	if(!yquery.Execute())
		log_admin("[yquery.ErrorMsg()]")
	log_admin("[key_name(usr)] unbanned [key] from [rank]")
	//M << "\red You have been unjobbanned from [rank]."

/obj/admins/proc/showjobbans()
	var/html = "<table>"
	var/DBQuery/cquery = dbcon.NewQuery("SELECT DISTINCT targetckey from jobbanlog")
	if(!cquery.Execute())
		log_admin("[cquery.ErrorMsg()]")
	else
		while(cquery.NextRow())
			var/list/derp = cquery.GetRowData()
			var/X = derp["targetckey"]
			html += "<tr><td><A href='?src=\ref[src];jobban1=[X]'>[derp["targetckey"]]</A></td><td>"
	html += "</table>"
	html = "<HR><B>Jobbans:</B><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[html]"
	usr << browse(html, "window=jobbanx1x;size=475x400")


