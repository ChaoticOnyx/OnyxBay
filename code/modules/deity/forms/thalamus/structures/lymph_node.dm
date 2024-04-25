#define LYMPHOCYTES_PER_INTRUDER_MIN 2
#define LYMPHOCYTES_PER_INTRUDER_MAX 4
#define NODE_COOLDOWN 15 SECONDS

/datum/deity_power/structure/thalamus/lymph_node
	name = "lymph_node"
	desc = "lymph_node"
	power_path = /obj/structure/deity/thalamus/lymph_node
	resource_cost = list(
		/datum/deity_resource/thalamus/nutrients = 10
	)

/obj/structure/deity/thalamus/lymph_node
	name = "lymph node"
	desc = ""
	icon_state = "lymph_node"
	var/damage = 14

	var/datum/proximity_trigger/square/proximity
	var/datum/hostility/hostility = /datum/hostility/lymph_node
	var/vision_range = 7
	var/last_lymph_spawn

	var/lymphocyte_type = /mob/living/simple_animal/hostile/lymphocyte

/obj/structure/deity/thalamus/lymph_node/Initialize(mapload, datum, owner, health)
	. = ..()
	proximity = new(
		src,
		/obj/structure/deity/thalamus/lymph_node/proc/on_proximity,
		/obj/structure/deity/thalamus/lymph_node/proc/on_changed_turf_visibility,
		vision_range,
		PROXIMITY_EXCLUDE_HOLDER_TURF,
		src
	)
	hostility = new hostility()
	proximity.register_turfs()

/obj/structure/deity/thalamus/lymph_node/proc/on_proximity(atom/movable/AM)
	if(hostility?.can_target(src, AM) && (world.time >= last_lymph_spawn + NODE_COOLDOWN))
		spawn_cells(AM)

/obj/structure/deity/thalamus/lymph_node/proc/on_changed_turf_visibility(list/prior_turfs, list/current_turfs)
	if(!length(prior_turfs))
		return

	if(QDELETED(src))
		return

	var/list/turfs_to_check = current_turfs - prior_turfs
	for(var/turf/T as anything in turfs_to_check)
		for(var/atom/movable/AM in T)
			on_proximity(AM)

/obj/structure/deity/thalamus/lymph_node/proc/spawn_cells(mob/intruder)
	last_lymph_spawn = world.time
	for(var/i = 0 to rand(LYMPHOCYTES_PER_INTRUDER_MIN, LYMPHOCYTES_PER_INTRUDER_MAX))
		flick("lymph_node_flick", src)
		var/mob/living/simple_animal/hostile/lymphocyte/lymph = new lymphocyte_type(get_turf(src))
		lymph.set_target_mob(intruder)

/datum/hostility/lymph_node/can_special_target(atom/holder, mob/target)
	if(!istype(holder))
		return

	if(!ismob(target))
		return FALSE

	if(target.invisibility >= INVISIBILITY_LEVEL_ONE)
		return FALSE

	return TRUE

#undef LYMPHOCYTES_PER_INTRUDER_MIN
#undef LYMPHOCYTES_PER_INTRUDER_MAX
#undef NODE_COOLDOWN
