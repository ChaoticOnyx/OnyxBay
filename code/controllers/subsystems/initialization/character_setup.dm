SUBSYSTEM_DEF(character_setup)
	name = "Character Setup"
	init_order = SS_INIT_CHAR_SETUP
	priority = SS_PRIORITY_CHAR_SETUP
	flags = SS_BACKGROUND
	wait = 1 SECOND
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/clients_awaiting_setup = list()
	var/list/newplayers_requiring_init = list()

	var/list/save_queue = list()

/datum/controller/subsystem/character_setup/Initialize()
	while(clients_awaiting_setup.len)
		var/client/C = clients_awaiting_setup[clients_awaiting_setup.len]
		clients_awaiting_setup.len--
		C?.setup_preferences(TRUE)

	// get_preference_value() requires value 'initialized' to be set TRUE.
	// If we don't do it now - following deferred_login() will fail.
	. = ..()

	while(newplayers_requiring_init.len)
		var/mob/new_player/new_player = newplayers_requiring_init[newplayers_requiring_init.len]
		newplayers_requiring_init.len--
		new_player.deferred_login()

/datum/controller/subsystem/character_setup/proc/queue_client(client/C)
	// Calling this after subsytem's initialization is pointless
	// and the client's preferences will never be loaded.
	ASSERT(!initialized)

	clients_awaiting_setup += C

/datum/controller/subsystem/character_setup/fire(resumed = FALSE)
	while(save_queue.len)
		var/datum/preferences/prefs = save_queue[save_queue.len]
		save_queue.len--

		if(!QDELETED(prefs))
			prefs.save_preferences()

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/character_setup/proc/queue_preferences_save(datum/preferences/prefs)
	save_queue |= prefs
