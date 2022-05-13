GLOBAL_LIST_EMPTY(station_areas)

/*
	List generation helpers
*/
/proc/get_filtered_areas(list/predicates = list(/proc/is_area_with_turf))
	. = list()
	if(!predicates)
		return
	if(!islist(predicates))
		predicates = list(predicates)
	for(var/area/A in world)
		if(all_predicates_true(list(A), predicates))
			. += A

/proc/get_area_turfs(area/A, list/predicates)
	. = new /list()
	A = istype(A) ? A : locate(A)
	if(!A)
		return
	for(var/turf/T in A.contents)
		if(!predicates || all_predicates_true(list(T), predicates))
			. += T

/proc/get_subarea_turfs(area/A, list/predicates)
	. = new /list()
	A = istype(A) ? A.type : A
	if(!A)
		return
	for(var/sub_area_type in typesof(A))
		var/area/sub_area = locate(sub_area_type)
		for(var/turf/T in sub_area.contents)
			if(!predicates || all_predicates_true(list(T), predicates))
				. += T

/proc/group_areas_by_name(list/predicates)
	. = list()
	for(var/area/A in get_filtered_areas(predicates))
		group_by(., A.name, A)

/proc/group_areas_by_z_level(list/predicates)
	. = list()
	for(var/area/A in get_filtered_areas(predicates))
		group_by(., num2text(A.z), A)

/*
	Pick helpers
*/
/proc/pick_subarea_turf(areatype, list/predicates)
	var/list/turfs = get_subarea_turfs(areatype, predicates)
	if(length(turfs))
		return pick(turfs)

/proc/pick_area_turf(area/A, list/predicates)
	var/list/turfs = get_area_turfs(A, predicates)
	if(length(turfs))
		return pick(turfs)

/proc/pick_area_by_type(areatype, list/predicates)
	. = new /list()

	for(var/area/A in world)
		if(istype(A, areatype) && all_predicates_true(list(A), predicates))
			. |= A

	return pick(.)

/proc/pick_area(list/predicates)
	var/list/areas = get_filtered_areas(predicates)
	if(length(areas))
		. = pick(areas)

/proc/pick_area_and_turf(list/area_predicates, list/turf_predicates)
	var/area/A = pick_area(area_predicates)
	if(!A)
		return
	return pick_area_turf(A, turf_predicates)

/*
	Predicate Helpers
*/
/proc/is_station_area(area/A)
	return A && isStationLevel(A.z)

/proc/is_contact_area(area/A)
	return A && isContactLevel(A.z)

/proc/is_player_area(area/A)
	return A && isPlayerLevel(A.z)

/proc/is_not_space_area(area/A)
	. = !istype(A, /area/space)

/proc/is_not_shuttle_area(area/A)
	. = !istype(A, /area/shuttle)

/proc/is_not_sealed_area(area/A)
	. = !(A.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_SEALED))

/proc/is_area_with_turf(area/A)
	return A && isnum(A.x)

/proc/is_area_without_turf(area/A)
	. = !is_area_with_turf(A)

GLOBAL_LIST_INIT(is_station_but_not_space_or_shuttle_area, list(/proc/is_station_area, /proc/is_not_space_area, /proc/is_not_shuttle_area))

GLOBAL_LIST_INIT(is_contact_but_not_space_or_shuttle_area, list(/proc/is_contact_area, /proc/is_not_space_area, /proc/is_not_shuttle_area))

GLOBAL_LIST_INIT(is_player_but_not_space_or_shuttle_area, list(/proc/is_player_area, /proc/is_not_space_area, /proc/is_not_shuttle_area))

GLOBAL_LIST_INIT(is_player_but_not_space_or_shuttle_area_or_sealed, list(/proc/is_player_area, /proc/is_not_space_area, /proc/is_not_shuttle_area, /proc/is_not_sealed_area))

GLOBAL_LIST_INIT(is_player_but_not_space_area, list(/proc/is_player_area, /proc/is_not_space_area))

/*
	Misc Helpers
*/
#define teleportlocs area_repository.get_areas_by_name_and_coords(GLOB.is_player_but_not_space_or_shuttle_area_or_sealed)
#define playerlocs area_repository.get_areas_by_name_and_coords(GLOB.is_player_but_not_space_or_shuttle_area)
