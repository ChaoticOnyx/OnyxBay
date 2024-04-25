/datum/deity_power/structure/thalamus/nerve_cluster
	name = "Nerve Cluster"
	desc = "A mass of twitching nerves used to grow your organs faster"
	power_path = /obj/structure/deity/thalamus/nerve_cluster
	resource_cost = list(/datum/deity_resource/thalamus/nutrients = 20)
	build_type_distance = list(/obj/structure/deity/thalamus/nerve_cluster = 4)

/obj/structure/deity/thalamus/nerve_cluster
	name = "nerve cluster"
	desc = "A cluster of nerve endings sprouting from the floor"
	icon_state = "nerve_cluster"

	var/expanding = TRUE
	var/max_expansion_range = 4
	var/current_expansion_range = 0
	var/list/turfs_in_range = list()

/obj/structure/deity/thalamus/nerve_cluster/Initialize(mapload, datum, owner, health)
	. = ..()

	turfs_in_range = RANGE_TURFS(max_expansion_range, src)
	add_think_ctx("expand", CALLBACK(src, nameof(.proc/expand)), world.time)
	set_next_think_ctx("expand", world.time + 5 SECONDS)

/obj/structure/deity/thalamus/nerve_cluster/proc/expand()
	if(current_expansion_range > max_expansion_range)
		expanding = FALSE
		return

	for(var/turf/T in turfs_in_range)
		if(get_dist(src, T) > current_expansion_range)
			continue

		T.thalamify()
		register_signal(T, SIGNAL_TURF_DETHALAMIFIED, nameof(.proc/turf_dethalamified))

	current_expansion_range++
	set_next_think_ctx("expand", world.time + 5 SECONDS)

/obj/structure/deity/thalamus/nerve_cluster/proc/turf_dethalamified(turf/dethalamified)
	if(!expanding)
		current_expansion_range = 0
		set_next_think_ctx("expand", world.time + 5 SECONDS)

/obj/structure/deity/thalamus/nerve_cluster/Destroy()
	for(var/turf/T in turfs_in_range)
		unregister_signal(T, SIGNAL_TURF_DETHALAMIFIED)

	turfs_in_range.Cut()
	return ..()
