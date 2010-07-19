/proc/wreakstation()
	world << "Preparing pre-round preperations"
	var/calc = 0
	for(var/obj/machinery/power/apc/a in world)
		a.cell.charge = 0
		if(prob(25))
			del a.cell
		if(prob(75))
			a.set_broken()
		calc += 1
		if(calc > 50)
			sleep(1)
			calc = 0
	world << "Damaging floors"
	sleep(20)
	for(var/turf/simulated/floor/a in world)
		if(prob(90))
			a.ex_act(3)
		if(prob(1) && prob(5))
			explosion(a,3,5,7,9)
		calc += 1
		if(calc > 50)
			sleep(1)
			calc = 0
	world << "Destroying walls"
	sleep(20)
	for(var/turf/simulated/wall/a in world)
		calc += 1
		if(calc > 50)
			sleep(1)
			calc = 0
		if(prob(25))
			a.ex_act(3)
	world << "Smashing windows"
	sleep(20)
	for(var/obj/window/a in world)
		if(prob(35))
			a.ex_act(3)
		calc += 1
		if(calc > 50)
			sleep(1)
			calc = 0
	world << "Hacking airlocks"
	sleep(20)

	for(var/obj/machinery/door/airlock/a in world)
		if(prob(30))
			a.open()
		if(prob(25))
			var/list/wires = list(1,2,3,4,5,6,7,8,9)
			for(var/i = 1 to rand(1,9))
				var/wire = pick(wires)
				a.cut(wire)
				wires -= wire
		calc += 1
		if(calc > 50)
			sleep(1)
			calc = 0
	world << "Stealing item s"

	for(var/turf/a in world)
		for(var/obj/item/w in a)
			for(var/i = 0 to rand(1,5))
				step(w,pick(cardinal))

			if(prob(60))
				del w
