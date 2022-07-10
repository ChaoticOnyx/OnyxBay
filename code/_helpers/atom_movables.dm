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

// Walks up the loc tree until loc is mob or turf.
// Needed for check of presence of any embedded item/effect etc in hand of character.
/proc/get_top_holder_obj(atom/A)
	var/atom/holder = A
	while(holder.loc && istype(holder.loc, /obj))
		holder = holder.loc
	return holder

// Walks up the loc tree until it finds a holder of the given holder_type
/proc/get_holder_of_type(atom/A, holder_type)
	if(!istype(A)) return
	for(A, A && !istype(A, holder_type), A=A.loc);
	return A

// Walks up the loc tree until it finds wrong loc or go to null
// stop_on is list of types of loc where check must stop
/proc/check_locs(atom/A, list/stop_on, checking_proc)
	var/atom/loc = A.loc
	var/is_correct = TRUE

	while(loc && is_correct)
		for(var/type in stop_on)
			if(istype(loc, type))
				return TRUE
		is_correct = call(A, checking_proc)(loc)
		loc = loc.loc
	return is_correct

/atom/movable/proc/throw_at_random(include_own_turf, maxrange, speed)
	var/list/turfs = trange(maxrange, src)
	if(!maxrange)
		maxrange = 1

	if(!include_own_turf)
		turfs -= get_turf(src)
	if(length(turfs))
		throw_at(pick(turfs), maxrange, speed, src)
