/datum/map/exodus/get_network_access(var/network)
	switch(network)
		if(NETWORK_CIVILIAN_WEST)
			return access_mailsorting
		if(NETWORK_RESEARCH_OUTPOST)
			return access_research
		if(NETWORK_TELECOM)
			return access_heads
	return get_shared_network_access(network) || ..()

/datum/map/exodus
	station_networks = list(
		NETWORK_CIVILIAN_EAST,
		NETWORK_CIVILIAN_WEST,
		NETWORK_COMMAND,
		NETWORK_ENGINE,
		NETWORK_ENGINEERING,
		NETWORK_ENGINEERING_OUTPOST,
		NETWORK_EXODUS,
		NETWORK_MAINTENANCE,
		NETWORK_MEDICAL,
		NETWORK_MINE,
		NETWORK_RESEARCH,
		NETWORK_RESEARCH_OUTPOST,
		NETWORK_ROBOTS,
		NETWORK_PRISON,
		NETWORK_SECURITY,
		NETWORK_ALARM_ATMOS,
		NETWORK_ALARM_CAMERA,
		NETWORK_ALARM_FIRE,
		NETWORK_ALARM_MOTION,
		NETWORK_ALARM_POWER,
		NETWORK_THUNDER,
		NETWORK_TELECOM,
		NETWORK_MASTER
	)

//
// Cameras
//

// Networks
/obj/machinery/camera/network/civilian_east
	network = list(NETWORK_CIVILIAN_EAST, NETWORK_MASTER)

/obj/machinery/camera/network/civilian_west
	network = list(NETWORK_CIVILIAN_WEST, NETWORK_MASTER)

/obj/machinery/camera/network/command
	network = list(NETWORK_COMMAND, NETWORK_MASTER)

/obj/machinery/camera/network/exodus
	network = list(NETWORK_EXODUS, NETWORK_MASTER)

/obj/machinery/camera/network/maintenance
	network = list(NETWORK_MAINTENANCE, NETWORK_MASTER)

/obj/machinery/camera/network/prison
	network = list(NETWORK_PRISON, NETWORK_MASTER)

/obj/machinery/camera/network/research
	network = list(NETWORK_RESEARCH, NETWORK_MASTER)

/obj/machinery/camera/network/research_outpost
	network = list(NETWORK_RESEARCH_OUTPOST)

/obj/machinery/camera/network/telecom
	network = list(NETWORK_TELECOM)

/obj/machinery/camera/network/engineering_outpost
	network = list(NETWORK_ENGINEERING_OUTPOST)

// Motion
/obj/machinery/camera/motion/command
	network = list(NETWORK_COMMAND, NETWORK_MASTER)

// X-ray
/obj/machinery/camera/xray/medbay
	network = list(NETWORK_MEDICAL, NETWORK_MASTER)

/obj/machinery/camera/xray/research
	network = list(NETWORK_RESEARCH, NETWORK_MASTER)

/obj/machinery/camera/xray/security
	network = list(NETWORK_SECURITY, NETWORK_MASTER)