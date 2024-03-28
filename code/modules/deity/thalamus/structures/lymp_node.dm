/datum/deity_power/structure/thalamus/lymp_node
	name = "lymp_node"
	desc = "lymp_node"
	power_path = /datum/deity_power/structure/thalamus/lymp_node
	resource_cost = list(
		/datum/deity_resource/thalamus/nutrients = 10
	)

/obj/structure/deity/thalamus/lymp_node
	name = "tendril"
	desc = ""
	icon_state = "lymp_hode"
	var/damage = 14

	var/datum/proximity_trigger/proximity
	vision_range = 7

/obj/structure/deity/thalamus/lymp_node/Initialize(mapload, datum, owner, health)
	. = ..()
	proximity = new(
		src,
		/obj/machinery/turret/proc/on_proximity,
		/obj/machinery/turret/proc/on_changed_turf_visibility,
		vision_range,
		PROXIMITY_EXCLUDE_HOLDER_TURF,
		src
	)
	proximity.register_turfs()

/obj/structure/deity/thalamus/lymp_node/proc/on_proximity(atom/movable/AM)
	if(can_be_hostile_to(AM))
		spawn_cells(AM)

/obj/structure/deity/thalamus/lymp_node/proc/can_be_hostile_to(atom/movable/potential_target)
	return hostility?.can_target(src, potential_target)

/obj/structure/deity/thalamus/lymp_node/proc/(list/prior_turfs, list/current_turfs)
	if(!length(prior_turfs))
		return

	if(QDELETED(src))
		return

	var/list/turfs_to_check = current_turfs - prior_turfs
	for(var/turf/T as anything in turfs_to_check)
		for(var/atom/movable/AM in T)
			on_proximity(AM)
