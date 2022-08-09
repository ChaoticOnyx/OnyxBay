SUBSYSTEM_DEF(think)
	name = "Think"
	priority = SS_PRIORITY_THINK
	flags = SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_NO_INIT
	wait = 1 SECOND

	var/list/next_group_run = list(0, 0, 0, 0, 0)
	var/list/thinkers_groups = list(list(), list(), list(), list(), list())
	var/list/current_run = list()
	var/last_group = 1

/datum/controller/subsystem/think/stat_entry()
	var/msg = "G:("

	for(var/grp in thinkers_groups)
		msg += "[length(grp)],"
	
	msg += "), NR:("

	for(var/next_run in next_group_run)
		msg += "[next_run],"
	
	msg += ")"

	..(msg)

/datum/controller/subsystem/think/fire(resumed = 0)
	if(!resumed)
		last_group += 1

		if(last_group > length(thinkers_groups))
			last_group = 1

		if(next_group_run[last_group] >= world.time)
			return

		next_group_run[last_group] = 0
		src.current_run = thinkers_groups[last_group].Copy()
		log_debug("group with size [length(src.current_run)]")

	// cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run
	var/len = length(current_run)

	if(len == 0)
		next_group_run[last_group] = 0
		return

	while(len)
		var/datum/thing = current_run[len]
		current_run.len--
		len--

		var/datum/think_context/main_ctx = thing._main_think_ctx
		if(main_ctx.next_think <= main_ctx.last_think)
			thing.clear_think()
			continue

		if(world.time >= main_ctx.next_think)
			main_ctx.callback.Invoke()
			main_ctx.last_think = world.time

		if(QDELETED(thing))
			continue

		for(var/ctx_name in thing._think_ctxs)
			var/datum/think_context/ctx = thing._think_ctxs[ctx_name]

			if(ctx.next_think <= ctx.last_think)
				thing._think_ctxs -= ctx_name
				continue

			if(world.time >= ctx.next_think)
				ctx.callback.Invoke()
				ctx.last_think = world.time

		if (MC_TICK_CHECK)
			return
