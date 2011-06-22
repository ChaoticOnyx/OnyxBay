/obj/alien/proc/process()
	return

/obj/item/alien/weeds/
	layer = 2
	health = 15
	icon = 'alien.dmi'
	name = "weeds"
	anchored = 1
	var/dead = 0
	var/list/allowed = list(/obj/closet,/obj/table,/obj/machinery/computer,/obj/machinery/disposal)

/obj/item/alien/weeds/New()
	//del(src)
	//return
	if(istype(src.loc, /turf/space))
		del(src)
		return
	processing_items.Add(src)
/obj/item/alien/weeds/process()
	if(dead) return
	//world << "hurr"
/*	var/turf/T = src.loc
	var/obj/item/alien/weeds/north = locate() in T.north
	var/obj/item/alien/weeds/west = locate() in T.west
	var/obj/item/alien/weeds/east = locate() in T.east
	var/obj/item/alien/weeds/south = locate() in T.south

	if(north && west && east && south)
		dead = 1
		return
	if(!north||!west||!east||!south)
		Life()
*/
	dead = 1	//No real reason for a weed to spread more than once.
	Life()
	updateicon(0)

/obj/item/alien/weeds/proc/updateicon(var/spread = 1)
	//world << "durr"
	var/turf/T = src.loc
	var/obj/item/alien/weeds/north = locate() in T.north
	var/obj/item/alien/weeds/west = locate() in T.west
	var/obj/item/alien/weeds/east = locate() in T.east
	var/obj/item/alien/weeds/south = locate() in T.south
	src.overlays = null
	var/dir

	if(!north)
		dir += "north"
	else if(spread)
		north.updateicon(0)

	if(!south)
		dir += "south"
	else if(spread)
		south.updateicon(0)

	if(!west)
		dir += "west"
	else if(spread)
		west.updateicon(0)

	if(!east)
		dir += "east"
	else if(spread)
		east.updateicon(0)

	if(!dir)
		icon_state = "creep_center"
	else
		icon_state = "creep_[dir]"

	return

/obj/item/alien/weeds/proc/Life()
	src.updateicon(0)
	var/turf/U = src.loc
	if (istype(U, /turf/space))
		del(src)
		return

	var/obj/machinery/light/L = locate() in src.loc
	if(L)
		L.broken()

	var/obj/machinery/power/apc/A = locate() in src.loc
	if(A)
		A.set_broken()
	if(prob(1))
		src.loc.ex_act(2)
	for(var/dirn in cardinal)
	//	sleep(100)
	//	if(prob(50))
	//		continue
		//sleep(10)
		var/turf/T = get_step(src,dirn)
		if (istype(T.loc, /area/shuttle/arrival))
			continue

		if(T.density)
			continue
		if(locate(/obj/machinery/door/airlock) in T)
			if(locate(/obj/machinery/door/airlock/external) in T)
				continue
			if(!locate(/obj/item/alien/weeds) in T)
			//	src.dead = 0
				var/obj/machinery/door/airlock/D = locate() in T
				if(D.density)
					D.forceopen()
				//sleep(10)
				var/obj/item/alien/weeds/B = new(src.loc)
				B.icon_state = ""
				if(T.Enter(B) && !(locate(/obj/alien/weeds) in T))
					B.loc = T
					//B.Life()
					B.updateicon(1)
					continue
				else
					del(B)
		if(locate(/obj/closet) in T || locate(/obj/table) in T || locate(/obj/machinery/computer) in T || locate(/obj/machinery/disposal) in T)
			var/obj/item/alien/weeds/B = new(T)
			//B.Life()
			B.updateicon(1)
			continue
		if(!locate(/obj/item/alien/weeds) in T)
			var/obj/item/alien/weeds/B = new(src.loc)
			B.icon_state = ""
			if(T.Enter(B))
				B.loc = T
				//B.Life()
				B.updateicon(1)
				continue
			else
				del(B)

	/*
	for(var/mob/living/carbon/human/h in src.loc)
		h.hallucination += 10

	for(var/dirn in cardinal)
		var/turf/T = get_step(src, dirn)

		if (istype(T.loc, /area/shuttle/arrival))
			continue

		if(T.density)
			continue

		if(locate(/obj/machinery/door) in T)
			var/obj/machinery/door/D = locate() in T
			if(D.density)
				D.forceopen()
			sleep(10)
			var/obj/alien/weeds/B = new /obj/alien/weeds(U)
			B.icon_state = pick("")
			if(T.Enter(B,src) && !(locate(/obj/alien/weeds) in T))
				B.loc = T
				B.Life()
				B.updateicon()
				sleep(100)
				continue
			else
				del(B)

		else if(locate(/obj/grille) in T || /obj/window/ in T)
			var/obj/alien/weeds/B = new /obj/alien/weeds(U)
			B.icon_state = pick("")
			if(T.Enter(B,src) && !(locate(/obj/alien/weeds) in T))
				B.loc = T
				spawn(80)
					if(B)
						B.Life()
						B.updateicon()
						continue
			else
				del(B)

		else if(!(locate(/obj/alien/weeds) in T))
			var/obj/alien/weeds/B = new /obj/alien/weeds(U)
			B.icon_state = pick("")
			B.loc = T
			spawn(80)
			if(B)
				B.Life()
				B.updateicon()
				continue
			else
				del(B)
						/*		if(T.Enter(B,src) && !(locate(/obj/alien/weeds) in T))
			B.loc = T
			updateicon()
			spawn(80)
				if(B)
					B.Life()
			// open cell, so expand
			*/*/

/obj/item/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
		else
	return

/obj/item/alien/weeds/attack_hand(mob/user as mob)
	return

/obj/item/alien/weeds/attack_paw(mob/user as mob)
	return

/obj/item/alien/weeds/attackby(obj/item/weapon/weldingtool/P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/weldingtool))
		if ((P:welding && P:welding))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] burns [] with the welding tool!", user, src), 1, "\red You hear a small burning noise", 2)
			src.health -= rand(3,5)
			if(src.health <= 0)
				del(src)
