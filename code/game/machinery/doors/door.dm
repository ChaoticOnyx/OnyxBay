//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
#define DOOR_REPAIR_AMOUNT 50	//amount of health regained per stack amount used

/obj/machinery/door
	name = "Door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	can_atmos_pass = ATMOS_PASS_PROC
	atom_flags = ATOM_FLAG_FULLTILE_OBJECT
	layer = CLOSED_DOOR_LAYER
	hitby_sound = 'sound/effects/metalhit2.ogg'
	var/open_layer = OPEN_DOOR_LAYER
	var/closed_layer = CLOSED_DOOR_LAYER

	var/visible = 1
	var/p_open = 0
	var/operating = 0
	var/autoclose = 0
	var/glass = 0
	var/normalspeed = 1
	var/heat_proof = 0 // For glass airlocks/opacity firedoors
	var/air_properties_vary_with_direction = 0
	var/maxhealth = 300
	var/health
	var/destroy_hits = 10 //How many strong hits it takes to destroy the door
	var/min_force = 10 //minimum amount of force needed to damage the door with a melee weapon
	var/hitsound = 'sound/effects/metalhit2.ogg' //sound door makes when hit with a weapon
	var/obj/item/stack/material/repairing
	var/block_air_zones = 1 //If set, air zones cannot merge across the door even when it is opened.
	//Multi-tile doors
	var/width = 1
	var/turf/filler
	var/tryingToLock = FALSE // for autoclosing
	// turf animation
	var/atom/movable/fake_overlay/c_animation = null
	/// Determines whether this door already has thinkg_close context running or not
	var/thinking_about_closing = FALSE
	rad_resist_type = /datum/rad_resist/door

/datum/rad_resist/door
	alpha_particle_resist = 350 MEGA ELECTRONVOLT
	beta_particle_resist = 0.5 MEGA ELECTRONVOLT
	hawking_resist = 81 MILLI ELECTRONVOLT

/obj/machinery/door/Initialize()
	. = ..()
	add_think_ctx("close_context", CALLBACK(src, nameof(.proc/close)), 0)

/obj/machinery/door/attack_generic(mob/user, damage)
	if(damage >= 10)
		visible_message("<span class='danger'>\The [user] smashes into \the [src]!</span>")
		take_damage(damage)
	else
		visible_message("<span class='notice'>\The [user] bonks \the [src] harmlessly.</span>")
	attack_animation(user)

/obj/machinery/door/New()
	. = ..()
	GLOB.all_doors += src
	if(density)
		layer = closed_layer
		explosion_resistance = initial(explosion_resistance)
		update_heat_protection(get_turf(src))
	else
		layer = open_layer
		explosion_resistance = 0
		atom_flags &= ~ATOM_FLAG_FULLTILE_OBJECT


	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
			filler = get_step(src, EAST)
			filler.set_opacity(opacity)
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size
			filler = get_step(src, NORTH)
			filler.set_opacity(opacity)

	health = maxhealth
	update_icon()

	update_nearby_tiles(need_rebuild=1)
	return

/obj/machinery/door/Destroy()
	GLOB.all_doors -= src
	if(filler && width > 1)
		filler.set_opacity(initial(filler.opacity))
		filler = null
	set_density(0)
	update_nearby_tiles()
	. = ..()

/obj/machinery/door/proc/can_open(forced = 0)
	if(!density || operating)
		return FALSE
	return TRUE

/obj/machinery/door/proc/can_close(forced = 0)
	if(density || operating)
		return FALSE
	return TRUE

/obj/machinery/door/Bumped(atom/AM)
	if(p_open || operating) return
	if(ismob(AM))
		var/mob/M = AM
		if(world.time - M.last_bumped <= 10) return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		if(!M.restrained() && (!issmall(M) || ishuman(M)))
			bumpopen(M)
		return

	if(istype(AM, /mob/living/bot))
		var/mob/living/bot/bot = AM
		if(src.check_access(bot.botcard))
			if(density)
				open()
		return

	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access)))
				open()
			else
				do_animate("deny")
		return
	if(istype(AM, /obj/structure/bed/chair/wheelchair))
		var/obj/structure/bed/chair/wheelchair/wheel = AM
		if(density)
			if(wheel.pulling && (src.allowed(wheel.pulling)))
				open()
			else
				do_animate("deny")
		return
	return


/obj/machinery/door/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return !opacity
	return !density

/obj/machinery/door/CanZASPass(turf/T, is_zone)
	if(is_zone)
		return !block_air_zones
	return !density


/obj/machinery/door/proc/bumpopen(mob/user)
	if(operating)	return
	if(user.last_airflow > world.time - vsc.airflow_delay) //Fakkit
		return
	src.add_fingerprint(user)
	if(density)
		if(allowed(user))	open()
		else				do_animate("deny")
	return

