/area/generated/planetoid/swamp
	area_flags = AREA_FLAG_CAVES_ALLOWED

/datum/map_generator/planet_generator/swamp
	perlin_zoom = 65
	mountain_height = 0.85

	primary_area_type = /area/generated/planetoid/swamp

	baseturf = /turf/simulated/floor/asteroid/swamp_dirt

	necessary_ruins = list(
		/datum/map_template/mining_outpost_swamp
	)

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
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 5,
		/turf/simulated/floor/asteroid/swamp = 1,
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/swamp = 5,
		/obj/structure/flora/swampgrass = 25,
		/obj/structure/flora/swampgrass/bush = 2,
		/obj/structure/flora/thorn_bush = 2
	)
	flora_spawn_chance = 20
	mob_spawn_chance = 0.3
	mob_spawn_list = list(
		///ADD BOGLNS
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/item/beartrap/deployed = 1,
	)

/datum/biome/jungle/dense
	flora_spawn_chance = 20
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 5,
		/turf/simulated/floor/asteroid/swamp = 1,
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/swamp = 5,
		/obj/structure/flora/swampgrass = 5,
		/obj/structure/flora/swampgrass/bush = 1,
		/obj/structure/flora/thorn_bush = 1
	)
	mob_spawn_chance = 0.6
	mob_spawn_list = list(
		///ADD BOGLNS
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/item/beartrap/deployed = 1,
	)

/datum/biome/jungle/plains
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 5,
		/turf/simulated/floor/asteroid/swamp = 1,
	)
	flora_spawn_chance = 20
	mob_spawn_chance = 1
	mob_spawn_list = list(
		///ADD BOGLNS
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/item/beartrap/deployed = 1,
	)

/datum/biome/mudlands
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 5,
		/turf/simulated/floor/asteroid/swamp = 1,
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/swamp = 2,
		/obj/structure/flora/swampgrass = 5,
		/obj/structure/flora/swampgrass/bush = 1,
		/obj/structure/flora/thorn_bush = 1
	)
	flora_spawn_chance = 20
	mob_spawn_chance = 0.05
	mob_spawn_list = list(
		///ADD BOGLNS
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/item/beartrap/deployed = 1,
	)

/datum/biome/jungle_wasteland
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 5,
		/turf/simulated/floor/asteroid/swamp = 1,
	)

/datum/biome/jungle/water
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 1,
		/turf/simulated/floor/asteroid/swamp = 5,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(/mob/living/simple_animal/hostile/carp = 1)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/swampgrass = 1
	)

/datum/biome/cave/jungle
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 5,
		/turf/simulated/floor/asteroid/swamp = 1,
	)
	closed_turf_types = list(/turf/simulated/mineral/swamp = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/tree/swamp = 1,
		/obj/structure/flora/swampgrass = 5,
		/obj/structure/flora/swampgrass/bush = 1,
		/obj/structure/flora/thorn_bush = 1
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		///ADD BOGLINS
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/item/beartrap/deployed = 1,
	)

/datum/biome/cave/jungle/dirt
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 5,
		/turf/simulated/floor/asteroid/swamp = 1,
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/swamp = 1,
		/obj/structure/flora/swampgrass = 5,
		/obj/structure/flora/swampgrass/bush = 1,
		/obj/structure/flora/thorn_bush = 1
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/item/beartrap/deployed = 1,
	)

/datum/biome/cave/lush
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 5,
		/turf/simulated/floor/asteroid/swamp = 1,
	)
	closed_turf_types = list(/turf/simulated/mineral/swamp = 1)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/tree/swamp = 1,
		/obj/structure/flora/ausbushes/brflowers = 1,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
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
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		///ADD BOGLINS
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/item/beartrap/deployed = 1,
	)

/datum/biome/cave/lush/bright
	open_turf_types = list(
		/turf/simulated/floor/asteroid/swamp_dirt = 5,
		/turf/simulated/floor/asteroid/swamp = 1,
	)
	flora_spawn_chance = 40
	mob_spawn_chance = 1
	mob_spawn_list = list(
		///ADD BOGLINS
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/item/beartrap/deployed = 1,
	)
