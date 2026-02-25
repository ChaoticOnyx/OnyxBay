
GLOBAL_DATUM_INIT(dview_mob, /mob/dview, new)
/mob/dview
	invisibility = 101
	density = 0

	anchored = 1
	simulated = 0

	see_in_dark = 1e6

	virtual_mob = null

/mob/dview/Initialize()
	. = ..()
	// We don't want to be in any mob lists; we're a dummy not a mob.
	STOP_PROCESSING(SSmobs, src)

/mob/dview/Destroy(force = FALSE)
	SHOULD_CALL_PARENT(FALSE)
	if(!force)
		util_crash_with("Prevented attempt to delete dview mob: [log_info_line(src)]")
		return QDEL_HINT_LETMELIVE // Prevents destruction

	util_crash_with("Dview was force-qdeleted, this should never happen: [log_info_line(src)]")

	GLOB.dview_mob = new /mob/dview
	return QDEL_HINT_QUEUE
