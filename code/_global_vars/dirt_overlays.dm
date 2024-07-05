GLOBAL_LIST_INIT(dirt_overlays, init_dirt_covers())

/proc/init_dirt_covers()
	var/list/covers = list()
	for(var/path in subtypesof(/datum/dirt_cover))
		covers += new path()

	return covers
