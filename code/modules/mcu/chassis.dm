/obj/item/mcu_chassis
	name = "MCU chassis"

	var/locked = TRUE
	var/obj/item/device/mcu/__mcu = null
	var/max_health = 10
	var/has_external_power_source = FALSE
	/// W/K
	var/cooling_bonus = 0

/obj/item/mcu_chassis/Initialize()
	. = ..()

	health = max_health

/obj/item/mcu_chassis/Destroy()
	if(!QDELETED(__mcu))
		__mcu.__chassis = null
		qdel(__mcu)
		__mcu = null

	. = ..()

/obj/item/mcu_chassis/emp_act(severity)
	if(!QDELETED(__mcu))
		__mcu.emp_act(severity)

	return ..()

/obj/item/mcu_chassis/bullet_act(obj/item/projectile/P, def_zone)
	..()

	health -= P.damage

	if(health <= 0)
		destroy()

/obj/item/mcu_chassis/ex_act(severity)
	destroy()

/obj/item/mcu_chassis/melt()
	..()

	qdel(src)

/obj/item/mcu_chassis/proc/destroy()
	visible_message(SPAN_DANGER("\The [src] breaks apart!"))

	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
	sparks.set_up(3, 1, get_turf(src))
	sparks.start()

	if(!QDELETED(__mcu))
		__mcu.power_off(null, FALSE)
		
		if(prob(25))
			__mcu.destroy(prob(50))

		if(!QDELETED(__mcu))
			__mcu.forceMove(get_turf(src))
			__mcu.throw_at_random(FALSE, 2, 1)
			__mcu.__chassis = null

		__mcu = null

	qdel(src)

/obj/item/mcu_chassis/proc/health_percentage()
	if(!max_health)
		return 0

	return (health / max_health) * 100

/obj/item/mcu_chassis/proc/examine_health()
	switch(health_percentage())
		if(-INFINITY to 25)
			return SPAN_DANGER("\The [src] looks seriously damaged, and probably won't last much more.")
		if(26 to 50)
			return SPAN_NOTICE("\The [src] looks damaged.")
		if(51 to 75)
			return "\The [src] looks slightly damaged."
		if(76 to 99)
			return "\The [src] has few dents."
		if(99 to INFINITY)
			return "\The [src] is in excellent condition."

/obj/item/mcu_chassis/examine(mob/user, infix)
	. = ..()

	if(!user.IsAdvancedToolUser())
		return
	
	if(user.Adjacent(src))
		if(QDELETED(__mcu) || !__mcu.is_on())
			. += "\The [src] is off"
		else
			. += "\The [src] is on"

		. += examine_health()

/obj/item/mcu_chassis/proc/try_drain_power(amount)
	return FALSE

/obj/item/mcu_chassis/attackby(obj/item/W, mob/user)
	if(!user.IsAdvancedToolUser())
		return ..()

	if(isScrewdriver(W))
		locked = !locked
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		
		if(locked)
			user.visible_message("[user] screws \the [src]", "You screwed up \the [src]")
		else
			user.visible_message("[user] unscrews \the [src]", "You unscrew \the [src]")

		return
	else if(istype(W, /obj/item/device/mcu))
		if(!try_insert_mcu(W, user, FALSE))
			return

		user.visible_message("[user] inserts \the [W] into \the [src]", "You insert \the [W] into \the [src]")

		return
	else if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W

		if(health >= max_health)
			return
		
		if(!WT.use_tool(src, user, 3 SECONDS, 5))
			return

		health = clamp(health + 5, 0, max_health)
		user.visible_message("[user] solders damage on \the [src]", "You solder damage on \the [src]")
		
		return

	return ..()

/obj/item/mcu_chassis/attack_self(mob/user)
	if(!user.IsAdvancedToolUser())
		return ..()

	if(QDELETED(__mcu))
		return ..()
	
	if(__mcu.__interact(user))
		return
	
	return ..()

/obj/item/mcu_chassis/proc/__on_mcu_on()
	return

/obj/item/mcu_chassis/proc/__on_mcu_off(is_trap = FALSE)
	return

/obj/item/mcu_chassis/proc/__on_mcu_insert()
	return

/obj/item/mcu_chassis/proc/__on_mcu_eject()
	return

/obj/item/mcu_chassis/proc/try_insert_mcu(obj/item/device/mcu/M, mob/activator = null, ignore_locked = FALSE)
	if(!ignore_locked && locked)
		if(activator != null)
			to_chat(activator, SPAN_WARNING("\The [src] is locked."))

		return FALSE
	
	if(!QDELETED(__mcu))
		if(activator != null)
			to_chat(activator, SPAN_WARNING("There is already a MCU in the chassis."))

		return FALSE

	ASSERT(M.__chassis == null)

	if(M.is_on())
		if(activator != null)
			to_chat(activator, SPAN_WARNING("Turn off \the [M] before inserting it."))

		return FALSE

	if(activator)
		if(!activator.drop(M, src))
			return FALSE
	else
		M.forceMove(src)

	__mcu = M
	M.__chassis = weakref(src)
	__on_mcu_insert()

	return TRUE

/obj/item/mcu_chassis/verb/eject_mcu()
	set src in view(1)
	set name = "Eject MCU"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return
	
	if(locked)
		to_chat(usr, SPAN_WARNING("\The [src] is locked."))
		return

	if(QDELETED(__mcu))
		to_chat(usr, SPAN_WARNING("There is no MCU in the chassis."))
		return
	
	var/obj/item/device/mcu/M = __mcu
	
	if(M.is_on())
		to_chat(usr, SPAN_WARNING("Turn off \the [M] before ejecting it."))
		return

	__mcu = null
	M.__chassis = null

	if(!usr.put_in_hands(M))
		M.forceMove(get_turf(src))

	usr.visible_message("[usr] ejects \the [M] from \the [src]", "You eject \the [M] from \the [src]")

	__on_mcu_eject()

/obj/item/mcu_chassis/verb/turn_on()
	set src in view(1)
	set name = "Turn On"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return

	__mcu?.power_on(usr)

/obj/item/mcu_chassis/verb/turn_off()
	set src in view(1)
	set name = "Turn Off"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return

	__mcu?.power_off(usr)
