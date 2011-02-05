var
	jobban_runonce	// Updates legacy bans with new info
	jobban_keylist[0]		//to store the keys & ranks

/proc/jobban_fullban(mob/M, rank,mob/bywho)
	if (!M || !M.key || !M.client) return
	var/DBQuery/xquery = dbcon.NewQuery("INSERT INTO jobban VALUES ('[M.ckey]','[rank]')")
	var/DBQuery/yquery = dbcon.NewQuery("INSERT INTO jobbanlog (`ckey`,`targetckey`,`rank`) VALUES ('[bywho.ckey]','[M.ckey]','[rank]')")
	if(!xquery.Execute())
		log_admin("[xquery.ErrorMsg()]")
	if(!yquery.Execute())
		world << "[yquery.ErrorMsg()]"
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



/obj/admins/proc/showjobbans()
	world << src
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

client/verb/ssd()
	src.holder.showjobbans()


