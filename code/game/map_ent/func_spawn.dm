/obj/map_ent/func_spawn
	name = "func_spawn"
	icon_state = "func_spawn"

	var/ev_target
	var/ev_new_args = list()
	var/ev_unique = FALSE
	var/ev_dir
	var/ev_spawned

	var/weakref/_instance

/obj/map_ent/func_spawn/Initialize()
	. = ..()

	if(ev_unique && istext(ev_target))
		var/atom/A = locate(ev_target)
		ev_target = A.type
		_instance = weakref(A)

/obj/map_ent/func_spawn/activate()
	var/list/new_args = list(get_turf(src)) + ev_new_args

	if(!ev_unique)
		var/atom/A = new ev_target(arglist(new_args))
		ev_spawned = "\ref[A]"
		A.set_dir(ev_dir)
		return

	var/atom/A = _instance?.resolve()
	if(!QDELETED(A))
		QDEL_NULL(A)
	
	A = new ev_target(arglist(new_args))
	ev_spawned = "\ref[A]"

	if(ev_dir)
		A.set_dir(ev_dir)

	_instance = weakref(A)
