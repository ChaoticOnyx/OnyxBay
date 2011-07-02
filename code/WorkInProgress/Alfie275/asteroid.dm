
/obj/landmark/mapload
	name = "Mapload marker"




/obj/landmark/mapload/asteroid
	New()

proc/setupasteroid()
	var/list/maps = list("bone","cartel")
	for(var/obj/landmark/mapload/asteroid/m in world)
		if(maps.len&&rand(0,1)==1)
			var/map = pick(maps)
			maps-=map
			QML_loadMap("maps/asteroid/[map].dmm",m.x-1,m.y-1,m.z-1)
		del m
/*	sleep(-1)
	sleep(10)
	var/list/walls = list()
	for(var/turf/simulated/asteroid/w in world)
		walls+=w
	var/mapped[walls.len]
	var/next[walls.len]
	for(var/Xa = 1,Xa<=walls.len,Xa++)
		var/turf/simulated/asteroid/w = walls[Xa]
		if(w.mapped)
			if(istype(walls[Xa],/turf/simulated/asteroid/floor))
				mapped[Xa]=-1
			else
				mapped[Xa] = 1
		else
			mapped[Xa]=0
		if(!rand(1))

			var/turf/simulated/asteroid/floor/f = new(locate(w.x,w.y, w.z))
			walls[Xa] = f
			next[Xa]=0
		else
			var/turf/simulated/asteroid/wall/f = new(locate(w.x,w.y, w.z))
			walls[Xa] = f
			next[Xa]=1

	var/times = 3
	while(times)
		sleep(-1)
		for(var/Xa = 1,Xa<=walls.len,Xa++)
			sleep(-1)
			var/turf/w = walls[Xa]
			var/count = 8
			for(var/d in cardinal8)
				var/turf/t = get_step(w,d)
				if(istype(t,/turf/simulated/asteroid/floor))
					count -= 1
			if(count>4)
				next[Xa] = 1
			else if(count<4)
				next[Xa] = 0
		sleep(-1)
		for(var/Xa = 1,Xa<=walls.len,Xa++)
			sleep(-1)
			if(!next[Xa])
				var/turf/w = walls[Xa]
				var/turf/simulated/asteroid/floor/f = new(locate(w.x,w.y, w.z))
				walls[Xa] = f
			else
				var/turf/w = walls[Xa]
				var/turf/simulated/asteroid/wall/f = new(locate(w.x,w.y, w.z))
				walls[Xa] = f
		times--
	sleep(-1)
	for(var/Xa = 1,Xa<=walls.len,Xa++)
		if(mapped[Xa])
			if(mapped[Xa]== -1)
				var/turf/w = walls[Xa]
				var/turf/simulated/asteroid/floor/f = new(locate(w.x,w.y, w.z))
				walls[Xa] = f
			else
				var/turf/w = walls[Xa]
				var/turf/simulated/asteroid/wall/f = new(locate(w.x,w.y, w.z))
				walls[Xa] = f
*/
/*Mloc hates laggy asteroid generators~*/