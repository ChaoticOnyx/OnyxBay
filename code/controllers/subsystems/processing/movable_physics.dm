///Real fast ticking subsystem for moving movables via modifying pixel_x/y/z
PROCESSING_SUBSYSTEM_DEF(movablephysics)
	name = "Movable Physics"
	wait = 0.5
	priority = SS_PRIORITY_PHYSICS

/datum/controller/subsystem/processing/movablephysics/fire(resumed = FALSE)
	if (!resumed)
		current_run = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = current_run

	while(currentrun.len)
		var/datum/component/thing = currentrun[currentrun.len]
		currentrun.len--
		if(QDELETED(thing))
			processing -= thing
		else
			if(thing.Process(wait * 0.1) == PROCESS_KILL) // INVOKE_ASYNC(thing, /datum/proc/Process) ???
				STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return
