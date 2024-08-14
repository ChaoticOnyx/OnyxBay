/mob/observer/ghost/player
	movement_handlers = list(
		/datum/movement_handler/mob/space,
		/datum/movement_handler/mob/delay,
		/datum/movement_handler/mob/incorporeal
	)
	/// For pedalique override.
	var/may_respawn = FALSE

/mob/observer/ghost/player/can_hear_radio(list/hearturfs)
	return get_turf(src) in hearturfs

/mob/observer/ghost/player/MayEnterTurf(turf/T)
	return T && !((mob_flags & MOB_FLAG_HOLY_BAD) && check_is_holy_turf(T)) && !turf_contains_dense_objects(T)

/mob/observer/ghost/player/DblClickOn(atom/A, params)
	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A))
			reenter_corpse()
			return

	if(ismob(A) && get_dist(src, A) <= 2)
		ManualFollow(A)

	if(isatom(A) && Adjacent(A, src))
		ManualFollow(A)

/mob/observer/ghost/player/respawn()
	if(!may_respawn)
		return

	return ..()
