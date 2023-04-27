PROCESSING_SUBSYSTEM_DEF(obj_tab_items)
	name = "Obj Tab Items"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	wait = 0.1 SECONDS

// I know this is mostly copypasta, but I want to change the processing logic
// Sorry bestie :(
/datum/controller/subsystem/processing/obj_tab_items/fire(resumed = FALSE)
	if (!resumed)
		current_run = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = current_run

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(QDELETED(thing) || (call(thing, process_proc)(wait, times_fired, src) == PROCESS_KILL))
			if(thing)
				thing.is_processing = null
			processing -= thing
		if(MC_TICK_CHECK)
			return
		currentrun.len--
