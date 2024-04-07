/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	pull_sound = SFX_PULL_CLOSET
	pull_slowdown = PULL_SLOWDOWN_HEAVY
	density = TRUE
	w_class = ITEM_SIZE_NO_CONTAINER
	layer = STRUCTURE_LAYER

	var/icon_closed = "closed"
	var/icon_opened = "open"

	var/icon_locked
	var/icon_broken = "sparks"
	var/icon_off

	var/welded = FALSE
	var/wall_mounted = FALSE //never solid (You can always pass over it)
	var/health = 100
	var/breakout = 0 //if someone is currently breaking out. mutex
	var/storage_capacity = 2 * MOB_MEDIUM //This is so that someone can't pack hundreds of items in a locker/crate
							  //then open it in a populated area to crash clients.
	var/open_sound = SFX_OPEN_CLOSET
	var/close_sound = SFX_CLOSE_CLOSET

	var/storage_types = CLOSET_STORAGE_ALL
	var/setup = CLOSET_CAN_BE_WELDED

	// TODO: Turn these into flags. Skipped it for now because it requires updating 100+ locations...
	var/broken = FALSE
	var/opened = FALSE
	var/locked = FALSE

	var/obj/item/shield/closet/cdoor
	var/dremovable = TRUE	//	some closets' doors cannot be removed
	var/nodoor = FALSE	// for crafting

	var/open_delay = 0

	var/material = /obj/item/stack/material/steel

	var/intact_closet = TRUE // List operations overhead bad

	rad_resist_type = /datum/rad_resist/closet

/datum/rad_resist/closet
	alpha_particle_resist = 41 MEGA ELECTRONVOLT
	beta_particle_resist = 3.4 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/structure/closet/nodoor
	nodoor = TRUE
	opened = TRUE
	density = FALSE
	intact_closet = FALSE

/obj/item/shield/closet
	name = "closet door"
	desc = "An essential part of a closet. Could it be used as a tower shield?.."
	icon = 'icons/obj/closet_doors.dmi'
	icon_state = "steel"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_shields.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_shields.dmi',
		)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 10.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 4
	w_class = ITEM_SIZE_HUGE
	mod_weight = 1.6
	mod_reach = 1.4
	mod_handy = 0.7
	mod_shield = 1.3
	block_tier = BLOCK_TIER_PROJECTILE
	origin_tech = list(TECH_MATERIAL = 2)
	matter = list(MATERIAL_STEEL = 1000)
	attack_verb = list("shoved", "bashed")

	req_access = list()
	req_one_access = list()

	var/icon_closed = "closed"
	var/icon_opened = "open"

	var/icon_locked
	var/icon_off

	var/lockable = FALSE

/obj/item/shield/closet/Initialize()
	. = ..()
	update_icon()

/obj/item/shield/closet/on_update_icon()
	..()
	if(isturf(loc))
		SetTransform(rotation = 90)
		pixel_y = -8
	else
		SetTransform(rotation = 0)
		pixel_y = initial(pixel_y)

/obj/item/shield/closet/pickup(mob/user)
	..()
	update_icon()

/obj/item/shield/closet/dropped(mob/user)
	..()
	update_icon()

/obj/item/shield/closet/attack_hand()
	..()
	update_icon()

/obj/item/shield/closet/on_enter_storage(obj/item/storage/S)
	..()
	update_icon()


