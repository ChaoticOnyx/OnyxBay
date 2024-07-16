SUBSYSTEM_DEF(watchdog)
	name = "Watchdog"
	wait = 1 SECOND
	priority = SS_PRIORITY_WATCHDOG
	init_order = SS_INIT_WATCHDOG
	runlevels = RUNLEVELS_ALL

/datum/controller/subsystem/watchdog/stat_entry(msg)
	msg += "E: [config.watchdog.enabled ? "1" : "0"]|"
	msg += "T: [config.watchdog.timeout || 0]"

	return ..()

/datum/controller/subsystem/watchdog/Initialize()
	. = ..()

	if(!config.watchdog.enabled)
		log_debug("Watchdog is disabled")
		return

	log_debug("Watchdog is enabled, timeout: [config.watchdog.timeout] seconds")
	rustg_wd_start(config.watchdog.timeout, config.watchdog.webhook_url, config.watchdog.message)

	return

/datum/controller/subsystem/watchdog/fire(resumed = 0)
	if(!config.watchdog.enabled)
		return

	rustg_wd_update(config.watchdog.timeout)

/datum/controller/subsystem/watchdog/Destroy()
	rustg_wd_stop()

	return ..()
