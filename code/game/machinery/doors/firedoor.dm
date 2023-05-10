
#define FIREDOOR_MAX_PRESSURE_DIFF 25 // kPa
#define FIREDOOR_MAX_TEMP 50 // °C
#define FIREDOOR_MIN_TEMP 0

// Bitflags
#define FIREDOOR_ALERT_HOT      1
#define FIREDOOR_ALERT_COLD     2
// Not used #define FIREDOOR_ALERT_LOWPRESS 4

/obj/machinery/door/firedoor
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/doorhazard.dmi'
	icon_state = "door_open"
	req_one_access = list(access_atmospherics, access_engine_equip)
	opacity = FALSE
	density = FALSE
	layer = BELOW_DOOR_LAYER
	open_layer = BELOW_DOOR_LAYER
	closed_layer = ABOVE_DOOR_LAYER
	atom_flags = ATOM_FLAG_ADJACENT_EXCEPTION

	//These are frequenly used with windows, so make sure zones can pass.
	//Generally if a firedoor is at a place where there should be a zone boundery then there will be a regular door underneath it.
	block_air_zones = FALSE

	var/blocked = FALSE // If the door is welded, it's blocked
	var/lockdown = FALSE // When the door has detected a problem, it locks.
	var/pdiff_alert = FALSE
	var/pdiff = 0
	var/net_id
	var/list/areas_added
	var/list/users_to_open = new

	var/hatch_open = FALSE

	power_channel = STATIC_ENVIRON
	idle_power_usage = 5 WATTS

	var/list/tile_info[4]
	var/list/dir_alerts[4] // 4 dirs, bitflags

	// MUST be in same order as FIREDOOR_ALERT_*
	var/list/ALERT_STATES=list(
		"hot",
		"cold"
	)

/obj/machinery/door/firedoor/Initialize()
	. = ..()
	for(var/obj/machinery/door/firedoor/F in loc)
		if(F != src)
			return INITIALIZE_HINT_QDEL
	var/area/A = get_area(src)
	ASSERT(istype(A))

	LAZYADD(A.all_doors, src)
	areas_added = list(A)

	for(var/direction in GLOB.cardinal)
		A = get_area(get_step(src,direction))
		if(istype(A) && !(A in areas_added))
			LAZYADD(A.all_doors, src)
			areas_added += A

/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		LAZYREMOVE(A.all_doors, src)
	. = ..()

/obj/machinery/door/firedoor/get_material()
	return get_material_by_name(MATERIAL_STEEL)

/obj/machinery/door/firedoor/_examine_text(mob/user)
	. = ..()
	if(!istype(usr, /mob/living/silicon) && (get_dist(src, user) > 1 || !density))
		return

	if(stat & (BROKEN|NOPOWER))
		return

	if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
		. += "\n<span class='danger'>WARNING: Current pressure differential is [round(pdiff)]kPa! Opening door may result in injury!</span>"
	. += "\n<b>Sensor readings:</b>"
	for(var/index = 1; index <= tile_info.len; index++)
		var/o = "&nbsp;&nbsp;"
		switch(index)
			if(1)
				o += "NORTH: "
			if(2)
				o += "SOUTH: "
			if(3)
				o += "EAST: "
			if(4)
				o += "WEST: "
		if(tile_info[index] == null)
			o += "<span class='warning'>DATA UNAVAILABLE</span>"
			. += "\n[o]"
			continue
		var/celsius = CONV_KELVIN_CELSIUS(tile_info[index][1])
		var/pressure = tile_info[index][2]
		o += "<span class='[(dir_alerts[index] & (FIREDOOR_ALERT_HOT|FIREDOOR_ALERT_COLD)) ? "warning" : "color:navy"]'>"
		o += "[celsius]&deg;C</span> "
		o += "<span style='color:navy'>"
		o += "[round(pressure)]kPa</span></li>"
		. += "\n[o]"
	if(islist(users_to_open) && users_to_open.len)
		var/users_to_open_string = users_to_open[1]
		if(users_to_open.len >= 2)
			for(var/i = 2 to users_to_open.len)
				users_to_open_string += ", [users_to_open[i]]"
		. += "\nThese people have opened \the [src] during an alert: [users_to_open_string]."

