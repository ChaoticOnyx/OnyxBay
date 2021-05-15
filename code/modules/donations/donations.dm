SUBSYSTEM_DEF(donations)
	name = "Donations"
	init_order = SS_INIT_DONATIONS
	flags = SS_NO_FIRE
	var/DBConnection/dbconnection = new()
	var/connected = FALSE

#define DONATIONS_DB_CREDENTIALS_SAVEFILE "data/donations_db_credentials.sav"
/datum/controller/subsystem/donations/Initialize(timeofday)
	if(!config.sql_enabled)
		log_debug("Donations system is disabled with SQL!")
		return

	if(!config.donations)
		log_debug("Donations system is disabled by configuration!")
		return

	var/credentials = null

	var/savefile/F = new(DONATIONS_DB_CREDENTIALS_SAVEFILE)
	if("credentials" in F)
		from_file(F["credentials"], credentials)

	if(!credentials)
		return

	Reconnect(credentials)

	if(connected)
		log_debug("Donations system successfully connected!")
	else
		log_debug("Donations system failed to connect with DB!")

	return ..()


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
		if(F)
			to_file(F["credentials"], credentials)
		log_debug("Donations DB credentials were updated!")
#undef DONATIONS_DB_CREDENTIALS_SAVEFILE


/datum/controller/subsystem/donations/proc/UpdateAllClients()
	set waitfor = 0
	for(var/client/C in GLOB.clients)
		log_client_to_db(C)
		update_donator(C)
		update_donator_items(C)
	log_debug("Donators info were updated!")


/datum/controller/subsystem/donations/proc/log_client_to_db(client/player)
	set waitfor = 0

	if(!connected)
		return FALSE

	var/DBQuery/query = dbconnection.NewQuery("INSERT IGNORE INTO players(ckey) VALUES (\"[player.ckey]\")")
	if(!query.Execute())
		log_debug("\[Donations DB] failed to log player: [query.ErrorMsg()]")
		return FALSE

	return TRUE


