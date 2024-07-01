/area/overmap_encounter/planetoid/waste
	area_flags = AREA_FLAG_CAVES_ALLOWED
	base_turf = /turf/simulated/floor/asteroid/jungle

/datum/map_generator/planet_generator/waste
	mountain_height = 0.35
	perlin_zoom = 40

	initial_closed_chance = 45
	smoothing_iterations = 20
	birth_limit = 4
	death_limit = 3
	primary_area_type = /area/overmap_encounter/planetoid/waste

	weather_controller_type = /datum/weather_controller/lush

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/waste/crater,
			BIOME_LOW_HUMIDITY = /datum/biome/waste/crater,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/waste/clearing,
			BIOME_HIGH_HUMIDITY = /datum/biome/waste/clearing/mushroom,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/waste/metal/rust
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/waste/crater,
			BIOME_LOW_HUMIDITY = /datum/biome/waste/crater/rad,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/waste,
			BIOME_HIGH_HUMIDITY = /datum/biome/waste/clearing/mushroom,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/waste/tar_bed
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/waste/clearing,
			BIOME_LOW_HUMIDITY = /datum/biome/waste/clearing,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/waste/clearing/mushroom,
			BIOME_HIGH_HUMIDITY = /datum/biome/waste,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/waste
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/waste,
			BIOME_LOW_HUMIDITY = /datum/biome/waste/tar_bed,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/waste/metal,
			BIOME_HIGH_HUMIDITY = /datum/biome/waste,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/waste/metal/rust
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/waste,
			BIOME_LOW_HUMIDITY = /datum/biome/waste/tar_bed,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/waste/tar_bed,
			BIOME_HIGH_HUMIDITY = /datum/biome/waste/tar_bed/total,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/waste/tar_bed/total
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/waste/metal,
			BIOME_LOW_HUMIDITY = /datum/biome/waste/metal,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/waste/metal,
			BIOME_HIGH_HUMIDITY = /datum/biome/waste/metal/rust,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/waste/metal/rust
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list( //irradiated caves
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/waste,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/waste,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/waste/tar_bed,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/waste/tar_bed/full,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/waste/tar_bed/full
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/waste,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/waste/rad,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/waste,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/waste/rad,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/waste
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/waste,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/waste,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/waste/metal,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/waste/metal,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/waste/tar_bed
		),
		BIOME_HOT_CAVE = list( //metal wreck for salvaging
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/waste/metal/hivebot,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/waste/metal/hivebot,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/waste/metal/hivebot,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/waste/metal/,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/waste/metal/
		)
	)

/datum/biome/waste
	open_turf_types = list(
		/turf/simulated/floor/asteroid/waste = 80,
		/turf/simulated/floor/asteroid/rust = 15,
	)

	flora_spawn_list = list(
		/obj/random/waste/mechwreck = 100,
		/obj/random/waste/mechwreck/rare = 20,

		/obj/random/waste/trash = 1800,
		/obj/random/waste/radiation = 80,
		/obj/random/waste/radiation/more_rads = 10,

		/obj/random/waste/girder = 600,
		/obj/structure/reagent_dispensers/fueltank = 100,
		/obj/structure/reagent_dispensers/watertank = 200,
		/obj/item/stack/cable_coil/cut = 500,
		/obj/structure/closet/crate/secure/loot = 30,
		/obj/random/waste/canister = 50,
		//obj/random/waste/salvageable = 300,
		/obj/random/waste/grille_or_trash = 200,

		/obj/random/scrap/moderate_weighted = 400,
		/obj/random/scrap/dense_weighted = 10,

		//obj/structure/flora/ash/garden/waste = 70,
		//obj/structure/flora/ash/glowshroom = 200,

		//obj/item/mine/pressure/explosive/shrapnel/live = 30,
		//obj/effect/spawner/lootdrop/mine = 8,
		//obj/effect/spawner/minefield = 2
	)

	feature_spawn_list = list(
		//obj/effect/radiation/waste = 30,
		//obj/effect/radiation/waste/intense = 10,
		/obj/structure/geyser/random = 1,
		//obj/effect/spawner/lootdrop/anomaly/waste = 1
	)

	mob_spawn_list = list(
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/strong = 70,
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged = 40,
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged/rapid = 30,

		//mob/living/simple_animal/bot/firebot/rockplanet = 15,
		//mob/living/simple_animal/bot/secbot/ed209/rockplanet = 3,
		//mob/living/simple_animal/hostile/abandoned_minebot = 15,
		//mob/living/simple_animal/bot/floorbot/rockplanet = 15,
	)

	flora_spawn_chance = 25
	feature_spawn_chance = 0.5
	mob_spawn_chance = 2

