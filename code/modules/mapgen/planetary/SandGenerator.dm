/area/generated/planetoid/sand
	area_flags = AREA_FLAG_CAVES_ALLOWED
	base_turf = /turf/simulated/floor/asteroid/whitesands

/datum/map_generator/planet_generator/sand
	mountain_height = 0.8
	perlin_zoom = 65

	primary_area_type = /area/generated/planetoid/sand

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/sand,
			BIOME_LOW_HUMIDITY = /datum/biome/sand,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/sand/grass/dead,
			BIOME_HIGH_HUMIDITY = /datum/biome/sand/icecap,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/sand/icecap
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/sand,
			BIOME_LOW_HUMIDITY = /datum/biome/sand/riverbed,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/sand/wasteland,
			BIOME_HIGH_HUMIDITY = /datum/biome/sand/wasteland,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/sand/icecap
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/sand,
			BIOME_LOW_HUMIDITY = /datum/biome/sand,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/sand/riverbed,
			BIOME_HIGH_HUMIDITY = /datum/biome/sand,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/sand
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/sand,
			BIOME_LOW_HUMIDITY = /datum/biome/sand/riverbed,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/sand/grass/dead,
			BIOME_HIGH_HUMIDITY = /datum/biome/sand/grass,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/sand/grass
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY =/datum/biome/sand/acid,
			BIOME_LOW_HUMIDITY = /datum/biome/sand/wasteland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/sand/riverbed,
			BIOME_HIGH_HUMIDITY = /datum/biome/sand,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/sand/grass
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/sand/acid/total,
			BIOME_LOW_HUMIDITY = /datum/biome/sand/acid,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/sand/riverbed,
			BIOME_HIGH_HUMIDITY = /datum/biome/sand/wasteland,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/sand
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/sand/volcanic/acidic,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/sand/deep,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/sand/deep,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/sand,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/sand
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/sand/volcanic/acidic,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/sand/volcanic,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/sand/deep,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/sand/deep,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/sand,
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/sand/volcanic/acidic,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/sand/volcanic,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/sand/deep,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/sand,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/sand
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/sand/volcanic/lava,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/sand/volcanic,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/sand/volcanic,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/sand/deep,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/sand,
		)
	)

/datum/biome/sand
	open_turf_types = list(/turf/simulated/floor/asteroid/whitesands = 1)
	flora_spawn_chance = 3
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
		/obj/structure/geyser/random = 8,
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 50,
		/mob/living/simple_animal/hostile/asteroid/basilisk/whitesands = 40,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 30,
		/mob/living/simple_animal/hostile/asteroid/whitesands/survivor/random = 25,
	)

/datum/biome/sand/wasteland
	open_turf_types = list(
		/turf/simulated/floor/asteroid/whitesands = 50,
		/turf/simulated/floor/asteroid/whitesands/dried = 40,
		/turf/unsimulated/mask = 20,
	)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/effect/decal/remains/human = 4,
		/obj/effect/spawner/lootdrop/maintenance = 40,
	)

/datum/biome/sand/grass
	open_turf_types = list(/turf/simulated/floor/asteroid/whitesands/grass = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/tree/tall/whitesands = 4,
		/obj/structure/flora/rock = 3,
		/obj/structure/flora/rock/pile = 3,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/whitesands/survivor/random = 1,
	)

/datum/biome/sand/grass/dead
	open_turf_types = list(/turf/simulated/floor/asteroid/whitesands/grass/dead = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead/barren = 4,
		/obj/structure/rock/basalt = 3,
		/obj/structure/rock/basalt/pile = 3,
	)

/datum/biome/sand/icecap
	open_turf_types = list(/turf/simulated/floor/asteroid/whitesands = 1, /turf/simulated/floor/natural/frozenground/snow = 5)
	flora_spawn_chance = 4
	mob_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/rock/basalt = 3,
		/obj/structure/rock/basalt/pile = 3,
	)

/datum/biome/sand/riverbed
	open_turf_types = list(/turf/simulated/floor/asteroid/whitesands/dried = 1)
	flora_spawn_chance = 0
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 40,
		/mob/living/simple_animal/hostile/asteroid/basilisk/whitesands = 30,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 20,
		/mob/living/simple_animal/hostile/asteroid/whitesands/survivor/random = 40,
	)

/datum/biome/cave/sand
	closed_turf_types = list(/turf/unsimulated/mask = 1)
	open_turf_types = list(
		/turf/simulated/floor/asteroid/whitesands = 5,
		/turf/simulated/floor/asteroid/whitesands/dried = 1
	)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/rock/basalt = 4,
		/obj/structure/rock/basalt/pile = 4,
	)
	feature_spawn_list = list(
		/obj/structure/geyser/random = 4,
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 50,
	)

/datum/biome/cave/sand/deep
	open_turf_types = list(/turf/simulated/floor/asteroid/whitesands/dried = 1)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 50,
	)

/datum/biome/cave/sand/volcanic
	open_turf_types = list(/turf/simulated/floor/asteroid/whitesands/dried = 1)
	mob_spawn_chance = 2

/datum/biome/cave/sand/volcanic/lava
	open_turf_types = list(/turf/simulated/floor/asteroid/whitesands/dried = 7, /turf/simulated/floor/natural/lava = 1)
