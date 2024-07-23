/obj/structure/railing
	name = "railing"
	desc = "A standard railing. Prevents human stupidity."
	icon = 'icons/obj/railing.dmi'
	icon_state = "railing_full"
	density = 1
	anchored = 1
	atom_flags = ATOM_FLAG_CHECKS_BORDER | ATOM_FLAG_CLIMBABLE
	obj_flags = OBJ_FLAG_ANCHOR_BLOCKS_ROTATION
	layer = 5.2 // Just above doors
	throwpass = 1
	can_buckle = 1
	buckle_require_restraints = 1
	var/health = 40
	var/maxhealth = 40
	var/check = 0
	var/material = ""
	var/material_path = "/obj/item/stack/rods"

/obj/structure/railing/Initialize()
	. = ..()
	if(anchored)
		update_icon(0)

	AddElement(/datum/element/simple_rotation)

/obj/structure/railing/Destroy()
	var/turf/location = loc
	. = ..()
	for(var/obj/structure/railing/R in orange(location, 1))
		R.update_icon()

/obj/structure/railing/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_TABLE)
		return TRUE
	if(get_dir(loc, target) == dir)
		return !density
	return TRUE

/obj/structure/railing/examine(mob/user, infix)
	. = ..()
	if(health < maxhealth)
		switch(health / maxhealth)
			if(0.0 to 0.25)
				. += SPAN_WARNING("It looks severely damaged!")
			if(0.25 to 0.5)
				. += SPAN_WARNING("It looks damaged!")
			if(0.5 to 1.0)
				. += SPAN_WARNING("It has a few scrapes and dents.")

/obj/structure/railing/proc/take_damage(amount)
	health -= amount
	if(health <= 0)
		visible_message("<span class='warning'>\The [src] breaks down!</span>")
		playsound(loc, 'sound/effects/grillehit.ogg', 50, 1)
		new material_path(get_turf(src))
		qdel(src)

/obj/structure/railing/proc/NeighborsCheck(UpdateNeighbors = 1)
	check = 0
	var/Rturn = turn(src.dir, -90)
	var/Lturn = turn(src.dir, 90)

	for(var/obj/structure/railing/R in src.loc)
		if ((R.dir == Lturn) && R.anchored)
			check |= 32
			if (UpdateNeighbors)
				R.update_icon(0)
		if ((R.dir == Rturn) && R.anchored)
			check |= 2
			if (UpdateNeighbors)
				R.update_icon(0)

	for (var/obj/structure/railing/R in get_step(src, Lturn))
		if ((R.dir == src.dir) && R.anchored)
			check |= 16
			if (UpdateNeighbors)
				R.update_icon(0)
	for (var/obj/structure/railing/R in get_step(src, Rturn))
		if ((R.dir == src.dir) && R.anchored)
			check |= 1
			if (UpdateNeighbors)
				R.update_icon(0)

	for (var/obj/structure/railing/R in get_step(src, (Lturn + src.dir)))
		if ((R.dir == Rturn) && R.anchored)
			check |= 64
			if (UpdateNeighbors)
				R.update_icon(0)
	for (var/obj/structure/railing/R in get_step(src, (Rturn + src.dir)))
		if ((R.dir == Lturn) && R.anchored)
			check |= 4
			if (UpdateNeighbors)
				R.update_icon(0)

// Greet the neighbors
/obj/structure/railing/on_update_icon(UpdateNeighgors = 1)
	NeighborsCheck(UpdateNeighgors)
	ClearOverlays()
	if (!check || !anchored)
		icon_state = "[material]railing"
	else
		icon_state = "[material]railing_full"
		if (check & 32)
			AddOverlays(image('icons/obj/railing.dmi', "[material]corneroverlay"))
		if ((check & 16) || !(check & 32) || (check & 64))
			AddOverlays(image('icons/obj/railing.dmi', "[material]frontoverlay_l"))
		if (!(check & 2) || (check & 1) || (check & 4))
			AddOverlays(image('icons/obj/railing.dmi', "[material]frontoverlay_r"))
			if(check & 4)
				switch (src.dir)
					if (NORTH)
						AddOverlays(image('icons/obj/railing.dmi', "[material]mcorneroverlay", pixel_x = 32))
					if (SOUTH)
						AddOverlays(image('icons/obj/railing.dmi', "[material]mcorneroverlay", pixel_x = -32))
					if (EAST)
						AddOverlays(image('icons/obj/railing.dmi', "[material]mcorneroverlay", pixel_y = -32))
					if (WEST)
						AddOverlays(image('icons/obj/railing.dmi', "[material]mcorneroverlay", pixel_y = 32))

/obj/structure/railing/verb/flip() // This will help push railing to remote places, such as open space turfs
	set name = "Flip Railing"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return 0

	if(!can_touch(usr) || ismouse(usr))
		return

	if(anchored)
		to_chat(usr, "It is fastened to the floor therefore you can't flip it!")
		return 0

	if(!neighbor_turf_passable())
		to_chat(usr, "You can't flip the [src] because something blocking it.")
		return 0

	forceMove(get_step(src, dir))
	set_dir(turn(dir, 180))
	update_icon()
	return

