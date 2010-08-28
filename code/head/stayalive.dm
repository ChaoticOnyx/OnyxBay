var/DBConnection/dbcon = new()
world
	proc
		startmysql(var/silent)
			dbcon.Connect("dbi:mysql:[DB_DBNAME]:[DB_SERVER]:3306","[DB_USER]","[DB_PASSWORD]")
			if(!dbcon.IsConnected()) CRASH(dbcon.ErrorMsg())
			else
				if(!silent)
					world << "\red \b Mysql connection established..."
				keepalive()
		keepalive()
			spawn while(1)
				sleep(200)
				updateserverstatus()
				if(!dbcon.IsConnected())
					dbcon.Connect("dbi:mysql:[DB_DBNAME]:[DB_SERVER]:3306","[DB_USER]","[DB_PASSWORD]")


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
	for(var/mob/C in world)
		if(C.client)
			players++
	var/mode
	if(ticker.current_state == GAME_STATE_PREGAME)
		mode = "Round Setup"
	else
		mode = ticker.mode.name
		var/DBQuery/key_query = dbcon.NewQuery("REPLACE INTO `status` (`host`,`link`,`players`,`mode`) VALUES ('[world.host],[world.internet_address]:[world.port]','[players]','[mode]')")
		if(!key_query.Execute())
			diary << "Failed-[key_query.ErrorMsg()]"