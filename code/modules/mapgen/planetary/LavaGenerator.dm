/datum/map_generator/planet_generator/lava
	// values near 0.5 look bad due to the behavior of naive perlin noise
	// so this was bumped down a little below 0.5
	mountain_height = 0.45
	perlin_zoom = 65

	primary_area_type = /area/overmap_encounter/planetoid/lava

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/lavaland/forest,
			BIOME_LOW_HUMIDITY = /datum/biome/lavaland/plains/dense/mixed,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/lavaland/forest/rocky,
			BIOME_HIGH_HUMIDITY = /datum/biome/lavaland/outback,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/lavaland/plains/dense
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/lavaland/plains,
			BIOME_LOW_HUMIDITY = /datum/biome/lavaland/outback,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/lavaland/plains/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/lavaland/plains/dense/mixed,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/lavaland/outback
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/lavaland,
			BIOME_LOW_HUMIDITY = /datum/biome/lavaland/plains,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/lavaland/forest,
			BIOME_HIGH_HUMIDITY = /datum/biome/lavaland/lush,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/lavaland/lava
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/lavaland/plains/dense/mixed,
			BIOME_LOW_HUMIDITY = /datum/biome/lavaland/forest,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/lavaland/plains/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/lavaland,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/lavaland/lava
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/lavaland/outback,
			BIOME_LOW_HUMIDITY = /datum/biome/lavaland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/lavaland/plains/dense/mixed,
			BIOME_HIGH_HUMIDITY = /datum/biome/lavaland,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/lavaland/lava
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/lavaland/forest/rocky,
			BIOME_LOW_HUMIDITY = /datum/biome/lavaland/outback,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/lavaland/plains,
			BIOME_HIGH_HUMIDITY = /datum/biome/lavaland,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/lavaland/lava
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/lavaland/rocky,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/lavaland/rocky,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/lavaland,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/lavaland,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/lavaland/mossy
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/lavaland/rocky,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/lavaland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/lavaland/lava,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/lavaland/mossy,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/lavaland/lava
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/lavaland/rocky,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/lavaland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/lavaland/mossy,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/lavaland/rocky,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/lavaland/lava
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/lavaland/rocky,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/lavaland/mossy,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/lavaland/mossy,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/lavaland/lava,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/lavaland/lava
		)
	)

/datum/biome/lavaland
	open_turf_types = list(
		/turf/simulated/floor/asteroid/basalt/lavaplanet = 1,
	)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/hell/ywflowers = 10,
		/obj/structure/flora/ausbushes/hell/sparsegrass = 40,
		/obj/structure/landmine = 1,
	)
	feature_spawn_chance = 0.3
	feature_spawn_list = list(
		/obj/structure/rock/basalt = 20,
		/obj/structure/geyser/random = 6,
		/obj/structure/rock/basalt = 14,
		/obj/effect/minefield = 1,
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 50,
	)

/datum/biome/lavaland/forest
	open_turf_types = list(/turf/simulated/floor/asteroid/basalt/purple/sand = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead/tall/grey = 1,
		/obj/structure/flora/tree/dead/barren = 1,
		/obj/structure/flora/ausbushes/hell/fullgrass = 10,
		/obj/structure/flora/ausbushes/hell/sparsegrass = 5
	)
	flora_spawn_chance = 85

/datum/biome/lavaland/forest/rocky
	flora_spawn_list = list(
		/obj/structure/rock/lava/pile = 3,
		/obj/structure/rock/lava = 2,
		/obj/structure/flora/tree/dead/tall/grey = 10,
		/obj/structure/flora/ausbushes/hell/fullgrass = 40,
		/obj/structure/flora/ausbushes/hell/sparsegrass = 20,
		/obj/structure/flora/ausbushes/hell = 2
	)
	flora_spawn_chance = 65

