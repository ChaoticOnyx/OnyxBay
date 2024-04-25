// Returns the atom sitting on the turf.
// For example, using this on a disk, which is in a bag, on a mob, will return the mob because it's on the turf.
/proc/get_atom_on_turf(atom/movable/M)
	var/atom/mloc = M
	while(mloc && mloc.loc && !istype(mloc.loc, /turf/))
		mloc = mloc.loc
	return mloc

/proc/iswall(turf/T)
	return (istype(T, /turf/simulated/wall) || istype(T, /turf/unsimulated/wall) || istype(T, /turf/simulated/shuttle/wall))

/proc/isfloor(turf/T)
	return (istype(T, /turf/simulated/floor) || istype(T, /turf/unsimulated/floor))

/proc/turf_clear(turf/T)
	for(var/atom/A in T)
		if(A.simulated)
			return 0
	return 1

// Picks a turf without a mob from the given list of turfs, if one exists.
// If no such turf exists, picks any random turf from the given list of turfs.
/proc/pick_mobless_turf_if_exists(list/start_turfs)
	if(!start_turfs.len)
		return null

	var/list/available_turfs = list()
	for(var/start_turf in start_turfs)
		var/mob/M = locate() in start_turf
		if(!M)
			available_turfs += start_turf
	if(!available_turfs.len)
		available_turfs = start_turfs
	return pick(available_turfs)

/proc/get_random_turf_in_range(atom/origin, outer_range, inner_range)
	origin = get_turf(origin)
	if(!origin)
		return
	var/list/turfs = list()
	for(var/turf/T in orange(origin, outer_range))
		if(!(T.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_SEALED))) // Picking a turf outside the map edge isn't recommended
			if(T.x >= world.maxx-TRANSITION_EDGE || T.x <= TRANSITION_EDGE)	continue
			if(T.y >= world.maxy-TRANSITION_EDGE || T.y <= TRANSITION_EDGE)	continue
		if(!inner_range || get_dist(origin, T) >= inner_range)
			turfs += T
	if(turfs.len)
		return pick(turfs)

/proc/parse_caught_click_modifiers(list/modifiers, client/viewer, turf/origin)
	if(!origin)
		return null

	var/list/actual_view = get_view_size(isnull(viewer) ? world.view : viewer.view)

	var/list/screen_loc = splittext(modifiers["screen-loc"], ",")
	var/list/click_params_x = splittext(screen_loc[1], ":")
	var/list/click_params_y = splittext(screen_loc[2], ":")

	var/turf_x = clamp(origin.x + text2num(click_params_x[1]) - ceil(actual_view[1] / 2), 1, world.maxx)
	var/turf_y = clamp(origin.y + text2num(click_params_y[1]) - ceil(actual_view[2] / 2), 1, world.maxy)
	var/turf_z = origin.z

	return locate(turf_x, turf_y, turf_z)

/*
	Predicate helpers
*/

/proc/is_holy_turf(turf/T)
	return T && T.holy

/proc/is_not_holy_turf(turf/T)
	return !is_holy_turf(T)

/proc/turf_contains_dense_objects(turf/T)
	return T.contains_dense_objects()

/proc/not_turf_contains_dense_objects(turf/T)
	return !turf_contains_dense_objects(T)

/proc/is_station_turf(turf/T)
	return T && isStationLevel(T.z)

/proc/has_air(turf/T)
	return !!T.return_air()

/proc/IsTurfAtmosUnsafe(turf/T)
	ASSERT(T)
	if(istype(T, /turf/space)) // Space tiles
		return "Spawn location is open to space."
	var/datum/gas_mixture/air = T.return_air()
	if(!air)
		return "Spawn location lacks atmosphere."
	return get_atmosphere_issues(air, 1)

/proc/IsTurfAtmosSafe(turf/T)
	return !IsTurfAtmosUnsafe(T)

/proc/is_below_sound_pressure(turf/T)
	var/datum/gas_mixture/environment = T ? T.return_air() : null
	var/pressure =  environment ? environment.return_pressure() : 0
	if(pressure < SOUND_MINIMUM_PRESSURE)
		return TRUE
	return FALSE

/*
	Turf manipulation
*/

//Returns an assoc list that describes how turfs would be changed if the
//turfs in turfs_src were translated by shifting the src_origin to the dst_origin
/proc/get_turf_translation(turf/src_origin, turf/dst_origin, list/turfs_src)
	var/list/turf_map = list()
	for(var/turf/source in turfs_src)
		var/x_pos = (source.x - src_origin.x)
		var/y_pos = (source.y - src_origin.y)
		var/z_pos = (source.z - src_origin.z)

		var/turf/target = locate(dst_origin.x + x_pos, dst_origin.y + y_pos, dst_origin.z + z_pos)
		if(!target)
			error("Null turf in translation @ ([dst_origin.x + x_pos], [dst_origin.y + y_pos], [dst_origin.z + z_pos])")
		turf_map[source] = target //if target is null, preserve that information in the turf map

	return turf_map


/proc/translate_turfs(list/translation, area/base_area = null, turf/base_turf)
	for(var/turf/source in translation)

		var/turf/target = translation[source]

		if(target)
			//update area first so that area/Entered() will be called with the correct area when atoms are moved
			if(base_area)
				source.loc.contents.Add(target)
				base_area.contents.Add(source)
			transport_turf_contents(source, target, base_turf || get_base_turf_by_area(source))

	//change the old turfs
	for(var/turf/source in translation)
		var/base = base_turf || get_base_turf_by_area(source)
		if(istype(source, base))
			continue
		source.ChangeTurf(base, 1, 1)

//Transports a turf from a source turf to a target turf, moving all of the turf's contents and making the target a copy of the source.
/proc/transport_turf_contents(turf/source, turf/target, base)
	if(!istype(source, base))
		target = target.ChangeTurf(source.type, 1, 1)
		target.transport_properties_from(source)

	for(var/obj/O in source)
		if(O.simulated)
			O.forceMove(target)

	for(var/mob/M in source)
		if(isEye(M)) continue // If we need to check for more mobs, I'll add a variable
		M.forceMove(target, unbuckle_mob = FALSE)

	return target
///Returns a random turf on the station, excludes dense turfs (like walls) and areas that are exposed to space
/proc/get_safe_random_station_turf(list/areas_to_pick_from = GLOB.station_areas)
	for(var/i in 1 to 5)
		var/list/turf_list = get_area_turfs(pick(areas_to_pick_from))
		var/turf/target

		while(turf_list.len && !target)
			var/I = rand(1, turf_list.len)
			var/turf/checked_turf = turf_list[I]
			var/area/turf_area = get_area(checked_turf)

			if(!checked_turf.density && !(turf_area.area_flags & AREA_FLAG_EXTERNAL))
				var/clear = TRUE
				for(var/obj/checked_object in checked_turf)
					if(checked_object.density)
						clear = FALSE
						break

				if(clear)
					target = checked_turf
			if (!target)
				turf_list.Cut(I, I + 1)

		if(target)
			return target
