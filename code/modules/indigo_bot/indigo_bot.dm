GLOBAL_DATUM_INIT(indigo_bot, /datum/indigo_bot, new)

/client/verb/connect_account()
	set name = "Connect Account"
	set category = "OOC"
	set desc = "Connect your BYOND and Discord accounts together."

	var/static/list/cooldowns = list()

	if(!cooldowns[usr.ckey])
		cooldowns[usr.ckey] = world.time

	var/datum/indigo_bot/B = GLOB.indigo_bot
	if(!B.is_enabled())
		to_chat(usr, SPAN_WARNING("The service is not available yet"))
		return

	THROTTLE_SHARED(cd, 1 SECOND, cooldowns[usr.ckey])

	var/bot_identity = B.identity()
	var/secret = input(usr, "Enter here your 2FA token. That token you can get from the Discord bot '[bot_identity["name"]]#[bot_identity["discriminator"]]' by DM him with the command '!2fa'", "Connect Account") as text | null

	if(!secret)
		return

	var/response = B.connect_byond(url_encode(secret), ckey)

	if(response == "ok")
		to_chat(usr, SPAN_NOTICE("Your account is now connected!"))
	else
		to_chat(usr, SPAN_DANGER("Your token is invalid or something went wrong, contact developers"))

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

/datum/indigo_bot/proc/connect_byond(secret, ckey)
	return __send("/api/byond/connect/byond?tfa_secret=[secret]&ckey=[ckey]&secret=[config.indigo_bot.secret]")

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