/obj/structure/closet/Initialize()
	. = ..()

	if((setup & CLOSET_HAS_LOCK))
		verbs += /obj/structure/closet/proc/togglelock_verb

	if(intact_closet && (z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
		GLOB.intact_station_closets.Add(src)

	return INITIALIZE_HINT_LATELOAD

/obj/structure/closet/LateInitialize(mapload, ...)
	var/list/will_contain = WillContain()
	if(will_contain)
		create_objects_in_loc(src, will_contain)

	if(!opened && mapload) // if closed and it's the map loading phase, relevant items at the crate's loc are put in the contents
		store_contents()

	if(dremovable && !nodoor)
		var/obj/item/shield/closet/ndoor = new /obj/item/shield/closet(src.loc)
		ndoor.icon_closed = icon_closed
		ndoor.icon_opened = icon_opened

		ndoor.icon_locked = icon_locked
		ndoor.icon_off = icon_off

		ndoor.name = "[name] door"
		ndoor.icon_state = icon_closed
		ndoor.item_state = icon_closed

		ndoor.req_access = req_access
		ndoor.req_one_access = req_one_access

		if((setup & CLOSET_HAS_LOCK))
			ndoor.lockable = TRUE

		ndoor.forceMove(src)
		cdoor = ndoor

	update_icon()

/obj/structure/closet/Destroy()
	QDEL_NULL(cdoor)
	if(intact_closet)
		GLOB.intact_station_closets.Remove(src)
	return ..()

/obj/structure/closet/proc/WillContain()
	return null

/obj/structure/closet/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) <= 1 && !opened)
		var/content_size = 0
		for(var/atom/movable/AM in src.contents)
			if(!AM.anchored)
				content_size += content_size(AM)
		if(!content_size)
			. += "It is empty."
		else if(storage_capacity > content_size*4)
			. += "It is barely filled."
		else if(storage_capacity > content_size*2)
			. += "It is less than half full."
		else if(storage_capacity > content_size)
			. += "There is still some free space."
		else
			. += "It is full."

	if(isghost(user))
		var/mob/observer/ghost/G = user
		if(!G.inquisitiveness)
			return

		if(src.opened)
			return

		. += "It contains: [items_english_list(contents)]."

/obj/structure/closet/CanPass(atom/movable/mover, turf/target)
	if(wall_mounted)
		return TRUE
	return ..()

/obj/structure/closet/proc/can_open()
	if((setup & CLOSET_HAS_LOCK) && locked)
		return FALSE
	if((setup & CLOSET_CAN_BE_WELDED) && welded)
		return FALSE
	if(dremovable && !cdoor)
		return FALSE
	return TRUE

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src)
			return FALSE
	if(dremovable && !cdoor) // there's nothing to close
		return FALSE
	return TRUE

/obj/structure/closet/proc/dump_contents()
	var/atom/L = drop_location()

	for(var/mob/M in src)
		M.forceMove(L)
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	for(var/atom/movable/AM in src)
		if(AM != cdoor)
			AM.forceMove(L)

/obj/structure/closet/proc/store_contents()
	var/stored_units = 0

	if(storage_types & CLOSET_STORAGE_ITEMS)
		stored_units += store_items(stored_units)
	if(storage_types & CLOSET_STORAGE_MOBS)
		stored_units += store_mobs(stored_units)
	if(storage_types & CLOSET_STORAGE_STRUCTURES)
		stored_units += store_structures(stored_units)

/obj/structure/closet/proc/open(force = FALSE)
	if(opened)
		return FALSE

	if(!can_open() && !force)
		return FALSE

	src.dump_contents()

	src.opened = TRUE
	playsound(src.loc, open_sound, 50, 1, -3)
	density = FALSE
	update_icon()

	if(intact_closet)
		intact_closet = FALSE
		GLOB.intact_station_closets.Remove(src)

	return TRUE

/obj/structure/closet/proc/close()
	if(!src.opened)
		return FALSE
	if(!src.can_close())
		return FALSE

	store_contents()
	src.opened = FALSE

	playsound(src.loc, close_sound, 50, 0, -3)
	density = TRUE

	update_icon()

	return TRUE

