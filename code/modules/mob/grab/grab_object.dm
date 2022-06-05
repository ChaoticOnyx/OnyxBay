
/obj/item/grab
	name = "grab"
	canremove = FALSE
	force_drop = TRUE

	var/mob/living/carbon/human/affecting = null
	var/mob/living/carbon/human/assailant = null

	var/datum/grab/current_grab
	var/type_name
	var/start_grab_name

	var/last_action
	var/last_upgrade

	var/last_target
	var/special_target_functional = 1

	var/attacking = 0
	var/target_zone
	var/done_struggle = FALSE // Used by struggle grab datum to keep track of state.

	w_class = ITEM_SIZE_NO_CONTAINER
	throw_range = 3
/*
	This section is for overrides of existing procs.
*/
/obj/item/grab/New(mob/living/carbon/human/attacker, mob/living/carbon/human/victim)
	..()

	assailant = attacker
	affecting = victim
	target_zone = attacker.zone_sel.selecting
	var/obj/item/O = get_targeted_organ()

	SetName("[name] ([O.name])")

	if(start_grab_name)
		current_grab = all_grabstates[start_grab_name]

/obj/item/grab/_examine_text(user)
	. = ..()
	var/obj/item/O = get_targeted_organ()
	. += "\nA grab on \the [affecting]'s [O.name]."

/obj/item/grab/Process()
	current_grab.process(src)

/obj/item/grab/attack_self(mob/user)
	if(!assailant || !affecting)
		return
	if(!assailant.canClick())
		return
	switch(assailant.a_intent)
		if(I_HELP)
			downgrade()
		else
			upgrade()

/obj/item/grab/attack(mob/M, mob/living/user)
	current_grab.hit_with_grab(src)

/obj/item/grab/dropped()
	..()
	delete_self()

/obj/item/grab/proc/delete_self()
	if(!QDELING(src))
		qdel(src)

/obj/item/grab/can_be_dropped_by_client(mob/M)
	return M == assailant

/obj/item/grab/Destroy()
	if(affecting)
		reset_position()
		affecting.grabbed_by -= src
		affecting.reset_plane_and_layer()
		affecting = null
	if(assailant)
		assailant.u_equip(src)
		assailant.client?.screen -= src
		assailant = null
		loc = null
	return ..()

/*
	This section is for newly defined useful procs.
*/
/obj/item/grab/proc/target_change()
	if(!assailant)
		return
	var/hit_zone = assailant.zone_sel.selecting
	if(src != assailant.get_active_hand())
		return 0
	if(hit_zone && hit_zone != last_target)
		last_target = hit_zone
		special_target_functional = current_grab.check_special_target(src)
		return hit_zone
	else
		return 0

/obj/item/grab/proc/is_eligible()
	// can't grab non-carbon/human/'s
	if(!istype(affecting))
		return FALSE

	if(assailant.anchored || affecting.anchored)
		return FALSE

	if(!assailant.Adjacent(affecting))
		return FALSE

	if(assailant.buckled || affecting.buckled)
		return FALSE

	var/obj/item/organ/external/O = get_targeted_organ()
	if(!O)
		to_chat(assailant, SPAN("warning", "[affecting] is missing the body part you were grabbing!"))
		return FALSE

	return TRUE

/obj/item/grab/proc/can_grab()
	if(!is_eligible())
		return FALSE

	if(length(affecting.grabbed_by))
		to_chat(assailant, SPAN("notice", "Someone already grabbed [affecting]!"))
		return FALSE

	for(var/obj/item/grab/G in affecting.grabbed_by)
		if(G.assailant == assailant && G.target_zone == target_zone)
			var/obj/O = G.get_targeted_organ()
			to_chat(assailant, SPAN("notice", "You already grabbed [affecting]'s [O.name]."))
			return FALSE

	return TRUE

// This is for all the sorts of things that need to be checked for pretty much every
// grab made. Feel free to override it but it stops a lot of situations that could
// cause runtimes so be careful with it.
/obj/item/grab/proc/pre_check()

	if(!assailant || !affecting)
		return 0

	if(assailant.lying)
		return 0

	if(assailant == affecting)
		to_chat(assailant, "<span class='notice'>You can't grab yourself.</span>")
		return 0

	if(assailant.get_active_hand())
		to_chat(assailant, "<span class='notice'>You can't grab someone if your hand is full.</span>")
		return 0

	if(assailant.grabbed_by.len)
		to_chat(assailant, "<span class='notice'>You can't grab someone if you're being grabbed.</span>")
		return 0

	var/obj/item/organ/external/O = get_targeted_organ()
	if(!O)
		to_chat(assailant, SPAN("warning", "[affecting] is missing the body part you tried to grab!"))
		return 0 // This check is kinda extra, but you can never be sure

	return 1

