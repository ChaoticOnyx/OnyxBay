/area/overmap_encounter/planetoid/jungle

/datum/map_generator/planet_generator/jungle
	perlin_zoom = 65
	mountain_height = 0.85

	primary_area_type = /area/overmap_encounter/planetoid/jungle

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle_wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle_wasteland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/mudlands
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle_wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/mudlands
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGH_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/mudlands,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/water,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/water,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/mudlands
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/dense
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/water,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/water
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle/dirt
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/lush,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/lush/bright,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/lush/bright
		)
	)

/datum/biome/jungle
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/jungleflora = 1,
		/obj/structure/flora/ausbushes/jungleflora/grassb = 1,
		/obj/structure/flora/tree/green/random = 3,
		/obj/structure/flora/jungleflora/rock = 1,
		/obj/structure/flora/ausbushes/jungleflora/busha = 1,
		/obj/structure/flora/ausbushes/jungleflora/bushb = 1,
		/obj/structure/flora/ausbushes/jungleflora/bushc = 1,
		/obj/structure/flora/ausbushes/jungleflora/large = 1,
		/obj/structure/flora/junglevines/heavy = 1,
		/obj/structure/flora/junglevines/medium = 4,
		/obj/structure/flora/junglevines/light = 3,
	)
	flora_spawn_chance = 90
	mob_spawn_chance = 0.3
	mob_spawn_list = list(
		/mob/living/carbon/human/monkey = 10,
		)

/datum/biome/jungle/dense
	flora_spawn_chance = 100
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle = 1, /turf/simulated/floor/asteroid/jungle/dirt = 9)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/jungleflora/grassa = 1,
		/obj/structure/flora/ausbushes/jungleflora/grassb = 1,
		/obj/structure/flora/tree/green/random = 5,
		/obj/structure/flora/jungleflora/rock = 1,
		/obj/structure/flora/ausbushes/jungleflora/busha = 1,
		/obj/structure/flora/ausbushes/jungleflora/bushb = 1,
		/obj/structure/flora/ausbushes/jungleflora/bushc = 1,
		/obj/structure/flora/ausbushes/jungleflora/large = 1,
		/obj/structure/flora/junglevines/heavy = 5,
		/obj/structure/flora/junglevines/medium = 8,
		/obj/structure/flora/junglevines/light = 7,
	)
	mob_spawn_chance = 0.6
	mob_spawn_list = list(
		/mob/living/carbon/human/monkey = 6,
		)

/datum/biome/jungle/plains
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle/ = 1)
	flora_spawn_chance = 50
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/carbon/human/monkey = 1,
	)

/datum/biome/mudlands
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle/dirt = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/jungleflora/grassa = 1,
		/obj/structure/flora/ausbushes/jungleflora/grassb = 1,
		/obj/structure/flora/jungleflora/rock = 1,
		/obj/structure/flora/junglevines/medium = 1,
		/obj/structure/flora/junglevines/light = 4,
	)
	flora_spawn_chance = 20
	mob_spawn_chance = 0.05
	//mob_spawn_list = list(/mob/living/simple_animal/hostile/poison/giant_spider/tarantula = 1)

/datum/biome/jungle_wasteland
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle/wasteland = 1)

/datum/biome/jungle/water
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle/water = 1)
	mob_spawn_chance = 1
	mob_spawn_list = list(/mob/living/simple_animal/hostile/carp = 1)
	flora_spawn_chance = 1
	flora_spawn_list = list(/obj/structure/rock/basalt = 1)

/datum/biome/cave/jungle
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle = 10, /turf/simulated/floor/asteroid/jungle/dirt = 10)
	closed_turf_types = list(/turf/unsimulated/mask = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/jungleflora/rock = 1,
		/obj/structure/rock/basalt/pile = 1,
		/obj/structure/rock/basalt = 1,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
	)
	feature_spawn_chance = 0.5
	feature_spawn_list = list(
		/obj/item/pickaxe/rusty = 1,
	)

/datum/biome/cave/jungle/dirt
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle/wasteland = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/jungleflora/busha = 1,
		/obj/structure/flora/ausbushes/jungleflora/bushb = 1,
		/obj/structure/flora/ausbushes/jungleflora/bushc = 1,
		//obj/structure/flora/ausbushes/jungleflora/bush/large = 1,
		/obj/structure/flora/jungleflora/rock/large = 1,
		/obj/structure/flora/ausbushes/jungleflora/grassa = 1,
		/obj/structure/flora/ausbushes/jungleflora/grassb = 1,
	)

/datum/biome/cave/lush
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle = 1)
	closed_turf_types = list(/turf/unsimulated/mask = 1)
	flora_spawn_chance = 50
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/glowshroom = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/palebush = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/sunnybush = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/pointybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
		/obj/structure/flora/ausbushes/ywflowers = 1,
		/obj/structure/flora/ausbushes/brflowers = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/jungleflora = 1,
		/obj/structure/flora/junglevines/heavy = 10,
		/obj/structure/flora/junglevines/medium = 20,
		/obj/structure/flora/junglevines/light = 10,
		/obj/structure/flora/jungleflora/rock = 1,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
	)

/datum/biome/cave/lush/bright
	open_turf_types = list(/turf/simulated/floor/asteroid/jungle = 12, /turf/simulated/floor/asteroid/jungle/water = 1)
	flora_spawn_chance = 40
	mob_spawn_chance = 1
	//mob_spawn_list = list(
	//	/mob/living/simple_animal/hostile/lightgeist = 1
	//)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(/obj/item/staff/plague_bell = 1)
