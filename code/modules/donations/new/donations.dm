#define DONATIONS_DB_CREDENTIALS_SAVEFILE "data/donations_db_credentials.sav"


/datum/donations
	var/DBConnection/dbconnection = new()
	var/enabled = FALSE


/datum/donations/proc/Initialize()
	var/credentials = null

	var/savefile/F = new(DONATIONS_DB_CREDENTIALS_SAVEFILE)
	if("credentials" in F)
		F["credentials"] >> credentials

	if(!credentials)
		return

	Reconnect(credentials)


/datum/donations/proc/Reconnect(var/credentials)
	var/list/items = splittext(credentials, ";")

	if(items.len != 5)
		error("Failed to connect with donations DB: bad credentials!")
		return FALSE

	var/address = items[1]
	var/port = items[2]
	var/user = items[3]
	var/pass = items[4]
	var/db = items[5]


	var/DBConnection/newconnection = new()

	newconnection.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(!newconnection.IsConnected())
		error("Failed to connect with donations database!")
		return FALSE

	dbconnection.Disconnect()
	dbconnection = newconnection
	enabled = TRUE

	UpdateAllClients()

	log_debug("Successfully connected to donators DB!")

	return TRUE


/datum/donations/proc/UpdateCredentials(var/credentials)
	set waitfor = 0

	var/result = Reconnect(credentials)

	if(result)
		var/savefile/F = new(DONATIONS_DB_CREDENTIALS_SAVEFILE)
		if (F)
			F["credentials"] << credentials
		log_debug("Donations DB credentials were updated!")


/datum/donations/proc/UpdateAllClients()
	for(var/client/C in GLOB.clients)
		LoadData(C)
	log_debug("Donators info was updated!")


/datum/donations/proc/DBError(var/err)
	enabled = FALSE
	error("Donations System is disabled due DB error: [err]")


/datum/donations/proc/LoadData(var/client/player)
	if(!enabled)
		return

	var/DBQuery/query = dbconnection.NewQuery("SELECT players.points, patron_types.type FROM players JOIN patron_types ON players.patron_type = patron_types.id WHERE ckey = \"[player.ckey]\" LIMIT 0,1")
	if(!query.Execute())
		log_debug("Donations DB query failed!")
		return FALSE

	if(query.NextRow())
		player.donator_info.donator = TRUE
		player.donator_info.points = query.item[1]
		player.donator_info.patron_type = query.item[2]
	
	return TRUE


/hook/startup/proc/connectDonationsDB()
	if(!config.sql_enabled)
		log_debug("SQL disabled. Donations system will be disabled.")
		return TRUE

	if(!config.donations)
		log_debug("Donations system is disabled by configuration!")
		return TRUE

	donations.Initialize()

	if(donations.enabled)
		log_debug("Donations system successfully initialized!")
	else
		log_debug("Failed to initialize donations system!")
		return FALSE

	return TRUE


/client/proc/update_donations_db_credentials()
	set name = "Update Donations DB Credentials"
	set hidden = TRUE
	if (!check_rights(R_HOST))
		to_chat(usr, "You have no permissions for donations DB!")
		return

	if(!config.sql_enabled)
		to_chat(usr, "SQL disabled. Donations system cannot be used!")
		return TRUE

	if(!config.donations)
		to_chat(usr, "Donations system is disabled by configuration!")
		return

	var/credentials = input("Enter Donations DB Credentials:", "Donations DB Credentials", "1.2.3.4;1234;user;password;db_name")
	donations.UpdateCredentials(credentials)
