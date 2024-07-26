/mob/can_be_grabbed(mob/grabber, target_zone)
	if(!grabber.can_pull_mobs)
		to_chat(grabber, SPAN_WARNING("\The [src] won't budge!"))
		return FALSE
	. = ..() && !buckled
	if(.)
		if((grabber.mob_size < grabber.mob_size) && grabber.can_pull_mobs != MOB_PULL_LARGER)
			to_chat(grabber, SPAN_WARNING("You are too small to move \the [src]!"))
			return FALSE
		if((grabber.mob_size == mob_size) && grabber.can_pull_mobs == MOB_PULL_SMALLER)
			to_chat(grabber, SPAN_WARNING("\The [src] is too large for you to move!"))
			return FALSE
		if(isliving(grabber))
			last_handled_by_mob = weakref(grabber)


/mob/proc/handle_grabs_after_move(turf/old_loc, direction)
	set waitfor = FALSE

/mob/proc/add_grab(obj/item/grab/grab, defer_hand = FALSE, use_pull_slot = FALSE)
	return FALSE

/mob/proc/ProcessGrabs()
	return

/mob/proc/get_active_grabs()
	. = list()
	for(var/obj/item/grab/grab in contents)
		. += grab

/mob/get_object_size()
	return mob_size
