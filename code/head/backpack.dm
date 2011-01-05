////////////// The backpack! \\\\\\\\
//////////// Handles item rewards for good RP \\\\\\\\\


/datum/backpack
	var/client/master
	var/list/items = list()
/datum/backpack/proc/Save()
	for(var/A in items)
		var/DBQuery/r_query = dbcon.NewQuery("INSERT INTO `backpack` (`ckey`, `type`) VALUES ('[master.ckey]', '[A]')")
		if(!r_query.Execute())
			world << "Failed-[r_query.ErrorMsg()]"
		else
			usr << "Saved item successfully."
/datum/backpack/New(client)
	if(!client)
		message_admins("ERROR")
	master = client
	var/DBQuery/gquery = dbcon.NewQuery("SELECT `type` FROM `backpack` WHERE ckey='[master.ckey]'")
	if(gquery.Execute())
		while(gquery.NextRow())
			var/list/col = gquery.GetRowData()
			var/type = text2path(col["type"])
			if(ispath(type))
				items += type
				world << "Adding [col["type"]]"
			else
				world << "Whoops can't add [col["type"]]"
/datum/backpack/proc/Add(type)

	if(!ispath(text2path(type)))
		return
	items += text2path(type)
	Save()
/datum/backpack/proc/Remove(type)
	var/DBQuery/gquery = dbcon.NewQuery("REMOVE FROM `backpack` WHERE ckey='[master.ckey]' AND type='[type]'")
	if(gquery.Execute())
		usr << "Removed successfully"
mob/verb/testbackpack()
	if(client || client.backpack)
		client.backpack = new(src)
mob/verb/backpackadd(var/type as text)
	client.backpack.Add(type)
mob/verb/backpackremove(var/type as text)
	client.backpack.Remove(type)
client/var/datum/backpack/backpack
