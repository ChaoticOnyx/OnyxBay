mob/verb/dumpbans()
	Banlist = new("data/banlist.bdb")
	log_admin("Loading Banlist")

	if (!length(Banlist.dir)) log_admin("Banlist is empty.")

	if (!Banlist.dir.Find("base"))
		log_admin("Banlist missing base dir.")
		Banlist.dir.Add("base")
		Banlist.cd = "/base"
	else if (Banlist.dir.Find("base"))
		Banlist.cd = "/base"
	var/file = file("bans.txt")
	var/dat = ""
	for (var/X in Banlist)
		Banlist.cd = "/base/[X]"

		var/reason = dbcon.Quote("[Banlist["reason"]]")
		dat += "INSERT INTO `bans` VALUES('[Banlist["key"]', '[Banlist["id"]]', [reason], '[Banlist["bannedby"]]', '[Banlist["temp"]]', '[Banlist["minutes"]]');\n"

	file << dat
	usr << "DONE"
mob/verb/dumpinvite()
	var/savefile/invitelist = new("data/invite.dat")
	var/list/keylist[0]
	invitelist["keys[0]"] >> keylist
	var/file = file("invite.txt")
	var/dat = ""
	var/key = input(usr,"Key","key")
	invitelist.cd = "/keys"
	usr << length(invitelist)
	for (var/X in keylist)

		dat += "INSERT INTO `invites` VALUES('[X]');\n"

	file << dat
	usr << "DONE"
/*
var
	crban_bannedmsg="<font color=red><big><tt>You have been banned from [world.name]</tt></big></font>"
	crban_preventbannedclients = 0 // Don't enable this, it'll throw null runtime errors due to the convolted way ss13 logs you in
	crban_keylist[0]  // Banned keys and their associated IP addresses
	crban_reason[0]	// Banned key+reason
	crban_time[0]	// Banned key+time
	crban_bannedby[0]	// who banned them
	crban_iplist[0]   // Banned IP addresses
	crban_ipranges[0] // Banned IP ranges
	crban_computerIDs[0] //Banned Computer IDs (Googolplexed)
	crban_unbanned[0] // So we can remove bans (list of ckeys)
	crban_runonce	// Updates legacy bans with new info

		Banlist["id"] << "trashid[i]"
		Banlist["reason"] << "Trashban[i]."
		Banlist["temp"] << a
		Banlist["minutes"] << CMinutes + rand(1,2000)
		Banlist["bannedby"] << "trashmin"
*/