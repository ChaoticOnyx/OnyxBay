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
	invite_keylist.Add(text("[M.ckey]"))
	invite_savebanfile()

/proc/invite_isallowed(mob/M)
	if (invite_keylist.Find(text("[M.ckey]")))
		return 1
	else
		if(M.client.holder)
			return 1
		return 0

/proc/invite_loadbanfile()
	var/savefile/S=new("data/invite.dat")
	S["keys[0]"] >> invite_keylist
	log_admin("Loading invite list")
	if (!length(invite_keylist))
		invite_keylist=list()
		log_admin("No people in invite list")

/proc/invite_savebanfile()
	var/savefile/S=new("data/invite.dat")
	S["keys[0]"] << invite_keylist

/proc/invite_remove(mob/M)
	invite_keylist.Remove(text("[M.ckey]"))
	invite_savebanfile()