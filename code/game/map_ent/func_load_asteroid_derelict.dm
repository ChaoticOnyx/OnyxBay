/obj/map_ent/func_load_map/derelict

	name = "util_derelict"
	icon_state = "random_room"

	var/width		// Preferred width of the derelict to spawn
	var/height		// Preferred heigh of the derelict to spawn
	var/force_map	// Force spawn of a specific map template using full path, format example: "maps/frontier/asteroid/camp/camp.dmm
	var/id			//Need for identification many entity, and check this map path
	var/place_chance = 50

/obj/map_ent/func_load_map/derelict/Initialize(...)
	select_map()
	. = ..()

/obj/map_ent/func_load_map/derelict/proc/select_map()
	if(force_map)
		var/datum/map_template/T = SSmapping.loadAsteroidDerelict(force_map)
		if(!T)
			log_to_dd("[name] placed with invalid force_map path")
			return
		ev_map_path = force_map
	else
		if(prob(place_chance))
			log_to_dd("[name] not working, its sleep")
			return
		else
			var/list/valid_map_templates = list()
			var/list/available_templates = SSmapping.asteroid_derelict_templates
			for(var/template_name in available_templates)
				var/datum/map_template/T = available_templates[template_name]
				if(T.width == width && T.height == height)
					valid_map_templates += T
			if(!valid_map_templates.len)
				log_to_dd("Out of maps to place")
				return
			var/picked_map_template = pick(valid_map_templates)
			ev_map_path = pick(picked_map_template.mappaths[1])
			SSmapping.asteroid_derelict_templates -= picked_map_template.name
			log_to_dd("Try to remove [picked_map_template.name]]")
