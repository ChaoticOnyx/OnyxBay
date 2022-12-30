/obj/map_ent/util_bar
	name = "util_bar"
	icon_state = "util_bar"

	var/ev_bar
	var/ev_result

/obj/map_ent/util_bar/activate()
	var/target_bar = ev_bar

	if(!target_bar)
		target_bar = config.mapping.preferable_bar

	if(target_bar == MAP_BAR_RANDOM)
		target_bar = pick(MAP_BAR_CLASSIC, MAP_BAR_MODERN, MAP_BAR_SALOON)

	ev_result = "maps/[GLOB.using_map.path]/bar/[target_bar].dmm"
