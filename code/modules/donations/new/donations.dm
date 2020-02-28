#define DONATIONS_DB_CREDENTIALS_SAVEFILE "data/donations_db_credentials.sav"


SUBSYSTEM_DEF(donations)
	name = "Donations"
	init_order = SS_INIT_DONATIONS
	flags = SS_NO_FIRE
	var/DBConnection/dbconnection = new()
	var/connected = FALSE


/datum/controller/subsystem/donations/Initialize(timeofday)
	if(!config.sql_enabled)
		log_debug("Donations system is disabled with SQL!")
		return

	if(!config.donations)
		log_debug("Donations system is disabled by configuration!")
		return

	..()

	var/credentials = null

	var/savefile/F = new(DONATIONS_DB_CREDENTIALS_SAVEFILE)
	if("credentials" in F)
		F["credentials"] >> credentials

	if(!credentials)
		return

	Reconnect(credentials)

	if(connected)
		log_debug("Donations system successfully connected!")
	else
		log_debug("Donations system failed to connect with DB!")
	

/datum/controller/subsystem/donations/proc/Reconnect(credentials)
	var/list/items = splittext(credentials, ";")

	if(items.len != 5)
		log_debug("Failed to connect with donations DB: bad credentials!")
		return FALSE

	var/address = items[1]
	var/port = items[2]
	var/user = items[3]
	var/pass = items[4]
	var/db = items[5]


	var/DBConnection/newconnection = new()

	newconnection.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(!newconnection.IsConnected())
		log_debug("Failed to connect with donations database!")
		return FALSE

	dbconnection.Disconnect()
	dbconnection = newconnection
	connected = TRUE

	UpdateAllClients()

	log_debug("Successfully connected to donators DB!")

	return TRUE


/datum/controller/subsystem/donations/proc/UpdateCredentials(credentials)
	var/result = Reconnect(credentials)

	if(result)
		var/savefile/F = new(DONATIONS_DB_CREDENTIALS_SAVEFILE)
		if (F)
			F["credentials"] << credentials
		log_debug("Donations DB credentials were updated!")


/datum/controller/subsystem/donations/proc/UpdateAllClients()
	set waitfor = 0
	for(var/client/C in GLOB.clients)
		LogAndLoadPlayerData(C)
	log_debug("Donators info were updated!")


/datum/controller/subsystem/donations/proc/LogAndLoadPlayerData(client/player)
	set waitfor = 0

	if(!connected)
		return

	var/DBQuery/query = dbconnection.NewQuery("INSERT IGNORE INTO players(ckey) VALUES (\"[player.ckey]\")")
	if(!query.Execute())
		log_debug("\[Donations DB] failed to log player: [query.ErrorMsg()]")
		return FALSE

	query = dbconnection.NewQuery("SELECT players.points, patron_types.type FROM players JOIN patron_types ON players.patron_type = patron_types.id WHERE ckey = \"[player.ckey]\" LIMIT 0,1")
	if(!query.Execute())
		log_debug("\[Donations DB] failed to load player's donation info: [query.ErrorMsg()]")
		return FALSE

	if(query.NextRow())
		player.donator_info.donator = TRUE
		player.donator_info.points = query.item[1]
		player.donator_info.patron_type = query.item[2]

	player.donator_info.on_loaded(player)
	
	return TRUE

/datum/controller/subsystem/donations/proc/CheckToken(client/player, token)
	if(!connected)
		return FALSE

	var/DBQuery/query = dbconnection.NewQuery("SELECT token, discord FROM tokens WHERE token = \"[token]\" LIMIT 0,1")
	if(!query.Execute())
		log_debug("\[Donations DB] failed to load token: [query.ErrorMsg()]")
		return FALSE

	if(!query.NextRow())
		return FALSE

	var/discord_id = query.item[2]

	query = dbconnection.NewQuery("UPDATE players SET discord=\"[discord_id]\" WHERE ckey=\"[player.ckey]\"")

	if(!query.Execute())
		log_debug("\[Donations DB] failed to update discord id: [query.ErrorMsg()]")
		return FALSE

	query = dbconnection.NewQuery("DELETE FROM tokens WHERE token = \"[token]\"")
	if(!query.Execute())
		log_debug("\[Donations DB] failed to delete token: [query.ErrorMsg()]")

	return TRUE



/client/proc/update_donations_db_credentials()
	set name = "Update Donations DB Credentials"
	set hidden = TRUE
	if (!check_rights(R_HOST))
		to_chat(usr, "You have no permissions for donations DB!")
		return

	if(!config.sql_enabled)
		to_chat(usr, "Donations system cannot be used, because SQL is disabled by configuration!")
		return

	if(!config.donations)
		to_chat(usr, "Donations system is disabled by configuration!")
		return

	var/credentials = input("Enter Donations DB Credentials:", "Donations DB Credentials", "1.2.3.4;1234;user;password;db_name")
	SSdonations.UpdateCredentials(credentials)


/client/verb/chaotic_token(token as text)
	set name = ".chaotic-token"
	set hidden = TRUE

	if(!config.sql_enabled)
		to_chat(usr, "Donations system cannot be used, because SQL is disabled by configuration!")
		return

	if(!config.donations)
		to_chat(usr, "Donations system is disabled by configuration!")
		return

	if(SSdonations.CheckToken(src, token))
		to_chat(usr, "Discord account was successfully linked with your BYOND ckey!")
	else
		to_chat(usr, "Failed to link discord account with BYOND ckey!")
