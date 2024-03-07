GLOBAL_DATUM_INIT(indigo_bot, /datum/indigo_bot, new)

/datum/indigo_bot/proc/is_enabled()
	return config.indigo_bot.address != null

/datum/indigo_bot/proc/identity()
	var/datum/http_request/R = new()
	R.prepare(RUSTG_HTTP_METHOD_GET, "/api/identity")

	var/datum/http_response/res = __send(R)

	if(res.errored || res.status_code != 200)
		CRASH("Invalid '/api/identity' response: code [res.status_code]")

	return res.body

/datum/indigo_bot/proc/__send(datum/http_request/R)
	if(!is_enabled())
		return

	R.url = "[config.indigo_bot.address][R.url]"
	R.execute_blocking()

	return R.into_response()

/datum/indigo_bot/proc/chat_webhook(secret, message)
	if(secret == null)
		return

	var/datum/http_request/R = new()
	R.prepare(RUSTG_HTTP_METHOD_POST, "/api/webhook/[secret]", json_encode(list(
		"message" = message
	)), list("Content-Type" = "application/json"), "")

	__send(R)

/datum/indigo_bot/proc/round_end_webhook(secret, round_id, game_mode, players_count, round_duration)
	var/datum/http_request/R = new()
	R.prepare(RUSTG_HTTP_METHOD_POST, "/api/webhook/[secret]", json_encode(list(
		"round_id" = round_id,
		"game_mode" = game_mode,
		"players" = players_count,
		"round_duration" = round_duration
	)), list("Content-Type" = "application/json"), "")

	__send(R)

/datum/indigo_bot/proc/bug_report_webhook(secret, title, body, ckey)
	var/datum/http_request/R = new()
	var/request_body = json_encode(list(
		"title" = title,
		"body" = body,
		"player" = ckey
	))

	R.prepare(RUSTG_HTTP_METHOD_POST, "/api/webhook/[secret]", request_body, list("Content-Type" = "application/json"), "")

	__send(R)
