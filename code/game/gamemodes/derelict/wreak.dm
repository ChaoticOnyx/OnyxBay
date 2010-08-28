/proc/wreakstation()
	world << "Preparing pre-round preparations"
	var/calc = 0
	for(var/obj/machinery/power/apc/a in world)
		a.cell.charge = 0
		if(prob(25))
			del a.cell
		if(prob(75))
			a.set_broken()
		calc += 1
		if(calc > 50)
			sleep(0)
			calc = 0
	world << "Damaging floors"
	sleep(20)
	for(var/turf/simulated/floor/a in world)
		if(locate(/obj/landmark/derelict/nodamage) in a)
			continue
		if(prob(90))
			a.ex_act(3)
		calc += 1
		if(calc > 50)
			sleep(0)
			calc = 0
		if(locate(/obj/landmark/derelict/noblast) in a)
			continue
		if(prob(1) && prob(5))
			explosion(a,3,5,7,9, 1)
	world << "Destroying walls (SLOW)"
	sleep(20)
	for(var/turf/simulated/wall/a in world)
		if(locate(/obj/landmark/derelict/nodamage) in a)
			continue
		calc += 1
		if(calc > 50)
			sleep(0)
			calc = 0
		if(prob(25))
			a.ex_act(3)
	world << "Smashing windows"
	sleep(20)
	for(var/obj/window/a in world)
		if(locate(/obj/landmark/derelict/nodamage) in get_turf(a))
			continue
		if(prob(35))
			a.ex_act(3)
		calc += 1
		if(calc > 50)
			sleep(0)
			calc = 0
	world << "Hacking airlocks"
	sleep(20)
	for(var/obj/window/a in world)
		if(locate(/obj/landmark/derelict/nodamage) in get_turf(a))
			continue
		if(prob(35))
			a.ex_act(3)
		calc += 1
		if(calc > 50)
			sleep(0)
			calc = 0
	world << "Breaking alarms"
	sleep(20)

	for(var/obj/machinery/alarm/a in world)
		if(locate(/obj/landmark/derelict/nodamage) in get_turf(a))
			continue
		if(prob(80))
			a.stat |= BROKEN
		calc += 1
		if(calc > 50)
			sleep(0)
			calc = 0
	world << "Stealing items"
	for(var/obj/machinery/bot/b in world)
		del b

	for(var/turf/a in world)
		if(a.z > 4)
			continue
		for(var/obj/item/w in a)
			for(var/i = 0 to rand(1,5))
				step(w,pick(cardinal))

			if(prob(60))
				del w

	var/list/b = get_area_all_objects(/area/hangar/derelict)
	for(var/obj/a in b)
		a.Move(locate(a.x, a.y, 4))


	for(var/obj/landmark/derelict/glass/glass in world)
		if(prob(30))
			var/obj/item/weapon/sheet/glass/g = new(glass.loc)
			g.amount = rand(2, 30)

	for(var/obj/landmark/derelict/metal/metal in world)
		if(prob(30))
			var/obj/item/weapon/sheet/metal/g = new(metal.loc)
			g.amount = rand(2, 30)

	for(var/obj/landmark/derelict/o2canister/o2 in world)
		if(prob(70))
			new /obj/machinery/portable_atmospherics/canister/air(o2.loc)

	for(var/obj/landmark/derelict/o2crate/o2 in world)
		if(prob(70))
			new /obj/crate/internals(o2.loc)