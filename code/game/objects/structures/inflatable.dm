
/// Items
/obj/item/inflatable
	name = "inflatable"
	w_class = ITEM_SIZE_NORMAL
	icon = 'icons/obj/inflatable.dmi'
	var/deploy_path = null
	var/inflatable_health

/obj/item/inflatable/attack_self(mob/user)
	if(!deploy_path)
		return
	user.visible_message("[user] starts inflating \the [src].", "You start inflating \the [src].")
	if(!do_after(user, 1 SECOND, src))
		return
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	user.visible_message(SPAN("notice", "[user] inflates \the [src]."), SPAN("notice", "You inflate \the [src]."))
	var/obj/structure/inflatable/R = new deploy_path(user.loc)
	R.dir = user.dir
	transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	if(inflatable_health)
		R.health = inflatable_health
	qdel(src)

/obj/item/inflatable/wall
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon_state = "folded_wall"
	deploy_path = /obj/structure/inflatable/wall

/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon_state = "folded_door"
	deploy_path = /obj/structure/inflatable/door

/obj/item/inflatable/panel
	name = "inflatable panel"
	desc = "A folded membrane which rapidly expands into a thin door on activation."
	icon_state = "folded_panel"
	deploy_path = /obj/structure/inflatable/door/panel

/obj/item/inflatable/torn
	name = "torn inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. It is too torn to be usable."
	icon_state = "folded_wall_torn"

/obj/item/inflatable/torn/attack_self(mob/user)
	to_chat(user, SPAN("notice", "The inflatable wall is too torn to be inflated!"))
	add_fingerprint(user)

/obj/item/inflatable/door/torn
	name = "torn inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation. It is too torn to be usable."
	icon_state = "folded_door_torn"

/obj/item/inflatable/door/torn/attack_self(mob/user)
	to_chat(user, SPAN("notice", "The inflatable door is too torn to be inflated!"))
	add_fingerprint(user)

/obj/item/inflatable/panel/torn
	name = "torn inflatable panel"
	desc = "A folded membrane which rapidly expands into a thin door on activation. It is too torn to be usable."
	icon_state = "folded_panel_torn"

/obj/item/inflatable/panel/torn/attack_self(mob/user)
	to_chat(user, SPAN("notice", "The inflatable panel is too torn to be inflated!"))
	add_fingerprint(user)

/// Structures
/obj/structure/inflatable
	name = "inflatable"
	desc = "An inflated membrane. Do not puncture."
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall"
	can_atmos_pass = ATMOS_PASS_DENSITY
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT

	var/icon_key = "wall"
	var/undeploy_path = null
	var/torn_path = null
	var/health = 10
	var/taped

	var/max_pressure_diff = HAZARD_HIGH_PRESSURE + 150
	var/max_temp = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/structure/inflatable/New(location)
	..()
	update_nearby_tiles(need_rebuild = 1)

/obj/structure/inflatable/Initialize()
	. = ..()
	set_next_think(world.time)

/obj/structure/inflatable/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/inflatable/think()
	check_environment()

	set_next_think(world.time + 1 SECOND)

/obj/structure/inflatable/proc/check_environment()
	var/min_pressure = INFINITY
	var/max_pressure = 0
	var/max_local_temp = 0

	for(var/check_dir in GLOB.cardinal)
		var/turf/T = get_step(get_turf(src), check_dir)
		var/datum/gas_mixture/env = T.return_air()
		var/pressure = env.return_pressure()
		min_pressure = min(min_pressure, pressure)
		max_pressure = max(max_pressure, pressure)
		max_local_temp = max(max_local_temp, env.temperature)

	if(prob(50) && (max_pressure - min_pressure > max_pressure_diff || max_local_temp > max_temp))
		take_damage(1)
		if(health == round(0.7 * initial(health)))
			visible_message(SPAN("warning", "\The [src] is taking damage!"))
		if(health == round(0.3 * initial(health)))
			visible_message(SPAN("warning", "\The [src] is barely holding up!"))

