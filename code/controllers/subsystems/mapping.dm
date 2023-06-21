SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = SS_INIT_MAPPING
	flags = SS_NO_FIRE

	var/list/map_templates = list()
	var/list/random_room_templates = list()

	///All possible biomes in assoc list as type || instance
	var/list/biomes = list()

/datum/controller/subsystem/mapping/Initialize(timeofday)
	initialize_biomes()
	preloadTemplates()
	preloadRandomRoomsTemplates()
	run_map_generation()
	..()

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
	map_templates = SSmapping.map_templates
	random_room_templates = SSmapping.random_room_templates

/datum/controller/subsystem/mapping/proc/preloadTemplates(path = "maps/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(paths = list("[path][map]"), rename = "[map]")
		map_templates[T.name] = T

/datum/controller/subsystem/mapping/proc/preloadRandomRoomsTemplates(path = "maps/random_rooms/")
	var/list/maplists = subtypesof(/datum/map_template/random_room)
	for(var/map in maplists)
		var/datum/map_template/random_room/T = new map
		random_room_templates[T.room_id] = T

///Initialize all biomes, assoc as type || instance
/datum/controller/subsystem/mapping/proc/initialize_biomes()
	for(var/biome_path in subtypesof(/datum/biome))
		var/datum/biome/biome_instance = new biome_path()
		biomes[biome_path] += biome_instance

/datum/controller/subsystem/mapping/proc/run_map_generation()
	for(var/area/A in GLOB.areas)
		A.RunGeneration()