/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(p_open || operating)
		return
	if(!density)
		return ..()
	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(mecha.occupant)
			var/mob/M = mecha.occupant
			if(world.time - M.last_bumped <= 10) return //Can bump-open one airlock per second. This is to prevent popup message spam.
			M.last_bumped = world.time
			attack_hand(M)
	return FALSE

/obj/machinery/door/firedoor/attack_hand(mob/user)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.

	if(blocked)
		to_chat(user, SPAN("danger","\The [src] is welded solid!"))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species?.can_shred(H))
			if(do_after(user, 30, src))
				if(density)
					user.visible_message(SPAN("danger", "\The [user] forces \the [src] open!"),\
										SPAN("danger", "\The [src] forced open!"),\
										SPAN("danger", "You hear metal strain, and a door opening!"))
					open(TRUE)
					shake_animation(2, 2)
			return

	var/alarmed = lockdown
	if(!alarmed)
		alarmed = is_alarmed()

	if(user.incapacitated() || (get_dist(src, user) > 1  && !issilicon(user)))
		to_chat(user, SPAN("warning","Sorry, you must remain able bodied and close to \the [src] in order to use it."))
		return

	if(density && (stat & (BROKEN|NOPOWER))) //can still close without power
		to_chat(user, SPAN("warning", "\The [src] is not functioning, you'll have to force it open manually."))
		return

	if(alarmed && density && lockdown && !allowed(user))
		to_chat(user, SPAN("warning", "Access denied. Please wait for authorities to arrive, or for the alert to clear."))
		return
	else
		user.visible_message(SPAN("notice", "\The [src] [density ? "open" : "close"]s for \the [user]."),\
							SPAN("notice", "\The [src] [density ? "open" : "close"]s."),\
							SPAN("notice", "You hear a beep, and a door [density ? "opening" : "closing"]."))

	var/needs_to_close = FALSE
	if(density)
		if(alarmed)
			// Accountability!
			users_to_open |= user.name
			needs_to_close = !issilicon(user)
		INVOKE_ASYNC(src, .proc/open)
	else
		INVOKE_ASYNC(src, .proc/close)

	if(needs_to_close)
		set_next_think(world.time + 5 SECOND)

/obj/machinery/door/firedoor/attack_generic(mob/user, damage)
	if(stat & (BROKEN|NOPOWER))
		if(damage >= 10)
			user.visible_message(SPAN("danger", "\The [user] forces \the [src] [density ? "open" : "closed"]!"),\
								SPAN("danger", "\The [src] forced [density ? "open" : "closed"]!"),\
								SPAN("danger", "You hear metal strain, and a door [density ? "opening" : "closing"]!"))
			if(src.density)
				open(TRUE)
			else
				close(TRUE)
		else
			user.visible_message(SPAN("notice","\The [user] strains fruitlessly to force \the [src] [density ? "open" : "closed"]."),\
								SPAN("notice","You strain fruitlessly to force \the [src] [density ? "open" : "closed"]."))
		return
	..()

