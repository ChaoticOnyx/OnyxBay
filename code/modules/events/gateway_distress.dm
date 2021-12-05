/datum/event/gateway_distress
	var/obj/machinery/gateway/centerstation/station_gateway
	var/gateway_area_name
	announceWhen = 30

/datum/event/gateway_distress/start()
	station_gateway = safepick(GLOB.station_gateways)
	if(!istype(station_gateway) || !length(GLOB.world_awaygateways) || !station_gateway.ready)
		return
	station_gateway.awaygate = GLOB.world_awaygateways[pick(GLOB.world_awaygateways)]
	station_gateway.forced = TRUE
	station_gateway.wait = world.time + config.gateway_delay
	announceWhen = round(config.gateway_delay / 30)
	gateway_area_name = get_area(station_gateway)?.name
	addtimer(CALLBACK(src, .proc/announce_open), config.gateway_delay)

/datum/event/gateway_distress/announce()
	if(!station_gateway)
		return
	command_announcement.Announce("Security anomaly found in \the [station_gateway.name], location - [gateway_area_name ? gateway_area_name : "Unknown"]. Attempting to iso... \
	Error. The IDS reports the IPS was shutted down. Intrusion alarm level: RED.\nThe IDS reports the transmission was accepted by device. The transmission source is \
	\"Unknown\", signature: \"NT high level distress signal\". Triangulation process detected.\n\
	Estimated time to triangulation completion: [round(((station_gateway.wait - world.time) / 10) / 60)] minutes.", "Gateway Managment Station", zlevels = affecting_z)

/datum/event/gateway_distress/proc/announce_open()
	if(!station_gateway)
		return
	command_announcement.Announce("\The [station_gateway.name] in [gateway_area_name ? gateway_area_name : "Unknown location"] reports the portal has been opened.", "Gateway Operation Computer", zlevels = affecting_z)
	station_gateway.toggleon()
