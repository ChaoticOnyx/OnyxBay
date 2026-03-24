/mob/living
	is_poi = TRUE
	var/next_grab_resist = 0

/mob/living/Initialize()
	. = ..()
	if(is_ooc_dead())
		add_to_dead_mob_list()
	else
		add_to_living_mob_list()

	if(give_ghost_proc_at_initialize)
		verbs |= /mob/living/proc/ghost

	if(controllable)
		GLOB.available_mobs_for_possess["\ref[src]"] += src

	update_transform() // Some mobs may start bigger or smaller than normal.

/mob/living/get_description_fluff()
	if(flavor_text)
		return flavor_text

	return ..()

//mob verbs are faster than object verbs. See mob/verb/examine.
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(AM.Adjacent(src))
		src.start_pulling(AM)

	return

//mob verbs are faster than object verbs. See above.
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(incapacitated())
		return 0
	if(status_flags & FAKEDEATH)
		return 0
	if(!..())
		return 0

	//Borgs and AI have their own message
	if(!issilicon(src))
		usr.visible_message("<b>[src]</b> points to [A]")
	return 1

// Check if current mob can push other mob or swap with it
// - other - the other mob to be pushed/swapped with
// - are_swaping - TRUE if current mob is intenting to swap, FALSE for pushing
// - passive - TRUE if current mob isn't initiator of swap/push
// Returns TRUE/FALSE
/mob/living/proc/can_move_mob(mob/living/other, are_swapping, passive)
	ASSERT(other)
	ASSERT(src != other)

	if(LAZYLEN(other.pinned))
		return

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

