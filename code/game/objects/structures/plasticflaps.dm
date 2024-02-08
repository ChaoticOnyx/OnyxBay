/obj/structure/plasticflaps
	name = "\improper plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1

	var/health = 50

	layer = ABOVE_HUMAN_LAYER
	explosion_resistance = 5
	var/list/mobs_can_pass = list(
		/mob/living/bot,
		/mob/living/carbon/metroid,
		/mob/living/simple_animal/mouse,
		/mob/living/silicon/robot/drone
		)

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.pass_flags & PASS_FLAG_GLASS)
		return prob(60)

	var/obj/structure/bed/B = A
	if (istype(A, /obj/structure/bed) && B.buckled_mob) //if it's a bed/chair and someone is buckled, it will not pass
		return 0

	if(istype(A, /obj/vehicle))	//no vehicles
		return 0

	var/mob/living/M = A
	if(istype(M))
		if(M.lying)
			return ..()
		for(var/mob_type in mobs_can_pass)
			if(istype(A, mob_type))
				return ..()
		return issmall(M)

	return ..()

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/structure/plasticflaps/proc/take_damage(force)
	if(health > 0)
		health -= force
		if(health <= 0)
			to_chat(usr, SPAN_DANGER("\The [src] has been destroyed!"))
			new /obj/item/stack/material/plastic(loc, 2)
			qdel(src)

/obj/structure/plasticflaps/bullet_act(obj/item/projectile/P)
	var/damage = P.get_structure_damage()
	if(!damage)
		return

	..()
	take_damage(damage)
	return

/obj/structure/plasticflaps/attackby(obj/item/O, mob/user)
	if(isWrench(O))
		if(do_after(user, 30, src))
			new /obj/item/stack/material/plastic(loc, 5)
			qdel(src)
		return

	else if(O.force >= 10)
		user.visible_message(SPAN_DANGER("\The [src] has been [pick(O.attack_verb)] with [O] by [user]!"))
		take_damage(O.force)
		user.setClickCooldown(O.update_attack_cooldown())
		user.do_attack_animation(src)
		obj_attack_sound(O)
		return

	. = ..()

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."
	can_atmos_pass = ATMOS_PASS_NO
