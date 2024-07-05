/datum/component/ambushable
	var/last_ambush
	var/ambush_check

/datum/component/ambushable/Initialize(...)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	register_signal(parent, SIGNAL_MOB_CONSIDER_AMBUSH, nameof(.proc/consider_ambush))

/datum/component/ambushable/Destroy(force, silent)
	unregister_signal(parent, SIGNAL_MOB_CONSIDER_AMBUSH)
	return ..()

/datum/component/ambushable/proc/can_be_ambushed()
	if(world.time < last_ambush + 300 SECONDS)
		return FALSE

	return TRUE

/datum/component/ambushable/proc/consider_ambush()
	if(prob(95))
		return FALSE

	if(world.time < ambush_check + 15 SECONDS)
		return FALSE

	if(!can_be_ambushed())
		return FALSE

	var/area/A = get_area(parent)
	var/turf/T = get_turf(parent)
	if(!istype(T))
		return FALSE

	if(!is_path_in_list(T.type, A.ambush_types))
		return FALSE

	var/list/victims_list = list(parent)
	for(var/mob/living/L in view(5, parent))
		if(L == parent)
			continue

		var/datum/component/ambushable/ambush_component = L.get_component(/datum/component/ambushable)
		if(!ambush_component?.can_be_ambushed())
			continue

		victims_list |= L

	if(victims_list.len > 3)
		return

	var/list/possible_spawn_locs = list()
	for(var/obj/structure/struct in view(5, parent))
		possible_spawn_locs |= struct

	if(!possible_spawn_locs.len)
		return

	for(var/mob/living/V in victims_list)
		var/datum/component/ambushable/ambush_component = V.get_component(/datum/component/ambushable)
		ambush_component?.last_ambush = world.time

	var/spawned_type = util_pick_weight(A.ambush_mobs)
	for(var/i in 1 to Clamp(victims_list.len *1, 2, 3))
		var/atom/spawnloc = safepick(possible_spawn_locs)
		if(!istype(spawnloc))
			continue

		new spawned_type(get_turf(spawnloc))

	shake_camera(parent, 2, 2)