#define CLOSET_CHECK_TOO_BIG(x) (stored_units + . + x > storage_capacity)
/obj/structure/closet/proc/store_items(stored_units)
	. = 0

	for(var/obj/effect/dummy/chameleon/AD in loc)
		if(CLOSET_CHECK_TOO_BIG(1))
			break
		.++
		AD.forceMove(src)

	for(var/obj/item/I in loc)
		if(QDELETED(I))
			continue
		if(istype(I,/obj/item/shield/closet))
			break
		if(I.anchored)
			continue
		var/item_size = content_size(I)
		if(CLOSET_CHECK_TOO_BIG(item_size))
			break
		. += item_size
		I.forceMove(src)
		I.pixel_x = 0
		I.pixel_y = 0
		I.pixel_z = 0

/obj/structure/closet/proc/store_mobs(stored_units)
	. = 0
	for(var/mob/living/M in loc)
		if(M.buckled || M.pinned.len || M.anchored)
			continue
		var/mob_size = content_size(M)
		if(CLOSET_CHECK_TOO_BIG(mob_size))
			break
		. += mob_size
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.forceMove(src)

/obj/structure/closet/proc/store_structures(stored_units)
	. = 0

	for(var/obj/structure/S in loc)
		if(S == src)
			continue
		if(S.anchored)
			continue
		var/structure_size = content_size(S)
		if(CLOSET_CHECK_TOO_BIG(structure_size))
			break
		. += structure_size
		S.forceMove(src)

	for(var/obj/machinery/M in loc)
		if(M.anchored)
			continue
		if(istype(M, /obj/machinery/power/supermatter))
			continue
		var/structure_size = content_size(M)
		if(CLOSET_CHECK_TOO_BIG(structure_size))
			break
		. += structure_size
		M.forceMove(src)

#undef CLOSET_CHECK_TOO_BIG

