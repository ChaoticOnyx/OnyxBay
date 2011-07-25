var/list/maps
datum/mapobject
	var/name = "NSV Luna"
	var/mapname = "NSV_Luna"
	var/decks = 4
datum/mapobject/baystation12
	name = "NSV Luna"
	mapname = "NSV_Luna"
	decks = 4
datum/mapobject/baystation12
	name = "Baystation 12"
	mapname = "baystation12"
	decks = 1


/world/Topic(T, addr, master, key)
	check_diary()
//	world << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/client/C)
			n++
		return n

	else if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		var/n = 0
		for(var/client/C)
			s["player[n]"] = C.key
			n++
		s["players"] = n
		return list2params(s)
	else if(findtext(T,"MSG:",1,0))
		var/name = copytext(T,findtext(T,":",1,0)+1,findtext(T,"/",1,0))
		var/msg =  copytext(T,findtext(T,"/",1,0)+1,0)
		for (var/client/C)
			if (C.holder)
				C.mob.ctab_message("Admin", "<span class=\"admin\"><span class=\"prefix\">ADMINIRC:</span> <span class=\"name\">[name]:</span> <span class=\"message\">[msg]</span></span>")
	else if(T == "teleplayer")
        //download and open savefile
		var/savefile/F = new(Import())
        //load mob
		var/mob/M
		var {saved_x; saved_y; saved_z}
		F["s_x"] >> saved_x
		F["s_y"] >> saved_y
		F["s_z"] >> saved_z
		F["mob"] >> M
		M.Move(locate(saved_x,saved_y,saved_z))
		return 1
	else if(T == "teleobj")
        //download and open savefile
		var/savefile/F = new(Import())
        //load mob
		var/obj/O
		var {saved_x; saved_y; saved_z}
		F["s_x"] >> saved_x
		F["s_y"] >> saved_y
		F["s_z"] >> saved_z
		F["obj"] >> O
		O.Move(locate(saved_x,saved_y,saved_z))
		return 1
	else if(T == "teleping")
		if(ticker)
			return 1
		return 2

var/jsonpath = "/home/bay12/public_html"
var/dmepath = "/home/bay12/git/bs12.dme"
world/proc/makejson()

	if(!makejson)
		return
	fdel("[jsonpath]/info.json")
		//usr << "Error cant delete json"
	//else
		//usr << "Deleted json in public html"
	fdel("info.json")
		//usr << "error cant delete local json"
	//else
		//usr << "Deleted local json"
	var/F = file("info.json")
	if(!isfile(F))
		return
	var/mode
	if(ticker.current_state == 1)
		mode = "Round Setup"
	else if(ticker.hide_mode)
		mode = "SECRET"
	else
		mode = master_mode
	var/playerscount = 0
	var/players = ""
	var/admins = "no"
	for(var/client/C)
		playerscount++
		if(C.holder)
			if(!C.stealth)
				admins = "yes"
				players += "[C.key];"
			else
				players += "[C.fakekey];"
		else
			players += "[C.key];"

	F << "{\"mode\":\"[mode]\",\"players\" : \"[players]\",\"playercount\" : \"[playerscount]\",\"admin\" : \"[admins]\"}"
	fcopy("info.json","[jsonpath]/info.json")
/proc/switchmap(newmap,newpath)
	var/obj/mapinfo/M = locate()
	if(!M)
		world << "Did not locate mapinfo object"
		return
	var/oldmap = M.mapname
	world << M.mapname
	var/text = file2text(dmepath)
	var/l = "\\"
	var/path = "#include \"maps[l][oldmap].dmm\""
	var/xpath = "#include \"maps[l][newpath].dmm\""
	var/loc = findtext(text,path,1,0)
	if(!loc)
		world << "NOT FOUND"
		return
	text = copytext(text,1,loc)
	text += "\n[xpath]"
/*	for(var/A in lines)
		if(findtext(A,path,1,0))
			lineloc = lines.Find(A,1,0)
			lines[lineloc] = xpath
			world << "FOUND"*/
	fdel(dmepath)
	var/file = file(dmepath)
	file << text
	world << "Compiling..."
	shell("./recompile")
	world << "Done"
	world.Reboot("Switching to [newmap]")
obj/mapinfo
	invisibility = 101
	var/mapname = "thismap"
	var/decks = 4
proc/GetMapInfo()
	var/obj/mapinfo/M = locate()
	world << M.name
	world << M.mapname
client/proc/ChangeMap(var/X as text)
	set name = "Change Map"
	set category  = "Admin"
	switchmap(X,X)
	//test
client/proc/testjson()
 	world.makejson()
proc/send2irc(msg,msg2)
 	shell("python26 nudge.py [msg] [msg2]")
proc/send2adminirc(channel,msg)
	world << channel << " "<< msg
	shell("python26 nudge.py '[channel]' [msg]")
proc/replacetext(haystack, needle, replace)
	if(!haystack || !needle || !replace)
		return
	var
		needleLen = length(needle)
		replaceLen = length(replace)
		pos = findtext(haystack, needle)
	while(pos)
		haystack = copytext(haystack, 1, pos) + \
			replace + copytext(haystack, pos+needleLen)
		pos = findtext(haystack, needle, pos+replaceLen)
	return haystack
proc/file2list(A)
	var/text = file2text(A)
	var/list/lines = list()
	var/done
	while (done!=1)
		var/X = findtext(text,"\n",1,0)
		if(!X)
			done = 1
			lines += text
		//	// "DONE"
			break
		else
			var/Y = copytext(text,1,X)
			text = copytext(
			text,X+1,0)
			lines += Y
		sleep(1)
	return lines