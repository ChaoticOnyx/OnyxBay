SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = SS_INIT_MAPPING
	flags = SS_NO_FIRE

	var/list/map_templates = list()
	var/list/holodeck_templates = list()
	///All possible biomes in assoc list as type || instance
	var/list/biomes = list()
	var/list/ghost_arena_templates = list()

/datum/controller/subsystem/mapping/Initialize(timeofday)
	initialize_biomes()
	preloadTemplates()
	preloadHolodeckTemplates()
	preloadGhostArenaTemplates()
	lateload_map_zlevels()
	return ..()

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
	map_templates = SSmapping.map_templates
	holodeck_templates = SSmapping.holodeck_templates

/datum/controller/subsystem/mapping/proc/preloadTemplates(path = "maps/templates") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(paths = list("[path][map]"), rename = "[map]")
		map_templates[T.name] = T

/datum/controller/subsystem/mapping/proc/preloadHolodeckTemplates(path = "maps/templates/holodeck")
	for(var/item in subtypesof(/datum/map_template/holodeck))
		var/datum/map_template/holodeck/holodeck_type = item
		if(!initial(holodeck_type.mappaths))
			continue

		var/datum/map_template/holodeck/holodeck_template = new holodeck_type()
		holodeck_templates[holodeck_template.template_id] = holodeck_template

/datum/controller/subsystem/mapping/proc/preloadGhostArenaTemplates(path = "maps/ghost_arena/")
	var/list/maplists = subtypesof(/datum/map_template/arena_map)
	for(var/map in maplists)
		var/datum/map_template/arena_map/T = new map
		ghost_arena_templates[T.name] = T

/// Initialize all biomes, assoc as type || instance
/datum/controller/subsystem/mapping/proc/initialize_biomes()
	for(var/biome_path in subtypesof(/datum/biome))
		var/datum/biome/biome_instance = new biome_path()
		biomes[biome_path] += biome_instance

/datum/controller/subsystem/mapping/proc/lateload_map_zlevels()
	GLOB.using_map.perform_map_generation(TRUE)
