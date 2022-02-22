PROCESSING_SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = SS_PRIORITY_MOB
	flags = SS_KEEP_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	// List of Z levels where player are
	var/static/tmp/list/player_levels = list()
	var/static/tmp/list/mob_list = list()

/datum/controller/subsystem/processing/mobs/PreInit()
	mob_list = processing // Simply setups a more recognizable var name than "processing"

/datum/controller/subsystem/processing/mobs/fire(resumed = 0)
	if(!resumed)
		current_run = processing.Copy()
		player_levels.Cut()
		for(var/P in GLOB.player_list)
			var/mob/living/player = P
			if(!istype(player) || (player.z in player_levels))
				continue
			player_levels += player.z

	var/mob/thing
	for(var/i = current_run.len to 1 step -1)
		thing = current_run[i]

		if(QDELETED(thing))
			processing -= thing
			continue

		if(thing.client || (thing.z in player_levels))
			thing.Life()

		if(MC_TICK_CHECK)
			current_run.Cut(i)
			return