/datum/biome/waste/crater
	open_turf_types = list(
		/turf/simulated/floor/asteroid/waste = 90,
		/turf/simulated/floor/asteroid/rust = 10,
	)

	flora_spawn_list = list(
		/obj/random/waste/trash = 180,
		/obj/random/waste/radiation = 16,
		/obj/random/waste/radiation/more_rads = 2,
		/obj/random/waste/canister = 36,
		//obj/random/waste/salvageable = 60,

		/obj/random/scrap/moderate_weighted = 200,
		/obj/random/scrap/dense_weighted = 10,

	)
	mob_spawn_chance = 1

/datum/biome/waste/crater/rad
	flora_spawn_list = list(
		//obj/structure/flora/ash/glowshroom = 180,
		/obj/random/waste/trash = 90,
		/obj/random/waste/radiation = 25,
		/obj/random/waste/radiation/more_rads = 7,
		/obj/random/waste/canister = 7,
		//obj/random/waste/salvageable = 15
		/obj/random/scrap/moderate_weighted = 200,
		/obj/random/scrap/dense_weighted = 10,
	)

/datum/biome/waste/clearing
	flora_spawn_chance = 20
	feature_spawn_chance = 2

/datum/biome/waste/clearing/mushroom
	flora_spawn_list = list(
		/obj/random/waste/mechwreck = 100,
		/obj/random/waste/trash = 900,
		/obj/random/waste/radiation = 300,
		/obj/random/waste/radiation/more_rads = 120,
		/obj/random/waste/girder = 600,
		/obj/structure/reagent_dispensers/fueltank = 100,
		/obj/structure/reagent_dispensers/watertank = 200,
		/obj/item/stack/cable_coil/cut = 500,
		/obj/structure/closet/crate/secure/loot = 30,
		/obj/random/waste/canister = 50,
		//obj/random/waste/salvageable = 300,
		/obj/random/waste/grille_or_trash = 200,
		//obj/effect/spawner/lootdrop/maintenance = 200,
		//obj/effect/spawner/lootdrop/maintenance/two = 100,
		//obj/effect/spawner/lootdrop/maintenance/three = 50,
		//obj/effect/spawner/lootdrop/maintenance/four = 20,
		//obj/structure/flora/ash/garden/waste = 300,
		///obj/structure/flora/ash/glowshroom = 1800,
		//obj/item/mine/pressure/explosive/shrapnel/live = 30,
		//obj/effect/spawner/lootdrop/mine = 8,
		//obj/effect/spawner/minefield = 2
		/obj/random/scrap/moderate_weighted = 200,
		/obj/random/scrap/dense_weighted = 10,
		/obj/structure/bonfire/dynamic = 40,
	)

/datum/biome/waste/tar_bed
	open_turf_types = list(
		/turf/simulated/floor/asteroid/waste = 85,
		/turf/simulated/floor/asteroid/rust = 15,
	)

/datum/biome/waste/tar_bed/total
	open_turf_types = list(
		/turf/simulated/floor/asteroid/waste = 1,
	)
	flora_spawn_chance = 0

