/datum/map_generator/single_turf
	var/turf/turf_type
	var/area/area_type

	var/area/used_area

/datum/map_generator/single_turf/New(...)
	used_area = GLOB.areas_by_type[area_type] || new area_type
	return ..()

/datum/map_generator/single_turf/generate_turf(turf/gen_turf, changeturf_flags)
	var/area/A = get_area(gen_turf)
	if(!(A.area_flags & AREA_FLAG_CAVES_ALLOWED))
		return FALSE

	used_area.contents += gen_turf
	//gen_turf.change_area(A, used_area)

	// take NO_RUINS_1 from gen_turf.flags_1, and save it
	var/stored_flags = gen_turf.turf_flags & TURF_FLAG_NORUINS
	gen_turf.ChangeTurf(turf_type)
	// readd the flag we saved
	gen_turf.turf_flags |= stored_flags
	return TRUE

/datum/map_generator/single_turf/space
	turf_type = /turf/space
	area_type = /area/space
