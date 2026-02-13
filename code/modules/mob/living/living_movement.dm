
/mob/living/Move(newloc, direct)
	if(buckled)
		return

	if(get_dist(src, pulling) > 1)
		stop_pulling()

	pull_sound = lying ? SFX_PULL_BODY : null

	. = ..()
	if(!.)
		return

	if(crawling)
		var/turf/L = get_turf(newloc)
		var/obj/structure/table/T = locate() in L.contents
		if(!istype(T))
			crawling = FALSE
			hiding = FALSE

	if(s_active && !((s_active in contents) || Adjacent(s_active)))
		s_active.close(src)

	if(update_metroids)
		for(var/mob/living/carbon/metroid/M in view(1, src))
			M.UpdateFeed()


/mob/living/proc/can_pull()
	if(!moving)
		return FALSE
	if(pulling.anchored)
		return FALSE
	if(!isturf(pulling.loc))
		return FALSE
	if(restrained())
		return FALSE

	if(get_dist(src, pulling) > 2)
		return FALSE

	if(pulling.z != z)
		if(pulling.z < z)
			return FALSE
		var/turf/T = GetAbove(src)
		if(!isopenspace(T))
			return FALSE
	return TRUE

/atom/movable/proc/handle_pulling_after_move(turf/target_turf)
	return FALSE // TODO: Use it somehow.

/mob/living/handle_pulling_after_move(turf/target_turf)
	if(!pulling)
		return FALSE

	if(!can_pull())
		stop_pulling()
		return FALSE

	if(!isliving(pulling))
		var/pull_dir = get_dir(pulling.loc, src)
		pulling.set_glide_size(glide_size)
		pulling.moving_from_pull = src
		pulling.Move(get_step(pulling.loc, pull_dir), pull_dir)
		step_glide(pulling, get_dir(pulling.loc, old_loc), glide_size)
		pulling.moving_from_pull = null
	else
		var/mob/living/M = pulling
		if(M.grabbed_by.len)
			if(prob(75))
				var/obj/item/grab/G = pick(M.grabbed_by)
				if(istype(G))
					M.visible_message(SPAN_WARNING("[G.affecting] has been pulled from [G.assailant]'s grip by [src]!"), SPAN_WARNING("[G.affecting] has been pulled from your grip by [src]!"))
					qdel(G)
		if(!M.grabbed_by.len)
			M.handle_pull_damage(src)

			var/atom/movable/t = M.pulling
			M.stop_pulling()
			step_glide(M, get_dir(pulling, target_turf), glide_size)
			if(t)
				M.start_pulling(t)

	//SEND_SIGNAL(src, SIGNAL_MOVED, src, old_loc, pulling.loc)

	handle_dir_after_pull()

	if(m_intent == M_RUN && pulling.pull_sound && (world.time - last_pull_sound) > 1 SECOND)
		last_pull_sound = world.time
		playsound(pulling, pulling.pull_sound, rand(50, 75), TRUE)

/mob/living/proc/handle_dir_after_pull()
	if(!pulling)
		return
	if(isobj(pulling))
		var/obj/O = pulling
		// Hacky check to know if you can pass through the closet
		if(istype(O, /obj/structure/closet) && !O.density)
			return set_dir(get_dir(src, pulling))
		if(O.pull_slowdown >= PULL_SLOWDOWN_MEDIUM)
			return set_dir(get_dir(src, pulling))
		else if(O.pull_slowdown == PULL_SLOWDOWN_WEIGHT && O.w_class >= ITEM_SIZE_HUGE)
			return set_dir(get_dir(src, pulling))
	if(isliving(pulling))
		var/mob/living/L = pulling
		// If pulled mob was bigger than us, we morelike will turn
		// I made additional check in case if someone want a hand walk
		if(L.mob_size > mob_size || L.lying)
			return set_dir(get_dir(src, pulling))

