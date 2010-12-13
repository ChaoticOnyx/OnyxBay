/obj/alien/proc/process()
	return

/obj/alien/weeds/
	layer = 2
	var/health = 15
	var/dead

/obj/alien/weeds/New()
	if(istype(src.loc, /turf/space))
		del(src)
	updateicon()
/obj/alien/weeds/process()
	spawn while(!dead)
		sleep(-1)
		var/turf/T = src.loc
		var/obj/alien/weeds/north = locate() in T.north
		var/obj/alien/weeds/west = locate() in T.west
		var/obj/alien/weeds/east = locate() in T.east
		var/obj/alien/weeds/south = locate() in T.south
		if(north && west && east && south)
			dead = 1
			return
		if(!north||!west||!east||!south)
			Life()
		else
			updateicon(0)
		sleep(50)
		if(dead) return
		src.process()

/obj/alien/weeds/proc/updateicon(var/spread = 1)
	var/turf/T = src.loc
	var/obj/alien/weeds/north = locate() in T.north
	var/obj/alien/weeds/west = locate() in T.west
	var/obj/alien/weeds/east = locate() in T.east
	var/obj/alien/weeds/south = locate() in T.south
	src.overlays = null
	var/dir

	if(!north)
		dir += "north"
	else
		north.updateicon()

	if(!south)
		dir += "south"
	else
		south.updateicon()

	if(!west)
		dir += "west"
	else
		west.updateicon()

	if(!east)
		dir += "east"
	else
		east.updateicon()

	if(!dir)
		icon_state = "creep_center"
	else
		icon_state = "creep_[dir]"

	return

/obj/alien/weeds/proc/Life()
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
						sleep(100)
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
				sleep(100)
				continue
			else
				del(B)
		sleep(100)		/*		if(T.Enter(B,src) && !(locate(/obj/alien/weeds) in T))
			B.loc = T
			updateicon()
			spawn(80)
				if(B)
					B.Life()
			// open cell, so expand
			*/

/obj/alien/weeds/ex_act(severity)
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

/obj/alien/weeds/attackby(obj/item/weapon/weldingtool/P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/weldingtool))
		if ((P:welding && P:welding))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] burns [] with the welding tool!", user, src), 1, "\red You hear a small burning noise", 2)
			src.health -= rand(3,5)
			if(src.health <= 0)
				del(src)
