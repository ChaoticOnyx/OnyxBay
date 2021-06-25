/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	dir = EAST
	var/id = null  // for blast door button that can work with windoors now
	min_force = 4
	hitsound = null
	maxhealth = 150 //If you change this, consiter changing ../door/window/brigdoor/ health at the bottom of this .dm file
	health = 150
	visible = 0.0
	use_power = POWER_USE_OFF
	atom_flags = ATOM_FLAG_CHECKS_BORDER
	opacity = 0
	var/obj/item/weapon/airlock_electronics/electronics = null
	explosion_resistance = 5
	can_atmos_pass = ATMOS_PASS_PROC
	air_properties_vary_with_direction = 1
	var/timer = null
	hitby_sound = "glass_hit"

/obj/machinery/door/window/Initialize()
	. = ..()
	update_nearby_tiles()
	update_icon()
	hitsound = pick(
		'sound/effects/materials/glass/knock1.ogg',
		'sound/effects/materials/glass/knock2.ogg',
		'sound/effects/materials/glass/knock3.ogg',
	)

/obj/machinery/door/window/update_icon()
	if(density)
		icon_state = base_state
	else
		icon_state = "[base_state]open"
	SSdemo.mark_dirty(src)

/obj/machinery/door/window/proc/shatter(display_message = 1)
	new /obj/item/weapon/material/shard(loc)
	var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(loc)
	CC.amount = 2
	var/obj/item/weapon/airlock_electronics/ae
	if(!electronics)
		ae = new /obj/item/weapon/airlock_electronics( loc )
		if(!req_access)
			check_access()
		if(req_access.len)
			ae.conf_access = req_access
		else if(req_one_access.len)
			ae.conf_access = req_one_access
			ae.one_access = 1
	else
		ae = electronics
		electronics = null
		ae.loc = loc
	if(operating == -1)
		ae.icon_state = "door_electronics_smoked"
		operating = 0
	set_density(0)
	playsound(src, "window_breaking", 70, 1)
	if(display_message)
		visible_message("[src] shatters!")
	qdel(src)

/obj/machinery/door/window/deconstruct(mob/user, moved = FALSE)
	shatter()

/obj/machinery/door/window/Destroy()
	if(timer)
		deltimer(timer)
	set_density(0)
	update_nearby_tiles()
	return ..()

/obj/machinery/door/window/Bumped(atom/movable/AM)
	if(operating)
		return FALSE

	if(isbot(AM))
		var/mob/living/bot/bot = AM
		if(check_access(bot.botcard))
			if(density)
				open(autoclose = TRUE)
			else
				close()

	else if(istype(AM, /obj/mecha))
		var/obj/mecha/mech = AM
		if(mech.occupant && allowed(mech.occupant))
			if(density)
				open(autoclose = TRUE)
			else
				close()

	else if(ismob(AM))
		var/mob/M = AM
		if(allowed(M))
			if(density)
				open(autoclose = TRUE)
			else
				close()
		else if(density)
			flick(text("[]deny", base_state), src)

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return TRUE
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	return TRUE

/obj/machinery/door/window/CanZASPass(turf/T, is_zone)
	if(get_dir(T, loc) == turn(dir, 180))
		if(is_zone) // No merging allowed.
			return FALSE
		return !density // Air can flow if open (density == FALSE).
	return TRUE // Windoors don't block if not facing the right way.

/obj/machinery/door/window/CheckExit(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/window/open(autoclose = FALSE)
	if(operating)
		return
	else
		operating = TRUE

	if(autoclose)
		timer = addtimer(CALLBACK(src, .proc/close), 10 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

	flick("[base_state]opening", src)
	set_density(0)
	update_icon()
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)

	explosion_resistance = 0
	update_nearby_tiles()
	operating = FALSE
	return 1

/obj/machinery/door/window/close()
	if(operating)
		return
	else
		operating = TRUE

	if(timer)
		deltimer(timer)
		timer = 0

	flick(text("[]closing", base_state), src)
	set_density(1)
	update_icon()
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)

	explosion_resistance = initial(explosion_resistance)
	update_nearby_tiles()
	operating = FALSE
	return 1

/obj/machinery/door/window/take_damage(damage)
	health = max(0, health - damage)
	if(health <= 0)
		shatter()

/obj/machinery/door/window/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/door/window/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species?.can_shred(H))
			playsound(loc, get_sfx("glass_hit"), 75, 1)
			visible_message("<span class='danger'>[user] smashes against the [name].</span>", 1)
			user.do_attack_animation(src)
			user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
			take_damage(25)
			return
	return attackby(user, user)

/obj/machinery/door/window/emag_act(remaining_charges, mob/user)
	if(density && operable())
		operating = -1
		flick("[base_state]spark", src)
		addtimer(CALLBACK(src, .proc/open), 10)
		return 1

/obj/machinery/door/emp_act(severity)
	if(prob(60 / severity))
		open()

/obj/machinery/door/window/attackby(obj/item/weapon/I, mob/user)
	if(operating)
		return

	if(istype(I, /obj/item/weapon/melee/energy/blade))
		if(emag_act(10, user))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, loc)
			spark_system.start()
			playsound(loc, "spark", 50, 1)
			playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
			visible_message("<span class='warning'>The glass door was sliced open by [user]!</span>")
		return 1

	//If it's emagged, crowbar can pry electronics out.
	if(operating == -1 && isCrowbar(I))
		playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message("[user] removes the electronics from the windoor.", "You start to remove electronics from the windoor.")
		if(do_after(user,40,src))
			to_chat(user, "<span class='notice'>You removed the windoor electronics!</span>")

			var/obj/structure/windoor_assembly/wa = new /obj/structure/windoor_assembly(loc)
			if(istype(src, /obj/machinery/door/window/brigdoor))
				wa.secure = "secure_"
				wa.SetName("Secure Wired Windoor Assembly")
			else
				wa.SetName("Wired Windoor Assembly")
			if(base_state == "right" || base_state == "rightsecure")
				wa.facing = "r"
			wa.set_dir(dir)
			wa.state = "02"
			wa.update_icon()

			var/obj/item/weapon/airlock_electronics/ae
			if(!electronics)
				ae = new /obj/item/weapon/airlock_electronics( loc )
				if(!req_access)
					check_access()
				if(req_access.len)
					ae.conf_access = req_access
				else if(req_one_access.len)
					ae.conf_access = req_one_access
					ae.one_access = 1
			else
				ae = electronics
				electronics = null
				ae.loc = loc
			ae.icon_state = "door_electronics_smoked"

			operating = 0
			shatter(src)
			return

	//If it's a weapon, smash windoor. Unless it's an id card, agent card, ect.. then ignore it (Cards really shouldnt damage a door anyway)
	if(density && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card))
		var/aforce = I.force
		playsound(loc, get_sfx("glass_hit"), 75, 1)
		visible_message("<span class='danger'>[src] was hit by [I].</span>")
		user.setClickCooldown(I.update_attack_cooldown())
		user.do_attack_animation(src)
		if(I.damtype == BRUTE || I.damtype == BURN)
			take_damage(aforce)
		return


	add_fingerprint(user, 0, I)

	if(allowed(user))
		if(density)
			open()
		else
			close()

	else if(density)
		flick(text("[]deny", base_state), src)

	return

/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(access_security)
	maxhealth = 300
	health = 300.0 //Stronger doors for prison (regular window door health is 150)

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright/merchant
	color = "#818181"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright/merchant
	color = "#818181"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"
