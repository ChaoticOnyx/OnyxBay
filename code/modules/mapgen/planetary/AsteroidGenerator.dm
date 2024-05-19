/area/generated/planetoid/asteroid

/datum/map_generator/planet_generator/asteroid
	mountain_height = 0.65
	perlin_zoom = 20

	initial_closed_chance = 45
	smoothing_iterations = 20
	birth_limit = 4
	death_limit = 3

	primary_area_type = /area/generated/planetoid/asteroid

	baseturf = /turf/space

	necessary_ruins = list(
		/datum/map_template/mining_outpost,
		/datum/map_template/research_outpost,
		/datum/map_template/prydwen_asteroid,
	)

	random_ruins = list(
		/datum/map_template/scorpion_lair = 1,
		/datum/map_template/goliath_lair = 1,
		/datum/map_template/evil_lair = 1,
		/datum/map_template/lizard_lair = 1,
	)

	edgeturf = /turf/space

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/asteroid,
			BIOME_LOW_HUMIDITY = /datum/biome/asteroid,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/asteroid,
			BIOME_HIGH_HUMIDITY = /datum/biome/asteroid,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/asteroid
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/asteroid,
			BIOME_LOW_HUMIDITY = /datum/biome/asteroid,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/asteroid,
			BIOME_HIGH_HUMIDITY = /datum/biome/asteroid,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/asteroid
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/asteroid,
			BIOME_LOW_HUMIDITY = /datum/biome/asteroid,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_HIGH_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/asteroid
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/asteroid,
			BIOME_LOW_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_HIGH_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/asteroid/carp
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/asteroid,
			BIOME_LOW_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_HIGH_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/asteroid/carp
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_LOW_HUMIDITY = /datum/biome/asteroid,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/asteroid,
			BIOME_HIGH_HUMIDITY = /datum/biome/asteroid/carp,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/asteroid/carp //gee what a diverse place
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/asteroid/ice,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/asteroid/ice,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/asteroid/ice,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/asteroid/ice
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/asteroid/ice
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/asteroid/carp_den,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/asteroid/carp_den
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/asteroid/vanilla,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/asteroid/carp_den,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/asteroid/carp_den,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/asteroid/carp_den
		)
	)

/datum/biome/asteroid
	open_turf_types = list(
		/turf/space = 1
	)

/datum/biome/asteroid/carp
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/carp = 1
	)

/datum/biome/cave/asteroid
	closed_turf_types =  list(
		/turf/unsimulated/mask = 1,
	)
	open_turf_types = list(
		/turf/simulated/floor/asteroid = 1
	)

/datum/biome/cave/asteroid/vanilla
	flora_spawn_list = list(
		//obj/structure/flora/ash/space/voidmelon = 1,
		/obj/structure/rock = 1,
		//obj/structure/flora/rock/pile = 1
	)

	feature_spawn_list = list(
		/obj/structure/geyser/random = 1,
	)

	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 25,
		/mob/living/simple_animal/hostile/asteroid/goliath/alpha = 20,
		/mob/living/simple_animal/hostile/asteroid/hoverhead = 25,
		/mob/living/simple_animal/hostile/asteroid/sand_lurker = 25,
		/mob/living/simple_animal/hostile/asteroid/shooter/beholder = 1,
	)

	flora_spawn_chance = 2
	feature_spawn_chance = 1
	mob_spawn_chance = 6

/datum/biome/cave/asteroid/ice
	open_turf_types = list(
		/turf/simulated/floor/natural/frozenground/snow = 1
	)

	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 25,
		/mob/living/simple_animal/hostile/asteroid/goliath/alpha = 20,
		/mob/living/simple_animal/hostile/asteroid/hoverhead = 25,
		/mob/living/simple_animal/hostile/asteroid/sand_lurker = 25,
		/mob/living/simple_animal/hostile/asteroid/shooter/beholder = 1,
	)

	mob_spawn_chance = 2

/datum/biome/cave/asteroid/carp_den
	closed_turf_types =  list(
		/turf/unsimulated/mask = 5
	)

	open_turf_types = list(
		/turf/simulated/floor/asteroid = 1
	)

	flora_spawn_list = list(
		//VOIDMELON
		/obj/structure/rock = 1,
	)

	feature_spawn_list = list(
		/obj/structure/geyser/random = 1,
	)

	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/carp = 25,
		/mob/living/simple_animal/hostile/carp/pike = 30,
	)

	flora_spawn_chance = 15
	feature_spawn_chance = 10
	mob_spawn_chance = 18