/obj/structure/inflatable/_examine_text(mob/user)
	. = ..()
	if(health >= initial(health))
		. += "\n[SPAN("notice", "It's undamaged.")]"
	else if(health >= 0.5 * initial(health))
		. += "\n[SPAN("warning", "It's showing signs of damage.")]"
	else if(health >= 0)
		. += "\n[SPAN("danger", "It's heavily damaged!")]"
	if(taped)
		. += "\n[SPAN("notice", "It's been duct taped in few places.")]"

/obj/structure/inflatable/bullet_act(obj/item/projectile/Proj)
	take_damage(Proj.get_structure_damage())
	if(health <= 0)
		return PROJECTILE_CONTINUE

/obj/structure/inflatable/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			deflate(TRUE)
			return
		if(3.0)
			if(prob(50))
				deflate(TRUE)
				return

/obj/structure/inflatable/attack_hand(mob/user)
	add_fingerprint(user)
	return

/obj/structure/inflatable/attackby(obj/item/W, mob/user)
	if(!istype(W) || istype(W, /obj/item/inflatable_dispenser))
		return
	if(istype(W, /obj/item/tape_roll) && health < initial(health) - 3)
		if(taped)
			to_chat(user, SPAN("notice", "\The [src] can't be patched any more with \the [W]!"))
			return TRUE
		else
			taped = TRUE
			to_chat(user, SPAN("notice", "You patch some damage in \the [src] with \the [W]!"))
			take_damage(-3)
			return TRUE
	else if((W.damtype == BRUTE || W.damtype == BURN) && (W.can_puncture() || W.force > 10))
		..()
		if(hit(W.force))
			visible_message(SPAN("danger", "[user] pierces [src] with [W]!"))
	return

/obj/structure/inflatable/proc/hit(damage, sound_effect = 1)
	take_damage(damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 75, 1)
	return health <= 0


/obj/structure/inflatable/proc/take_damage(damage)
	health = max(0, health - damage)
	if(health <= 0)
		deflate(TRUE)

/obj/structure/inflatable/CtrlClick()
	return hand_deflate()

/obj/structure/inflatable/proc/deflate(violent = FALSE)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(violent)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/torn/R = new torn_path(loc)
		transfer_fingerprints_to(R)
		qdel(src)
	else
		if(!undeploy_path)
			return
		visible_message("\The [src] slowly deflates.")
		spawn(50)
			var/obj/item/inflatable/R = new undeploy_path(loc)
			transfer_fingerprints_to(R)
			R.inflatable_health = health
			qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(isobserver(usr) || usr.restrained() || !usr.Adjacent(src))
		return FALSE

	verbs -= /obj/structure/inflatable/verb/hand_deflate
	deflate()
	return TRUE

/obj/structure/inflatable/attack_generic(mob/user, damage, attack_verb)
	health -= damage
	attack_animation(user)
	if(health <= 0)
		user.visible_message(SPAN("danger", "[user] [attack_verb] open the [src]!"))
		spawn(1)
			deflate(TRUE)
	else
		user.visible_message(SPAN("danger", "[user] [attack_verb] at [src]!"))
	return 1

// Walls
/obj/structure/inflatable/wall
	name = "inflatable wall"
	icon_state = "wall"
	icon_key = "wall"

	undeploy_path = /obj/item/inflatable/wall
	torn_path = /obj/item/inflatable/torn

// Doors
/obj/structure/inflatable/door //Based on mineral door code
	name = "inflatable door"
	icon_state = "door_closed"
	icon_key = "door"

	density = TRUE
	anchored = TRUE
	opacity = FALSE
	layer = CLOSED_DOOR_LAYER

	undeploy_path = /obj/item/inflatable/door
	torn_path = /obj/item/inflatable/door/torn

	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = FALSE

/obj/structure/inflatable/door/attack_ai(mob/user) //those aren't machinery, they're just big fucking balloons
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user)) // but cyborgs can
		if(Adjacent(user)) // not remotely though
			return TryToSwitchState(user)