/datum/biome/waste/metal
	open_turf_types = list(
		/turf/simulated/floor/asteroid/waste = 70,
		/turf/simulated/floor/asteroid/rust = 30,
	)

	flora_spawn_list = list(
		/obj/random/waste/mechwreck = 200,
		/obj/random/waste/mechwreck/rare = 50,
		/obj/random/waste/trash = 900,
		/obj/random/waste/radiation = 80,
		/obj/random/waste/radiation/more_rads = 20,
		/obj/random/waste/girder = 600,
		/obj/structure/reagent_dispensers/fueltank = 100,
		/obj/structure/reagent_dispensers/watertank = 200,
		/obj/item/stack/cable_coil/cut = 500,
		/obj/structure/closet/crate/secure/loot = 30,
		//obj/random/waste/atmos_can = 50,
		//obj/random/waste/atmos_can/rare = 1,
		//obj/random/waste/salvageable = 300,
		/obj/random/waste/grille_or_trash = 200,
		//obj/effect/spawner/lootdrop/maintenance = 200,
		//obj/effect/spawner/lootdrop/maintenance/two = 100,
		//obj/effect/spawner/lootdrop/maintenance/three = 50,
		//obj/effect/spawner/lootdrop/maintenance/four = 20,
		/obj/structure/closet/crate/secure/loot = 30,
		/obj/random/waste/canister = 180,
		//obj/random/waste/atmos_can/rare = 1,
		//obj/random/waste/salvageable = 300,
		//obj/item/mine/pressure/explosive/rad/live = 30,
		//obj/effect/spawner/lootdrop/mine = 8,
		//obj/effect/spawner/minefield = 2
		/obj/structure/bonfire/dynamic = 40,
	)
	mob_spawn_list = list(
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/strong = 80,
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged = 50,
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged/rapid = 50,
		//mob/living/simple_animal/bot/firebot/rockplanet = 15,
		//mob/living/simple_animal/bot/secbot/ed209/rockplanet = 3,
		//mob/living/simple_animal/hostile/abandoned_minebot = 15,
		//mob/living/simple_animal/bot/floorbot/rockplanet = 15,
		//obj/structure/spawner/wasteplanet/hivebot/low_threat = 20,
		//obj/structure/spawner/wasteplanet/hivebot/medium_threat = 10,
		//obj/structure/spawner/wasteplanet/hivebot/high_threat = 5,
		//obj/structure/spawner/wasteplanet/hivebot/extreme_threat = 2
	)

/datum/biome/waste/metal/rust
	open_turf_types = list(
		/turf/simulated/floor/asteroid/waste = 85,
		/turf/simulated/floor/asteroid/rust = 15,
	)