/mob/living/Bump(atom/movable/AM, yes)
	. = ..()
	if(.) // We were thrown into something
		return

	if(!yes || now_pushing || QDELETED(src) || QDELETED(AM) || !loc || !AM.loc)
		return

	if(isliving(AM))
		var/mob/living/pushed_mob = AM

		// Leaping mobs just land on the tile, no pushing, no anything.
		if(status_flags & LEAPING)
			forceMove(pushed_mob.loc)
			status_flags &= ~LEAPING
			return

		// Checking for the pushed mob being restrained by somebody, or restraining somebody.
		for(var/mob/living/M in range(pushed_mob, 1))
			if((M.pulling == pushed_mob || LAZYISIN(pushed_mob.grabbed_by, M)) && pushed_mob.restrained() && !M.restrained() && !M.stat)
				if(!(world.time % 5))
					to_chat(src, SPAN("warning", "[pushed_mob] is restrained by [M], you cannot push past!"))
				return
			if((pushed_mob.pulling == M || LAZYISIN(M.grabbed_by, pushed_mob)) && M.restrained() && !pushed_mob.restrained() && !pushed_mob.stat)
				if(!(world.time % 5))
					to_chat(src, SPAN("warning", "[pushed_mob] is restraining [M], you cannot push past!"))
				return

		// Trying to swap positions.
		if(can_swap_with(pushed_mob))
			if(moving_diagonally)
				return
			now_pushing = TRUE
			var/turf/oldloc = loc
			forceMove(pushed_mob.loc)
			pushed_mob.forceMove(oldloc)
			now_pushing = FALSE
			// TODO: Handle latched metroids' movement with signals or something.
			for(var/mob/living/carbon/metroid/metroid in view(1, pushed_mob))
				if(metroid.Victim == pushed_mob)
					metroid.UpdateFeed()
			return

		// Checking if we can actually push the pushed mob.
		if(!can_move_mob(pushed_mob, FALSE, FALSE))
			return

		// Can't push people around while restrained.
		if(restrained())
			return

		// Additional prob() checks.
		if(pushed_mob.a_intent != I_HELP)
			// Pushing fat asses is difficult. TODO: Replace with fat bodybuild check.
			if(ishuman(pushed_mob) && (MUTATION_FAT in pushed_mob.mutations) && !(MUTATION_FAT in mutations) && prob(40))
				to_chat(src, SPAN("warning", "You fail to push [pushed_mob]'s fat ass out of the way."))
				return

			// Pushing riot shields is even more difficult.
			if((istype(pushed_mob.r_hand, /obj/item/shield/riot) || istype(pushed_mob.l_hand, /obj/item/shield/riot)) && prob(99))
				return

		// Can't push the unpushable.
		if(!(pushed_mob.status_flags & CANPUSH))
			return

		// TODO: Check if we actually need this thing.
		if(!iscarbon(src))
			pushed_mob.LAssailant = null
		else
			pushed_mob.LAssailant = weakref(src)

	// Checking if the object is too big for us to move.
	if(isobj(AM) && !AM.anchored)
		var/obj/pushed_obj = AM
		if(can_pull_size < pushed_obj.w_class)
			to_chat(src, SPAN("warning", "\The [pushed_obj] won't budge!"))
			return

	// Running into things.
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

	// No
	if(moving_diagonally)
		return

	var/saved_dir = AM.dir
	var/push_dir = get_dir(src, AM)

	// Can't push identical "bordered" windows into each other.
	if(istype(AM, /obj/structure/window))
		var/obj/structure/window/pushed_window = AM
		for(var/obj/structure/window/obstacle_window in get_step(AM, push_dir))
			if(pushed_window.dir == obstacle_window.dir)
				return

	// Pushing currently-pulled atoms causes them to be moved smoothly, without interrupting pulls.
	now_pushing = TRUE
	var/pulled_pushing = (AM.pulledby == src && pulling == AM)
	if(pulled_pushing)
		step_glide(AM, push_dir, AM.glide_size)
	else
		step(AM, push_dir)

	if(isliving(AM))
		// Moving chairs, beds, etc. along with the pushed mob.
		var/mob/living/pushed_mob = AM
		if(istype(pushed_mob.buckled, /obj/structure/bed))
			if(!pushed_mob.buckled.anchored)
				step_glide(pushed_mob.buckled, push_dir, pushed_mob.buckled.glide_size)

		// Grabby stuff. TODO: Find out what the fuck.
		if(ishuman(AM))
			var/mob/living/carbon/human/pushed_human = AM
			for(var/obj/item/grab/G in pushed_human.grabbed_by)
				step(G.assailant, get_dir(G.assailant, pushed_human))
				G.adjust_position()

	// Reassigning the direction.
	if(saved_dir)
		AM.set_dir(saved_dir)

	// Moving along the pull-pushed atom, and re-pulling it, unless it's on a different Z-level now.
	if(pulled_pushing && AM.z == z)
		step_glide(src, push_dir, glide_size)
		if(pulling != AM)
			start_pulling(AM, TRUE)

	now_pushing = FALSE
	return

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

/mob/living/proc/update_health()
	if(status_flags & GODMODE)
		health = 100
		set_stat(CONSCIOUS)
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - getHalLoss()

//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	take_overall_damage(0, burn_amount)

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		log_debug("[src] ~ [src.bodytemperature] ~ [temperature]")

	return temperature


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)

/mob/living/proc/getBruteLoss()
	return maxHealth - health

/mob/living/proc/adjustBruteLoss(amount)
	if(status_flags & GODMODE)
		return 0
	health = Clamp(health-amount, 0, maxHealth)

/mob/living/proc/getOxyLoss()
	return 0

/mob/living/proc/adjustOxyLoss(amount)
	return

/mob/living/proc/setOxyLoss(amount)
	return

/mob/living/proc/getToxLoss()
	return 0

/mob/living/proc/adjustToxPercent(amount)
	if(status_flags & GODMODE)
		return 0
	adjustToxLoss(amount)

/mob/living/proc/adjustToxLoss(amount)
	if(status_flags & GODMODE)
		return 0
	adjustBruteLoss(amount * 0.5)

/mob/living/proc/setToxLoss(amount)
	adjustBruteLoss((amount * 0.5)-getBruteLoss())

/mob/living/proc/getFireLoss()
	return