/obj/machinery/door/bullet_act(obj/item/projectile/Proj)
	..()

	var/damage = Proj.get_structure_damage()

	// Emitter Blasts - these will eventually completely destroy the door, given enough time.
	if(damage > 90)
		destroy_hits--
		if(destroy_hits <= 0)
			visible_message("<span class='danger'>\The [src.name] disintegrates!</span>")
			switch (Proj.damage_type)
				if(BRUTE)
					new /obj/item/stack/material/steel(src.loc, 2)
					new /obj/item/stack/rods(src.loc, 3)
				if(BURN)
					new /obj/effect/decal/cleanable/ash(src.loc) // Turn it to ashes!
			qdel(src)

	if(damage)
		//cap projectile damage so that there's still a minimum number of hits required to break the door
		take_damage(min(damage, 100))


/obj/machinery/door/hitby(atom/movable/AM, speed = 1, nomsg = FALSE)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 15 * (speed/5)
	else
		tforce = AM:throwforce * (speed/5)
	take_damage(tforce)
	return

/obj/machinery/door/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/door/attack_hand(mob/user)
	return src.attackby(user, user)

/obj/machinery/door/attack_tk(mob/user)
	if(requiresID() && !allowed(null))
		return
	..()

/obj/machinery/door/attackby(obj/item/I, mob/user)
	src.add_fingerprint(user, 0, I)

	if(istype(I, /obj/item/stack/material) && I.get_material_name() == src.get_material_name())
		if(stat & BROKEN)
			to_chat(user, "<span class='notice'>It looks like \the [src] is pretty busted. It's going to need more than just patching up now.</span>")
			return
		if(health >= maxhealth)
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
			return
		if(!density)
			to_chat(user, "<span class='warning'>\The [src] must be closed before you can repair it.</span>")
			return

		//figure out how much metal we need
		var/amount_needed = (maxhealth - health) / DOOR_REPAIR_AMOUNT
		amount_needed = ceil(amount_needed)

		var/obj/item/stack/stack = I
		var/transfer
		if(repairing)
			transfer = stack.transfer_to(repairing, amount_needed - repairing.amount)
			if(!transfer)
				to_chat(user, "<span class='warning'>You must weld or remove \the [repairing] from \the [src] before you can add anything else.</span>")
		else
			repairing = stack.split(amount_needed, force=TRUE)
			if(repairing)
				repairing.forceMove(src)
				transfer = repairing.amount
				repairing.uses_charge = FALSE //for clean robot door repair - stacks hint immortal if true

		if(transfer)
			to_chat(user, "<span class='notice'>You fit [transfer] [stack.singular_name]\s to damaged and broken parts on \the [src].</span>")

		return

	if(repairing && isWelder(I))
		if(!density)
			to_chat(user, "<span class='warning'>\The [src] must be closed before you can repair it.</span>")
			return

		var/obj/item/weldingtool/WT = I

		to_chat(user, SPAN_NOTICE("You start to fix dents and weld \the [repairing] into place."))
		if(!WT.use_tool(src, user, delay = 5 * repairing.amount, amount = 5))
			return

		if(QDELETED(src) || !user)
			return

		to_chat(user, SPAN_NOTICE("You finish repairing the damage to \the [src]."))
		health = between(health, health + repairing.amount*DOOR_REPAIR_AMOUNT, maxhealth)
		update_icon()
		qdel(repairing)
		repairing = null
		return

	if(repairing && isCrowbar(I))
		to_chat(user, "<span class='notice'>You remove \the [repairing].</span>")
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		repairing.dropInto(user.loc)
		repairing = null
		return

	//psa to whoever coded this, there are plenty of objects that need to call attack() on doors without bludgeoning them.
	if(isobj(I) && density && user.a_intent == I_HURT && !(istype(I, /obj/item/card) || istype(I, /obj/item/device/pda)))
		if(I.damtype == BRUTE || I.damtype == BURN)
			user.do_attack_animation(src)
			user.setClickCooldown(I.update_attack_cooldown())
			if(I.force <= 0)
				user.visible_message(SPAN("notice", "\The [user] smacks \the [src] with \the [I] with no visible effect."))
				playsound(loc, hitsound, 10, 1)
			else if(I.force < min_force)
				user.visible_message("<span class='danger'>\The [user] hits \the [src] with \the [I] with no visible effect.</span>")
				playsound(loc, hitsound, 25, 1)
			else
				user.visible_message("<span class='danger'>\The [user] forcefully strikes \the [src] with \the [I]!</span>")
				playsound(loc, hitsound, 100, 1)
				take_damage(I.force)
				shake_animation(3, 3)
		return

	if(src.operating > 0 || isrobot(user))	return //borgs can't attack doors open because it conflicts with their AI-like interaction with them.

	if(src.operating) return

	if(allowed(user) && operable())
		density ? open() : close()
		return

	if(src.density)
		do_animate("deny")
	return

