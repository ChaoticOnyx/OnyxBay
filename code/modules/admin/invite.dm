var
	invite_keylist[0]		//to store the keys & ranks


/proc/toggleinvite(mob/M)
	if(invite_isallowed(M))
		invite_remove(M)
	else
		invite_add(M)
	return

/proc/invite_add(mob/M)
	if (!M || !M.key || !M.client) return
	var/DBQuery/xquery = dbcon.NewQuery("REPLACE INTO `invites` (`ckey`) VALUES ('[M.ckey]')")
	if(!xquery.Execute())
		log_admin("Failed to add invite..")
		return 0
	else
		return 1
/proc/invite_addtext(ckey as text)
	if (ckey) return
	var/DBQuery/xquery = dbcon.NewQuery("REPLACE INTO `invites` (`ckey`) VALUES ('[ckey]')")
	if(!xquery.Execute())
		log_admin("Failed to add invite..")
		return 0
	else
		return 1
/proc/invite_isallowed(mob/M)
	var/found = 0
	var/DBQuery/xquery = dbcon.NewQuery("SELECT * FROM `invites` WHERE ckey='[M.ckey]'")
	if(xquery.Execute())
		while(xquery.NextRow())
			var/list/row = xquery.GetRowData()
			if(row["ckey"] == M.ckey)// it should but you never can be too sure.
				found = 1
	if (found)
		return 1
	else
		if(M.client.holder)
			return 1
		return 0
/proc/invite_isallowedtext(var/ckey)
	var/found = 0
	var/DBQuery/xquery = dbcon.NewQuery("SELECT * FROM `invites` WHERE ckey='[ckey]'")
	if(xquery.Execute())
		while(xquery.NextRow())
			var/list/row = xquery.GetRowData()
			if(row["ckey"] == ckey)// it should but you never can be too sure.
				found = 1
	if (found)
		return 1
	else
		return 0

/*/proc/invite_loadbanfile()
	var/DBQuery/xquery = dbcon.NewQuery("SELECT * FROM `invites`")
	if(xquery.Execute())
		while(xquery.NextRow())
			var/list/row = xquery.GetRowData()
			invite_keylist += row["ckey"]
	log_admin("Loading invite list")
	if (!length(invite_keylist))
		invite_keylist=list()
		log_admin("No people in invite list")
*/
/proc/invite_remove(mob/M)
	if (!M || !M.key || !M.client) return
	var/DBQuery/xquery = dbcon.NewQuery("DELETE FROM `invites` WHERE ckey='[M.ckey]'")
	if(!xquery.Execute())
		log_admin("Failed to remove invite..")
		return 0
	else
		return 1
/proc/invite_removetext(ckey as text)
	var/DBQuery/xquery = dbcon.NewQuery("DELETE FROM `invites` WHERE ckey='[ckey]'")
	if(!xquery.Execute())
		log_admin("Failed to remove invite..")
		return 0
	else
		return 1

/obj/admins/proc/invite_panel()
	var/DBQuery/kquery = dbcon.NewQuery("SELECT * FROM `invites`")
	var/list/keys = list()
	var/dat
	if(!kquery.Execute())
		return 0
	else
		while(kquery.NextRow())
			var/list/ban = kquery.GetRowData()
			keys += ban["ckey"]
			dat += text("<tr><td><A href='?src=\ref[src];uninvite1='[ban["ckey"]]'>(R)</A>Key: <B>[ban["ckey"]]</B></td><td>")
	var/count = 0

	count = keys.len
	dat += "</table>"
	dat = "<HR><B>Invites:</B> - <B> <A href='?src=\ref[src];invite1='1'>(Add Invite)</A> - <B><FONT COLOR=green>([count] Invites)</FONT><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[dat]"
	usr << browse(dat, "window=invitep;size=875x400")
