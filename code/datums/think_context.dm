/datum/think_context
	var/last_think
	var/next_think
	var/datum/callback/callback
	var/group
	var/list/arguments

/datum/think_context/New(time, clbk, ...)
	last_think = 0
	next_think = time
	callback = clbk
	ASSIGN_THINK_GROUP(group, time)

	if(length(args) > 2)
		arguments = args.Copy(3)
	else
		arguments = list()

/datum/think_context/proc/stop()
	if(group)
		SSthink.contexts_groups[group] -= src

	last_think = 0
	next_think = 0
	group = null
	arguments.Cut()

/datum/think_context/Destroy()
	stop()
	QDEL_NULL(callback)
	arguments = null

	return ..()
