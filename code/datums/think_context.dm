/datum/think_context
	var/last_think
	var/next_think
	var/datum/callback/callback

/datum/think_context/New(time, clbk)
	last_think = 0
	next_think = time
	callback = clbk

/datum/think_context/Destroy()
	qdel(callback)
	
	. = ..()
