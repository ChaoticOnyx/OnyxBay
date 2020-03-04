SUBSYSTEM_DEF(character_setup)
	name = "Character Setup"
	priority = SS_PRIORITY_CHAR_SETUP
	flags = SS_BACKGROUND|SS_NO_INIT
	wait = 1 SECOND
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/preferences_datums = list()
	var/list/save_queue = list()

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
