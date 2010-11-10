var/DBConnection/dbcon = new()
world
	proc
		startmysql(var/silent)
			dbcon.Connect("dbi:mysql:[DB_DBNAME]:[DB_SERVER]:[DB_PORT]","[DB_USER]","[DB_PASSWORD]")
			if(!dbcon.IsConnected()) CRASH(dbcon.ErrorMsg())
			else
				if(!silent)
					world << "\red \b Mysql connection established..."
				keepalive()
		keepalive()
			spawn while(1)
				sleep(200)
				if(!dbcon.IsConnected())
					dbcon.Connect("dbi:mysql:[DB_DBNAME]:[DB_SERVER]:[DB_PORT]","[DB_USER]","[DB_PASSWORD]")
				updateserverstatus()



/*mob/verb/updateserverstatus()
	var/players = 0
	for(var/mob/C in world)
		if(C.client)
			players++
	var/mode
	if(ticker.current_state == GAME_STATE_PREGAME)
		mode = "PreGamePhase"
	else
		mode = ticker.mode.name
	var/DBQuery/key_query = dbcon.NewQuery("REPLACE INTO `status` (`link`,`players`,`mode`) VALUES ('[world.internet_address]:[world.port]','[players]','[mode]')")
	if(!key_query.Execute())
		diary << "Failed-[key_query.ErrorMsg()]"
*/
proc/updateserverstatus()
	var/players = 0
	for(var/client/C)
		players++
		var/playing = 1
		if(istype(C.mob,/mob/dead) || istype(C.mob,/mob/new_player))
			playing = 0
		var/DBQuery/r_query = dbcon.NewQuery("REPLACE INTO `currentplayers` (`name`,`playing`) VALUES ([dbcon.Quote(C.key)],[dbcon.Quote(playing)])")
		if(!r_query.Execute())
			diary << "Failed-[r_query.ErrorMsg()]"
	var/mode
	if(ticker.current_state == GAME_STATE_PREGAME)
		mode = "Round Setup"
	else
		mode = ticker.mode.name
	var/DBQuery/key_query = dbcon.NewQuery("REPLACE INTO `status` (`name`,`link`,`players`,`mode`) VALUES ([dbcon.Quote(world.name)],[dbcon.Quote("[world.internet_address]:[world.port]")],'[players]',[dbcon.Quote(mode)])")
	if(!key_query.Execute())
		diary << "Failed-[key_query.ErrorMsg()]"
var/motdmysql = null
/client/proc/showmotd()
	if(!motdmysql)
		var/DBQuery/r_query = dbcon.NewQuery("SELECT * FROM `config`")
		if(!r_query.Execute())
			diary << "Failed-[r_query.ErrorMsg()]"
		else
			var/lawl
			while(r_query.NextRow())
				var/list/column_data = r_query.GetRowData()
				lawl = column_data["motd"]
			if(!lawl)
				src << "ERROR GETTING MOTD"
				return
		//	motdmysql += "<head><style type='text/css'>h2 {color:#FFFFFF;text-align:center;}body { background-color:#28343b;color:gray;text-indent: 50px;}p{text-indent: 50px;text-align:justify;letter-spacing:3px;}</style></head>"
		//	motdmysql += "<body>"
			motdmysql += "[lawl]"
			motdmysql += "<BR><center><a href=?src=\ref[src];closemotd=1>Close</a></center>"
			motdmysql += "</body>"

			usr << browse(motdmysql,"window=motd;size=800x600;titlebar=0")
	else
		usr << browse(motdmysql,"window=motd;size=800x600;titlebar=0")
client/Topic(href, href_list[])
	if(href_list["closemotd"])
		src << browse(null,"window=motd;")
	..()