/datum/biome/cave/waste
	open_turf_types = list(
		/turf/simulated/floor/asteroid/waste = 85,
		/turf/simulated/floor/asteroid/rust = 15,
	)

	closed_turf_types =  list(
		/turf/simulated/wall/mineral = 1,
	)

	flora_spawn_list = list(
		/obj/random/waste/mechwreck = 100,
		/obj/random/waste/mechwreck/rare = 20,
		/obj/random/waste/trash = 1800,
		/obj/random/waste/radiation = 80,
		/obj/random/waste/radiation/more_rads = 10,
		/obj/random/waste/girder = 600,
		/obj/structure/reagent_dispensers/fueltank = 100,
		/obj/structure/reagent_dispensers/watertank = 200,
		/obj/item/stack/cable_coil/cut = 500,
		/obj/structure/closet/crate/secure/loot = 30,
		/obj/random/waste/canister = 50,
		//obj/random/waste/atmos_can/rare = 5,
		//obj/random/waste/salvageable = 300,
		/obj/random/waste/grille_or_trash = 200,
		//obj/effect/spawner/lootdrop/maintenance = 20,
		//obj/effect/spawner/lootdrop/maintenance/two = 50,
		//obj/effect/spawner/lootdrop/maintenance/three = 100,
		//obj/effect/spawner/lootdrop/maintenance/four = 200,
		//obj/random/waste/salvageable = 400,
		//obj/structure/flora/ash/garden/waste = 70,
		//obj/structure/flora/ash/glowshroom = 400,
		//obj/item/mine/pressure/explosive/rad/live = 10,
		//obj/effect/spawner/lootdrop/mine = 8,
		//obj/effect/spawner/minefield = 2
		/obj/random/scrap/moderate_weighted = 200,
		/obj/random/scrap/dense_weighted = 10,
		/obj/structure/bonfire/dynamic = 40,
	)

	feature_spawn_list = list(
		//obj/effect/radiation/waste = 30,
		//obj/effect/radiation/waste/intense = 10,
		/obj/structure/geyser/random = 1,
		//obj/effect/spawner/lootdrop/anomaly/waste/cave = 1
	)
	mob_spawn_list = list(
		//mob/living/simple_animal/hostile/hivebot/strong/rockplanet = 70,
		//mob/living/simple_animal/hostile/hivebot/range/rockplanet = 40,
		//mob/living/simple_animal/hostile/hivebot/rapid/rockplanet = 30,
		//mob/living/simple_animal/bot/firebot/rockplanet = 15,
		//mob/living/simple_animal/bot/secbot/ed209/rockplanet = 3,
		//mob/living/simple_animal/hostile/abandoned_minebot = 15,
		//mob/living/simple_animal/bot/floorbot/rockplanet = 15,
	)

	flora_spawn_chance = 30
	feature_spawn_chance = 4
	mob_spawn_chance = 5

/datum/biome/cave/waste/tar_bed
	open_turf_types = list(
		/turf/simulated/floor/asteroid/waste = 80,
		/turf/simulated/floor/asteroid/rust = 15,
		/turf/simulated/floor/asteroid/tar_water = 5,
	)

/datum/biome/cave/waste/tar_bed/full
	open_turf_types = list(
		/turf/simulated/floor/asteroid/tar_water = 1
	)
	flora_spawn_chance = 0

/datum/biome/cave/waste/rad
	flora_spawn_list = list(
		/obj/random/waste/trash = 900,
		/obj/random/waste/radiation = 250,
		/obj/random/waste/radiation/more_rads = 70,
		/obj/random/waste/canister = 50,
		//obj/random/waste/salvageable = 150,
		/obj/random/waste/girder = 200,
		/obj/structure/reagent_dispensers/fueltank = 10,
		/obj/structure/reagent_dispensers/watertank = 10,
		/obj/item/stack/cable_coil/cut = 500,
		/obj/structure/closet/crate/secure/loot = 30,
		/obj/random/waste/grille_or_trash = 200,
		//obj/effect/spawner/lootdrop/maintenance = 20,
		//obj/effect/spawner/lootdrop/maintenance/two = 50,
		//obj/effect/spawner/lootdrop/maintenance/three = 100,
		//obj/effect/spawner/lootdrop/maintenance/four = 200,
		//obj/structure/flora/ash/glowshroom = 1800,
		//obj/item/mine/pressure/explosive/rad/live = 30,
		//obj/effect/spawner/lootdrop/mine = 8,
		//obj/effect/spawner/minefield = 2
		/obj/random/scrap/moderate_weighted = 200,
		/obj/random/scrap/dense_weighted = 10,
		/obj/structure/bonfire/dynamic = 40,
	)
	feature_spawn_chance = 12

