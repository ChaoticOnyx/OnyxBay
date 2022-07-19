/obj/map_ent/func_rand_spawn
	name = "func_rand_spawn"
	icon_state = "func_rand_spawn"

	var/ev_paths = list()
	var/ev_new_args = list()

/obj/map_ent/func_rand_spawn/activate()
	var/list/new_args = list(get_turf(src)) + ev_new_args
	var/to_spawn = pick(ev_paths)

	if(!ispath(to_spawn))
		crash_with("invalid path in ev_paths: `[to_spawn]`")
		return

	new to_spawn(arglist(new_args))
