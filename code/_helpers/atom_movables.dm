/proc/get_turf_pixel(atom/movable/AM)
	if(!istype(AM))
		return

	//Find AM's matrix so we can use it's X/Y pixel shifts
	var/matrix/M = matrix(AM.transform)

	var/pixel_x_offset = AM.pixel_x + M.get_x_shift()
	var/pixel_y_offset = AM.pixel_y + M.get_y_shift()

	//Irregular objects
	if(AM.bound_height != world.icon_size || AM.bound_width != world.icon_size)
		var/icon/AMicon = icon(AM.icon, AM.icon_state)
		pixel_x_offset += ((AMicon.Width()/world.icon_size)-1)*(world.icon_size*0.5)
		pixel_y_offset += ((AMicon.Height()/world.icon_size)-1)*(world.icon_size*0.5)
		qdel(AMicon)

	//DY and DX
	var/rough_x = round(round(pixel_x_offset,world.icon_size)/world.icon_size)
	var/rough_y = round(round(pixel_y_offset,world.icon_size)/world.icon_size)

	//Find coordinates
	var/turf/T = get_turf(AM) //use AM's turfs, as it's coords are the same as AM's AND AM's coords are lost if it is inside another atom
	var/final_x = T.x + rough_x
	var/final_y = T.y + rough_y

	if(final_x || final_y)
		return locate(final_x, final_y, T.z)

// Walks up the loc tree until it finds a holder of the given holder_type
/proc/get_holder_of_type(atom/A, holder_type)
	if(!istype(A)) return
	for(A, A && !istype(A, holder_type), A=A.loc);
	return A

/atom/movable/proc/throw_at_random(include_own_turf, maxrange, speed)
	var/list/turfs = trange(maxrange, src)
	if(!maxrange)
		maxrange = 1

	if(!include_own_turf)
		turfs -= get_turf(src)
	if(length(turfs))
		throw_at(pick(turfs), maxrange, speed, src)

///Returns the closest atom of a specific type in a list from a source
/proc/get_closest_atom(type, list/atom_list, source)
	var/closest_atom
	var/closest_distance
	for(var/atom in atom_list)
		if(!istype(atom, type))
			continue
		var/distance = get_dist(source, atom)
		if(!closest_atom)
			closest_distance = distance
			closest_atom = atom
		else
			if(closest_distance > distance)
				closest_distance = distance
				closest_atom = atom
	return closest_atom

///Returns a list of all locations (except the area) the movable is within.
/proc/get_nested_locs(atom/movable/atom_on_location, include_turf = FALSE)
	. = list()
	var/atom/location = atom_on_location.loc
	var/turf/our_turf = get_turf(atom_on_location)
	while(location && location != our_turf)
		. += location
		location = location.loc
	if(our_turf && include_turf) //At this point, only the turf is left, provided it exists.
		. += our_turf
