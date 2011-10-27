zone
	New(turf/start)
		if(istype(start,/list))
			contents = start
		else
			contents = FloodFill(start)
		for(var/turf/T in contents)
			T.zone = src
			if(istype(T,/turf/space))
				AddSpace(T)
		air = new
		for(var/turf/simulated/T in contents)
			air.oxygen = max(air.oxygen,T.oxygen)
			air.nitrogen = max(air.nitrogen,T.nitrogen)
			air.carbon_dioxide = max(air.carbon_dioxide,T.carbon_dioxide)
			air.toxins = max(air.toxins,T.toxins)
			air.temperature = max(air.temperature,T.temperature)
		air.group_multiplier = contents.len
		zones += src
	Del()
		zones -= src
		. = ..()

proc/FloodFill(turf/start)
	var
		list
			open = list(start)
			closed = list()

	while(open.len)
		for(var/turf/T in open)
			if(!T.HasDoor())
				for(var/d in cardinal)
					var/turf/O = get_step(T,d)
					if(O.ZCanPass(T) && !(O in open) && !(O in closed))
						open += O
			open -= T
			closed += T

	return closed

turf/proc/ZCanPass(turf/T)
	if(istype(T,/turf/space)) return 0
	else
		if(T.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
				continue
			if(!obstacle.CanPass(0, T, 0, 1))
				return 0
		for(var/obj/obstacle in T)
			if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
				continue
			if(!obstacle.CanPass(0, src, 0, 1))
				return 0

		return 1