/obj/machinery/door/firedoor/attackby(obj/item/C, mob/user)
	add_fingerprint(user, 0, C)
	if(operating)
		return//Already doing something.

	if(isWelder(C) && !repairing)
		var/obj/item/weldingtool/W = C
		if(W.remove_fuel(0, user))
			blocked = !blocked
			user.visible_message(SPAN("danger", "\The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W]."),\
								SPAN("danger", "You [blocked ? "weld" : "unweld"] \the [src] with \the [W]."),\
								SPAN("danger", "You hear something being welded."))
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			update_icon()
			return

	if(density && isScrewdriver(C))
		hatch_open = !hatch_open
		user.visible_message(SPAN("danger", "\The [user] has [hatch_open ? "opened" : "closed"] \the [src] maintenance hatch."),\
							SPAN("danger", "You have [hatch_open ? "opened" : "closed"] \the [src] maintenance hatch."))
		update_icon()
		return

	if(blocked)
		if(isCrowbar(C) && !repairing)
			if(!hatch_open)
				to_chat(user, SPAN("danger", "\The [src] is welded solid!"))
			else
				user.visible_message(SPAN("danger", "\The [user] is removing the electronics from \the [src]."),\
									SPAN("danger", "You start to remove the electronics from \the [src]."))
				if(do_after(user,30,src))
					if(blocked && density && hatch_open)
						playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
						user.visible_message(SPAN("danger", "\The [user] has removed the electronics from \the [src]."),\
											SPAN("danger", "You have removed the electronics from \the [src]."),\
											SPAN("danger", "You hear something pried out."))
						deconstruct(user)
		return

	if(isCrowbar(C) || istype(C,/obj/item/material/twohanded/fireaxe))
		if(istype(C,/obj/item/material/twohanded/fireaxe))
			var/obj/item/material/twohanded/fireaxe/F = C
			if(!F.wielded)
				return

		user.visible_message(SPAN("danger", "\The [user] starts to force \the [src] [density ? "open" : "closed"] with \a [C]!"),\
							SPAN("danger", "You start forcing \the [src] [density ? "open" : "closed"] with \the [C]!"),\
							SPAN("danger", "You hear metal strain and groan!"))
		var/forcing_time = istype(C, /obj/item/crowbar/emergency) ? 60 : 30
		if(!do_after(user, forcing_time, src))
			return
		if(isCrowbar(C))
			user.visible_message(SPAN("danger", "\The [user] forces \the [src] [density ? "open" : "closed"] with \a [C]!"),\
								 SPAN("danger", "You force \the [src] [density ? "open" : "closed"] with \the [C]!"),\
								 SPAN("notice", "You hear a door [density ? "opening" : "closing"]."))
		if(density)
			INVOKE_ASYNC(src, /obj/machinery/door/proc/open, TRUE)
			set_next_think(world.time + 15 SECOND)
		else
			INVOKE_ASYNC(src, /obj/machinery/door/proc/close, TRUE)
		return

	return ..()

/obj/machinery/door/firedoor/deconstruct(mob/user, moved = FALSE)
	if (stat & BROKEN)
		new /obj/item/circuitboard/broken(src.loc)
	else
		new /obj/item/airalarm_electronics(src.loc)

	var/obj/structure/firedoor_assembly/FA = new /obj/structure/firedoor_assembly(src.loc)
	FA.anchored = !moved
	FA.set_density(1)
	FA.wired = 1
	FA.update_icon()
	qdel(src)

	return FA

/obj/machinery/door/firedoor/can_open(forced = FALSE)
	if(blocked)
		return FALSE

	if(!forced && (stat & (NOPOWER|BROKEN)))
		return FALSE

	return ..()

/obj/machinery/door/firedoor/can_close(forced = FALSE)
	if(blocked)
		return FALSE

	return ..()

/obj/machinery/door/firedoor/open(forced = FALSE)
	if(!forced)
		lockdown = FALSE

	if(hatch_open)
		hatch_open = FALSE
		visible_message(SPAN("notice", "The maintenance hatch of \the [src] closes."))
		update_icon()

	if(!forced)
		use_power_oneoff(360)
	else
		var/area/A = get_area(src)
		log_admin("[usr]([usr.ckey]) has forced open an emergency shutter at X:[x], Y:[y], Z:[z] Area: [A.name].")
	return ..()

/obj/machinery/door/firedoor/close(forced = FALSE, push_mobs = TRUE)
	set_next_think(world.time + 1 SECOND)
	return ..()

// Only opens when all areas connecting with our turf have an air alarm and are cleared
/obj/machinery/door/firedoor/proc/can_safely_open()
	var/turf/neighbour
	for(var/dir in GLOB.cardinal)
		neighbour = get_step(src.loc, dir)
		if(neighbour.c_airblock(src.loc) & AIR_BLOCKED)
			continue
		for(var/obj/O in src.loc)
			if(istype(O, /obj/machinery/door))
				continue
			. |= O.c_airblock(neighbour)
		if(. & AIR_BLOCKED)
			continue
		var/area/A = get_area(neighbour)
		if(!A.master_air_alarm)
			return
		if(A.atmosalm)
			return
	return TRUE

