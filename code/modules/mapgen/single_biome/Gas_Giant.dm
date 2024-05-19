/datum/map_generator/single_biome/gas_giant
	use_cellautomata = FALSE

	biome_type = /datum/biome/gas_giant
	area_type = /area/overmap_encounter/planetoid/gas_giant

/datum/biome/gas_giant
	open_turf_types = list(/turf/open/chasm/gas_giant = 1)

	flora_spawn_list = null
	feature_spawn_list = null
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 1
		//in the future, I'd like to add something like.
		//The slylandro, or really any floating gas bag species, it'd be cool
	)

/datum/map_generator/single_biome/plasma_giant
	use_cellautomata = FALSE

	biome_type = /datum/biome/plasma_giant
	area_type = /area/overmap_encounter/planetoid/gas_giant

/datum/biome/plasma_giant
	open_turf_types = list(/turf/open/chasm/gas_giant/plasma = 1)

	flora_spawn_list = null
	feature_spawn_list = null
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/goliath = 1
	)
