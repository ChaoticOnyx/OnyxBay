/obj/map_ent/func_load_map/derelict

	name = "util_derelict"
	icon_state = "random_room"

	var/width		// Preferred width of the derelict to spawn
	var/height		// Preferred heigh of the derelict to spawn
	var/force_map	// Force spawn of a specific map template using full path, format example: "maps/frontier/asteroid/camp/camp.dmm

/obj/map_ent/func_load_map/derelict/Initialize(...)
	select_map()
	. = ..()

/obj/map_ent/func_load_map/derelict/proc/select_map()
	if(force_map)
		log_to_dd("trying to load forced map template")
		var/datum/map_template/T = SSmapping.loadAsteroidDerelict(force_map)
		if(!T)
			util_crash_with("[name] placed with invalid force_map path")
			return
		log_to_dd("forced derelict template loaded with path: [force_map]")
		ev_map_path = force_map
		log_to_dd("Check you ev_map_path: [ev_map_path]") // OK, finnaly OK
	else
		var/list/valid_map_paths = list()
		log_to_dd("selecting map started, iterating over available templates") // x2
		log_to_dd("Begun cycle for with next variables: [SSmapping.asteroid_derelict_templates.len]")
		var/list/available_templates = SSmapping.asteroid_derelict_templates
		for(var/template_name in available_templates)
			var/datum/map_template/T = available_templates[template_name]
			log_to_dd("iterating over derelict templates: [T.name], want: [width]x[height], template has: [T.width]x[T.height]")
			if(T.width == width && T.height == height)
				log_to_dd("derelict template matched dimensions")
				if(T.mappaths.len)
					log_to_dd("adding map template to valid list")
					valid_map_paths += T.mappaths[1]
					log_to_dd("valid_map_paths len: [valid_map_paths.len]")
		ev_map_path = pick(valid_map_paths)

//MULTI_Z
//OH, FUCK, THIS SO HARD.