/datum/controller/subsystem/donations/proc/update_donator(client/player)
	set waitfor = 0

	if(!connected)
		return FALSE
	ASSERT(player)

	var/was_donator = player.donator_info.donator

	var/DBQuery/query = dbconnection.NewQuery({"
		SELECT patron_types.type
		FROM players
		JOIN patron_types ON players.patron_type = patron_types.id
		WHERE ckey = "[player.ckey]"
		LIMIT 0,1
	"})
	if(!query.Execute())
		log_debug("\[Donations DB] failed to load player's donation info: [query.ErrorMsg()]")
		return FALSE

	if(query.NextRow())
		player.donator_info.patron_type = query.item[1]

	query = dbconnection.NewQuery({"
		SELECT `change`
		FROM points_transactions
		JOIN players ON players.id = points_transactions.player
		WHERE ckey = "[player.ckey]"
	"})

	if(!query.Execute())
		log_debug("\[Donations DB] failed to load player's donation info: [query.ErrorMsg()]")
		return FALSE

	player.donator_info.opyxes = 0
	while(query.NextRow())
		player.donator_info.opyxes += text2num(query.item[1])

	if(player.donator_info.opyxes > 0)
		player.donator_info.donator = TRUE

	if(!was_donator)
		player.donator_info.on_patreon_tier_loaded(player)

	return TRUE

/datum/controller/subsystem/donations/proc/update_donator_items(client/player)
	set waitfor = 0

	if(!connected)
		return FALSE

	var/DBQuery/query = dbconnection.NewQuery({"
		SELECT item_path
		FROM store_players_items
		WHERE player = (SELECT id from players WHERE ckey="[player.ckey]")
	"})
	if(!query.Execute())
		log_debug("\[Donations DB] failed to load donator's items: [query.ErrorMsg()]")
		return FALSE

	while(query.NextRow())
		player.donator_info.items.Add(query.item[1])

	return TRUE

/datum/controller/subsystem/donations/proc/create_transaction(client/player, change, type, comment)
	if(!connected)
		return FALSE
	ASSERT(player)
	ASSERT(isnum(change))

	update_donator(player)
	if(!player) // check if player was gone away, while we were updating him
		return FALSE

	if(player.donator_info.opyxes + change < 0)
		return FALSE
	type = sql_sanitize_text(type)
	comment = sql_sanitize_text(comment)

	var/DBQuery/query = dbconnection.NewQuery({"
		INSERT INTO
			points_transactions(player, type, datetime, `change`, comment)
		VALUES (
			(SELECT id from players WHERE ckey="[player.ckey]"),
			(SELECT id from points_transactions_types WHERE type="[type]"),
			NOW(),
			[change],
			"[comment]")
	"})
	if(!query.Execute())
		log_debug("\[Donations DB] failed to create new transaction: [query.ErrorMsg()]")
		return FALSE

	var/transaction_id
	query = dbconnection.NewQuery({"
		SELECT id
		FROM points_transactions
		WHERE
			player = (SELECT id from players WHERE ckey="[player.ckey]") AND
			comment = "[comment]"
		ORDER BY id DESC
	"})
	if(!query.Execute() || !query.NextRow())
		log_debug("\[Donations DB] failed to load transaction's id: [query.ErrorMsg()]")
	else
		transaction_id = query.item[1]

	update_donator(player)

	return text2num(transaction_id)


/datum/controller/subsystem/donations/proc/remove_transaction(client/player, id)
	if(!connected)
		return FALSE
	ASSERT(isnum(id))

	log_debug("\[Donations DB] Transaction [id] rollback is called! User is '[player]'.")

	var/DBQuery/query = dbconnection.NewQuery({"
		DELETE FROM
			points_transactions
		WHERE
			id = [id]
	"})
	if(!query.Execute())
		log_debug("\[Donations DB] failed to delete transaction [id]: [query.ErrorMsg()]")
		return FALSE

	if(player)
		update_donator(player)
	return TRUE


/datum/controller/subsystem/donations/proc/give_item(client/player, item_type, transaction_id = null)
	if(!connected)
		return FALSE
	ASSERT(player)
	ASSERT(item_type)
	ASSERT(transaction_id == null || isnum(transaction_id))

	var/DBQuery/query = dbconnection.NewQuery({"
		INSERT INTO
			store_players_items(player, transaction, obtaining_date, item_path)
		VALUES (
			(SELECT id from players WHERE ckey="[player.ckey]"),
			[transaction_id ? transaction_id : "NULL"],
			NOW(),
			"[item_type]")
	"})

	if(!query.Execute())
		log_debug("\[Donations DB] failed to give an item to the player: [query.ErrorMsg()]")
		return FALSE

	player.donator_info.items.Add("[item_type]")

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


/datum/controller/subsystem/donations/proc/show_donations_info(user)
	ASSERT(user)
	var/ui_key = "donation_info"
	var/list/data = list(
		"SSdonations" = "\ref[SSdonations]"
	)
	var/datum/nanoui/ui = SSnano.try_update_ui(user, src, ui_key, null, data, force_open=FALSE)
	if(!ui)
		ui = new (user, src, ui_key, "donations_info.tmpl", "Donations Info", 500, 600, state=GLOB.interactive_state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)


/datum/controller/subsystem/donations/Topic(href, href_list)
	var/mob/user = usr

	switch(href_list["action"])
		if("go_to_patreon")
			log_debug("\[Donations] patreon link used by '[user]'")
			send_link(user, config.patreonurl)
			return 1
		if("go_to_discord")
			log_debug("\[Donations] discord link used by '[user]'")
			send_link(user, config.discordurl)
			return 1

	return 0


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


/client/verb/donations_info()
	set name = "Donations Info"
	set desc = "View information about donations to Onyx."
	set hidden = 1

	SSdonations.show_donations_info(usr)
