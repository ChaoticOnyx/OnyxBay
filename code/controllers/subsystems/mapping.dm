SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = SS_INIT_MAPPING
	flags = SS_NO_FIRE


	var/list/map_templates = list()
	var/list/random_room_templates = list()
	var/list/asteroid_derelict_templates = list()
	var/asteroid_folder_name = "asteroid"

/datum/controller/subsystem/mapping/Initialize(timeofday)
	preloadTemplates()
	preloadRandomRoomsTemplates()
	preloadAsteroidDerelicts()
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

/datum/controller/subsystem/mapping/proc/preloadAsteroidDerelicts(path = "maps/[GLOB.using_map.path]/[asteroid_folder_name]/")
	var/list/derelict_folder_list = flist(path)
	log_to_dd("Asteroid derelicts found: [derelict_folder_list.len]")
	for(var/derelict_folder in derelict_folder_list)
		if(copytext("[derelict_folder]", -1) != "/") // skip if not a folder
			continue
		var/list/map_variants = flist("[path][derelict_folder]")
		var/picked_map_variant = pick(map_variants)
		var/datum/map_template/T = new(paths = list("[path][derelict_folder][picked_map_variant]"), rename = "[picked_map_variant]")
		asteroid_derelict_templates[T.name] = T

/datum/controller/subsystem/mapping/proc/loadAsteroidDerelict(path)
	if(!fexists(path))
		return null
	var/datum/map_template/T = new(paths = list(path))
	return T
