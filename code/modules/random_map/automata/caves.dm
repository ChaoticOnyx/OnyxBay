/datum/random_map/automata/cave_system
	iterations = 5
	descriptor = "moon caves"
	wall_type =  /turf/simulated/mineral
	floor_type = /turf/simulated/floor/asteroid
	target_turf_type = /turf/unsimulated/mask
	var/mineral_sparse =  /turf/simulated/mineral/random
	var/mineral_rich = /turf/simulated/mineral/random/high_chance
	var/list/ore_turfs = list()
	var/max_mobs_count = 250 //maximum amount of mobs on the map. Some of the numbers lost in "frame" of the map
/datum/random_map/automata/cave_system/get_appropriate_path(var/value)
	switch(value)
		if(DOOR_CHAR)
			return mineral_sparse
		if(EMPTY_CHAR)
			return mineral_rich
		if(FLOOR_CHAR)
			return floor_type
		if(WALL_CHAR)
			return wall_type

/datum/random_map/automata/cave_system/get_map_char(var/value)
	switch(value)
		if(DOOR_CHAR)
			return "x"
		if(EMPTY_CHAR)
			return "X"
	return ..(value)

// Create ore turfs.
/datum/random_map/automata/cave_system/cleanup()
	var/tmp_cell
	for (var/x = 1 to limit_x)
		for (var/y = 1 to limit_y)
			tmp_cell = TRANSLATE_COORD(x, y)
			if (CELL_ALIVE(map[tmp_cell]))
				ore_turfs += tmp_cell

	game_log("ASGEN", "Found [ore_turfs.len] ore turfs.")
	var/ore_count = round(map.len/20)
	var/door_count = 0
	var/empty_count = 0
	while((ore_count>0) && (ore_turfs.len>0))

		if(!priority_process)
			CHECK_TICK

		var/check_cell = pick(ore_turfs)
		ore_turfs -= check_cell
		if(prob(75))
			map[check_cell] = DOOR_CHAR  // Mineral block
			door_count += 1
		else
			map[check_cell] = EMPTY_CHAR // Rare mineral block.
			empty_count += 1
		ore_count--

	game_log("ASGEN", "Set [door_count] turfs to random minerals.")
	game_log("ASGEN", "Set [empty_count] turfs to high-chance random minerals.")
	var/list/mob_spawnable_turf = list()
	for (var/x = 1 to limit_x)
		for (var/y = 1 to limit_y)
			tmp_cell = TRANSLATE_COORD(x, y)
			if (map[tmp_cell] == FLOOR_CHAR)
				mob_spawnable_turf += tmp_cell

	for (var/i = 0, i<max_mobs_count, i++)
		var/check_cell = pick(mob_spawnable_turf)
		mob_spawnable_turf -= check_cell
		map[check_cell] = MONSTER_CHAR
	while(mob_spawnable_turf.len>0)
		if(!priority_process)
			CHECK_TICK
		var/check_cell = pick(mob_spawnable_turf)
		mob_spawnable_turf -= check_cell
		if(prob(5))
			map[check_cell] = CAVE_BIG_ROCK_CHAR

	return 1

/datum/random_map/automata/cave_system/apply_to_map()
	if(!origin_x) origin_x = 1
	if(!origin_y) origin_y = 1
	if(!origin_z) origin_z = 1

	var/tmp_cell
	var/new_path
	var/num_applied = 0

	var/count_goliath = 0
	var/count_hoverhead = 0
	var/count_sand_lurker = 0
	var/count_basilisk = 0
	var/count_basilisk_spectator = 0
	var/mobs_count = 0
	for (var/thing in block(locate(origin_x, origin_y, origin_z), locate(limit_x, limit_y, origin_z)))
		var/turf/T = thing
		new_path = null
		if (!T || (target_turf_type && !istype(T, target_turf_type)))
			continue

		tmp_cell = TRANSLATE_COORD(T.x, T.y)

		switch (map[tmp_cell])
			if(DOOR_CHAR)
				new_path = mineral_sparse
			if(EMPTY_CHAR)
				new_path = mineral_rich
			if(FLOOR_CHAR)
				new_path = floor_type
			if(WALL_CHAR)
				new_path = wall_type
			if(MONSTER_CHAR)
				new_path = floor_type
				var/chance = rand(100)
				if(chance <= 40)
					new /mob/living/simple_animal/hostile/asteroid/sand_lurker(T)
					count_sand_lurker++
				else if(chance <= 70 && chance > 40)
					new /mob/living/simple_animal/hostile/asteroid/goliath(T)
					count_goliath++
				else if(chance <= 85 && chance > 70)
					new /mob/living/simple_animal/hostile/asteroid/hoverhead(T)
					count_hoverhead++
				else if(chance <= 95 && chance > 85)
					new /mob/living/simple_animal/hostile/asteroid/basilisk(T)
					count_basilisk++
				else if (chance > 95)
					new /mob/living/simple_animal/hostile/asteroid/basilisk/spectator(T)
					count_basilisk_spectator++
				mobs_count++
			if(CAVE_BIG_ROCK_CHAR)
				new_path = floor_type
				new /obj/structure/rock(T)
		if (!new_path)
			continue

		num_applied += 1
		T.ChangeTurf(new_path)

		CHECK_TICK
	game_log("ASGEN", "Applied [num_applied] turfs.")
	game_log("ASGEN", "Spawned [mobs_count] monsters (asteroid).")
	game_log("ASGEN", "Spawned [count_goliath] goliaths (asteroid).")
	game_log("ASGEN", "Spawned [count_hoverhead] hoverheads (asteroid).")
	game_log("ASGEN", "Spawned [count_sand_lurker] sand lurkers (asteroid).")
	game_log("ASGEN", "Spawned [count_basilisk] basilisk (asteroid).")
	game_log("ASGEN", "Spawned [count_basilisk_spectator] basilisk spectators (asteroid).")
	log_world("Spawned [mobs_count] monsters (asteroid).")
