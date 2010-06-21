/turf/simulated/proc/find_group()
	//Basically, join any nearby valid groups
	//	If more than one, pick one with most members at my borders
	// If can not find any but there was an ungrouped at border with me, call for group assembly
	// If can not find any and no ungrouped at border, register as a single tile

	var/turf/simulated/floor/north = get_step(src,NORTH)
	var/turf/simulated/floor/south = get_step(src,SOUTH)
	var/turf/simulated/floor/east = get_step(src,EAST)
	var/turf/simulated/floor/west = get_step(src,WEST)

	//TODO integrate up/down support
	var/turf/simulated/floor/open/above = get_step_3d(src,UP)
	var/turf/simulated/floor/below = get_step_3d(src,DOWN)

	//Clear those we do not have access to
	if(!CanPass(null, north, null, 1) || !istype(north))
		north = null
	if(!CanPass(null, south, null, 1) || !istype(south))
		south = null
	if(!CanPass(null, east, null, 1) || !istype(east))
		east = null
	if(!CanPass(null, west, null, 1) || !istype(west))
		west = null

	if(!istype(above))
		above = null

	if(!istype(src, /turf/simulated/floor/open))
		below = null

	var/new_group_possible = 0


	//TODO incorporate connections
	var/north_votes = 0
	var/south_votes = 0
	var/east_votes = 0
	var/below_votes = 0
	var/above_votes = 0

	if(north)
		if(north.parent)
			north_votes = 1

			if(south && (south.parent == north.parent))
				north_votes++
				south = null

			if(east && (east.parent == north.parent))
				north_votes++
				east = null

			if(west && (west.parent == north.parent))
				north_votes++
				west = null

			if(above && (above.parent == north.parent))
				north_votes++
				above = null

			if(below && (below.parent == north.parent))
				north_votes++
				below = null
		else
			new_group_possible = 1

	if(south)
		if(south.parent)
			south_votes = 1

			if(east && (east.parent == south.parent))
				south_votes++
				east = null

			if(west && (west.parent == south.parent))
				south_votes++
				west = null

			if(above && (above.parent == south.parent))
				south_votes++
				above = null

			if(below && (below.parent == south.parent))
				south_votes++
				below = null
		else
			new_group_possible = 1

	if(east)
		if(east.parent)
			east_votes = 1

			if(west && (west.parent == east.parent))
				east_votes++
				west = null

			if(above && (above.parent == east.parent))
				east_votes++
				above = null

			if(below && (below.parent == east.parent))
				east_votes++
				below = null
		else
			new_group_possible = 1

	if(above)
		if(above.parent)
			above_votes = 1

			if(west && (west.parent == above.parent))
				above_votes++
				west = null

			if(below && (below.parent == above.parent))
				above_votes++
				below = null
		else
			new_group_possible = 1

	if(below)
		if(below.parent)
			below_votes = 1

			if(west && (west.parent == below.parent))
				below_votes++
				west = null
		else
			new_group_possible = 1

	if(west)
		if(west.parent)
			west.parent.suspend_group_processing()
			west.parent.members += src
			parent = west.parent

			air_master.tiles_to_update += west.parent.members
			return 1

		else
			new_group_possible = 1

	if(north_votes && (north_votes >= south_votes) && (north_votes >= east_votes) && (north_votes >= above_votes) && (north_votes >= below_votes))
		north.parent.suspend_group_processing()
		north.parent.members += src
		parent = north.parent

		air_master.tiles_to_update += north.parent.members
		return 1


	if(south_votes  && (south_votes >= east_votes))
		south.parent.suspend_group_processing()
		south.parent.members += src
		parent = south.parent

		air_master.tiles_to_update += south.parent.members
		return 1

	if(east_votes)
		east.parent.suspend_group_processing()
		east.parent.members += src
		parent = east.parent

		air_master.tiles_to_update += east.parent.members
		return 1

	if(new_group_possible)
		air_master.assemble_group_turf(src)
		return 1

	else
		air_master.active_singletons += src
		return 1