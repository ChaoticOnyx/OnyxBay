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

	var/list/bot_identity = json_decode(B.identity())
	var/tfa_secret = tgui_input_text(usr, "Enter here your 2FA token. That token you can get from the Discord bot '[bot_identity["name"]]#[bot_identity["discriminator"]]' by DM him with the command '!2fa'", "Connect Account")

	if(!tfa_secret)
		return

	var/datum/http_response/response = B.connect_byond(url_encode(tfa_secret), ckey)

	if(response.status_code == 200)
		to_chat(usr, SPAN_NOTICE("Your account is now connected!"))
	else
		to_chat(usr, SPAN_DANGER("Your token is invalid or something went wrong, contact developers (code: [response.status_code])"))

/datum/indigo_bot/proc/is_enabled()
	return config.indigo_bot.address != null

/datum/indigo_bot/proc/identity()
	var/datum/http_request/R = new()
	R.prepare(RUSTG_HTTP_METHOD_GET, "/api/identity")

	var/datum/http_response/res = __send(R)

	if(res.errored || res.status_code != 200)
		CRASH("Invalid '/api/identity' response: code [res.status_code]")

	return res.body

/datum/indigo_bot/proc/__send(datum/http_request/R, wait = TRUE)
	if(!is_enabled())
		return

	R.url = "[config.indigo_bot.address][R.url]"
	R.begin_async()

	if(!wait)
		return

	while(!R.is_complete())
		stoplag()

	return R.into_response()

/datum/indigo_bot/proc/connect_byond(tfa_secret, ckey)
	var/datum/http_request/R = new()
	R.prepare(RUSTG_HTTP_METHOD_POST, "/api/connect/byond", json_encode(list(
		"tfa_secret" = tfa_secret,
		"ckey" = ckey,
	)), list(
		"Content-Type" = "application/json",
		"Authorization" = "Bearer [config.indigo_bot.secret]"
	), "")

	return __send(R, TRUE)

/datum/indigo_bot/proc/chat_webhook(secret, message)
	if(secret == null)
		return

	var/datum/http_request/R = new()
	R.prepare(RUSTG_HTTP_METHOD_POST, "/api/webhook/[secret]", json_encode(list(
		"message" = message
	)), list("Content-Type" = "application/json"), "")

	__send(R, FALSE)

/datum/indigo_bot/proc/round_end_webhook(secret, round_id, game_mode, players_count, round_duration)
	var/datum/http_request/R = new()
	R.prepare(RUSTG_HTTP_METHOD_POST, "/api/webhook/[secret]", json_encode(list(
		"round_id" = round_id,
		"game_mode" = game_mode,
		"players" = players_count,
		"round_duration" = round_duration
	)), list("Content-Type" = "application/json"), "")

	__send(R, FALSE)

/datum/indigo_bot/proc/bug_report_webhook(secret, title, body, ckey)
	var/datum/http_request/R = new()
	var/request_body = json_encode(list(
		"title" = title,
		"body" = body,
		"player" = ckey
	))

	R.prepare(RUSTG_HTTP_METHOD_POST, "/api/webhook/[secret]", request_body, list("Content-Type" = "application/json"), "")

	__send(R, FALSE)
