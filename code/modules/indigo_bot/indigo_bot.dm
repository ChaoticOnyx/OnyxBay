GLOBAL_DATUM_INIT(indigo_bot, /datum/indigo_bot, new)

/datum/indigo_bot/proc/is_enabled()
	return config.indigo_bot.address != null && config.indigo_bot.secret != null

/datum/indigo_bot/proc/identity()
	var/res = __send("/api/identity")
	return res

/datum/indigo_bot/proc/__send(query)
	if(!is_enabled())
		return

	var/response = world.Export("[config.indigo_bot.address][query]")

	if(response != null)
		var/content = file2text(response["CONTENT"])
		return json_decode(content)

/datum/indigo_bot/proc/chat_webhook(secret, message)
	if(secret == null)
		return

	message = url_encode(message)
	__send("/api/byond/webhook/[secret]?message=[message]")

/datum/indigo_bot/proc/round_end_webhook(secret, round_id, game_mode, players_count, round_duration)
	round_id = url_encode(round_id)
	game_mode = url_encode(game_mode)
	players_count = url_encode(players_count)
	round_duration = url_encode(round_duration)
	__send("/api/byond/webhook/[secret]?round_id=[round_id]&game_mode=[game_mode]&players=[players_count]&round_duration=[round_duration]")