/obj/structure/railing/proc/neighbor_turf_passable()
	var/turf/T = get_step(src, src.dir)
	if(!T || !istype(T))
		return 0
	if(T.density == 1)
		return 0
	for(var/obj/O in T.contents)
		if(istype(O,/obj/structure))
			if(istype(O,/obj/structure/railing))
				return 1
			else if(O.density == 1)
				return 0
	return 1

// So you can toss people or objects over
/obj/structure/railing/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.pass_flags & PASS_FLAG_TABLE)
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/railing/attackby(obj/item/W as obj, mob/user as mob)
	// Dismantle
	if(isWrench(W) && !anchored)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 20, src, luck_check_type = LUCK_CHECK_ENG))
			user.visible_message("<span class='notice'>\The [user] dismantles \the [src].</span>", "<span class='notice'>You dismantle \the [src].</span>")
			new material_path(get_turf(usr), 2)
			qdel(src)
			return

	// Repair
	if(health < maxhealth && isWelder(W))
		var/obj/item/weldingtool/F = W
		if(!F.use_tool(src, user, delay = 2 SECONDS, amount = 5))
			return

		if(QDELETED(src) || !user)
			return

		user.visible_message(SPAN_NOTICE("\The [user] repairs some damage to \the [src]."), SPAN_NOTICE("You repair some damage to \the [src]."))
		health = min(health + (maxhealth / 4), maxhealth) // 25% repair per application
		return

	// (Un)Anchor
	if(isScrewdriver(W))
		user.visible_message(anchored ? "<span class='notice'>\The [user] begins unscrewing \the [src].</span>" : "<span class='notice'>\The [user] begins fasten \the [src].</span>" )
		playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
		if(do_after(user, 10, src, luck_check_type = LUCK_CHECK_ENG))
			to_chat(user, (anchored ? "<span class='notice'>You have unfastened \the [src] from the floor.</span>" : "<span class='notice'>You have fastened \the [src] to the floor.</span>"))
			anchored = !anchored
			update_icon()
			return

	else
		playsound(loc, 'sound/effects/grillehit.ogg', 50, 1)
		take_damage(W.force)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	return ..()

/obj/structure/railing/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			qdel(src)
			return
	return

/obj/structure/railing/proc/check_tile(mob/living/user, turf/T)
	if(T.density == 1)
		to_chat(user, SPAN_DANGER("There is \a [T] in the way."))
		return 0
	else
		for(var/obj/O in T.contents)
			if(O == src)
				continue
			if(O == usr)
				continue
			if(O.density == 0)
				continue
			if(istype(O,/obj/structure))
				var/obj/structure/S = O
				if(S.atom_flags & ATOM_FLAG_CLIMBABLE)
					continue
			if(O.atom_flags & ATOM_FLAG_CHECKS_BORDER && !(turn(O.dir, 180) & src.dir))//checks if next item is directed
				//allows if not directed towards climber
				continue
			to_chat(user, SPAN_DANGER("There is \a [O] in the way."))
			return 0
	return 1

/obj/structure/railing/can_climb(mob/living/user, post_climb_check = 0)
	var/turf/OT = get_step(src, src.dir)//opposite turf of railing
	var/turf/T = get_turf(src)//current turf of railing
	var/turf/UT = get_turf(usr)
	if (OT == UT)
		return check_tile(user, T)
	else if (T == UT)
		return check_tile(user, OT)
	else
		to_chat(user, SPAN_DANGER("Too far to climb"))
		return 0


// Snowflake do_climb code that handles special railing cases.
/obj/structure/railing/do_climb(mob/living/user)
	if (!can_climb(user))
		return

	user.visible_message("<span class='warning'>\The [user] starts climbing over \the [src]!</span>")
	LAZYDISTINCTADD(climbers, user)

	if(!do_after(user,(issmall(user) ? 30 : 50), src))
		LAZYREMOVE(climbers, user)
		return

	if (!can_climb(user))
		LAZYREMOVE(climbers, user)
		return

	if(get_turf(user) == get_turf(src))
		usr.forceMove(get_step(src, src.dir))
	else
		usr.forceMove(get_turf(src))

	// If the rail isn't anchored, it'll fall over the edge.
	// Always fun to climb over a railing, fall to the floor below, and then have the railing fall on you.
	if(!anchored)
		user.visible_message("<span class='warning'>\The [user] tries to climb over \the [src], but it collapses!</span>")
		user.Weaken(30)
		src.forceMove(get_turf(user))
		take_damage(maxhealth/2)
	else
		user.visible_message("<span class='warning'>\The [user] climbs over \the [src]!</span>")

	LAZYREMOVE(climbers, user)

/obj/structure/railing/steel
	icon_state = "steel_railing_full"
	material = "steel_"
	desc = "A steel railing. Prevents human stupidity."
	material_path = "/obj/item/stack/material/steel"

/obj/structure/railing/wood
	icon_state = "wood_railing_full"
	material = "wood_"
	desc = "A wooden railing. Prevents human stupidity."
	material_path = "/obj/item/stack/material/wood"

/obj/structure/railing/darkwood
	icon_state = "darkwood_railing_full"
	material = "darkwood_"
	desc = "A darkwood railing. Prevents human stupidity."
	material_path = "/obj/item/stack/material/darkwood"
