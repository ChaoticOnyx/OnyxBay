/datum/visualnet/cultnet
	valid_source_types = list(/mob/living/)
	chunk_type = /datum/chunk/cultnet

/datum/chunk/cultnet/acquire_visible_turfs(list/visible)
	for(var/source in sources)
		if(istype(source, /mob/living))
			var/mob/living/L = source
			if(L.is_ic_dead())
				continue

		for(var/turf/t in seen_turfs_in_range(source, world.view))
			visible[t] = t
