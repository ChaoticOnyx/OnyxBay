/datum/think_context
	var/last_think
	var/next_think
	var/datum/callback/callback
	var/group

/datum/think_context/New(time, clbk)
	last_think = 0
	next_think = time
	callback = clbk
	ASSIGN_THINK_GROUP(group, time)

/datum/think_context/Destroy()
	SSthink.contexts_groups[group] -= src
	qdel(callback)
	last_think = 0
	next_think = 0
	group = null
	
	. = ..()
