SUBSYSTEM_DEF(think)
	name = "Think"
	priority = SS_PRIORITY_THINK
	flags = SS_TICKER
	wait = 1

	// Length of these lists should be equal to THINKER_GROUPS
	var/list/next_group_run = list(0, 0, 0, 0, 0)
	var/list/contexts_groups = list(list(), list(), list(), list(), list())

	var/list/current_run = list()
	var/last_group = 1
	var/next_possible_run = 0

/datum/controller/subsystem/think/stat_entry()
	var/msg = "G:("

	for(var/grp in contexts_groups)
		msg += "[length(grp)],"

	msg += "), NR:("

	for(var/next_run in next_group_run)
		msg += "[next_run],"

	msg += ")"

	..(msg)

/datum/controller/subsystem/think/fire(resumed = 0)
	if(!resumed)
		next_possible_run = 0
		last_group += 1

		if(last_group > length(contexts_groups))
			last_group = 1

		if(next_group_run[last_group] >= world.time)
			return

		src.current_run = contexts_groups[last_group].Copy()
		next_group_run[last_group] = 0

	// cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run

	if(length(current_run) == 0)
		next_group_run[last_group] = 0
		return

	while(length(current_run))
		var/datum/think_context/ctx = current_run[length(current_run)]
		current_run.len--

		if(QDELETED(ctx))
			continue

		if(ctx.next_think <= ctx.last_think)
			ctx.stop()
			continue

		if(world.time >= ctx.next_think)
			var/last_think = world.time
			ctx.callback.Invoke(arglist(ctx.arguments))
			ctx.last_think = last_think
		else
			if(next_possible_run == 0)
				next_possible_run = ctx.next_think
			else
				next_possible_run = min(next_possible_run, ctx.next_think)

		if (MC_TICK_CHECK)
			return

	if(next_possible_run != 0)
		if(next_group_run[last_group] == 0)
			next_group_run[last_group] = next_possible_run
		else
			next_group_run[last_group] = min(next_group_run[last_group], next_possible_run)
