/datum/deity_power/structure
	/// Set to TRUE if this can only be bult once
	var/unique = FALSE
	/// Must be built within this amount of turfs to another deity building. 0 == infinite distance
	var/build_distance = 2
	/// Cannot be built within the specified amount of turfs to another TYPE of deity building. 'building' = 'min_distance'
	var/list/build_type_distance = list()
	/// Determines how fast it will be built
	var/build_time = 0
	/// Maximum health of the building
	var/health_max = 10

/datum/deity_power/structure/can_manifest(atom/target, mob/living/deity/D)
	if(!..())
		return FALSE

	var/turf/target_turf = get_turf(target)

	if(target_turf.density)
		to_chat(D, SPAN_WARNING("You cannot build on a wall!"))
		return FALSE

	if(istype(target_turf, /turf/space) || istype(target_turf, /turf/simulated/open))
		to_chat(D, SPAN_WARNING("You must build on solid ground!"))
		return FALSE

	if(unique && D.get_building_type_amount(power_path) > 0)
		to_chat(D, SPAN_WARNING("You can only have one of these at a time!"))
		return FALSE

	for(var/atom/a in target_turf)
		if(a.density || istype(a, /obj/structure/deity) || istype(a, /mob/living/deity))
			to_chat(D, SPAN_WARNING("You cannot build there!"))
			return FALSE

	if(build_distance)
		var/r = D.get_dist_to_nearest_building(target) <= build_distance
		if(!r)
			to_chat(D, SPAN_WARNING("You must build that closer to another deity building!"))
			return FALSE

	if(build_type_distance.len)
		for(var/type in build_type_distance)
			var/distance = D.get_dist_to_nearest_building_type(target, type)
			var/in_range = distance > build_type_distance[type]
			if(!in_range && distance != -1)
				to_chat(D, SPAN_WARNING("You must build this farther from another building of [type]"))
				return FALSE

	return TRUE

/datum/deity_power/structure/manifest(atom/target, mob/living/deity/D)
	if(can_manifest(target, D) && pay_costs(D))
		return new power_path(target, src, D, health_max)
