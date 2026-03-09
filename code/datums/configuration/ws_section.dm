/datum/configuration_section/ws
	name = "ws"

	var/address
	var/proxy_port
	var/max_connections
	var/max_connections_per_ip
	var/handshake_timeout_ms
	var/idle_timeout_ms
	var/ping_interval_ms
	var/pong_timeout_ms
	var/max_message_size
	var/max_frame_size
	var/max_handshake_size
	var/max_write_buffer_size
	var/rate_limit_messages_per_sec
	var/rate_limit_bytes_per_sec
	var/initial_message_timeout_ms
	var/afk_timeout_ms
	var/trust_x_real_ip
	var/log

/datum/configuration_section/ws/load_data(list/data)
	CONFIG_LOAD_STR(address, data["address"])
	CONFIG_LOAD_NUM(proxy_port, data["proxy_port"])
	CONFIG_LOAD_NUM(max_connections, data["max_connections"])
	CONFIG_LOAD_NUM(max_connections_per_ip, data["max_connections_per_ip"])
	CONFIG_LOAD_NUM(handshake_timeout_ms, data["handshake_timeout_ms"])
	CONFIG_LOAD_NUM(idle_timeout_ms, data["idle_timeout_ms"])
	CONFIG_LOAD_NUM(ping_interval_ms, data["ping_interval_ms"])
	CONFIG_LOAD_NUM(pong_timeout_ms, data["pong_timeout_ms"])
	CONFIG_LOAD_NUM(max_message_size, data["max_message_size"])
	CONFIG_LOAD_NUM(max_frame_size, data["max_frame_size"])
	CONFIG_LOAD_NUM(max_handshake_size, data["max_handshake_size"])
	CONFIG_LOAD_NUM(max_write_buffer_size, data["max_write_buffer_size"])
	CONFIG_LOAD_NUM(rate_limit_messages_per_sec, data["rate_limit_messages_per_sec"])
	CONFIG_LOAD_NUM(rate_limit_bytes_per_sec, data["rate_limit_bytes_per_sec"])
	CONFIG_LOAD_NUM(initial_message_timeout_ms, data["initial_message_timeout_ms"])
	CONFIG_LOAD_NUM(afk_timeout_ms, data["afk_timeout_ms"])
	CONFIG_LOAD_BOOL(trust_x_real_ip, data["trust_x_real_ip"])
	CONFIG_LOAD_BOOL(log, data["log"])