/mob/living/proc/adjustFireLoss(amount)
	if(status_flags & GODMODE)
		return 0
	adjustBruteLoss(amount * 0.5)

/mob/living/proc/setFireLoss(amount)
	adjustBruteLoss((amount * 0.5)-getBruteLoss())

/mob/living/proc/getHalLoss()
	return 0

/mob/living/proc/adjustHalLoss(amount)
	if(status_flags & GODMODE)
		return 0
	adjustBruteLoss(amount * 0.5)

/mob/living/proc/setHalLoss(amount)
	adjustBruteLoss((amount * 0.5)-getBruteLoss())

/mob/living/proc/getBrainLoss()
	return 0

/mob/living/proc/adjustBrainLoss(amount)
	return

/mob/living/proc/setBrainLoss(amount)
	return

/mob/living/proc/getCloneLoss()
	return 0

/mob/living/proc/setCloneLoss(amount)
	return

/mob/living/proc/adjustCloneLoss(amount)
	return

/mob/living/proc/getInternalLoss()
	return 0

/mob/living/proc/setInternalLoss(amount)
	return

/mob/living/proc/adjustInternalLoss(amount)
	return

/mob/living/proc/getMaxHealth()
	var/result = maxHealth
	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.max_health_flat))
			result += M.max_health_flat
	// Second loop is so we can get all the flat adjustments first before multiplying, otherwise the result will be different.
	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.max_health_percent))
			result *= M.max_health_percent
	return result

/mob/living/proc/setMaxHealth(newMaxHealth)
	maxHealth = newMaxHealth

// ++++ROCKDTBEN++++ MOB PROCS //END

/mob/proc/get_contents()
	return