/obj/structure/inflatable/door/attack_hand(mob/user)
	return TryToSwitchState(user)

/obj/structure/inflatable/door/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/inflatable/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates)
		return
	if(ismob(user))
		var/mob/M = user
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()

/obj/structure/inflatable/door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()
	update_nearby_tiles()

/obj/structure/inflatable/door/proc/Open()
	isSwitchingStates = TRUE
	flick("[icon_key]_opening", src)
	sleep(10)
	set_density(FALSE)
	set_opacity(FALSE)
	state = 1
	update_icon()
	isSwitchingStates = FALSE
	atom_flags &= ~ATOM_FLAG_FULLTILE_OBJECT
	layer = ABOVE_HUMAN_LAYER

/obj/structure/inflatable/door/proc/Close()
	isSwitchingStates = TRUE
	flick("[icon_key]_closing", src)
	sleep(10)
	set_density(TRUE)
	set_opacity(FALSE)
	state = 0
	update_icon()
	isSwitchingStates = FALSE
	atom_flags |= ATOM_FLAG_FULLTILE_OBJECT
	layer = CLOSED_DOOR_LAYER

/obj/structure/inflatable/door/update_icon()
	if(state)
		icon_state = "[icon_key]_open"
	else
		icon_state = "[icon_key]_closed"

// Panels
/obj/structure/inflatable/door/panel //Based on mineral door code
	name = "inflatable panel"
	icon_state = "panel_closed"
	icon_key = "panel"

	density = TRUE
	anchored = TRUE
	opacity = FALSE

	atom_flags = ATOM_FLAG_CHECKS_BORDER
	can_atmos_pass = ATMOS_PASS_PROC
	undeploy_path = /obj/item/inflatable/panel
	torn_path = /obj/item/inflatable/panel/torn

/obj/structure/inflatable/door/panel/Open()
	isSwitchingStates = TRUE
	flick("[icon_key]_opening", src)
	sleep(10)
	set_density(FALSE)
	set_opacity(FALSE)
	state = 1
	update_icon()
	isSwitchingStates = FALSE
	layer = ABOVE_HUMAN_LAYER

/obj/structure/inflatable/door/panel/Close()
	isSwitchingStates = TRUE
	flick("[icon_key]_closing", src)
	sleep(10)
	set_density(TRUE)
	set_opacity(FALSE)
	state = 0
	update_icon()
	isSwitchingStates = FALSE
	layer = CLOSED_DOOR_LAYER

/obj/structure/inflatable/door/panel/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return TRUE
	if(get_dir(loc, target) & dir)
		return !density
	return TRUE

/obj/structure/inflatable/door/panel/CanZASPass(turf/T, is_zone)
	if(get_dir(T, loc) == turn(dir, 180)) // Make sure we're handling the border correctly.
		return state
	return TRUE

/obj/structure/inflatable/door/panel/proc/CanDiagonalPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return TRUE
	var/mover_dir = get_dir(loc, target)
	if((mover_dir & dir) || (mover_dir & turn(dir, -45)) || (mover_dir & turn(dir, 45)))
		return !density
	return TRUE

/obj/structure/inflatable/door/panel/proc/CheckDiagonalExit(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return TRUE
	var/mover_dir = get_dir(mover.loc, target)
	if((mover_dir & dir) || (turn(mover_dir, -45) & dir) || (turn(mover_dir, 45) & dir))
		return FALSE
	return TRUE


/obj/item/storage/briefcase/inflatable
	name = "inflatable barriers kit"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf_box"
	item_state = "case"
	w_class = ITEM_SIZE_LARGE
	max_storage_space = null
	storage_slots = 8
	max_w_class = ITEM_SIZE_NORMAL
	can_hold = list(/obj/item/inflatable)
	startswith = list(/obj/item/inflatable/door = 2, /obj/item/inflatable/wall = 4, /obj/item/inflatable/panel = 2)
