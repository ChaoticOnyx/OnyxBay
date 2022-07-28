/obj/map_ent/func_load_map
	name = "func_load_map"
	icon_state = "func_load_map"

	var/ev_map_path
	var/ev_clear_conents = TRUE

/obj/map_ent/func_load_map/activate()
	if(!ev_map_path)
		crash_with("func_load_map has invalid ev_map_path: `[ev_map_path]`")
		return

	var/map_file

	if(istext(ev_map_path))
		map_file = file(ev_map_path)

	maploader.load_map(map_file, loc.x, loc.y, loc.z, FALSE, FALSE, TRUE, ev_clear_conents)
