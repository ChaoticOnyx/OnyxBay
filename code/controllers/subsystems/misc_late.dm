//Initializes relatively late in subsystem init order.

SUBSYSTEM_DEF(misc_late)
	name = "Late Initialization"
	init_order = SS_INIT_MISC_LATE
	flags = SS_NO_FIRE

/datum/controller/subsystem/misc_late/Initialize()
	populate_lathe_recipes() // This creates and deletes objects; could use improvement.
	. = ..()