// If you adjust any of the values below, please also update /proc/unit_test_weight_of_path(var/path)
/obj/structure/closet/proc/content_size(atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		return M.mob_size
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		return (I.w_class / 2)
	if(istype(AM, /obj/structure) || istype(AM, /obj/machinery))
		return MOB_LARGE
	return FALSE

/obj/structure/closet/proc/toggle(mob/user)
	if(locked)
		togglelock(user)
	else if(!(src.opened ? src.close() : src.open()))
		if(dremovable && !cdoor)
			to_chat(user, SPAN_NOTICE("There's no door to close!"))
		else
			to_chat(user, SPAN_NOTICE("It won't budge!"))
		update_icon()

// this should probably use dump_contents()
/obj/structure/closet/ex_act(severity)
	switch(severity)
		if(1)
			destroy_door()
			for(var/atom/movable/A in src)//pulls everything out of the locker and hits it with an explosion
				A.forceMove(loc)
				A.ex_act(severity + 1)
			qdel(src)
		if(2)
			if(prob(50))
				if(prob(50))
					destroy_door()
				else
					remove_door()
				for(var/atom/movable/A in src)
					A.forceMove(src.loc)
					A.ex_act(severity + 1)
				qdel(src)
		if(3)
			if(prob(5))
				remove_door()
				for(var/atom/movable/A in src)
					A.forceMove(loc)
				qdel(src)

/obj/structure/closet/proc/damage(damage)
	health -= damage
	if(health <= 0)
		remove_door()
		for(var/atom/movable/A in src)
			A.forceMove(src.loc)
		qdel(src)

/obj/structure/closet/bullet_act(obj/item/projectile/Proj)
	var/proj_damage = Proj.get_structure_damage()
	if(proj_damage)
		..()
		damage(proj_damage)

	if(Proj.penetrating)
		var/distance = get_dist(Proj.starting, get_turf(loc))
		for(var/mob/living/L in contents)
			Proj.attack_mob(L, distance)
			if(!(--Proj.penetrating))
				break

/obj/structure/closet/blob_act()
	if(opened)
		remove_door()
		qdel(src)
	else
		break_open()

/obj/structure/closet/attackby(obj/item/W, mob/user)
	if(src.opened)
		if(istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			src.MouseDrop_T(G.affecting, user)      //act like they were dragged onto the closet
			return FALSE
		if(istype(W,/obj/item/tk_grab))
			return FALSE

		if(isWelder(W))
			var/obj/item/weldingtool/WT = W
			if(WT.use_tool(src, user))
				slice_into_parts(WT, user)
				return

		if(istype(W, /obj/item/storage/laundry_basket) && W.contents.len)
			var/obj/item/storage/laundry_basket/LB = W
			var/turf/T = get_turf(src)
			for(var/obj/item/I in LB.contents)
				LB.remove_from_storage(I, T)
			user.visible_message(SPAN_NOTICE("[user] empties \the [LB] into \the [src]."),
								 \SPAN_NOTICE("You empty \the [LB] into \the [src]."),
								 \SPAN_NOTICE("You hear rustling of clothes."))
			return

		if(isScrewdriver(W) && dremovable && cdoor)
			user.visible_message(SPAN_NOTICE("[user] starts unscrewing [cdoor] from [src]."))
			user.next_move = world.time + 10
			if(!do_after(user, 30))
				return FALSE
			if(!cdoor)
				return FALSE
			if(remove_door())
				user.visible_message(SPAN("notice", "[user] unscrewed [cdoor] from [src]."))
			return

		if(istype(W, /obj/item/shield/closet) && dremovable && !cdoor)
			var/obj/item/shield/closet/C = W
			user.visible_message(SPAN_NOTICE("[user] starts connecting [C] to [src]."))
			user.next_move = world.time + 10
			if(!do_after(user, 20))
				return FALSE
			if(cdoor)
				return FALSE
			if(istype(C.loc, /obj/item/gripper)) // Snowflaaaaakeeeeey
				var/obj/item/gripper/G = C.loc
				G.wrapped.forceMove(get_turf(src))
				G.wrapped = null
			else if(!user.drop(C))
				return
			user.visible_message(SPAN_NOTICE("[user] connected [C] to [src]."))
			attach_door(C)
			return

		if(istype(W.loc, /obj/item/gripper)) // It's kinda tricky, see drone_items.dm L#313 for grippers' resolve_attackby().
			var/obj/item/gripper/G = W.loc
			if(!G.wrapped)
				return
			G.wrapped.forceMove(loc)
			G.wrapped.pixel_x = 0
			G.wrapped.pixel_y = 0
			G.wrapped.pixel_z = 0
			G.wrapped.pixel_w = 0
			G.wrapped = null
			return

		if(usr.drop(W, loc))
			W.pixel_x = 0
			W.pixel_y = 0
			W.pixel_z = 0
			W.pixel_w = 0
		return

	else if(istype(W, /obj/item/melee/energy))
		var/obj/item/melee/energy/WS = W
		if(WS.active)
			emag_act(INFINITY, user, SPAN_DANGER("The locker has been sliced open by [user] with \an [W]!"), SPAN_DANGER("You hear metal being sliced and sparks flying."))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(src.loc, SFX_SPARK, 50, 1)
			open()
	else if(istype(W, /obj/item/packageWrap))
		return
	else if(isWelder(W) && (setup & CLOSET_CAN_BE_WELDED))
		var/obj/item/weldingtool/WT = W
		if(!WT.use_tool(src, user))
			return

		src.welded = !src.welded
		src.update_icon()
		user.visible_message(SPAN_WARNING("\The [src] has been [welded?"welded shut":"unwelded"] by \the [user]."), blind_message = "You hear welding.", range = 3)
	else if(isMultitool(W) && (setup & CLOSET_HAS_LOCK))
		var/obj/item/device/multitool/multi = W
		if(multi.in_use)
			to_chat(user, SPAN("warning", "This multitool is already in use!"))
			return
		multi.in_use = 1
		var/prev_locked = locked
		for(var/i in 1 to rand(4, 8))
			user.visible_message(SPAN("warning", "[user] picks in wires of \the [name] with a multitool."),
								 SPAN("warning", "I am trying to reset circuitry lock module ([i])..."))
			if(!do_after(user, 200, src) || locked != prev_locked || opened || (!istype(src, /obj/structure/closet/crate) && dremovable && !cdoor))
				multi.in_use = 0
				return
		locked = !locked
		broken = !locked
		update_icon()
		multi.in_use = 0
		user.visible_message(SPAN("warning", "[user] [locked ? "locks" : "unlocks"] \the [name] with a multitool."),
							 SPAN("warning", "I [locked ? "enable" : "disable"] the locking modules."))
	else if(setup & CLOSET_HAS_LOCK)
		src.togglelock(user, W)
	else
		src.attack_hand(user)

/obj/structure/closet/proc/slice_into_parts(obj/item/weldingtool/WT, mob/user)
	if(!WT.use_tool(src, user, amount = 1))
		return

	if(material != null)
		new material(loc)
	else
		log_debug("\The [src] doesnt have material, this is bug", loc, type)
	user.visible_message(SPAN_NOTICE("\The [src] has been cut apart by [user] with \the [WT]."), SPAN_NOTICE("You have cut \the [src] apart with \the [WT]."), "You hear welding.")
	remove_door()
	qdel(src)

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/user)
	if(QDELETED(O))
		return
	if(istype(O, /atom/movable/screen))	//fix for HUD elements making their way into the world	-Pete
		return
	if(O.loc == user)
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis)
		return
	if((!( istype(O, /atom/movable) ) || O.anchored || !Adjacent(user) || !Adjacent(O) || !user.Adjacent(O) || user.contents.Find(src)))
		return
	if(!isturf(user.loc)) // are you in a container/closet/pod/etc?
		return
	if(!opened)
		return ..()
	if(istype(O, /obj/structure/closet))
		return
	step_towards(O, src.loc)
	if(user != O)
		user.show_viewers(SPAN_DANGER("[user] stuffs [O] into [src]!"))
	src.add_fingerprint(user)
	return

