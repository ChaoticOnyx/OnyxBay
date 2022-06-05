//An area can override the z-level base turf, so our solar array areas etc. can be space-based.
/proc/get_base_turf_by_area(turf/T)
	var/area/A = T.loc

	if(A.base_turf)
		return A.base_turf
	
	return GLOB.using_map.map_levels[T.z]?.base_turf || world.turf