/datum/biome/cave/waste/metal
	open_turf_types = list(
		/turf/simulated/floor/asteroid/waste = 90,
		/turf/simulated/floor/asteroid/rust = 10,
	)
	closed_turf_types = list(
		/turf/simulated/wall/mineral = 1,
	)
	flora_spawn_list = list(
		/obj/random/waste/mechwreck = 40,
		/obj/random/waste/mechwreck/rare = 10,
		/obj/random/waste/trash = 180,
		/obj/random/waste/radiation = 32,
		/obj/random/waste/radiation/more_rads = 4,
		/obj/random/waste/girder = 120,
		/obj/structure/reagent_dispensers/fueltank = 20,
		/obj/structure/reagent_dispensers/watertank = 40,
		/obj/item/stack/cable_coil/cut = 100,
		/obj/structure/closet/crate/secure/loot = 6,
		/obj/random/waste/canister = 10,
		//obj/random/waste/salvageable = 60,
		/obj/random/waste/grille_or_trash = 40,
		///obj/effect/spawner/lootdrop/maintenance = 4,
		//obj/effect/spawner/lootdrop/maintenance/two = 10,
		//obj/effect/spawner/lootdrop/maintenance/three = 20,
		///obj/effect/spawner/lootdrop/maintenance/four = 40,
		//obj/random/waste/salvageable = 80,
		//obj/item/mine/proximity/spawner/manhack/live = 40,
		//obj/effect/spawner/lootdrop/mine = 8,
		//obj/effect/spawner/minefield/manhack = 2
		/obj/random/scrap/moderate_weighted = 200,
		/obj/random/scrap/dense_weighted = 10,
		/obj/structure/bonfire/dynamic = 40,
	)
	mob_spawn_list = list(
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/strong = 80,
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged = 50,
		///mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged/rapid = 50,
		//mob/living/simple_animal/bot/firebot/rockplanet = 15,
		//mob/living/simple_animal/bot/secbot/ed209/rockplanet = 3,
		//mob/living/simple_animal/hostile/abandoned_minebot = 15,
		//mob/living/simple_animal/bot/floorbot/rockplanet = 15,
		///obj/structure/spawner/wasteplanet/hivebot/low_threat = 20,
		//obj/structure/spawner/wasteplanet/hivebot/medium_threat = 10,
		//obj/structure/spawner/wasteplanet/hivebot/high_threat = 5,
		//obj/structure/spawner/wasteplanet/hivebot/extreme_threat = 2
	)

/datum/biome/cave/waste/metal/hivebot
	flora_spawn_list = list(
		/obj/random/waste/trash = 90,
		/obj/random/waste/radiation = 16,
		/obj/random/waste/radiation/more_rads = 2,
		/obj/random/waste/girder = 60,
		/obj/structure/reagent_dispensers/fueltank = 10,
		/obj/structure/reagent_dispensers/watertank = 20,
		/obj/item/stack/cable_coil/cut = 50,
		/obj/structure/closet/crate/secure/loot = 3,
		//obj/effect/spawner/lootdrop/maintenance = 2,
		//obj/effect/spawner/lootdrop/maintenance/two = 5,
		//obj/effect/spawner/lootdrop/maintenance/three = 10,
		///obj/effect/spawner/lootdrop/maintenance/four = 20,
		//obj/random/waste/salvageable = 40,
		/obj/structure/foamedmetal = 100,
		//obj/item/mine/proximity/spawner/manhack/live = 20
		/obj/random/scrap/moderate_weighted = 200,
		/obj/random/scrap/dense_weighted = 10,
		/obj/structure/bonfire/dynamic = 40,
	)
	mob_spawn_list = list(
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/strong = 80,
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged = 50,
		//mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged/rapid = 50,

	)
	mob_spawn_chance = 30
	feature_spawn_list = list(
		//obj/structure/spawner/wasteplanet/hivebot/low_threat = 20,
		//obj/structure/spawner/wasteplanet/hivebot/medium_threat = 10,
		//obj/structure/spawner/wasteplanet/hivebot/high_threat = 5,
		//obj/structure/spawner/wasteplanet/hivebot/extreme_threat = 2,
		//obj/effect/spawner/minefield/manhack = 2
		)
	feature_spawn_chance = 2
