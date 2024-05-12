GLOBAL_VAR_INIT(__pt_test_start, null)
GLOBAL_VAR_INIT(__pt_test_goal, null)
GLOBAL_LIST_INIT(__pt_test_paths, new())

/obj/effect/pathfinding
	name = "Pathfinding"
	icon = 'icons/testing/pathfinding.dmi'

/obj/effect/pathfinding/path
	name = "Pathfinding Path"
	icon_state = "path"

/obj/effect/pathfinding/start
	name = "Pathfinding Start"
	icon_state = "start"

/obj/effect/pathfinding/goal
	name = "Pathfinding Goal"
	icon_state = "goal"

/proc/test_pathfinding_vis(turf/from, turf/goal, pass_bit, deny_bit, list/costs)
	QDEL_LIST(GLOB.__pt_test_paths)

	var/result = rustg_generate_path_astar(\
		json_encode(list("x" = from.x, "y" = from.y, "z" = from.z)),\
		json_encode(list("x" = goal.x, "y" = goal.y, "z" = goal.z)),\
		pass_bit,\
		deny_bit,\
		json_encode(costs)\
	)

	if(!rustg_json_is_valid(result))
		CRASH(result)

	var/list/path = json_decode(result)

	for(var/i = 2; i < length(path); i++)
		var/list/pos = path[i]
		var/turf/target = locate(pos["x"], pos["y"], pos["z"])

		GLOB.__pt_test_paths.Add(new /obj/effect/pathfinding/path(target))

/client/proc/test_pt_mark_start()
	set category = "Debug"
	set name = "Pathfinding Mark Start"

	if(!check_rights(R_DEBUG))
		return

	var/obj/O = GLOB.__pt_test_start

	if(O)
		qdel(O)

	GLOB.__pt_test_start = new /obj/effect/pathfinding/start(get_turf(mob))

/client/proc/test_pt_mark_goal()
	set category = "Debug"
	set name = "Pathfinding Mark Goal"

	if(!check_rights(R_DEBUG))
		return

	var/obj/O = GLOB.__pt_test_goal

	if(O)
		qdel(O)

	GLOB.__pt_test_goal = new /obj/effect/pathfinding/goal(get_turf(mob))

/client/proc/test_pt_clear()
	set category = "Debug"
	set name = "Pathfinding Clear"

	if(!check_rights(R_DEBUG))
		return

	if(GLOB.__pt_test_start)
		qdel(GLOB.__pt_test_start)

	if(GLOB.__pt_test_goal)
		qdel(GLOB.__pt_test_goal)

	QDEL_LIST(GLOB.__pt_test_paths)

/client/proc/test_pt_vis()
	set category = "Debug"
	set name = "Pathfinding Visualize"

	if(!check_rights(R_DEBUG))
		return

	if(!GLOB.__pt_test_start)
		CRASH("Mark the starting turf first")

	if(!GLOB.__pt_test_goal)
		CRASH("Mark the goal turf first")

	test_pathfinding_vis(
		get_turf(GLOB.__pt_test_start),
		get_turf(GLOB.__pt_test_goal),
		NODE_TURF_BIT,
		NODE_DENSE_BIT | NODE_SPACE_BIT,
		null
	)
