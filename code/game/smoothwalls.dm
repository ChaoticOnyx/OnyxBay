// Credit to TG Station for the more elegant solution to SmoothWalls.
// Need to modify it to correct seeing junctions where there shouldn't be any.

//Separate dm because it relates to two types of atoms + ease of removal in case it's needed.
//Also assemblies.dm for falsewall checking for this when used.

/atom/proc/relativewall() //atom because it should be useable both for walls and false walls

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls

	for(var/turf/simulated/wall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			junction |= get_dir(src,W)
/*
	for(var/obj/falsewall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			junction |= get_dir(src,W)
*/
	if(istype(src, /turf/simulated/wall/heatshield))
		return
	else if(istype(src, /turf/simulated/wall/r_wall))
		src.icon_state = "rwall[junction]"
	else
		src.icon_state = "wall[junction]"

/* When we have animations for different directions of falsewalls, then it'd be needed. Not now.
	if(istype(src,/obj/falsewall)) //saving the junctions for the falsewall because it changes icon_state often instead of once
		var/obj/falsewall/F = src
		F.junctions = junction
*/
	return


/turf/simulated/wall/New()
	update_nearby_tiles(1)
	for(var/turf/simulated/wall/W in range(src,1))
		W.relativewall()
/*
	for(var/obj/falsewall/W in range(src,1))
		W.relativewall()
*/
	..()


/turf/simulated/wall/Del()

	var/temploc = src.loc

	spawn(10)
		for(var/turf/simulated/wall/W in range(temploc,1))
			W.relativewall()
	update_nearby_tiles(0)
/*
		for(var/obj/falsewall/W in range(temploc,1))
			W.relativewall()
*/
	..()

turf/proc/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0

	var/turf/simulated/source = src
	var/turf/simulated/north = get_step(source,NORTH)
	var/turf/simulated/south = get_step(source,SOUTH)
	var/turf/simulated/east = get_step(source,EAST)
	var/turf/simulated/west = get_step(source,WEST)
	var/turf/simulated/up = get_step_3d(source,UP)
	var/turf/simulated/down = get_step_3d(source,DOWN)

	if(need_rebuild)
		if(istype(source)) //Rebuild/update nearby group geometry
			if(source.parent)
				air_master.groups_to_rebuild += source.parent
			else
				air_master.tiles_to_update += source
		if(istype(north))
			if(north.parent)
				air_master.groups_to_rebuild += north.parent
			else
				air_master.tiles_to_update += north
		if(istype(south))
			if(south.parent)
				air_master.groups_to_rebuild += south.parent
			else
				air_master.tiles_to_update += south
		if(istype(east))
			if(east.parent)
				air_master.groups_to_rebuild += east.parent
			else
				air_master.tiles_to_update += east
		if(istype(west))
			if(west.parent)
				air_master.groups_to_rebuild += west.parent
			else
				air_master.tiles_to_update += west
		if(istype(up))
			if(up.parent)
				air_master.groups_to_rebuild += up.parent
			else
				air_master.tiles_to_update += up
		if(istype(down))
			if(down.parent)
				air_master.groups_to_rebuild += down.parent
			else
				air_master.tiles_to_update += down
	else
		if(istype(source)) air_master.tiles_to_update += source
		if(istype(north)) air_master.tiles_to_update += north
		if(istype(south)) air_master.tiles_to_update += south
		if(istype(east)) air_master.tiles_to_update += east
		if(istype(west)) air_master.tiles_to_update += west
		if(istype(up)) air_master.tiles_to_update += up
		if(istype(down)) air_master.tiles_to_update += down

	return 1