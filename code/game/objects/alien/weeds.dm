/obj/alien/weeds/New()
	if(istype(src.loc, /turf/space))
		del(src)
	var/obj/cable/C = locate() in src.loc
	if(C)
		del(C)
	var/obj/machinery/light/L = locate() in src.loc
	if(L)
		L.broken()
	updateicon()
/obj/alien/weeds/proc/updateicon()
	var/turf/T = src.loc
	var/obj/alien/weeds/north = locate() in T.north
	var/obj/alien/weeds/west = locate() in T.west
	var/obj/alien/weeds/east = locate() in T.east
	var/obj/alien/weeds/south = locate() in T.south
	src.overlays = null
	if(north)
		world << "Found North"
		overlays += "weeds1n"
		north.overlays += "weeds1s"
	if(south)
		world << "found south"
		overlays += "weeds1s"
		south.overlays += "weeds1n"
	if(west)
		world << "Found West"
		overlays += "weeds1w"
		west.overlays += "weeds1e"
	if(east)
		world << "Found East"
		overlays += "weeds1e"
		east.overlays += "weeds1w"

/obj/alien/weeds/proc/Life()
	var/turf/U = src.loc
/*
	if (locate(/obj/movable, U))
		U = locate(/obj/movable, U)
		if(U.density == 1)
			del(src)
			return

Alien plants should do something if theres a lot of poison
	if(U.poison> 200000)
		src.health -= round(U.poison/200000)
		src.update()
		return
*/
	if (istype(U, /turf/space))
		del(src)
		return

	for(var/dirn in cardinal)
		var/turf/T = get_step(src, dirn)

		if (istype(T.loc, /area/arrival))
			continue

//		if (locate(/obj/movable, T)) // don't propogate into movables
//			continue

		var/cont = 0
		for(var/obj/O in T)
			if(O.density)
				if(istype(O,/obj/machinery/door))
					break
				else
					cont = 1
					break

		if(cont)
			continue

		var/obj/alien/weeds/B = new /obj/alien/weeds(U)
		B.icon_state = pick("weeds", "weeds1", "weeds2")

		if(T.Enter(B,src) && !(locate(/obj/alien/weeds) in T))
			B.loc = T
			updateicon()
			spawn(80)
				if(B)
					B.Life()
			// open cell, so expand
		else
			var/obj/machinery/door/airlock/D = locate() in T
			if(D)
				world << "ATTEMPTING TO OPEN DOOR"
				if(D.density)
					D.forcedopen()
					D.locked = 1
				else
					world << "door already open"
				sleep(50)
				world << "ATTEMPTING TO OPEN DOOR"
				if(T.Enter(B,src) && !(locate(/obj/alien/weeds) in T))
					B.loc = T
					updateicon()
					spawn(80)
					if(B)
						B.Life()
				else
					del(B)
			del(B)
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

/*
/obj/alien/weeds/burn(fi_amount)
	if (fi_amount > 18000)
		spawn( 0 )
			del(src)
			return
		return 0
	return 1
*/