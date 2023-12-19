SUBSYSTEM_DEF(inactivity)
	name = "Inactivity"
	wait = 1 MINUTE
	priority = SS_PRIORITY_INACTIVITY
	flags = SS_NO_INIT
	var/tmp/list/client_list
	var/number_kicked = 0

/datum/controller/subsystem/inactivity/fire(resumed = FALSE)
	if(!config.misc.kick_inactive)
		suspend()
		return
	if(!resumed)
		client_list = GLOB.clients.Copy()

	while(client_list.len)
		var/client/C = client_list[client_list.len]
		client_list.len--
		if(!C.holder && C.is_afk(config.misc.kick_inactive MINUTES) && !isobserver(C.mob))
			log_access("AFK: [key_name(C)]")
			to_chat(C, SPAN("warning", "You have been inactive for more than [config.misc.kick_inactive] minute\s and have been disconnected."), type = MESSAGE_TYPE_SYSTEM)
			qdel(C)
			number_kicked++
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/inactivity/stat_entry(msg)
	msg = "Kicked: [number_kicked]"
	return ..()
