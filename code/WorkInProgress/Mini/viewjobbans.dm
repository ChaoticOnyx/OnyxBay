client/verb/view_job_bans()
	var/DBQuery/cquery = dbcon.NewQuery("SELECT * FROM `jobban` WHERE ckey='[src.ckey]'")
	if(!cquery.Execute())
		log_admin("[cquery.ErrorMsg()]")
		src << "Error, please report this."
		return
	var/dat = "<table>"
	while(cquery.NextRow())
		var/list/derp = cquery.GetRowData()
		dat += "<tr><td>[derp["rank"]]</td><td>[derp["ckey"]]</td><td>[derp["when"]]</td><td>[derp["why"]]</td></tr>"
	dat += "</table>"
	if(dat == "<table></table>")
		dat = "You have no jobbans!"
	usr << browse(dat, "window=jobbanx1x;size=600x400")