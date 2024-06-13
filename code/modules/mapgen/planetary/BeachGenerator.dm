/datum/map_generator/planet_generator/beach
	mountain_height = 0.95
	perlin_zoom = 75

	primary_area_type = /area/overmap_encounter/planetoid/beachplanet

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/grass/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/dense
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/grass/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass,
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach/cove,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach/magical,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach/magical,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach/cove
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach/magical,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach/cove,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach
		)
	)

/datum/biome/grass
	open_turf_types = list(/turf/simulated/floor/asteroid/beach/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/green/random = 1,
		/obj/structure/flora/ausbushes/brflowers = 1,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/palebush = 1,
		/obj/structure/flora/ausbushes/pointybush = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/sunnybush = 1,
		/obj/structure/flora/ausbushes/ywflowers = 1,
		/obj/structure/flora/tree/palm = 1,
		//obj/structure/flora/ash/garden = 1,
	)
	flora_spawn_chance = 25
	mob_spawn_list = list(
		//mob/living/simple_animal/butterfly = 1,
		//mob/living/simple_animal/chicken/rabbit/normal = 1,
		/mob/living/simple_animal/mouse = 1,
		/mob/living/simple_animal/cow = 1,
		//mob/living/simple_animal/deer = 1
	)
	mob_spawn_chance = 1

/datum/biome/grass/dense
	flora_spawn_chance = 70
	mob_spawn_list = list(
		/mob/living/simple_animal/butterfly = 4,
		/mob/living/simple_animal/hostile/retaliate/poison/snake = 5,
		/mob/living/simple_animal/hostile/poison/bees = 3,
	)
	mob_spawn_chance = 2
	feature_spawn_chance = 0.1

/datum/biome/beach
	open_turf_types = list(/turf/simulated/floor/asteroid/beach = 1)
	mob_spawn_list = list(
		/mob/living/simple_animal/crab = 7,
		/mob/living/simple_animal/hostile/asteroid/lobstrosity/beach = 5
	)
	mob_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 1,
		/obj/structure/rock/basalt = 3,
		/obj/structure/flora/driftwood = 3,
		/obj/structure/flora/driftlog = 1,
		//obj/item/toy/seashell = 1,
	)
	flora_spawn_chance = 5

/datum/biome/beach/dense
	open_turf_types = list(/turf/simulated/floor/asteroid/beach = 1)
	flora_spawn_list = list(
		/obj/structure/rock/pile = 6,
		/obj/structure/rock/basalt = 2,
		/obj/structure/flora/driftwood = 6,
		//obj/item/toy/seashell = 1,
		/obj/structure/flora/driftlog = 2
	)
	flora_spawn_chance = 2

/datum/biome/ocean
	open_turf_types = list(/turf/simulated/floor/asteroid/beach/water = 1)
	flora_spawn_list = list(
		/obj/structure/rock/basalt = 1,
		/obj/structure/basalt/pile = 1,
		//obj/structure/flora/ash/garden/seaweed = 1
	)
	flora_spawn_chance = 1

/datum/biome/ocean/deep
	open_turf_types = list(/turf/simulated/floor/asteroid/beach/water = 1)

/datum/biome/cave/beach
	open_turf_types = list(/turf/simulated/floor/asteroid/beach = 1)
	closed_turf_types = list(/turf/unsimulated/mask = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 1,
		/obj/structure/flora/rock/basalt = 1,
		/obj/structure/rock/pile = 6
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/bear/cave = 5,
		/mob/living/simple_animal/hostile/asteroid/lobstrosity/beach = 1,
	)

/datum/biome/cave/beach/cove
	open_turf_types = list(/turf/simulated/floor/asteroid/beach = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine/dead = 1,
		/obj/structure/flora/rock/basalt = 1,
		/obj/structure/flora/driftwood = 3,
		/obj/structure/flora/driftlog = 2
	)
	flora_spawn_chance = 6

/datum/biome/cave/beach/magical
	open_turf_types = list(/turf/simulated/floor/asteroid/beach/grass/fairy = 1)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/palebush = 1,
		/obj/structure/flora/ausbushes/pointybush = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/sunnybush = 1,
	)
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/simple_animal/butterfly = 1,
		/mob/living/simple_animal/slime/pet = 1,
		/mob/living/simple_animal/hostile/lightgeist = 1
	)
