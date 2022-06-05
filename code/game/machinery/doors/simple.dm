/obj/machinery/door/unpowered/simple
	name = "door"
	icon = 'icons/obj/doors/material_doors.dmi'
	icon_state = "metal"

	var/material/material
	var/icon_base
	hitsound = 'sound/effects/fighting/genhit.ogg'
	var/datum/lock/lock
	var/initial_lock_value //for mapping purposes. Basically if this value is set, it sets the lock to this value.


/obj/machinery/door/unpowered/simple/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	TemperatureAct(exposed_temperature)

/obj/machinery/door/unpowered/simple/proc/TemperatureAct(temperature)
	take_damage(100*material.combustion_effect(get_turf(src),temperature, 0.3))

/obj/machinery/door/unpowered/simple/New(newloc, material_name, locked)
	..()
	if(!material_name)
		material_name = MATERIAL_STEEL
	material = get_material_by_name(material_name)
	if(!material)
		qdel(src)
		return
	maxhealth = max(100, material.integrity*10)
	health = maxhealth
	if(!icon_base)
		icon_base = material.door_icon_base
	hitsound = material.hitsound
	name = "[material.display_name] door"
	color = material.icon_colour
	if(initial_lock_value)
		locked = initial_lock_value
	if(locked)
		lock = new(src,locked)

	if(material.opacity < 0.5)
		glass = 1
		set_opacity(0)
	else
		set_opacity(1)
	update_icon()

/obj/machinery/door/unpowered/simple/requiresID()
	return 0

/obj/machinery/door/unpowered/simple/get_material()
	return material

/obj/machinery/door/unpowered/simple/get_material_name()
	return material.name

/obj/machinery/door/unpowered/simple/bullet_act(obj/item/projectile/Proj)
	var/damage = Proj.get_structure_damage()
	if(damage)
		//cap projectile damage so that there's still a minimum number of hits required to break the door
		take_damage(min(damage, 100))

/obj/machinery/door/unpowered/simple/update_icon()
	if(density)
		icon_state = "[icon_base]"
	else
		icon_state = "[icon_base]open"
	return

/obj/machinery/door/unpowered/simple/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[icon_base]opening", src)
		if("closing")
			flick("[icon_base]closing", src)
	return

/obj/machinery/door/unpowered/simple/inoperable(additional_flags = 0)
	return (stat & (BROKEN|additional_flags))

/obj/machinery/door/unpowered/simple/close(forced = 0)
	if(!can_close(forced))
		return
	playsound(src.loc, material.dooropen_noise, 100, 1)
	..()

/obj/machinery/door/unpowered/simple/open(forced = 0)
	if(!can_open(forced))
		return
	playsound(src.loc, material.dooropen_noise, 100, 1)
	..()

/obj/machinery/door/unpowered/simple/set_broken(new_state)
	..()
	if(new_state)
		deconstruct(null)

/obj/machinery/door/unpowered/simple/deconstruct(mob/user, moved = FALSE)
	material.place_dismantled_product(get_turf(src))
	qdel(src)

/obj/machinery/door/unpowered/simple/attack_ai(mob/user as mob) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user)) //but cyborgs can
		if(Adjacent(user)) //not remotely though
			return attack_hand(user)

/obj/machinery/door/unpowered/simple/ex_act(severity)
	switch(severity)
		if(1.0)
			set_broken(TRUE)
		if(2.0)
			if(prob(25))
				set_broken(TRUE)
			else
				take_damage(300)
		if(3.0)
			if(prob(20))
				take_damage(150)