/obj/structure/closet/attack_ai(mob/user)
	if(istype(user, /mob/living/silicon/robot) && Adjacent(user)) // Robots can open/close it, but not the AI.
		attack_hand(user)

/obj/structure/closet/relaymove(mob/user)
	if(user.stat || !isturf(src.loc))
		return

	if(!src.open())
		to_chat(user, SPAN_NOTICE("It won't budge!"))

/obj/structure/closet/attack_hand(mob/user)
	add_fingerprint(user)
	user.setClickCooldown(2)
	if(in_use)
		to_chat(user, SPAN("warning", "You can't do this right now."))
		return
	in_use = TRUE
	if(open_delay && !do_after(user, open_delay))
		in_use = FALSE
		return
	toggle(user)
	in_use = FALSE

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	src.add_fingerprint(user)
	if(!src.toggle())
		to_chat(usr, SPAN_NOTICE("It won't budge!"))

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!CanPhysicallyInteract(usr))
		return

	if(ishuman(usr))
		attack_hand(usr)
	else
		to_chat(usr, SPAN_WARNING("This mob type can't use this verb."))

/obj/structure/closet/on_update_icon()//Putting the welded stuff in update_icon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	ClearOverlays()

	if(dremovable)
		icon_state = "[icon_closed]nodoor"
		if(cdoor)
			if(!opened)
				if(broken && icon_off)
					var/icon/cdoor_icon = new /icon("icon" = 'icons/obj/closet_doors.dmi', "icon_state" = "[cdoor.icon_off]")
					AddOverlays(cdoor_icon)
					AddOverlays(icon_broken)
				else if((setup & CLOSET_HAS_LOCK) && locked && cdoor.icon_locked)
					var/icon/cdoor_icon = new /icon("icon" = 'icons/obj/closet_doors.dmi', "icon_state" = "[cdoor.icon_locked]")
					AddOverlays(cdoor_icon)
				else
					var/icon/cdoor_icon = new /icon("icon" = 'icons/obj/closet_doors.dmi', "icon_state" = "[cdoor.icon_closed]")
					AddOverlays(cdoor_icon)
				if(welded)
					AddOverlays("welded")
			else
				var/icon/cdoor_icon = new /icon("icon" = 'icons/obj/closet_doors.dmi', "icon_state" = "[cdoor.icon_opened]")
				AddOverlays(cdoor_icon)
	else
		if(!opened)
			if(broken && icon_off)
				icon_state = icon_off
				AddOverlays(icon_broken)
			else if((setup & CLOSET_HAS_LOCK) && locked && icon_locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
			if(welded)
				AddOverlays("welded")
		else
			icon_state = icon_opened

/obj/structure/closet/attack_generic(mob/user, damage, attack_message = "destroys", wallbreaker)
	if(!damage || !wallbreaker)
		return
	attack_animation(user)
	visible_message(SPAN_DANGER("[user] [attack_message] the [src]!"))
	dump_contents()
	spawn(1) qdel(src)
	return TRUE

/obj/structure/closet/proc/req_breakout()
	if(opened)
		return FALSE //Door's open... wait, why are you in it's contents then?
	if((setup & CLOSET_HAS_LOCK) && locked)
		return TRUE // Closed and locked
	if(welded)
		return TRUE // Welded
	return (!welded) //closed but not welded...

/obj/structure/closet/proc/mob_breakout(mob/living/escapee)
	var/breakout_time = 2 //2 minutes by default

	if(breakout || !req_breakout())
		return

	if(locked && welded)
		breakout_time = 3 //3 minutes for welded+locked closets

	escapee.setClickCooldown(100)

	//okay, so the closet is either welded or locked... resist!!!
	if(istype(src, /obj/structure/closet/body_bag))
		to_chat(escapee, SPAN_WARNING("You're trying to open \the [src] from the inside. (this will take about [breakout_time] minutes)"))
	else
		to_chat(escapee, SPAN_WARNING("You lean on the back of \the [src] and start pushing the door open. (this will take about [breakout_time] minutes)"))

	if(isturf(loc))
		visible_message(SPAN_DANGER("\The [src] begins to shake violently!"))

	breakout = 1 //can't think of a better way to do this right now.
	for(var/i in 1 to (6*breakout_time * 2)) //minutes * 6 * 5seconds * 2
		if(!do_after(escapee, 50, incapacitation_flags = INCAPACITATION_DEFAULT & ~(INCAPACITATION_RESTRAINED | INCAPACITATION_FORCELYING))) //5 seconds
			breakout = 0
			return
		//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
		if(!req_breakout())
			breakout = 0
			return

		playsound(src.loc, 'sound/effects/grillehit.ogg', 100, 1)
		shake_animation()
		add_fingerprint(escapee)

	//Well then break it!
	breakout = FALSE
	to_chat(escapee, SPAN_WARNING("You successfully break out!"))
	visible_message(SPAN_DANGER("\The [escapee] successfully broke out of \the [src]!"))
	playsound(src.loc, 'sound/effects/grillehit.ogg', 100, 1)
	break_open()
	shake_animation()

/obj/structure/closet/proc/break_open()
	welded = FALSE

	if((setup & CLOSET_HAS_LOCK) && locked)
		make_broken()

	//Do this to prevent contents from being opened into nullspace (read: bluespace)
	if(istype(loc, /obj/structure/bigDelivery))
		var/obj/structure/bigDelivery/BD = loc
		BD.unwrap()
	open()
	if(dremovable)
		remove_door()

/obj/structure/closet/onDropInto(atom/movable/AM)
	return

// If we use the /obj/structure/closet/proc/togglelock variant BYOND asks the user to select an input for id_card, which is then mostly irrelevant.
/obj/structure/closet/proc/togglelock_verb()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	return togglelock(usr)

/obj/structure/closet/proc/togglelock(mob/user, obj/item/card/id/id_card)
	if(!(setup & CLOSET_HAS_LOCK))
		return FALSE
	if(!CanPhysicallyInteract(user))
		return FALSE
	if(src.opened)
		to_chat(user, SPAN_NOTICE("Close \the [src] first."))
		return FALSE
	if(src.broken)
		to_chat(user, SPAN_WARNING("\The [src] appears to be broken."))
		return FALSE
	if(user.loc == src)
		to_chat(user, SPAN_NOTICE("You can't reach the lock from inside."))
		return FALSE

	add_fingerprint(user)

	if(!user.IsAdvancedToolUser(1))
		to_chat(user, FEEDBACK_YOU_LACK_DEXTERITY)
		return FALSE

	if(CanToggleLock(user, id_card))
		locked = !locked
		visible_message(SPAN_NOTICE("\The [src] has been [locked ? null : "un"]locked by \the [user]."), range = 3)
		update_icon()
		return TRUE
	else
		to_chat(user, SPAN_WARNING("Access denied!"))
		return FALSE

/obj/structure/closet/proc/CanToggleLock(mob/user, obj/item/card/id/id_card)
	return allowed(user) || (istype(id_card) && check_access_list(id_card.GetAccess()))

/obj/structure/closet/AltClick(mob/user)
	if(!src.opened)
		togglelock(user)
	else
		return ..()

/obj/structure/closet/CtrlAltClick(mob/user)
	verb_toggleopen()

/obj/structure/closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && (setup & CLOSET_HAS_LOCK))
		if(prob(50/severity))
			locked = !locked
			src.update_icon()
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				src.req_access = list()
				src.req_access += pick(get_all_station_access())
	..()

