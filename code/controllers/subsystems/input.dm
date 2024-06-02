SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1
	init_order = SS_INIT_INPUT
	flags = SS_TICKER
	priority = SS_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/macro_set

/datum/controller/subsystem/input/Initialize()
	. = ..()
	setup_default_macro_sets()
	refresh_client_macro_sets()

/datum/controller/subsystem/input/proc/setup_default_macro_sets()
	macro_set = list(
		"Any" = "\"KeyDown \[\[*\]\]\"",
		"Any+UP" = "\"KeyUp \[\[*\]\]\"",
		"Back" = "\".winset \\\"outputwindow.input.text=\\\"\\\"\\\"\"",
		"Escape" = "Reset-Held-Keys",
	)

/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	for(var/client/C in GLOB.clients)
		C.set_macros()

/**
 * It feels input's fire should have CHECK_TICK
 * However, stoplag() will probably fuck up all clients' input.
 */

/datum/controller/subsystem/input/fire()
	for(var/client/C in GLOB.clients)
		C.keyLoop()
