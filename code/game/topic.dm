/world/Topic(T, addr, master, key)
	check_diary()
	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

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

var/jsonpath = "/var/www/html"

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
		players += "[C.key];"
		if(C.holder)
			if(!C.stealth)
				admins = "yes"
	F << "{\"mode\":\"[mode]\",\"players\" : \"[players]\",\"playercount\" : \"[playerscount]\",\"admin\" : \"[admins]\"}"
	fcopy("info.json","[jsonpath]/info.json")

client/proc/testjson()
 	world.makejson()
client/verb/testannoucement(var/msg as text)
 	shell("python26 nudge.py [msg]")