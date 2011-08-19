var/datum/map/mapholder = new /datum/map()
datum/map // holds infomation about PDA map
	var/list/grid[world.maxx][world.maxy][world.maxz]
datum/map/New()
	for(var/turf/T in world)
		grid[T.x][T.y][T.z] = GetIcon(T)
//mob/verb/TesMap()
//	var/dat = mapholder.GetLocalMap(src)
//	src << browse(dat,"window=map")
datum/map/proc/GetLocalMap(mob/M)
	var/xloc = M.x - 12
	var/yloc = M.y + 12
	world << "XLOC:[xloc]"
	world << "YLOC:[yloc]"
	//we should bounds check here
	var/dat = "<table border='0' cellpadding='2'>"
	var/yn
	var/xn
	for(yn = 0,yn <= 25,yn++)
		dat += "<tr>"
		for(xn = 0,xn <= 25,xn++)
			var/xx = xn + xloc
			var/yy = yn + yloc
			var/T = "?"
			if(xx == M.x && yy == M.y)
				T = "@"
			else
				T = mapholder.grid[xx][yy][M.z]
			dat += "<td>[T]</td>"
		dat += "</tr>"
	return dat
datum/map/proc/GetIcon(var/turf/T)
	if(istype(T,/turf/space))
		return "*"

	else if(istype(T,/turf/simulated/floor))
		return "."
	else if(istype(T,/turf/simulated/wall))
		return "#"
	else
		return "?"