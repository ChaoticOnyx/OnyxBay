PROCESSING_SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = SS_PRIORITY_MOB
	flags = SS_KEEP_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	process_proc = /mob/proc/Life

	// List of Z levels where player are
	var/list/player_levels = list()
	var/list/mob_list

/datum/controller/subsystem/processing/mobs/PreInit()
	mob_list = processing // Simply setups a more recognizable var name than "processing"

/datum/controller/subsystem/processing/mobs/fire(resumed = 0)
	if (!resumed)
		src.current_run = processing.Copy()
		player_levels.Cut()

		for(var/mob/living/player in GLOB.player_list)
			if (!(player.z in player_levels))
				player_levels += player.z

	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run
	var/wait = src.wait
	var/times_fired = src.times_fired

	while(current_run.len)
		var/mob/thing = current_run[current_run.len]
		current_run.len--

		if(QDELETED(thing))
			processing -= thing
			continue

		if (thing.client || (thing.z in player_levels))
			if (call(thing, process_proc)(wait, times_fired, src) == PROCESS_KILL)
				thing?.is_processing = null
				processing -= thing

		if (MC_TICK_CHECK)
			return