// Checks if there are fire alarms in any areas associated with that firedoor
/obj/machinery/door/firedoor/proc/is_alarmed()
	for(var/area/A in areas_added)
		if(A.fire || A.air_doors_activated)
			return TRUE

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)
	return


/obj/machinery/door/firedoor/update_icon()
	overlays.Cut()
	set_light(0)
	var/do_set_light = FALSE

	if(density)
		icon_state = "door_closed"
		if(hatch_open)
			overlays += "hatch"
		if(blocked)
			overlays += "welded"
		if(pdiff_alert)
			overlays += "palert"
			do_set_light = TRUE
		if(dir_alerts)
			for(var/d = 1; d <= 4; d++)
				var/cdir = GLOB.cardinal[d]
				for(var/i = 1; i <= ALERT_STATES.len; i++)
					if(dir_alerts[d] & (1 << (i-1)))
						overlays += new /icon(icon,"alert_[ALERT_STATES[i]]", dir = cdir)
						do_set_light = TRUE
	else
		icon_state = "door_open"
		if(blocked)
			overlays += "welded_open"

	if(do_set_light)
		set_light(0.25, 0.1, 1, 2, COLOR_SUN)

// CHECK PRESSURE
/obj/machinery/door/firedoor/think()
	if(stat & (BROKEN|NOPOWER))
		return

	if (!density)
		if(lockdown || is_alarmed())
			close()
		return

	var/changed = FALSE
	lockdown = FALSE

	// Pressure alerts
	pdiff = getOPressureDifferential(src.loc)
	if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
		lockdown = TRUE
		if(!pdiff_alert)
			pdiff_alert = TRUE
			changed = TRUE // update_icon()
	else
		if(pdiff_alert)
			pdiff_alert = FALSE
			changed = TRUE // update_icon()

	tile_info = getCardinalAirInfo(src.loc,list("temperature","pressure"))
	var/old_alerts = dir_alerts
	for(var/index = 1; index <= 4; index++)
		var/list/tileinfo=tile_info[index]
		if(tileinfo==null)
			continue // Bad data.
		var/celsius = CONV_KELVIN_CELSIUS(tileinfo[1])

		var/alerts=0

		// Temperatures
		if(celsius >= FIREDOOR_MAX_TEMP)
			alerts |= FIREDOOR_ALERT_HOT
			lockdown = TRUE
		else if(celsius <= FIREDOOR_MIN_TEMP)
			alerts |= FIREDOOR_ALERT_COLD
			lockdown = TRUE

		dir_alerts[index]=alerts

	if(dir_alerts != old_alerts)
		changed = TRUE

	if(changed)
		update_icon()

	set_next_think(world.time + 10 SECOND)

//These are playing merry hell on ZAS.  Sorry fellas :(

/obj/machinery/door/firedoor/border_only
/*
	icon = 'icons/obj/doors/edge_doorfire.dmi'
	glass = 1 //There is a glass window so you can see through the door
			  //This is needed due to BYOND limitations in controlling visibility
	heat_proof = 1
	air_properties_vary_with_direction = 1

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
			return 1
		if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
			if(air_group) return 0
			return !density
		else
			return 1

	CheckExit(atom/movable/mover, turf/target)
		if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
			return 1
		if(get_dir(loc, target) == dir)
			return !density
		else
			return 1


	update_nearby_tiles(need_rebuild)
		if(!air_master) return 0

		var/turf/simulated/source = loc
		var/turf/simulated/destination = get_step(source,dir)

		update_heat_protection(loc)

		if(istype(source)) air_master.tiles_to_update += source
		if(istype(destination)) air_master.tiles_to_update += destination
		return 1
*/

/obj/machinery/door/firedoor/multi_tile
	icon = 'icons/obj/doors/doorhazard2x1.dmi'
	dir = EAST
	width = 2