/obj/structure/closet/emag_act(remaining_charges, mob/user, obj/item/emag_source, visual_feedback = "", audible_feedback = "")
	if(make_broken())
		update_icon()
		if(visual_feedback)
			visible_message(visual_feedback, audible_feedback)
		else if(user && emag_source)
			visible_message(SPAN_WARNING("\The [src] has been broken by \the [user] with \an [emag_source]!"), "You hear a faint electrical spark.")
		else
			visible_message(SPAN_WARNING("\The [src] sparks and breaks open!"), "You hear a faint electrical spark.")
		on_hack_behavior()
		return TRUE
	else
		. = ..()

/obj/structure/closet/proc/make_broken()
	if(broken)
		return FALSE
	if(!(setup & CLOSET_HAS_LOCK))
		return FALSE
	broken = TRUE
	locked = FALSE
	desc += " It appears to be broken."
	return TRUE

/obj/structure/closet/proc/remove_door()
	if(!cdoor)
		return FALSE
	if(welded || locked)
		return FALSE
	open(TRUE)
	broken = FALSE
	locked = FALSE
	cdoor.forceMove(loc)
	cdoor.update_icon()
	cdoor = null

	setup = CLOSET_CAN_BE_WELDED

	update_icon()

	return TRUE

/obj/structure/closet/proc/attach_door(obj/item/shield/closet/C)
	if(cdoor)
		return FALSE
	broken = FALSE
	locked = FALSE
	C.forceMove(src)
	cdoor = C

	req_access = cdoor.req_access
	req_one_access = cdoor.req_one_access

	if(cdoor.lockable)
		setup = CLOSET_HAS_LOCK

	cdoor.update_icon()
	update_icon()

	return TRUE

/obj/structure/closet/proc/destroy_door()
	if(!cdoor)
		return FALSE
	var/obj/item/shield/closet/C = cdoor
	remove_door()
	qdel(C)
	return TRUE

/obj/structure/closet/hides_inside_walls() // Let's just don't
	return FALSE

/obj/structure/closet/proc/on_hack_behavior()
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)
	spark_system.start()
	playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
	playsound(src.loc, "spark", 50, 1)
	open()

/obj/structure/closet/allow_drop()
	return TRUE
