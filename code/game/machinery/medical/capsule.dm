/obj/machinery/capsule
	name = "\improper Capsule"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = TRUE
	anchored = TRUE

	// Who lives here? JK. Represents occupant for easy referencing in methods, assigns in go_in().
	var/mob/living/carbon/human/occupant = null

	// Is capsule closed? If TRUE occupant can't get out without extra help.
	var/locked = FALSE

	// Used to specify occupants name, assigns in go_in().
	var/occupant_name = null

/obj/machinery/capsule/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Occupant"

	if(usr.stat != CONSCIOUS)
		return
	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/capsule/update_icon()
	if(panel_open)
		icon_state = "body_scanner_1"
		return
	icon_state = "body_scanner_[occupant ? "1" : "0"]"

/obj/machinery/capsule/Initialize()
	. = ..()
	RefreshParts()
	update_icon()

/obj/machinery/capsule/_examine_text(mob/user)
	. = ..()
	if(user.Adjacent(src))
		if(occupant)
			. += "\n[occupant._examine_text(user)]"

/obj/machinery/capsule/Destroy()
	go_out()
	..()

/obj/machinery/capsule/relaymove(mob/user)
	if(user.stat)
		return
	go_out()

/obj/machinery/capsule/resleever/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/capsule/attack_hand(mob/user)
	if(!anchored)
		return
	if(stat & (NOPOWER|BROKEN))
		to_chat(usr, "\The [src] doesn't appear to function.")
		return
	if(panel_open)
		to_chat(user, SPAN_WARNING("Close the maintenance panel first!"))
		return
	if(user == occupant)
		to_chat(user, SPAN_WARNING("You can't reach the controls from the inside!"))
		return

/obj/machinery/capsule/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, I))
		return
	if(isCrowbar(I))
		if(occupant && panel_open)
			occupant.loc = get_turf(src)
			occupant = null
			locked = FALSE
			update_use_power(1)
			update_icon()
		else
			default_deconstruction_crowbar(user, I)
		return
	if(default_part_replacement(user, I))
		return
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(!ismob(G.affecting))
			return
		if(!check_compatibility(G.affecting, user))
			return
		visible_message(SPAN_NOTICE("\The [user] starts placing \the [G.affecting] into \the [src]."), \
					SPAN_NOTICE("You start placing \the [G.affecting] into \the [src]."))
		if(do_after(user, 20, src))
			if(!check_compatibility(G.affecting, user))
				return
			G.affecting.stop_pulling()
			if(G.affecting.client)
				G.affecting.client.perspective = EYE_PERSPECTIVE
				G.affecting.client.eye = src
			G.affecting.forceMove(src)
			update_use_power(POWER_USE_IDLE)
			occupant = G.affecting
			update_icon()
			qdel(I)
			return
		else
			return
	..()

/obj/machinery/capsule/ex_act(severity)
	switch(severity)
		if(1.0)
			drop_contents_with_prob(100, severity)
			return
		if(2.0)
			drop_contents_with_prob(50, severity)
			return
		if(3.0)
			drop_contents_with_prob(25, severity)
			return
	return

/obj/machinery/capsule/proc/drop_contents_with_prob(chance, severity)
	if(prob(chance))
		for(var/atom/movable/A as mob|obj in src)
			A.dropInto(loc)
			ex_act(severity)
		qdel(src)

/obj/machinery/capsule/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(occupant)
		go_out()

	if(!emagged && prob(10))
		emag_act()

	..(severity)

/obj/machinery/capsule/emag_act(remaining_charges, mob/user)
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, loc)

	if(locked)
		to_chat(user, SPAN_DANGER("You short out locking system."))
		toggle_lock()
		spark_system.start()
		playsound(src.loc, SFX_SPARK, 50, 1)
		return 1

/obj/machinery/capsule/Process()
	if(stat & (NOPOWER|BROKEN))
		return

	if (!(occupant in src))
		go_out()

	play_beep()

/obj/machinery/capsule/proc/check_compatibility(mob/target, mob/user)
	if(!istype(user) || !istype(target))
		return FALSE
	if(!CanMouseDrop(target, user))
		return FALSE
	if(occupant)
		to_chat(user, SPAN_WARNING("The scanner is already occupied!"))
		return FALSE
	if(target.abiotic())
		to_chat(user, SPAN_WARNING("The subject cannot have abiotic items on!"))
		return FALSE
	if(target.buckled)
		to_chat(user, SPAN_WARNING("Unbuckle the subject before attempting to move them!"))
		return FALSE
	for(var/mob/living/carbon/metroid/M in range(1, target))
		if(M.Victim == target)
			to_chat(user, "[target.name] will not fit into the [src] because they have a metroid latched onto their head.")
			return FALSE
	return TRUE

/obj/machinery/capsule/MouseDrop_T(mob/target, mob/user)
	if(!CanMouseDrop(target, user))
		return
	if(!istype(target))
		return
	if(target.buckled)
		to_chat(user, SPAN_WARNING("Unbuckle the subject before attempting to move them!"))
		return
	if(!check_compatibility(target, user))
		return
	go_in(target, user)

/obj/machinery/capsule/proc/go_in(mob/M, mob/user)
	if(!M)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	if(occupant)
		to_chat(user, SPAN_WARNING("\The [src] is already occupied."))
		return
	if(panel_open)
		to_chat(user, SPAN_NOTICE("Close the maintenance panel first!"))
		return
	if(user == M)
		visible_message(SPAN_NOTICE("\The [user] starts climbing into \the [src]."), \
					SPAN_NOTICE("You start climbing into \the [src]."))
	else
		visible_message(SPAN_NOTICE("\The [user] begins placing \the [M] into \the [src]."), \
					SPAN_NOTICE("You start placing \the [M] into \the [src]."))

	if(do_after(user, 20, src))
		if(!check_compatibility(M, user))
			return
		if(occupant)
			to_chat(user, SPAN_WARNING("\The [src] is already occupied!"))
			return
		M.stop_pulling()
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.forceMove(src)
		update_use_power(POWER_USE_ACTIVE)
		occupant = M
		occupant_name = M.name
		update_icon()

/obj/machinery/capsule/proc/is_occupant_ejectable()
	if(!occupant)
		return FALSE
	if(locked)
		return FALSE
	return TRUE

/obj/machinery/capsule/proc/go_out()
	if(!is_occupant_ejectable())
		return
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	if(occupant in src)
		occupant.dropInto(loc)
	occupant = null
	occupant_name = null
	for(var/atom/movable/A in src) // In case an object was dropped inside or something ~ Kelenius
		if(locate(A) in component_parts)
			continue
		A.dropInto(loc)
	update_use_power(POWER_USE_IDLE)
	update_icon()

/obj/machinery/capsule/proc/toggle_lock()
	if(!occupant)
		locked = FALSE
		return
	to_chat(occupant, SPAN_WARNING("You hear a quiet click as the locking bolts [locked ? "go up" : "drop down"]!"))
	locked = !locked
