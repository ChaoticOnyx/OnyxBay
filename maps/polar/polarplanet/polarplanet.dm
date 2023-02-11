GLOBAL_LIST_INIT(polar_derelicts, list(
			MAP_POLAR_DERELICT_MEADOW,
			MAP_POLAR_DERELICT_ICE_LAKE,
			MAP_POLAR_DERELICT_FOREST_3,
			MAP_POLAR_DERELICT_FOREST_2,
			MAP_POLAR_DERELICT_FOREST_1,
			MAP_POLAR_DERELICT_CULTIST_MEADOW,
			MAP_POLAR_DERELICT_CONSTRUCTION_SITE,
			MAP_POLAR_DERELICT_CHURCH,
			MAP_POLAR_DERELICT_CAVE_2,
			MAP_POLAR_DERELICT_CAVE_1,
			MAP_POLAR_DERELICT_BAR,
			MAP_POLAR_DERELICT_ARCHEOLOGICAL_CENTER,
			MAP_POLAR_DERELICT_ABANDONED_VILLAGE,
			MAP_POLAR_DERELICT_NULL))

/datum/space_level/polarplanet
	base_turf = /turf/unsimulated/floor/frozenground

/datum/space_level/polarplanet/derelict_spawn_template_1
	path='derelicts_spawn_template_1.dmm'
	travel_chance = 15
	traits = list(
		ZTRAIT_CONTACT,
		ZTRAIT_POLAR_WEATHER
	)

/datum/space_level/polarplanet/derelict_spawn_template_2
	path='derelicts_spawn_template_2.dmm'
	travel_chance = 15
	traits = list(
		ZTRAIT_CONTACT,
		ZTRAIT_POLAR_WEATHER
	)

/obj/map_ent/derelict
	name = "util_polar_derelict"
	icon_state = "util_bio"

	var/ev_derelict
	var/ev_result

/obj/map_ent/derelict/activate()
	var/target_derelict = ev_derelict

	if(!target_derelict)
		target_derelict = pick_n_take(GLOB.polar_derelicts)

	ev_result = "maps/polar/polarplanet/derelicts/[target_derelict].dmm"
