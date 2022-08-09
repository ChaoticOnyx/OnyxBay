SUBSYSTEM_DEF(think)
	name = "Think"
	priority = SS_PRIORITY_THINK
	flags = SS_TICKER
	wait = 1

	var/list/next_group_run[THINKER_GROUPS]
	// Lists count should be equal to THINKER_GROUPS.
	var/list/contexts_groups = list(list(), list(), list(), list(), list())
	var/list/current_run = list()
	var/last_group = 1

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
		last_group += 1

		if(last_group > length(contexts_groups))
			last_group = 1

		if(next_group_run[last_group] >= world.time)
			return

		next_group_run[last_group] = 0
		src.current_run = contexts_groups[last_group].Copy()

	// cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run
	var/len = length(current_run)

	if(len == 0)
		next_group_run[last_group] = 0
		return

	while(len)
		var/datum/think_context/ctx = current_run[len]
		current_run.len--
		len--

		if(ctx.next_think <= ctx.last_think)
			contexts_groups[ctx.group] -= ctx
			continue

		ctx.callback.Invoke()
		ctx.last_think = world.time

		if (MC_TICK_CHECK)
			return