/obj/machinery/door/unpowered/simple/attackby(obj/item/I as obj, mob/user as mob)
	src.add_fingerprint(user, 0, I)
	if(istype(I, /obj/item/key) && lock)
		var/obj/item/key/K = I
		if(!lock.toggle(I))
			to_chat(user, "<span class='warning'>\The [K] does not fit in the lock!</span>")
		return
	if(lock && lock.pick_lock(I,user))
		return

	if(istype(I,/obj/item/material/lock_construct))
		if(lock)
			to_chat(user, "<span class='warning'>\The [src] already has a lock.</span>")
		else
			var/obj/item/material/lock_construct/L = I
			lock = L.create_lock(src,user)
		return

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
		var/obj/item/stack/stack = I
		var/amount_needed = ceil((maxhealth - health)/DOOR_REPAIR_AMOUNT)
		var/used = min(amount_needed,stack.amount)
		if (used)
			to_chat(user, "<span class='notice'>You fit [used] [stack.singular_name]\s to damaged and broken parts on \the [src].</span>")
			stack.use(used)
			health = between(health, health + used*DOOR_REPAIR_AMOUNT, maxhealth)
		return

	//psa to whoever coded this, there are plenty of objects that need to call attack() on doors without bludgeoning them.
	if(density && user.a_intent == I_HURT && !(istype(I, /obj/item/card) || istype(I, /obj/item/device/pda)))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if(I.damtype == BRUTE || I.damtype == BURN)
			user.do_attack_animation(src)
			if(I.force <= 0)
				user.visible_message(SPAN("notice", "\The [user] smacks \the [src] with \the [I] with no visible effect."))
				playsound(loc, hitsound, 5, 1)
			else if(I.force < min_force)
				user.visible_message("<span class='danger'>\The [user] hits \the [src] with \the [I] with no visible effect.</span>")
				playsound(loc, hitsound, 10, 1)
			else
				user.visible_message("<span class='danger'>\The [user] forcefully strikes \the [src] with \the [I]!</span>")
				playsound(loc, hitsound, 100, 1)
				take_damage(I.force)
		return

	if(src.operating) return

	if(lock && lock.isLocked())
		to_chat(user, "\The [src] is locked!")

	if(operable())
		if(src.density)
			open()
		else
			close()
		return

	return

/obj/machinery/door/unpowered/simple/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 1 && lock)
		. += "\n<span class='notice'>It appears to have a lock.</span>"

/obj/machinery/door/unpowered/simple/can_open()
	if(!..() || (lock && lock.isLocked()))
		return 0
	return 1

/obj/machinery/door/unpowered/simple/Destroy()
	qdel(lock)
	lock = null

	return ..()

/obj/machinery/door/unpowered/simple/iron/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_IRON, complexity)

/obj/machinery/door/unpowered/simple/silver/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_SILVER, complexity)

/obj/machinery/door/unpowered/simple/gold/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_GOLD, complexity)

/obj/machinery/door/unpowered/simple/uranium/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_URANIUM, complexity)

/obj/machinery/door/unpowered/simple/sandstone/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_SANDSTONE, complexity)

/obj/machinery/door/unpowered/simple/diamond/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_DIAMOND, complexity)

/obj/machinery/door/unpowered/simple/wood
	icon_state = "wood"
	color = "#824b28"

/obj/machinery/door/unpowered/simple/wood/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_WOOD, complexity)

/obj/machinery/door/unpowered/simple/wood/saloon
	icon_base = "saloon"
	autoclose = 1
	normalspeed = 0

/obj/machinery/door/unpowered/simple/wood/saloon/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_WOOD, complexity)
	glass = 1
	set_opacity(0)

/obj/machinery/door/unpowered/simple/resin/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_RESIN, complexity)

/obj/machinery/door/unpowered/simple/resin/allowed(mob/M)
	if(istype(M, /mob/living/carbon/alien/larva))
		return TRUE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.internal_organs_by_name[BP_HIVE])
			return TRUE
	return FALSE

/obj/machinery/door/unpowered/simple/resin/attackby(obj/item/I, mob/user) // It's much more simple that the other doors, no lock support etc.
	add_fingerprint(user, 0, I)
	if(user.a_intent == I_HURT)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if(I.damtype == BRUTE || I.damtype == BURN)
			user.do_attack_animation(src)
			if(I.force < min_force)
				user.visible_message(SPAN("danger", "\The [user] hits \the [src] with \the [I] with no visible effect."))
			else
				user.visible_message(SPAN("danger", "\The [user] forcefully strikes \the [src] with \the [I]!"))
				playsound(loc, hitsound, 100, 1)
				take_damage(I.force)
			return

	if(operating)
		return

	if(allowed(user))
		if(density)
			open()
		else
			close()

/obj/machinery/door/unpowered/simple/cult/New(newloc,material_name,complexity)
	..(newloc, MATERIAL_CULT, complexity)
