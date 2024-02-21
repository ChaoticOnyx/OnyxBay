SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = SS_INIT_MAPPING
	flags = SS_NO_FIRE

	var/list/map_templates = list()
	var/list/holodeck_templates = list()
	var/list/random_room_templates = list()

/datum/controller/subsystem/mapping/Initialize(timeofday)
	preloadTemplates()
	preloadHolodeckTemplates()
	preloadRandomRoomsTemplates()
	return ..()

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
	map_templates = SSmapping.map_templates
	random_room_templates = SSmapping.random_room_templates

/datum/controller/subsystem/mapping/proc/preloadTemplates(path = "maps/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(paths = list("[path][map]"), rename = "[map]")
		map_templates[T.name] = T

/datum/controller/subsystem/mapping/proc/preloadHolodeckTemplates(path = "maps/templates/")
	for(var/item in subtypesof(/datum/map_template/holodeck))
		var/datum/map_template/holodeck/holodeck_type = item
		if(!initial(holodeck_type.mappaths))
			continue

		var/datum/map_template/holodeck/holodeck_template = new holodeck_type()
		holodeck_templates[holodeck_template.template_id] = holodeck_template

/datum/controller/subsystem/mapping/proc/preloadRandomRoomsTemplates(path = "maps/random_rooms/")
	var/list/maplists = subtypesof(/datum/map_template/random_room)
	for(var/map in maplists)
		var/datum/map_template/random_room/T = new map
		random_room_templates[T.room_id] = T
