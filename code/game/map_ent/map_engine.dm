/obj/map_ent/util_engine
	name = "util_engine"
	icon_state = "util_engine"

	var/ev_engine
	var/ev_result

/obj/map_ent/util_engine/activate()
	var/target_engine = ev_engine
	
	if(!target_engine)
		target_engine = config.misc.preferable_engine
	
	if(target_engine == MAP_ENG_RANDOM)
		target_engine = pick(MAP_ENG_SINGULARITY, MAP_ENG_MATTER)

	ev_result = "maps/[GLOB.using_map.path]/[target_engine].dmm"