//Recursive function to find everything a mob is holding.
/mob/living/get_contents(obj/item/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += src.contents
		for(var/obj/item/organ/E in contents)
			L += E.get_contents()
		for(var/obj/item/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)

		for(var/obj/item/gift/G in src.contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in src.contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0

/mob/living/proc/can_inject(mob/user, target_zone)
	return 1

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter:zone_sel.selecting
	if ((t in list( BP_EYES, BP_MOUTH )))
		t = BP_HEAD
	var/obj/item/organ/external/def_zone = ran_zone(t)
	return def_zone


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(brute, burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.update_health()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(brute, burn, emp=0)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.update_health()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(brute, burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.update_health()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(brute, burn, damage_flags = 0, used_weapon = null, spread_damage = TRUE, check_armor = null)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.update_health()

/mob/living/proc/restore_all_organs(ignore_prosthetic_prefs = FALSE)
	return

/mob/living/update_gravity(has_gravity)
	if(has_gravity)
		stop_floating()
	else
		start_floating()

/mob/living/proc/revive(ignore_prosthetic_prefs = FALSE)
	rejuvenate(ignore_prosthetic_prefs)
	if(buckled)
		buckled.unbuckle_mob()
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if(C.handcuffed && !initial(C.handcuffed))
			C.drop(C.handcuffed, force = TRUE)
		C.handcuffed = initial(C.handcuffed)
	BITSET(hud_updateflag, HEALTH_HUD)
	BITSET(hud_updateflag, STATUS_HUD)
	BITSET(hud_updateflag, LIFE_HUD)
	ExtinguishMob()
	fire_stacks = 0

/mob/living/proc/rejuvenate(ignore_prosthetic_prefs = FALSE)
	if(reagents)
		reagents.clear_reagents()

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setInternalLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)

	// shut down ongoing problems
	radiation = SPACE_RADIATION
	bodytemperature = 20 CELSIUS
	sdisabilities = 0
	disabilities = 0

	// fix blindness and deafness
	blinded = 0
	eye_blind = 0
	eye_blurry = 0
	ear_deaf = 0
	ear_damage = 0
	heal_overall_damage(getBruteLoss(), getFireLoss())

	// fix all of our organs
	restore_all_organs(ignore_prosthetic_prefs)

	// remove the character from the list of the dead
	if(is_ooc_dead())
		switch_from_dead_to_living_mob_list()
		timeofdeath = 0

	// restore us to conciousness
	set_stat(CONSCIOUS)

	// finally update health to make everything work correctly
	update_health()

	// make the icons look correct
	regenerate_icons()

	BITSET(hud_updateflag, HEALTH_HUD)
	BITSET(hud_updateflag, STATUS_HUD)
	BITSET(hud_updateflag, LIFE_HUD)

	failed_last_breath = 0 //So mobs that died of oxyloss don't revive and have perpetual out of breath.
	reload_fullscreen()
	return

/mob/living/proc/update_damage_overlays()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.character_setup.allow_metadata)
		if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")

	return

/mob/living/Move(newloc, direct)
	if(buckled)
		return

	if(get_dist(src, pulling) > 1)
		stop_pulling()

	var/turf/oldloc = get_turf(src)

	pull_sound = lying ? SFX_PULL_BODY : null

	. = ..()
	if(!.)
		return

	if(pulling)
		var/pull_dir = get_dir(pulling, src)
		if(get_dist(src, pulling) > 1 || (moving_diagonally != /atom/movable::SECOND_DIAGONAL_STEP && ISDIAGONALDIR(pull_dir)))
			handle_pulling_after_move(oldloc)

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

/mob/living/proc/handle_pulling_after_move(turf/target_turf)
	if(!pulling)
		return

	if(!can_pull())
		stop_pulling()
		return

	if(pulling.loc == loc || pulling.loc == target_turf)
		return

	if(!isliving(pulling))
		step_glide(pulling, get_dir(pulling.loc, target_turf), glide_size)
	else
		var/mob/living/M = pulling
		if(M.grabbed_by.len)
			if(prob(75))
				var/obj/item/grab/G = pick(M.grabbed_by)
				if(istype(G))
					M.visible_message(SPAN_WARNING("[G.affecting] has been pulled from [G.assailant]'s grip by [src]!"),\
									  SPAN_WARNING("[G.affecting] has been pulled from your grip by [src]!"))
					qdel(G)
		if(!M.grabbed_by.len)
			M.handle_pull_damage(src)

			var/atom/movable/t = M.pulling
			M.stop_pulling()
			step_glide(M, get_dir(pulling.loc, target_turf), glide_size)
			if(t)
				M.start_pulling(t)

	SEND_SIGNAL(src, SIGNAL_MOVED, src, target_turf, pulling.loc)

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
	if(!has_gravity())
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

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!incapacitated(INCAPACITATION_KNOCKOUT) && canClick())
		setClickCooldown(20)
		resist_grab("manual_verb")
		if(!weakened)
			process_resist()

/mob/living/proc/process_resist()

	SEND_SIGNAL(src, SIGNAL_MOB_RESIST, src)
	//Getting out of someone's inventory.
	if(istype(src.loc, /obj/item/holder))
		escape_inventory(src.loc)
		return

	//unbuckling yourself
	if(buckled)
		spawn() escape_buckle()
		return TRUE

	//Breaking out of a locker?
	if(src.loc && (istype(src.loc, /obj/structure/closet)) )
		var/obj/structure/closet/closet = loc
		spawn() closet.mob_breakout(src)
		return TRUE

	//Trying to escape from Spider?
	if(src.loc && (istype(src.loc, /obj/structure/spider/cocoon)))
		var/obj/structure/spider/cocoon/cocoon = loc
		spawn() cocoon.mob_breakout(src)
		return TRUE

/mob/living/proc/escape_inventory(obj/item/holder/H)
	if(H != src.loc) return

	var/mob/M = H.loc //Get our mob holder (if any).

	if(istype(M))
		M.drop(H)
		to_chat(M, "<span class='warning'>\The [H] wriggles out of your grip!</span>")
		to_chat(src, "<span class='warning'>You wriggle out of \the [M]'s grip!</span>")

		// Update whether or not this mob needs to pass emotes to contents.
		for(var/atom/A in M.contents)
			if(istype(A,/mob/living/simple_animal/borer) || istype(A,/obj/item/holder))
				return
		M.status_flags &= ~PASSEMOTES
	else if(istype(H.loc,/obj/item/clothing/accessory/holster))
		var/obj/item/clothing/accessory/holster/holster = H.loc
		if(holster.holstered == H)
			holster.clear_holster()
		to_chat(src, "<span class='warning'>You extricate yourself from \the [holster].</span>")
		H.forceMove(get_turf(H))
	else if(istype(H.loc,/obj))
		to_chat(src, "<span class='warning'>You struggle free of \the [H.loc].</span>")
		H.forceMove(get_turf(H))

	if(loc != H)
		qdel(H)

/mob/living/proc/escape_buckle()
	if(buckled)
		if(buckled.can_buckle)
			buckled.user_unbuckle_mob(src)
		else
			to_chat(usr, "<span class='warning'>You can't seem to escape from \the [buckled]!</span>")
			return

/mob/living/proc/resist_grab(origin = "unknown")
	if(try_grab_resist(origin))
		visible_message("<span class='danger'>[src] resists!</span>")

/mob/living/proc/try_grab_resist(origin = "unknown")
	if(world.time < next_grab_resist)
		return FALSE

	if(!length(grabbed_by))
		return FALSE

	var/resisting = FALSE
	for(var/obj/item/grab/G in grabbed_by.Copy())
		if(QDELETED(G) || G.affecting != src || !G.current_grab)
			continue
		resisting = TRUE
		G.current_grab.handle_resist(G)

	if(resisting)
		next_grab_resist = world.time + GRAB_RESIST_CD

	return resisting

/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	if(!incapacitated(INCAPACITATION_KNOCKOUT) && canClick())
		setClickCooldown(3)
		set_resting(!resting)
		to_chat(src, SPAN("notice", "You are now [resting ? "resting" : "getting up"]."))

//called when the mob receives a bright flash
/mob/living/flash_eyes(intensity = FLASH_PROTECTION_MODERATE, override_blindness_check = FALSE, affect_silicon = FALSE, visual = FALSE, type = /atom/movable/screen/fullscreen/flash, effect_duration = 25)
	if(override_blindness_check || !(disabilities & BLIND))
		overlay_fullscreen("flash", type)
		spawn(effect_duration)
			if(src)
				clear_fullscreen("flash", 25)
		return 1

/mob/living/proc/cannot_use_vents()
	if(mob_size > MOB_SMALL)
		return "You can't fit into that vent."
	return null

/mob/living/proc/has_brain()
	return 1

/mob/living/proc/has_eyes()
	return 1

/mob/living/proc/slip(slipped_on, stun_duration = 8)
	return 0

/mob/living/proc/slip_on_obj(/obj/slipped_on, stun_duration = 8, slip_dist = 0)
	return 0

/mob/living/carbon/drop(obj/item/W, atom/Target = null, force = null, changing_slots)
	if(W in internal_organs)
		return
	. = ..()

//damage/heal the mob ears and adjust the deaf amount
/mob/living/adjustEarDamage(damage, deaf)
	ear_damage = max(0, ear_damage + damage)
	ear_deaf = max(0, ear_deaf + deaf)

//pass a negative argument to skip one of the variable
/mob/living/setEarDamage(damage = null, deaf = null)
	if(!isnull(damage))
		ear_damage = damage
	if(!isnull(deaf))
		ear_deaf = deaf

/mob/proc/can_be_possessed_by(mob/observer/ghost/possessor)
	return istype(possessor) && possessor.client

/mob/living/can_be_possessed_by(mob/observer/ghost/possessor)
	if(!..())
		return 0
	if(!possession_candidate)
		to_chat(possessor, "<span class='warning'>That animal cannot be possessed.</span>")
		return 0
	if(jobban_isbanned(possessor, "Animal"))
		to_chat(possessor, "<span class='warning'>You are banned from animal roles.</span>")
		return 0
	if(!possessor.MayRespawn(1,ANIMAL_SPAWN_DELAY))
		return 0
	return 1

/mob/living/proc/do_possession(mob/observer/ghost/possessor)

	if(!(istype(possessor) && possessor.ckey))
		return 0

	if(src.ckey || src.client)
		to_chat(possessor, "<span class='warning'>\The [src] already has a player.</span>")
		return 0

	message_admins("<span class='adminnotice'>[key_name_admin(possessor)] has taken control of \the [src].</span>")
	log_admin("[key_name(possessor)] took control of \the [src].")
	src.ckey = possessor.ckey
	qdel(possessor)

	if(round_is_spooky(6)) // Six or more active cultists.
		to_chat(src, "<span class='notice'>You reach out with tendrils of ectoplasm and invade the mind of \the [src]...</span>")
		to_chat(src, "<b>You have assumed direct control of \the [src].</b>")
		to_chat(src, "<span class='notice'>Due to the spookiness of the round, you have taken control of the poor animal as an invading, possessing spirit - roleplay accordingly.</span>")
		src.universal_speak = 1
		src.universal_understand = 1
		//src.cultify() // Maybe another time.
		return

	to_chat(src, "<b>You are now \the [src]!</b>")
	to_chat(src, "<span class='notice'>Remember to stay in character for a mob of this type!</span>")
	if("\ref[src]" in GLOB.available_mobs_for_possess)
		GLOB.available_mobs_for_possess -= "\ref[src]"
	return 1

/mob/living/reset_layer()
	if(hiding)
		layer = HIDING_MOB_LAYER
	else
		..()

/mob/living/update_height_offset()
	if(hiding)
		return
	else
		..()

/mob/living/update_icons()
	if(auras)
		AddOverlays(auras)

/mob/living/proc/add_aura(obj/aura/aura)
	LAZYDISTINCTADD(auras,aura)
	update_icons()
	return 1

/mob/living/proc/remove_aura(obj/aura/aura)
	LAZYREMOVE(auras,aura)
	update_icons()
	return 1

/mob/living/Destroy()
	if(auras)
		for(var/a in auras)
			remove_aura(a)
	if(mind)
		mind.set_current(null)
	QDEL_NULL(aiming)
	if(controllable)
		controllable = FALSE
		GLOB.available_mobs_for_possess -= "\ref[src]"
	return ..()

/mob/proc/set_m_intent(intent)
	if(intent != M_WALK && intent != M_RUN)
		return FALSE

	m_intent = intent

	update_move_intent_slowdown()

	if(hud_used)
		if(hud_used.move_intent)
			hud_used.move_intent.icon_state = (intent == M_WALK ? "walking" : "running")

/mob/living/proc/melee_accuracy_mods()
	. = 0
	if(eye_blind)
		. += 75
	if(eye_blurry)
		. += 15
	if(confused)
		. += 30
	if(MUTATION_CLUMSY in mutations)
		. += 40

/mob/living/proc/ranged_accuracy_mods()
	. = 0
	if(jitteriness)
		. -= 2
	if(confused)
		. -= 2
	if(eye_blind)
		. -= 5
	if(eye_blurry)
		. -= 1
	if(MUTATION_CLUMSY in mutations)
		. -= 3

/mob/living/proc/nervous_system_failure()
	return FALSE

/mob/living/proc/needs_wheelchair()
	return FALSE

/mob/living/proc/seizure()
	set waitfor = 0
	sleep(rand(5,10))
	if(!paralysis && stat == CONSCIOUS)
		visible_message("<span class='warning'>\The [src] starts having a seizure!</span>")
		Paralyse(rand(8,16))
		make_jittery(rand(150,200))
		adjustHalLoss(rand(50,60))

/mob/living/proc/on_ghost_possess()
	return

/mob/living/set_stat(new_stat)
	var/old_stat = stat
	. = ..()
	if(stat != old_stat)
		SEND_SIGNAL(src, SIGNAL_STAT_SET, src, old_stat, new_stat)
