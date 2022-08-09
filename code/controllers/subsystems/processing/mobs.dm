PROCESSING_SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = SS_PRIORITY_MOB
	flags = SS_KEEP_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	// List of Z levels where player are
	var/static/list/player_levels = list()
	var/static/list/mob_list = list()

/datum/controller/subsystem/processing/mobs/PreInit()
	mob_list = processing // Simply setups a more recognizable var name than "processing"

/datum/controller/subsystem/processing/mobs/fire(resumed = 0)
	if(!resumed)
		current_run = processing.Copy()
		player_levels.Cut()
		for(var/P in GLOB.player_list)
			var/mob/living/player = P
			var/turf/T = get_turf(player)
			if(!istype(player) || !istype(T) || (T.z in player_levels))
				continue
			player_levels |= T.z

	var/mob/thing
	for(var/i = current_run.len to 1 step -1)
		thing = current_run[i]

		if(QDELETED(thing))
			processing -= thing
			continue

		var/turf/T = get_turf(thing)
		if(thing.client || (istype(T) && (T.z in player_levels)) || thing.teleop)
			thing.Life()

		if(MC_TICK_CHECK)
			current_run.Cut(i)
			return
