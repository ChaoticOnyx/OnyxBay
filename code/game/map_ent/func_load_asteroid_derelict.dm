/obj/map_ent/func_load_map/derelict

	name = "util_derelict"
	icon_state = "random_room"

	var/width				// Preferred width of the derelict to spawn
	var/height				// Preferred heigh of the derelict to spawn
	var/force_map			// Force spawn of a specific map template using full path, format example: "maps/frontier/asteroid/camp/camp.dmm
	var/id					//Need for identification many entity, and check this map path
	var/place_chance = 25	//This can be changed in the mapping

/obj/map_ent/func_load_map/derelict/Initialize(...)
	select_map()
	if(!ev_map_path)
		return INITIALIZE_HINT_QDEL
	. = ..()

/obj/map_ent/func_load_map/derelict/proc/select_map()
	if(force_map)
		var/datum/map_template/T = SSmapping.loadAsteroidDerelict(force_map)
		if(!T)
			CRASH("[name] placed with invalid force_map path")
		ev_map_path = force_map
		return

	if(prob(place_chance))
		return

	var/list/valid_map_templates = list()
	var/list/available_templates = SSmapping.asteroid_derelict_templates
	for(var/template_name in available_templates)
		var/datum/map_template/T = available_templates[template_name]
		if(T.width == width && T.height == height)
			valid_map_templates += T
	if(!length(valid_map_templates))
		return

	var/datum/map_template/picked_map_template = pick(valid_map_templates)
	var/derelict_name = picked_map_template.name
	ev_map_path = picked_map_template.mappaths[1]
	SSmapping.asteroid_derelict_templates -= derelict_name
	log_to_dd("New derelict is placed: [derelict_name]")