/obj/machinery/door/emag_act(remaining_charges)
	if(density && operable())
		do_animate("spark")
		sleep(6)
		open()
		operating = -1
		return 1

/obj/machinery/door/proc/take_damage(damage)
	var/initialhealth = src.health
	src.health = max(0, src.health - damage)
	if(src.health <= 0 && initialhealth > 0)
		src.set_broken(TRUE)
	else if(src.health < src.maxhealth / 4 && initialhealth >= src.maxhealth / 4)
		visible_message("\The [src] looks like it's about to break!" )
	else if(src.health < src.maxhealth / 2 && initialhealth >= src.maxhealth / 2)
		visible_message("\The [src] looks seriously damaged!" )
	else if(src.health < src.maxhealth * 3/4 && initialhealth >= src.maxhealth * 3/4)
		visible_message("\The [src] shows signs of damage!" )
	update_icon()
	return


/obj/machinery/door/examine(mob/user, infix)
	. = ..()

	if(health < maxhealth / 4)
		. += "\The [src] looks like it's about to break!"
	else if(src.health < src.maxhealth / 2)
		. += "\The [src] looks seriously damaged!"
	else if(src.health < src.maxhealth * 3/4)
		. += "\The [src] shows signs of damage!"


/obj/machinery/door/set_broken(new_state)
	. = ..()
	if(. && new_state)
		visible_message("<span class = 'warning'>\The [src.name] breaks!</span>")

/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(25))
				qdel(src)
			else
				take_damage(300)
		if(3.0)
			if(prob(80))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
			else
				take_damage(150)
	return


/obj/machinery/door/on_update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"
	return


/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(p_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("spark")
			if(density)
				flick("door_spark", src)
		if("deny")
			if(density && !(stat & (NOPOWER|BROKEN)))
				flick("door_deny", src)
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
	return


/obj/machinery/door/proc/open(forced = FALSE)
	var/wait = normalspeed ? 150 : 5
	if(!can_open(forced))
		return FALSE
	operating = TRUE

	do_animate("opening")
	icon_state = "door0"
	set_opacity(FALSE)
	if(filler)
		filler.set_opacity(opacity)
	sleep(3)
	set_density(FALSE)
	update_nearby_tiles()
	atom_flags &= ~ATOM_FLAG_FULLTILE_OBJECT
	sleep(7)
	layer = open_layer
	explosion_resistance = 0
	update_icon()
	set_opacity(FALSE)
	if(filler)
		filler.set_opacity(opacity)
	operating = FALSE

	if(autoclose && !thinking_about_closing)
		thinking_about_closing = TRUE
		set_next_think_ctx("close_context", world.time + wait)

	return TRUE

/obj/machinery/door/proc/close(forced = FALSE, push_mobs = TRUE)
	var/wait = normalspeed ? 150 : 5
	if(!can_close(forced))
		if(autoclose)
			tryingToLock = TRUE
			set_next_think_ctx("close_context", world.time + wait)
		return FALSE

	thinking_about_closing = FALSE
	operating = TRUE

	do_animate("closing")
	sleep(3)
	set_density(TRUE)
	explosion_resistance = initial(explosion_resistance)
	layer = closed_layer
	update_nearby_tiles()
	atom_flags |= ATOM_FLAG_FULLTILE_OBJECT
	sleep(7)
	update_icon()
	if(visible && !glass)
		set_opacity(TRUE) //caaaaarn!
		if(filler)
			filler.set_opacity(opacity)
	operating = FALSE

	shove_everything(shove_mobs = push_mobs, min_w_class = ITEM_SIZE_NORMAL) // Door shields cheesy meta must be gone.

	//I shall not add a check every x ticks if a door has closed over some fire.
	var/obj/fire/fire = locate() in loc
	if(fire)
		qdel(fire)
	return TRUE

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/allowed(mob/M)
	if(!requiresID())
		return ..(null) //don't care who they are or what they have, act as if they're NOTHING
	return ..(M)

/obj/machinery/door/update_nearby_tiles(need_rebuild)
	. = ..()
	for(var/turf/simulated/turf in locs)
		update_heat_protection(turf)
		SSair.mark_for_update(turf)
	return 1

/obj/machinery/door/proc/update_heat_protection(turf/simulated/source)
	if(istype(source))
		if(src.density && (src.opacity || src.heat_proof))
			source.thermal_conductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)

/obj/machinery/door/Move(new_loc, new_dir)
	update_nearby_tiles()

	. = ..()
	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
			filler.set_opacity(initial(filler.opacity))
			filler = (get_step(src, EAST)) //Find new turf
			filler.set_opacity(opacity)
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size
			filler.set_opacity(initial(filler.opacity))
			filler = (get_step(src, NORTH)) //Find new turf
			filler.set_opacity(opacity)

	if(.)
		deconstruct(null, TRUE)


/obj/machinery/door/proc/deconstruct(mob/user, moved = FALSE)
	return null

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'
