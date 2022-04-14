/datum/event/gateway_distress
	var/obj/machinery/gateway/centerstation/station_gateway
	var/gateway_area_name

/datum/event/gateway_distress/start()
	station_gateway = safepick(GLOB.station_gateways)
	if(!istype(station_gateway) || !length(GLOB.world_awaygateways) || !station_gateway.ready)
		return
	var/time_to_open = rand(5, 10)
	time_to_open = time_to_open MINUTES
	station_gateway.awaygate = GLOB.world_awaygateways[pick(GLOB.world_awaygateways)]
	station_gateway.forced = TRUE
	station_gateway.wait = world.time + time_to_open
	gateway_area_name = get_area(station_gateway)?.name
	addtimer(CALLBACK(src, .proc/announce_open), time_to_open)

/datum/event/gateway_distress/announce()
	if(!station_gateway)
		return

	command_announcement.AnnounceLocalizeable(
		TR_DATA(L10N_ANNOUNCE_GATEWAY_DISTRESS, null, list("gateway_name" = station_gateway.name, "time" = round(((station_gateway.wait - world.time) / 10) / 60), "location" = gateway_area_name ? lowertext(gateway_area_name) != lowertext(station_gateway.name) ? "" : ", location - [gateway_area_name]" : ", location - Unknown")),
		TR_DATA(L10N_ANNOUNCE_GATEWAY_DISTRESS_TITLE, null, null),
		zlevels = affecting_z
	)

/datum/event/gateway_distress/proc/announce_open()
	if(!station_gateway)
		return
	command_announcement.AnnounceLocalizeable(
		TR_DATA(L10N_ANNOUNCE_GATEWAY_DISTRESS_OPEN, null, list("gateway_name" = station_gateway.name, "location" = gateway_area_name ? lowertext(gateway_area_name) == lowertext(station_gateway.name) ? "" : " in [gateway_area_name]": " in Unknown location")),
		TR_DATA(L10N_ANNOUNCE_GATEWAY_DISTRESS_TITLE, null, null),
		zlevels = affecting_z
	)
	station_gateway.toggleon()