/obj/item/grab/proc/init()
	last_target = assailant.zone_sel.selecting
	affecting.update_canmove()
	adjust_position()
	update_icons()
	action_used()

// Returns the organ of the grabbed person that the grabber is targeting
/obj/item/grab/proc/get_targeted_organ()
	return (affecting?.get_organ(target_zone))

/obj/item/grab/proc/resolve_item_attack(mob/living/M, obj/item/I, target_zone)
	if((M && ishuman(M)) && I)
		return current_grab.resolve_item_attack(src, M, I, target_zone)
	else
		return 0

/obj/item/grab/proc/action_used()
	last_action = world.time

/obj/item/grab/proc/check_action_cooldown()
	return (world.time >= last_action + current_grab.action_cooldown)

/obj/item/grab/proc/check_upgrade_cooldown()
	return (world.time >= last_upgrade + current_grab.upgrade_cooldown)

/obj/item/grab/proc/upgrade(bypass_cooldown = FALSE)
	if(!check_upgrade_cooldown() && !bypass_cooldown)
		to_chat(assailant, "<span class='danger'>It's too soon to upgrade.</span>")
		return

	var/datum/grab/upgrab = current_grab.upgrade(src)
	if(upgrab)
		current_grab = upgrab
		last_upgrade = world.time
		adjust_position()
		update_icons()
		current_grab.enter_as_up(src)

/obj/item/grab/proc/downgrade()
	var/datum/grab/downgrab = current_grab.downgrade()
	if(downgrab)
		current_grab = downgrab
		update_icons()

/obj/item/grab/proc/update_icons()
	if(!current_grab)
		return
	if(current_grab.icon)
		icon = current_grab.icon
	if(current_grab.icon_state)
		icon_state = current_grab.icon_state

/obj/item/grab/proc/draw_affecting_over()
	affecting.plane = assailant.plane
	affecting.layer = assailant.layer + 0.01

/obj/item/grab/proc/draw_affecting_under()
	affecting.plane = assailant.plane
	affecting.layer = assailant.layer - 0.01


/obj/item/grab/proc/throw_held()
	return current_grab.throw_held(src)

/obj/item/grab/proc/handle_resist()
	current_grab.handle_resist(src)

/obj/item/grab/proc/adjust_position(force = FALSE)
	if(force)
		affecting.forceMove(assailant.loc)

	if(!assailant || !affecting || !assailant.Adjacent(affecting))
		delete_self()
		return FALSE
	else
		current_grab.adjust_position(src)

/obj/item/grab/proc/reset_position()
	current_grab?.reset_position(src)

/obj/item/grab/proc/has_hold_on_organ(obj/item/organ/external/O)
	if(!O)
		return FALSE

	if(get_targeted_organ() == O)
		return TRUE

	return FALSE

/*
	This section is for the simple procs used to return things from current_grab.
*/
/obj/item/grab/proc/stop_move()
	return current_grab.stop_move

/obj/item/grab/proc/force_stand()
	return current_grab.force_stand

/obj/item/grab/attackby(obj/W, mob/user)
	if(user == assailant)
		current_grab.item_attack(src, W)

/obj/item/grab/proc/can_absorb()
	return current_grab.can_absorb

/obj/item/grab/proc/reverse_moving()
	return current_grab.reverse_moving

/obj/item/grab/proc/shield_assailant()
	return current_grab.shield_assailant

/obj/item/grab/proc/point_blank_mult()
	return current_grab.point_blank_mult

/obj/item/grab/proc/force_danger()
	return current_grab.force_danger

/obj/item/grab/proc/grab_slowdown()
	return current_grab.grab_slowdown

/obj/item/grab/proc/ladder_carry()
	return current_grab.ladder_carry

/obj/item/grab/proc/restrains()
	return current_grab.restrains

/obj/item/grab/proc/resolve_openhand_attack()
		return current_grab.resolve_openhand_attack(src)
