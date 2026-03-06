SUBSYSTEM_DEF(ws)
	name = "WS"
	wait = 1
	flags = SS_TICKER
	priority = SS_PRIORITY_WS

	var/port = null // TBD

/datum/controller/subsystem/ws/stat_entry()
	var/msg = "P:"

	if(port != null)
		msg += "[port] "
	else
		msg += "TBD "

	msg += "C:[port != null ? Z_WS_CONNECTIONS() : "N/A"]"

	return ..(msg)

/datum/controller/subsystem/ws/Initialize()
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
		"rate_limit_messages_per_sec" = config.ws.rate_limit_messages_per_sec,
		"rate_limit_bytes_per_sec" = config.ws.rate_limit_bytes_per_sec,
	)

	if(!Z_WS_START(config.ws.port, nameof(.proc/OnWSText), nameof(.proc/OnWSBinary), json_encode(cfg)))
		log_error("Failed to start a WebSocket server: [Z_GET_LAST_ERROR()]")
	else
		port = Z_WS_GET_PORT()
		log_debug("Running a WebSocket server on port: [port]")
	
	. = ..()

/datum/controller/subsystem/ws/fire(resumed = 0)
	if(port != null)
		Z_WS_TICK()

/datum/controller/subsystem/ws/Destroy()
	if(port != null)
		Z_WS_STOP()

	port = null
	. = ..()
