/client/proc/test_mapgen()
	set category = "Debug"
	set name = "Test Mapgenerator"

	if(!check_rights(R_DEBUG))
		return

	var/datum/map_template/empty127/empty = new /datum/map_template/empty127()
	var/turf/center = empty.load_new_z()
	// We can not directly get spawned atoms from load_new_z() as there we must account for bounds.
	var/list/spawned = block(
		locate(0 + world.view, 0 + world.view, center.z),
		locate(127 - world.view, 127 - world.view, center.z)
	)

	var/datum/map_template/mining_outpost/outpost = new /datum/map_template/mining_outpost()
	var/turf/ruin_turf = locate(
		rand(0 + world.view, 127 - outpost.height - world.view),
		rand(0 + world.view, 127 - outpost.width -  world.view),
		center.z
	)
	outpost.load(ruin_turf)

	var/datum/map_generator/mapgen = new /datum/map_generator/planet_generator/swamp()
	mapgen.generate_turfs(spawned)
	mapgen.populate_turfs(spawned)

	//new /datum/random_map/automata/cave_system(null, 1, 1, center.z, 127, 127)

/datum/map_template/empty127
	mappaths = list('maps/templates/empty_127.dmm')
	returns_created_atoms = TRUE



/area/testoutpost
	area_flags = AREA_FLAG_UNIQUE_AREA
