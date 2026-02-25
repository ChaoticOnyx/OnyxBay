SUBSYSTEM_DEF(donations)
	name = "Donations"
	init_order = SS_INIT_DONATIONS
	flags = SS_NO_FIRE

/datum/controller/subsystem/donations/Initialize(timeofday)
	if(!config.external.sql_enabled)
		log_debug("Donations system is disabled with SQL!")
		return

	if(!config.donations.enable)
		log_debug("Donations system is disabled by configuration!")
		return

	if(establish_don_db_connection())
		log_debug("Donations system successfully connected!")
		UpdateAllClients()
	else
		log_debug("Donations system failed to connect with DB!")

	return ..()

/datum/controller/subsystem/donations/proc/UpdateAllClients()
	set waitfor = 0
	for(var/client/C in GLOB.clients)
		log_client_to_db(C)
		update_donator(C)
		update_donator_items(C)
	log_debug("Donators info were updated!")


/datum/controller/subsystem/donations/proc/log_client_to_db(client/player)
	set waitfor = 0

	if(!establish_don_db_connection())
		return FALSE

	sql_query("INSERT IGNORE INTO players (ckey) VALUES ($ckey)", dbcon_don, list(ckey = player.ckey))

	return TRUE


/datum/controller/subsystem/donations/proc/update_donator(client/player)
	set waitfor = 0

	if(!establish_don_db_connection())
		return FALSE
	ASSERT(player)

	var/was_donator = player.donator_info.donator

	var/DBQuery/query = sql_query({"
		SELECT
			patron_types.type
		FROM
			players
		JOIN
			patron_types ON players.patron_type = patron_types.id
		WHERE
			ckey = $ckey
		LIMIT 0,1
	"}, dbcon_don, list(ckey = player.ckey))

	if(query.NextRow())
		player.donator_info.patron_type = query.item[1]

	query = sql_query({"
		SELECT
			`change`
		FROM
			points_transactions
		JOIN
			players ON players.id = points_transactions.player
		WHERE
			ckey = $ckey
	"}, dbcon_don, list(ckey = player.ckey))

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

	if(!establish_don_db_connection())
		return FALSE

	var/DBQuery/query = sql_query({"
		SELECT
			item_path
		FROM
			store_players_items
		WHERE
			player = (SELECT id FROM players WHERE ckey = $ckey)
	"}, dbcon_don, list(ckey = player.ckey))

	while(query.NextRow())
		player.donator_info.items.Add(query.item[1])

	return TRUE

/datum/controller/subsystem/donations/proc/create_transaction(client/player, change, type, comment)
	if(!establish_don_db_connection())
		return FALSE
	ASSERT(player)
	ASSERT(isnum(change))

	update_donator(player)
	if(!player) // check if player was gone away, while we were updating him
		return FALSE

	if(player.donator_info.opyxes + change < 0)
		return FALSE

	sql_query({"
		INSERT INTO
			points_transactions
		VALUES (
			NULL,
			(SELECT id FROM players WHERE ckey = $ckey),
			(SELECT id FROM points_transactions_types WHERE type = $type),
			NOW(),
			$change,
			$comment)
	"}, dbcon_don, list(ckey = player.ckey, type = type, change = change, comment = comment))

	var/transaction_id
	var/DBQuery/query = sql_query({"
		SELECT
			id
		FROM
			points_transactions
		WHERE
			player = (SELECT id FROM players WHERE ckey = $ckey)
			AND
			comment = $comment
		ORDER BY
			id
			DESC
	"}, dbcon_don, list(ckey = player.ckey, comment = comment))

	if(query.NextRow())
		transaction_id = query.item[1]

	update_donator(player)

	return text2num(transaction_id)


/datum/controller/subsystem/donations/proc/remove_transaction(client/player, id)
	if(!establish_don_db_connection())
		return FALSE
	ASSERT(isnum(id))

	log_debug("\[Donations DB] Transaction [id] rollback is called! User is '[player]'.")

	sql_query({"
		DELETE FROM
			points_transactions
		WHERE
			id = $id
	"}, dbcon_don, list(id = id))

	if(player)
		update_donator(player)
	return TRUE


/datum/controller/subsystem/donations/proc/give_item(client/player, item_type, transaction_id = null)
	if(!establish_don_db_connection())
		return FALSE
	ASSERT(player)
	ASSERT(item_type)
	ASSERT(transaction_id == null || isnum(transaction_id))

	sql_query({"
		INSERT INTO
			store_players_items
		VALUES
			(NULL,
			(SELECT id from players WHERE ckey = $ckey),
			$tid,
			NOW(),
			$item_type)
	"}, dbcon_don, list(ckey = player.ckey, tid = transaction_id ? transaction_id : "NULL", item_type = item_type))

	player.donator_info.items.Add("[item_type]")

	return TRUE

/datum/controller/subsystem/donations/proc/CheckToken(client/player, token)
	if(!establish_don_db_connection())
		return FALSE

	var/DBQuery/query = sql_query("SELECT token, discord FROM tokens WHERE token = $token LIMIT 0,1", dbcon_don, list(token = token))

	if(!query.NextRow())
		return FALSE

	var/discord_id = query.item[2]

	// Check if we have two distinct records for user's discord and ckey in the players table
	// If that's true, then we have to merge them
	query = sql_query("SELECT id FROM players WHERE discord = $discord_id AND ckey IS NULL", dbcon_don, list(discord_id = discord_id))
	if(!query.NextRow()) //We don't have that, use an old method
		sql_query("UPDATE players SET discord = $discord_id WHERE ckey = $ckey", dbcon_don, list(discord_id = discord_id, ckey = player.ckey))
	else
		var/discord_player_id = query.item[1]
		query = sql_query("SELECT id FROM players WHERE ckey = $ckey", dbcon_don, list(ckey = player.ckey))
		if(query.NextRow())
			var/ckey_player_id = query.item[1]

			//Update donations to old record
			sql_query("UPDATE points_transactions SET player = $discord_player_id WHERE player = $ckey_player_id", dbcon_don, list(discord_player_id = discord_player_id, ckey_player_id = ckey_player_id))
			sql_query("UPDATE money_transactions SET player = $discord_player_id WHERE player = $ckey_player_id", dbcon_don, list(discord_player_id = discord_player_id, ckey_player_id = ckey_player_id))
			sql_query("UPDATE store_players_items SET player = $discord_player_id WHERE player = $ckey_player_id", dbcon_don, list(discord_player_id = discord_player_id, ckey_player_id = ckey_player_id))
			sql_query("DELETE FROM players WHERE id = $ckey_player_id", dbcon_don, list(ckey_player_id = ckey_player_id))

		sql_query("UPDATE players SET ckey = $ckey WHERE discord = $discord_id", dbcon_don, list(ckey = player.ckey, discord_id = discord_id))

	sql_query("DELETE FROM tokens WHERE token = $token", dbcon_don, list(token = token))

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
		if("go_to_boosty")
			log_debug("\[Donations] boosty link used by '[user]'")
			send_link(user, config.link.boosty)
			return 1
		if("go_to_discord")
			log_debug("\[Donations] discord link used by '[user]'")
			send_link(user, config.link.discord)
			return 1

	return 0

/client/verb/chaotic_token(token as text)
	set name = ".chaotic-token"
	set hidden = TRUE

	if(!config.external.sql_enabled)
		to_chat(usr, "Donations system cannot be used, because SQL is disabled by configuration!")
		return

	if(!config.donations.enable)
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