/datum/biome/lavaland/plains
	open_turf_types = list(
		/turf/simulated/floor/asteroid/lavaplanet/grass/purple = 30
	)

	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/hell/fullgrass = 50,
		/obj/structure/flora/ausbushes/hell/sparsegrass = 35,
		/obj/structure/flora/ausbushes/hell/ywflowers = 1,
		/obj/structure/flora/ausbushes/hell/grassybush = 4,
		/obj/structure/flora/ausbushes/hell/firebush = 1
	)
	flora_spawn_chance = 15

/datum/biome/lavaland/plains/dense
	flora_spawn_chance = 85
	open_turf_types = list(
		/turf/simulated/floor/asteroid/lavaplanet/grass = 50
	)
	feature_spawn_chance = 5
	feature_spawn_list = list(
		/obj/structure/flora/tree/dead/barren = 50,
		/obj/structure/flora/tree/dead/tall/grey = 45,
	)

/datum/biome/lavaland/plains/dense/mixed
	flora_spawn_chance = 50
	open_turf_types = list(
		/turf/simulated/floor/asteroid/lavaplanet/grass = 50,
		/turf/simulated/floor/asteroid/lavaplanet/grass/purple = 45,
	)

/datum/biome/lavaland/outback
	open_turf_types = list(
		/turf/simulated/floor/asteroid/lavaplanet/grass/orange = 20
	)

	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/hell/grassybush = 10,
		/obj/structure/flora/ausbushes/hell/genericbush = 10,
		/obj/structure/flora/ausbushes/hell/sparsegrass = 3,
		/obj/structure/flora/ausbushes/hell = 3,
		/obj/structure/flora/tree/dead/hell = 3,
		/obj/structure/flora/rock/lava = 2
	)
	flora_spawn_chance = 30

/datum/biome/lavaland/lush
	open_turf_types = list(
		/turf/simulated/floor/asteroid/lavaplanet/grass/purple = 20,
		/turf/simulated/floor/asteroid/basalt/purple = 1
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead/hell = 1,
		/obj/structure/flora/ausbushes/hell/grassybush = 5,
		/obj/structure/flora/ausbushes/hell/fullgrass = 10,
		/obj/structure/flora/ausbushes/hell/sparsegrass = 8,
		/obj/structure/flora/ausbushes/hell = 5,
		/obj/structure/flora/ausbushes/hell/fernybus= 5,
		/obj/structure/flora/ausbushes/hell/genericbush = 5,
		/obj/structure/flora/ausbushes/hell/ywflowers = 7,
		/obj/structure/flora/ausbushes/hell/firebush = 3
	)
	flora_spawn_chance = 30

/datum/biome/lavaland/lava
	open_turf_types = list(/turf/simulated/floor/natural/lava = 1)
	flora_spawn_list = list(
		/obj/structure/rock/lava = 1,
		/obj/structure/rock/lava/pile = 1
	)
	flora_spawn_chance = 2
	feature_spawn_chance = 0

/datum/biome/lavaland/lava/rocky
	flora_spawn_chance = 4

/datum/biome/cave/lavaland
	open_turf_types = list(
		/turf/simulated/floor/asteroid/basalt/lavaplanet = 1
	)
	closed_turf_types = list(
		/turf/unsimulated/mask = 1
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 50,
	)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/landmine = 1,
		/obj/structure/landmine = 1
	)

/datum/biome/cave/lavaland/rocky
	open_turf_types = list(/turf/simulated/floor/asteroid/basalt/purple/sand = 1)
	flora_spawn_list = list(
		/obj/structure/rock/lava/pile = 3,
		/obj/structure/rock/lava = 3,
		/obj/structure/landmine  = 1
	)
	flora_spawn_chance = 5

/datum/biome/cave/lavaland/lava
	open_turf_types = list(/turf/simulated/floor/natural/lava = 1)
	feature_spawn_chance = 1
	feature_spawn_list = list(/obj/structure/rock/lava/pile = 1)
