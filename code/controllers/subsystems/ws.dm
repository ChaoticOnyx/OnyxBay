#define WS_TOKEN_DURATION (60 SECONDS)

GLOBAL_VAR(ws_secret)
GLOBAL_PROTECT(ws_secret)

SUBSYSTEM_DEF(ws)
	name = "WS"
	wait = 1
	flags = SS_NO_INIT | SS_NO_FIRE

	var/address = null // TBD
	var/port = null // TBD

/datum/controller/subsystem/ws/stat_entry()
	var/list/stats = json_decode(Z_WS_STATS())

	var/msg = "T:[stats["tick_duration_ms"]]ms "
	msg += "S:[stats["sent_kilobytes_per_second"]]KB/s "
	msg += "R:[stats["received_kilobytes_per_second"]]KB/s "

	if(address != null)
		msg += "A:[address] "
	else
		msg += "A:TBD "

	msg += "C:[port != null ? Z_WS_CONNECTIONS() : "N/A"]/[config.ws.max_connections]"

	return ..(msg)

/datum/controller/subsystem/ws/proc/start_server()
	var/list/cfg = list(
		"max_connections" = config.ws.max_connections,
		"max_connections_per_ip" = config.ws.max_connections_per_ip,
		"handshake_timeout_ms" = config.ws.handshake_timeout_ms,
		"idle_timeout_ms" = config.ws.idle_timeout_ms,
		"ping_interval_ms" = config.ws.ping_interval_ms,
		"pong_timeout_ms" = config.ws.pong_timeout_ms,
		"max_message_size" = config.ws.max_message_size,
		"max_frame_size" = config.ws.max_frame_size,
		"max_handshake_size" = config.ws.max_handshake_size,
		"max_write_buffer_size" = config.ws.max_write_buffer_size,
		"rate_limit_messages_per_sec" = config.ws.rate_limit_messages_per_sec,
		"rate_limit_bytes_per_sec" = config.ws.rate_limit_bytes_per_sec,
		"initial_message_timeout_ms" = config.ws.initial_message_timeout_ms,
		"afk_timeout_ms" = config.ws.afk_timeout_ms,
		"trust_x_real_ip" = config.ws.trust_x_real_ip,
		"log" = config.ws.log,
	)

	var/parts = splittext(config.ws.address, ":")

	if(length(parts) != 3)
		CRASH("Invalid WebSocket address: [config.ws.address]")


	port = text2num(parts[3]) || 0

	if(!Z_WS_START(port, nameof(.proc/OnWSText), null, json_encode(cfg)))
		CRASH("Failed to start a WebSocket server: [Z_GET_LAST_ERROR()]")

	port = Z_WS_GET_PORT()

	// In case we use a proxy we should display the proxy's port, not the WebSocket's server port.
	if(config.ws.proxy_port)
		address = "[parts[1]]:[parts[2]]:[config.ws.proxy_port]"
	else
		address = "[parts[1]]:[parts[2]]:[port]"

	log_debug("Running a WebSocket server on port: [port]")

	loop()

/datum/controller/subsystem/ws/proc/loop()
	set waitfor = FALSE

	while(src != null && port != null)
		Z_WS_TICK()
		sleep(world.tick_lag)

/datum/controller/subsystem/ws/Destroy()
	if(port != null)
		Z_WS_STOP()
	
	port = null
	GLOB.ws_secret = null

	. = ..()

/datum/controller/subsystem/ws/proc/get_address()
	return address

/datum/controller/subsystem/ws/proc/issue_token(ckey)
	if(GLOB.ws_secret == null)
		GLOB.ws_secret = Z_CRYPTO_RANDOM_BASE64(64)
		ASSERT(GLOB.ws_secret != null)

	var/payload = "[ckey];[game_id];[world.time]"
	var/signature = Z_CRYPTO_HMAC_SHA256(payload, GLOB.ws_secret)
	ASSERT(signature != null)

	return "[signature];[payload]"

/datum/controller/subsystem/ws/proc/verify_token(token)
	if(GLOB.ws_secret == null)
		return FALSE

	if(token == null || token == "")
		return FALSE

	var/parts = splittext(token, ";") // only ascii

	if(length(parts) != 4)
		return FALSE

	if(parts[3] != game_id)
		return FALSE

	var/created_at = text2num(parts[4])

	if(created_at == null || world.time > created_at + WS_TOKEN_DURATION)
		return FALSE

	var/payload = "[parts[2]];[parts[3]];[parts[4]]"
	var/signature = Z_CRYPTO_HMAC_SHA256(payload, GLOB.ws_secret)

	if(signature != parts[1])
		return FALSE

	return parts[2]

/proc/OnWSText(content, addr, conn_id)
	try
		var/list/data = json_decode(content)
		var/ckey = SSws.verify_token(data["token"])

		if(!ckey)
			return FALSE
		
		if(!data["payload"])
			return FALSE

		var/client/client = client_by_ckey(ckey)

		if(!client)
			return FALSE

		switch(data["type"])
			if("tgui/connect")
				return tgui_WSConnect(data["payload"], addr, conn_id, client)
			else
				return FALSE
	catch
		return FALSE

#undef WS_TOKEN_DURATION
