var/CMinutes = null
var/savefile/Banlist


/proc/CheckBan(var/client/clientvar)

	var/id = clientvar.computer_id
	var/key = clientvar.ckey
	var/DBQuery/q1 = dbcon.NewQuery("SELECT * FROM `bans` WHERE computerid='[id]'")
	var/DBQuery/q2 = dbcon.NewQuery("SELECT * FROM `bans` WHERE ckey='[key]'")
	var/list/ban = list()
	if(!q2.Execute())
		log_admin("[q2.ErrorMsg()]")
		return 0
	else
		while(q2.NextRow()) // i made a hell of mess here pendling rewriteing because its overly complex for a thing like this.
			if(!isnull(q2.GetRowData()))
				ban = q2.GetRowData()
	if(!q1.Execute())
		log_admin("[q1.ErrorMsg()]")
		return 0
	else
		while(q1.NextRow())
			if(!isnull(q1.GetRowData()))
				ban = q1.GetRowData()
	if(ban.len < 1)
		return 0
	if(text2num(ban["temp"]))
		var/asd = text2num(ban["minute"])
		if (!GetExp(asd))
			ClearTempbans()
			return 0
		else
			return "[ban["reason"]]\n(This ban will be automatically removed in [GetExp(asd)].)"
	else
		return "[ban["reason"]]\n(This is a permanent ban)"
	return 0


/proc/UpdateTime() //No idea why i made this a proc.
	CMinutes = (world.realtime / 10) / 60
	return 1

/*/proc/LoadBans()

	Banlist = new("data/banlist.bdb")
	log_admin("Loading Banlist")

	if (!length(Banlist.dir)) log_admin("Banlist is empty.")

	if (!Banlist.dir.Find("base"))
		log_admin("Banlist missing base dir.")
		Banlist.dir.Add("base")
		Banlist.cd = "/base"
	else if (Banlist.dir.Find("base"))
		Banlist.cd = "/base"
	ClearTempbans()
	return 1
*/
/proc/ClearTempbans()
	UpdateTime()
	var/DBQuery/query = dbcon.NewQuery("SELECT `ckey` FROM `bans`")
	var/DBQuery/kquery = dbcon.NewQuery("SELECT * FROM `bans`")
	var/list/keys = list()
	var/list/expired = list()
	if(!query.Execute())
		log_admin("[query.ErrorMsg()]")
		return 0
	else
		while(query.NextRow())
			keys = query.GetRowData()
	if(!kquery.Execute())
		log_admin("[kquery.ErrorMsg()]")
		return 0
	else
		while(kquery.NextRow())
			var/list/colm = kquery.GetRowData()
			for(var/P in keys)
				if(!text2num(colm["temp"]))
					continue
				if(CMinutes >= text2num(colm["minute"]))
					var/ckeys = colm["ckey"]
					expired += ckeys
	for(var/p in expired)
		RemoveBan(p)
	return 1
/proc/AddBan(ckey, computerid, reason, bannedby, temp, minutes)
	var/bantimestamp = 0
	if (temp)
		UpdateTime()
		bantimestamp = CMinutes + minutes
	var/reason1 = dbcon.Quote(reason)
	var/DBQuery/query = dbcon.NewQuery("REPLACE INTO `bans` (`ckey`,`computerid`,`reason`,`bannedby`,`temp`,`minute`) VALUES ('[ckey]','[computerid]','[reason1]','[bannedby]','[temp]','[bantimestamp]')")
	if(!query.Execute())
		message_admins("MYSQL Error ban failed")
		message_admins(query.ErrorMsg())
		log_admin(query.ErrorMsg())
		return 0
	else
		return 1
/proc/RemoveBan(var/ckey)
	var/DBQuery/qquery = dbcon.NewQuery("INSERT INTO `unbans` SELECT * FROM `bans` WHERE ckey='[ckey]'")
	if(!qquery.Execute())
		message_admins("MYSQL Error unban backup failed")
		message_admins(qquery.ErrorMsg())
		log_admin(qquery.ErrorMsg())
	var/DBQuery/query = dbcon.NewQuery("DELETE FROM `bans` WHERE ckey='[ckey]'")
	if(!query.Execute())
		message_admins("MYSQL Error unban failed")
		message_admins(query.ErrorMsg())
		log_admin(query.ErrorMsg())
		return 0
	if(!usr)
		log_admin("Ban Expired: [ckey]")
		message_admins("Ban Expired: [ckey]")
	else
		log_admin("[key_name_admin(usr)] unbanned [ckey]")
		message_admins("[key_name_admin(usr)] unbanned: [ckey]")
	return 1

/proc/GetExp(minutes as num)
	UpdateTime()
	var/exp = minutes - CMinutes
	if (exp <= 0)
		return 0
	else
		var/timeleftstring
		if (exp >= 1440) //1440 = 1 day in minutes
			timeleftstring = "[round(exp / 1440, 0.1)] Days"
		else if (exp >= 60) //60 = 1 hour in minutes
			timeleftstring = "[round(exp / 60, 0.1)] Hours"
		else
			timeleftstring = "[exp] Minutes"
		return timeleftstring

/obj/admins/proc/unbanpanel()
	var/DBQuery/kquery = dbcon.NewQuery("SELECT * FROM `bans`")
	var/list/keys = list()
	var/dat
	if(!kquery.Execute())
		return 0
	else
		while(kquery.NextRow())
			var/list/ban = kquery.GetRowData()
			keys += ban["ckey"]
			dat += text("<tr><td><A href='?src=\ref[src];unbanf=[ban["ckey"]]'>(U)</A><A href='?src=\ref[src];unbane=[ban["ckey"]]'>(E)</A> Key: <B>[ban["ckey"]]</B></td><td> ([text2num(ban["temp"]) ? "[GetExp(text2num(ban["minute"])) ? GetExp(text2num(ban["minute"])) : "Removal pending" ]" : "Permaban"])</td><td>(By: [ban["bannedby"]])</td><td>(Reason: [ban["reason"]])</td></tr>")
	var/count = 0

	count = keys.len
	dat += "</table>"
	dat = "<HR><B>Bans:</B> <FONT COLOR=blue>(U) = Unban , (E) = Edit Ban</FONT> - <FONT COLOR=green>([count] Bans)</FONT><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[dat]"
	usr << browse(dat, "window=unbanp;size=875x400")

//////////////////////////////////// DEBUG ////////////////////////////////////

/proc/CreateBans()

	UpdateTime()

	var/i
	var/last

	for(i=0, i<1001, i++)
		var/a = pick(1,0)
		var/b = pick(1,0)
		if(b)
			Banlist.cd = "/base"
			Banlist.dir.Add("trash[i]trashid[i]")
			Banlist.cd = "/base/trash[i]trashid[i]"
			Banlist["key"] << "trash[i]"
		else
			Banlist.cd = "/base"
			Banlist.dir.Add("[last]trashid[i]")
			Banlist.cd = "/base/[last]trashid[i]"
			Banlist["key"] << last
		Banlist["id"] << "trashid[i]"
		Banlist["reason"] << "Trashban[i]."
		Banlist["temp"] << a
		Banlist["minutes"] << CMinutes + rand(1,2000)
		Banlist["bannedby"] << "trashmin"
		last = "trash[i]"

	Banlist.cd = "/base"

/proc/ClearAllBans()
	Banlist.cd = "/base"
	for (var/A in Banlist.dir)
		RemoveBan(A)