/mob/living/proc/handle_pull_damage(mob/living/puller)
	var/area/A = get_area(src)
	if(!A.has_gravity)
		return
	var/turf/location = get_turf(src)
	if(lying && prob(getBruteLoss() / 6))
		location.add_blood(src)
		if(prob(25))
			adjustBruteLoss(1)
			visible_message(SPAN("danger", "\The [src]'s [src.isSynthetic() ? "state worsens": "wounds open more"] from being dragged!"))
			. = TRUE
	if(pull_damage())
		if(prob(25))
			adjustBruteLoss(2)
			visible_message(SPAN("danger", "\The [src]'s [src.isSynthetic() ? "state worsens" : "wounds worsen"] terribly from being dragged!"))
			location.add_blood(src)
			if(ishuman(src))
				var/mob/living/carbon/human/H = src
				if(round(H.vessel.get_reagent_amount(/datum/reagent/blood)) > 0)
					H.vessel.remove_reagent(/datum/reagent/blood, 1)
			. = TRUE

/mob/living/proc/cannot_use_vents()
	if(mob_size > MOB_SMALL)
		return "You can't fit into that vent."
	return null

// Check if current mob can push other mob or swap with it
// - other - the other mob to be pushed/swapped with
// - are_swaping - TRUE if current mob is intenting to swap, FALSE for pushing
// - passive - TRUE if current mob isn't initiator of swap/push
// Returns TRUE/FALSE
/mob/living/proc/can_move_mob(mob/living/other, are_swapping, passive)
	ASSERT(other)
	ASSERT(src != other)

	if(!passive)
		return other.can_move_mob(src, are_swapping, TRUE)

	var/context_flags = 0
	if(are_swapping)
		context_flags = other.mob_swap_flags
	else
		context_flags = other.mob_push_flags

	if(!mob_bump_flag) //nothing defined, go wild
		return TRUE

	if(mob_bump_flag & context_flags)
		return TRUE

	return a_intent == I_HELP && other.a_intent == I_HELP

/mob/living/canface()
	if(stat)
		return 0
	return ..()

/mob/living/Bump(atom/A, yes)
	if(..())
		return
	if(now_pushing || !yes || !loc)
		return
	if(ismob(A))
		var/mob/M = A
		if(MobBump(M))
			return
	if(isObj(AM))
		var/obj/O = A
		if(ObjBump(O))
			return
	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		if(PushAM(AM))
			return

