/turf/simulated/wall/thalamus
	icon_state = "thalamus"
	var/previous_type = /turf/simulated/wall

/turf/simulated/floor/misc/thalamus
	name = "thalamus floor"
	icon = 'icons/turf/flooring/plating.dmi'
	icon_state = "no name"
	//initial_flooring = /decl/flooring/reinforced/cult
	var/previous_type = /turf/simulated/floor

/turf/proc/thalamify()
	SEND_SIGNAL(src, SIGNAL_TURF_THALAMIFIED, src)

/turf/simulated/floor/thalamify()
	thalamify_floor()
	..()

/turf/simulated/shuttle/wall/thalamify()
	thalamify_wall()
	..()

/turf/simulated/wall/thalamify()
	thalamify_wall()
	..()

/turf/simulated/floor/proc/thalamify_floor()
	var/turf/simulated/floor/floor = src
	var/old_type = floor.type
	var/turf/simulated/floor/misc/cult/cult_floor = src
	ChangeTurf(/turf/simulated/floor/misc/thalamus)
	cult_floor.previous_type = old_type

/turf/simulated/floor/misc/thalamus/proc/dethalamify_floor()
	SEND_SIGNAL(src, SIGNAL_TURF_DETHALAMIFIED, src)
	ChangeTurf(previous_type)

/turf/proc/thalamify_wall()
	var/turf/simulated/wall/wall = src
	var/old_type = wall.type
	var/turf/simulated/wall/thalamus/cult_wall = src
	if(!istype(wall))
		return

	if(wall.reinf_material)
		ChangeTurf(/turf/simulated/wall/thalamus)
		cult_wall.previous_type = old_type
	else
		ChangeTurf(/turf/simulated/wall/thalamus)
		cult_wall.previous_type = old_type
	GLOB.cult.add_cultiness(CULTINESS_PER_TURF)

/turf/simulated/wall/thalamus/proc/dethalamify_wall()
	SEND_SIGNAL(src, SIGNAL_TURF_DETHALAMIFIED, src)
	ChangeTurf(previous_type)
