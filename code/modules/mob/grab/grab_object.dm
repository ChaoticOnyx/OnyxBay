
/obj/item/grab
	name = "grab"
	canremove = FALSE
	force_drop = TRUE

	w_class = ITEM_SIZE_NO_CONTAINER
	throw_range = 3

	drop_sound = null
	pickup_sound = null

	/// Atom being targeted by this grab.
	var/atom/movable/affecting = null
	/// Mob that instantiated this grab.
	var/mob/assailant = null

	/// Current grab singletone, used to handle actions/overrides/etc.
	var/datum/grab/current_grab
	var/start_grab_name

	/// Tracks world.time of last action.
	var/last_action
	/// Tracks world.time of last upgrade.
	var/last_upgrade

	var/last_target
	var/special_target_functional = TRUE

	var/target_zone
	/// Used by struggle grab datum to keep track of state.
	var/done_struggle = FALSE
	/// Used to avoid stacking interactions that sleep during /datum/grab/proc/on_hit_foo() (ie. do_after() is used)
	var/is_currently_resolving_hit = FALSE

/obj/item/grab/Initialize(mapload, atom/movable/target, use_grab_state, defer_hand, use_pull_slot)
	. = ..(mapload)
	if(. == INITIALIZE_HINT_QDEL)
		return

	current_grab = GLOB.all_grabstates[use_grab_state]
	if(!istype(current_grab))
		return INITIALIZE_HINT_QDEL

	assailant = loc
	if(!istype(assailant) || !assailant.add_grab(src, defer_hand = defer_hand, use_pull_slot = use_pull_slot))
		return INITIALIZE_HINT_QDEL

	affecting = target
	if(!istype(affecting))
		return INITIALIZE_HINT_QDEL

	target_zone = check_zone(assailant.zone_sel?.selecting)

	var/mob/living/affecting_mob = get_affecting_mob()
	if(affecting_mob)
		affecting_mob.update_canmove(TRUE)
		if(ishuman(affecting_mob))
			var/mob/living/carbon/human/H = affecting_mob
			var/obj/item/uniform = H.get_equipped_item(slot_w_uniform_str)
			if(uniform)
				uniform.add_fingerprint(assailant)

	LAZYADD(affecting.grabbed_by, src) // This is how we handle affecting being deleted.
	adjust_position()
	action_used()
	INVOKE_ASYNC(assailant, nameof(/atom/movable.proc/do_attack_animation), affecting)
	playsound(affecting.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	update_icon()

	register_signal(affecting, nameof(.proc/on_affecting_move))
	if(assailant.zone_sel)
		register_signal(assailant.zone_sel, SIGNAL_MOB_ZONE_SELECTED, nameof(.proc/on_target_change))

	var/obj/item/organ/O = get_targeted_organ()
	var/datum/gender/G = gender_datums[assailant.gender]
	if(affecting_mob && O) // may have grabbed a buckled mob, so may be grabbing their holder
		SetName("[name] (\the [affecting_mob]'s [O.name])")
		register_signal(affecting_mob, SIGNAL_MOB_ORGAN_REMOVED, nameof(.proc/on_organ_loss))
		if(affecting_mob != assailant)
			visible_message(SPAN_DANGER("\The [assailant] has grabbed [affecting_mob]'s [O.name]!"))
		else
			visible_message(SPAN_NOTICE("\The [assailant] has grabbed [G.his] [O.name]!"))
	else
		if(affecting != assailant)
			visible_message(SPAN_DANGER("\The [assailant] has grabbed \the [affecting]!"))
		else
			visible_message(SPAN_NOTICE("\The [assailant] has grabbed [G.self]!"))

	add_think_ctx("handle_resist", CALLBACK(src, nameof(.proc/handle_resist)), 0)

	if(affecting_mob && assailant?.a_intent == I_HURT)
		upgrade(TRUE)

/obj/item/grab/can_be_unequipped_by(mob/M, disable_warning = 0)
	return M == assailant

/obj/item/grab/examine(mob/user, infix)
	. = ..()
	var/mob/M = get_affecting_mob()
	var/obj/item/O = get_targeted_organ()
	if(M && O)
		. += "A grip on \the [M]'s [O.name]."
	else
		. += "A grip on \the [affecting]."

/obj/item/grab/Process()
	current_grab.process(src)

/obj/item/grab/attack_self(mob/user)
	switch(assailant.a_intent)
		if(I_HELP)
			downgrade()
		else
			upgrade()

/obj/item/grab/attack(mob/living/M, mob/living/user, target_zone)
	pass()

/obj/item/grab/proc/can_absorb()
	return current_grab.can_absorb

/obj/item/grab/proc/force_stand()
	return current_grab.force_stand

/obj/item/grab/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(QDELETED(src) || !current_grab || !assailant || proximity_flag) // Close-range is handled in resolve_attackby().
		return
	if(current_grab.hit_with_grab(src, target, proximity_flag))
		return

	return ..()

/obj/item/grab/resolve_attackby(atom/A, mob/user, click_params)
	if(QDELETED(src) || !current_grab || !assailant)
		return TRUE

	if(A.grab_attack(src) || current_grab.hit_with_grab(src, A, get_dist(user, A) <= 1))
		return TRUE

	return ..()

/obj/item/grab/dropped()
	..()
	if(!QDELETED(src))
		qdel(src)

/obj/item/grab/can_be_dropped_by_client(mob/M)
	if(M == assailant)
		return TRUE

/obj/item/grab/Destroy()
	var/atom/old_affecting = affecting
	if(affecting)
		unregister_signal(affecting, SIGNAL_MOB_ORGAN_REMOVED)
		unregister_signal(affecting, SIGNAL_MOVED)
		LAZYREMOVE(affecting.grabbed_by, src)
		if(ismob(affecting))
			var/mob/M = affecting
			M.reset_layer()
		else
			affecting.reset_plane_and_layer()
		affecting = null
	if(assailant)
		unregister_signal(assailant?.zone_sel, SIGNAL_MOB_ZONE_SELECTED)
		if(assailant.pull_grab == src)
			assailant.pull_grab = null
			assailant.pullin?.icon_state = "pull0"
		assailant = null
	. = ..()
	if(old_affecting)
		//old_affecting.reset_offsets(5)
		if(ismob(old_affecting))
			var/mob/M = old_affecting
			M.reset_layer()
		else
			old_affecting.reset_plane_and_layer()

/*
	This section is for newly defined useful procs.
*/

/obj/item/grab/proc/on_target_change(old_sel, new_sel)
	if(src != assailant.get_active_item())
		return // Note that because of this condition, there's no guarantee that target_zone = old_sel
	if(target_zone == new_sel)
		return
	var/old_zone = target_zone
	target_zone = check_zone(new_sel, affecting)
	if(!istype(get_targeted_organ(), /obj/item/organ))
		current_grab.let_go(src)
		return
	current_grab.on_target_change(src, old_zone, new_sel)

/obj/item/grab/proc/on_organ_loss(mob/victim, obj/item/organ/lost)
	if(affecting != victim)
		util_crash_with("A grab switched affecting targets without properly re-registering for dismemberment updates.")
		return

	var/obj/item/organ/O = get_targeted_organ()
	if(!istype(O))
		current_grab.let_go(src)
		return // Sanity check in case the lost organ was improperly removed elsewhere in the code.

	if(lost != O)
		return

	current_grab.let_go(src)

/obj/item/grab/proc/on_affecting_move()
	if(!affecting || !isturf(affecting.loc) || get_dist(affecting, assailant) > 1)
		force_drop()

/obj/item/grab/proc/force_drop()
	assailant.drop(src)

/obj/item/grab/proc/get_affecting_mob()
	if(isobj(affecting))
		var/obj/O = affecting
		return O.buckled_mob
	if(isliving(affecting))
		return affecting

// Returns the organ of the grabbed person that the grabber is targeting
/obj/item/grab/proc/get_targeted_organ()
	var/mob/affecting_mob = get_affecting_mob()
	if(ishuman(affecting_mob))
		var/mob/living/carbon/human/H = affecting_mob
		return H.get_organ(check_zone(target_zone))

/obj/item/grab/proc/resolve_item_attack(mob/living/M, obj/item/I, target_zone)
	if(M && ishuman(M) && I)
		return current_grab.resolve_item_attack(src, M, I, target_zone)
	return 0

/obj/item/grab/proc/action_used()
	if(ishuman(assailant))
		var/mob/living/carbon/human/H = assailant
		H.remove_cloaking_source(H.species)
	last_action = world.time
	leave_forensic_traces()

/obj/item/grab/proc/check_action_cooldown()
	return (world.time >= last_action + current_grab.action_cooldown)

/obj/item/grab/proc/check_upgrade_cooldown()
	return (world.time >= last_upgrade + current_grab.upgrade_cooldown)

/obj/item/grab/proc/leave_forensic_traces()
	if(ishuman(affecting))
		var/mob/living/carbon/human/affecting_mob = affecting
		var/obj/item/clothing/C = affecting_mob.get_covering_equipped_item(check_zone(target_zone))
		C?.add_fingerprint(assailant)

/obj/item/grab/proc/upgrade(bypass_cooldown = FALSE)
	if(!check_upgrade_cooldown() && !bypass_cooldown)
		return

	var/datum/grab/upgrab = current_grab.upgrade(src)
	if(upgrab)
		current_grab = upgrab
		last_upgrade = world.time
		adjust_position()
		update_icon()
		leave_forensic_traces()
		current_grab.enter_as_up(src)

/obj/item/grab/proc/downgrade()
	var/datum/grab/downgrab = current_grab.downgrade(src)
	if(downgrab)
		current_grab = downgrab
		adjust_position()
		update_icon()

/obj/item/grab/on_update_icon()
	. = ..()
	if(current_grab.grab_icon)
		icon = current_grab.grab_icon
	if(current_grab.grab_icon_state)
		icon_state = current_grab.grab_icon_state

/obj/item/grab/proc/throw_held()
	return current_grab.throw_held(src)

/obj/item/grab/proc/handle_resist()
	current_grab.handle_resist(src)

/obj/item/grab/proc/adjust_position(force = 0)

	if(!QDELETED(assailant) && force)
		affecting.forceMove(assailant.loc)

	if(QDELETED(assailant) || QDELETED(affecting) || !assailant.AdjacentMultiz(affecting))
		qdel(src)
		return 0

	var/adir = get_dir(assailant, affecting)
	if(assailant)
		assailant.set_dir(adir)
	if(current_grab.same_tile)
		affecting.forceMove(get_turf(assailant))
		affecting.set_dir(assailant.dir)
	//affecting.reset_offsets(5)
	if(ismob(affecting))
		var/mob/M = affecting
		M.reset_layer()
	else
		affecting.reset_plane_and_layer()

/*
	This section is for the simple procs used to return things from current_grab.
*/
/obj/item/grab/proc/stop_move()
	return current_grab.stop_move

/obj/item/grab/attackby(obj/W, mob/user)
	if(user == assailant)
		current_grab.item_attack(src, W)

/obj/item/grab/proc/assailant_reverse_facing()
	return current_grab.reverse_facing

/obj/item/grab/proc/shield_assailant()
	return current_grab.shield_assailant

/obj/item/grab/proc/point_blank_mult()
	return current_grab.point_blank_mult

/obj/item/grab/proc/damage_stage()
	return current_grab.damage_stage

/obj/item/grab/proc/force_danger()
	return current_grab.force_danger

/obj/item/grab/proc/grab_slowdown()
	var/slowdown = 0
	if(isobj(affecting))
		var/obj/O = affecting
		if(O.pull_slowdown == PULL_SLOWDOWN_WEIGHT)
			slowdown += between(0, O.w_class, ITEM_SIZE_GARGANTUAN) / 5
		else
			slowdown += O.pull_slowdown
	else if(ismob(affecting))
		var/mob/M = affecting
		slowdown += max(0, M.mob_size) / MOB_MEDIUM * (M.lying ? 2 : 0.5)
	else
		slowdown += 1

	if(istype(src, /mob/living/))
		var/mob/living/L = src

		for(var/datum/modifier/M in L.modifiers)
			if(isnull(M.pull_slowdown_percent))
				continue

			slowdown *= M.pull_slowdown_percent

	return slowdown

/obj/item/grab/proc/assailant_moved()
	affecting.glide_size = assailant.glide_size // Note that this is called _after_ the Move() call resolves, so while it adjusts affecting's move animation, it won't adjust anything else depending on it.
	current_grab.assailant_moved(src)

/obj/item/grab/proc/restrains()
	return current_grab.restrains

/obj/item/grab/proc/resolve_openhand_attack()
	return current_grab.resolve_openhand_attack(src)
