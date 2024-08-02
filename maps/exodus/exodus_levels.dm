/datum/space_level/exodus_1
	path = 'exodus-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 5

/datum/space_level/exodus_2
	path = 'exodus-2.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 5

/datum/space_level/exodus_3
	path = 'maps/templates/empty_255.dmm'
	travel_chance = 10
	traits = list(
		ZTRAIT_CONTACT
	)
	lateloading_level = TRUE
	var/list/possible_planet_types = list(
		/datum/map_generator/planet_generator/asteroid = 1,
	)

/datum/space_level/exodus_3/generate(z)
	var/planet_type = util_pick_weight(possible_planet_types)
	var/datum/map_generator/planet_generator/mapgen = new planet_type()

	mapgen.load_necessary_ruins(z)
	mapgen.load_random_ruins(z)

	var/list/spawned = block(
		locate(0 + TRANSITION_EDGE, 0 + TRANSITION_EDGE, z),
		locate(255 - TRANSITION_EDGE, 255 - TRANSITION_EDGE, z)
	)

	mapgen.generate_edge_turf(z)
	mapgen.generate_turfs(spawned)
	mapgen.populate_turfs(spawned)
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 255, 255)
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)
	if(ispath(mapgen.weather_controller_type))
		mapgen.weather_controller_type = new mapgen.weather_controller_type(z)

/datum/space_level/exodus_4
	path = 'exodus-4.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)
