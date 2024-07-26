/mob/living/proc/check_grab_hand(defer_hand)
	if(defer_hand)
		if(l_hand && r_hand)
			to_chat(src, SPAN_WARNING("Your hands are full!"))
			return FALSE

	else if(get_active_hand())
		to_chat(src, SPAN_WARNING("Your [hand ? "left hand" : "right hand"] is full!"))
		return FALSE

	return TRUE

/mob/living/proc/can_grab(atom/movable/target, target_zone, defer_hand = FALSE)
	if(!ismob(target) && target.anchored)
		to_chat(src, SPAN_WARNING("\The [target] won't budge!"))
		return FALSE

	if(!check_grab_hand(defer_hand))
		return FALSE

	if(LAZYLEN(grabbed_by))
		to_chat(src, SPAN_WARNING("You cannot start grappling while already being grappled!"))
		return FALSE

	for(var/obj/item/grab/G in target.grabbed_by)
		if(G.assailant != src)
			continue

		if(!target_zone || !ismob(target))
			to_chat(src, SPAN_WARNING("You already have a grip on \the [target]!"))
			return FALSE

		if(G.target_zone == target_zone)
			var/obj/O = G.get_targeted_organ()
			if(O)
				to_chat(src, SPAN_WARNING("You already have a grip on \the [target]'s [O.name]."))
				return FALSE

	return TRUE

/mob/living/proc/make_grab(atom/movable/target, grab_tag = /datum/grab/simple, defer_hand = FALSE, force_grab_tag = FALSE, use_pull_slot = FALSE)
	// Resolve to the 'topmost' atom in the buckle chain, as grabbing someone buckled to something tends to prevent further interaction.
	var/atom/movable/original_target = target
	var/mob/grabbing_mob = (ismob(target) && target)
	while(istype(grabbing_mob) && grabbing_mob.buckled)
		grabbing_mob = grabbing_mob.buckled
	if(grabbing_mob && grabbing_mob != original_target)
		target = grabbing_mob
		to_chat(src, SPAN_WARNING("As \the [original_target] is buckled to \the [target], you try to grab that instead!"))

	if(!istype(target))
		return

	if(!force_grab_tag)
		var/datum/species/my_species = all_species[get_species()]
		if(my_species?.grab_type)
			grab_tag = my_species.grab_type

	face_atom(target)
	var/obj/item/grab/grab
	if(ispath(grab_tag, /datum/grab) && can_grab(target, check_zone(zone_sel?.selecting), defer_hand = defer_hand) && target.can_be_grabbed(src, check_zone(zone_sel?.selecting), defer_hand))
		grab = new /obj/item/grab(src, target, grab_tag, defer_hand, use_pull_slot)

	if(QDELETED(grab))
		if(original_target != src && ismob(original_target))
			to_chat(original_target, SPAN_WARNING("\The [src] tries to grab you, but fails!"))
		to_chat(src, SPAN_WARNING("You try to grab \the [target], but fail!"))
	return grab

/mob/living/add_grab(obj/item/grab/grab, defer_hand = FALSE, use_pull_slot = FALSE)
	for(var/obj/item/grab/other_grab in contents)
		if(other_grab != grab)
			return FALSE

	grab.forceMove(src)
	pull_grab = grab
	pullin?.icon_state = "pull1"
	return TRUE

/mob/living/ProcessGrabs()
	if(LAZYLEN(grabbed_by))
		resist()

/mob/living/give_control_grab(mob/living/M)
	return (isliving(M) && M == buckled_mob) ? M.make_grab(src, /datum/grab/simple/control, force_grab_tag = TRUE) : ..()

/mob/living/handle_grabs_after_move(turf/old_loc, direction)
	..()
	if(!isturf(loc))
		for(var/G in get_active_grabs())
			qdel(G)
		return

	if(isturf(old_loc))
		for(var/atom/movable/AM as anything in ret_grab())
			if(AM != src && AM.loc != loc && !AM.anchored && old_loc.Adjacent(AM))
				if(get_z(AM) <= get_z(src))
					if(ismob(AM))
						AM.DoMove(get_dir(get_turf(AM), old_loc), src, TRUE)
					else
						step_glide(AM, get_dir(get_turf(AM), old_loc), glide_size)
				else // Hackfix for eternal bump due to grabber moving down through an openturf.
					AM.dropInto(get_turf(src))

	var/list/mygrabs = get_active_grabs()
	for(var/obj/item/grab/G as anything in mygrabs)
		if(G.assailant_reverse_facing())
			set_dir(GLOB.flip_dir[direction])
		G.assailant_moved()
		if(QDELETED(G) || QDELETED(G.affecting))
			mygrabs -= G

	if(length(grabbed_by))
		for(var/obj/item/grab/G as anything in grabbed_by)
			G.adjust_position()
		update_offsets()
		reset_layer()

	if(!length(mygrabs))
		return

	if(direction & (UP|DOWN))
		var/txt_dir = (direction & UP) ? "upwards" : "downwards"
		if(old_loc)
			old_loc.visible_message(SPAN_NOTICE("\The [src] moves [txt_dir]."))
		for(var/obj/item/grab/G as anything in mygrabs)
			var/turf/start = G.affecting.loc
			var/turf/destination = (direction == UP) ? GetAbove(G.affecting) : GetBelow(G.affecting)
			if(!start.CanZPass(G.affecting, direction))
				to_chat(src, SPAN_WARNING("\The [start] blocked your pulled object!"))
				mygrabs -= G
				qdel(G)
				continue

			for(var/atom/A in destination)
				if(!A.CanMoveOnto(G.affecting, start, 1.5, direction))
					to_chat(src, SPAN_WARNING("\The [A] blocks the [G.affecting] you were pulling."))
					mygrabs -= G
					qdel(G)
					continue

			G.affecting.forceMove(destination)
			if(QDELETED(G) || QDELETED(G.affecting))
				mygrabs -= G
			continue

	for(var/obj/item/grab/grab as anything in mygrabs)
		var/mob/living/affecting_mob = grab.get_affecting_mob()
		if(affecting_mob)
			affecting_mob.handle_grab_damage()

		if(m_intent == M_RUN && grab.affecting?.pull_sound && (world.time - last_pull_sound) > 1 SECOND)
			last_pull_sound = world.time
			playsound(grab.affecting, grab.affecting?.pull_sound, rand(50, 75), TRUE)
