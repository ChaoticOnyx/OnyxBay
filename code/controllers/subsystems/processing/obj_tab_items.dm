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
	var/list/curr = current_run

	while(curr.len)
		var/datum/thing = curr[curr.len]
		if(QDELETED(thing))
			processing -= thing
		else if(thing.Process(wait * 0.1) == PROCESS_KILL)
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return
		curr.len--