/mob/living/Bumped(atom/movable/AM)
	..()
	last_bumped = world.time

	spawn(0)
		if(!istype(AM, /mob/living/bot/mulebot))
			now_pushing = 1
		if (istype(AM, /mob/living))
			var/mob/living/tmob = AM

			for(var/mob/living/M in range(tmob, 1))
				if(LAZYLEN(tmob.pinned) ||  ((M.pulling == tmob && ( tmob.restrained() && !( M.restrained() ) && M.stat == 0)) || locate(/obj/item/grab, tmob.grabbed_by.len)) )
					if ( !(world.time % 5) )
						to_chat(src, "<span class='warning'>[tmob] is restrained, you cannot push past</span>")
					now_pushing = 0
					return
				if( tmob.pulling == M && ( M.restrained() && !( tmob.restrained() ) && tmob.stat == 0) )
					if ( !(world.time % 5) )
						to_chat(src, "<span class='warning'>[tmob] is restraining [M], you cannot push past</span>")
					now_pushing = 0
					return

			//Leaping mobs just land on the tile, no pushing, no anything.
			if(status_flags & LEAPING)
				forceMove(tmob.loc)
				status_flags &= ~LEAPING
				now_pushing = 0
				return

			if(can_swap_with(tmob)) // mutual brohugs all around!
				var/turf/oldloc = loc
				forceMove(tmob.loc)
				tmob.forceMove(oldloc)
				now_pushing = 0
				for(var/mob/living/carbon/metroid/metroid in view(1,tmob))
					if(metroid.Victim == tmob)
						metroid.UpdateFeed()
				return

			if(!can_move_mob(tmob, 0, 0))
				now_pushing = 0
				return
			if(src.restrained())
				now_pushing = 0
				return
			if(tmob.a_intent != I_HELP)
				if(istype(tmob, /mob/living/carbon/human) && (MUTATION_FAT in tmob.mutations))
					if(prob(40) && !(MUTATION_FAT in src.mutations))
						to_chat(src, "<span class='danger'>You fail to push [tmob]'s fat ass out of the way.</span>")
						now_pushing = 0
						return
				if(tmob.r_hand && istype(tmob.r_hand, /obj/item/shield/riot))
					if(prob(99))
						now_pushing = 0
						return
				if(tmob.l_hand && istype(tmob.l_hand, /obj/item/shield/riot))
					if(prob(99))
						now_pushing = 0
						return
			if(!(tmob.status_flags & CANPUSH))
				now_pushing = 0
				return
			tmob.LAssailant = weakref(src)

		if(isobj(AM) && !AM.anchored)
			var/obj/I = AM
			if(!can_pull_size || can_pull_size < I.w_class)
				to_chat(src, "<span class='warning'>It won't budge!</span>")
				now_pushing = 0
				return

		now_pushing = 0
		spawn(0)
			..()
			var/saved_dir = AM.dir

			if(!istype(AM, /atom/movable) || AM.anchored || AM.atom_flags & ATOM_FLAG_UNPUSHABLE)
				if(confused && prob(50) && m_intent == M_RUN && !lying)
					var/obj/machinery/disposal/D = AM

					if(istype(D) && !(D.stat & BROKEN))
						Weaken(6)
						playsound(AM, 'sound/effects/clang.ogg', 75)
						visible_message(SPAN_WARNING("[src] falls into \the [AM]!"), SPAN_WARNING("You fall into \the [AM]!"))

						if(client)
							client.perspective = EYE_PERSPECTIVE
							client.eye = src

						forceMove(AM)
					else
						Weaken(2)
						playsound(loc, SFX_FIGHTING_PUNCH, rand(80, 100), 1, -1)
						visible_message(SPAN_WARNING("[src] [pick("ran", "slammed")] into \the [AM]!"))

					src.apply_damage(5, BRUTE)
				return

			if(!now_pushing && !moving_diagonally)
				now_pushing = 1

				var/t = get_dir(src, AM)

				if(istype(AM, /obj/structure/window))
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return

				var/pulled_pushing = (AM.pulledby == src && pulling == AM)
				if(pulled_pushing)
					step_glide(AM, t, AM.glide_size)
				else
					step(AM, t)

				if(istype(AM, /mob/living))
					var/mob/living/tmob = AM
					if(istype(tmob.buckled, /obj/structure/bed))
						if(!tmob.buckled.anchored)
							step_glide(tmob.buckled, t, tmob.buckled.glide_size)

				if(ishuman(AM))
					var/mob/living/carbon/human/M = AM
					for(var/obj/item/grab/G in M.grabbed_by)
						step(G.assailant, get_dir(G.assailant, AM))
						G.adjust_position()

				if(saved_dir)
					AM.set_dir(saved_dir)

				if(pulled_pushing)
					step_glide(src, t, glide_size)
					if(pulling != AM)
						start_pulling(AM, TRUE)

				now_pushing = 0

	return TRUE

/proc/swap_density_check(mob/swapper, mob/swapee)
	var/turf/T = get_turf(swapper)
	if(T)
		if(T.density)
			return 1
		for(var/atom/movable/A in T)
			if(A == swapper)
				continue
			if(!A.CanPass(swapee, T, 1))
				return 1

/mob/living/proc/can_swap_with(mob/living/tmob)
	if(!tmob)
		return 0
	if(tmob.buckled || buckled || tmob.anchored)
		return 0
	//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
	if(!(tmob.mob_always_swap || (tmob.a_intent == I_HELP || tmob.restrained()) && (a_intent == I_HELP || src.restrained())))
		return 0
	if(!tmob.MayMove(src) || incapacitated())
		return 0

	if(swap_density_check(src, tmob))
		return 0

	if(swap_density_check(tmob, src))
		return 0

	return can_move_mob(tmob, 1, 0)
