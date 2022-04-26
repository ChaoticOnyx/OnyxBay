/datum
	var/weakref/weakref

/datum/Destroy()
	weakref = null // Clear this reference to ensure it's kept for as brief duration as possible.
	return ..()

// Creates/obtains a weakref to the given input.
/proc/weakref(datum/D)
	if(!istype(D))
		return
	if(QDELETED(D))
		return
	if(istype(D, /weakref))
		return D
	if(!D.weakref)
		D.weakref = new /weakref(D)
	return D.weakref

/datum/proc/create_weakref() //Forced creation for admin proccalls
	return weakref(src)

/weakref
	var/ref

	// Handy info for debugging
	var/tmp/ref_name
	var/tmp/ref_type

/weakref/New(datum/D)
	ref = "\ref[D]"
	ref_name = "[D]"
	ref_type = D.type

/weakref/Destroy(force)
	var/datum/target = resolve()
	qdel(target)

	// A weakref datum should not be manually destroyed as it is a shared resource,
	// rather it should be automatically collected by the BYOND GC when all references are gone.
	if(!force)
		return QDEL_HINT_IWILLGC //Let BYOND autoGC this when nothing is using it anymore.
	target?.weakref = null
	return ..()

/weakref/proc/resolve()
	var/datum/D = locate(ref)
	return (!QDELETED(D) && D.weakref == src) ? D : null

/weakref/get_log_info_line()
	return "[ref_name] ([ref_type]) ([ref]) (WEAKREF)"
