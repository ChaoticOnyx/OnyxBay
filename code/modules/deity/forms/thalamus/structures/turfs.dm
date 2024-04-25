/material/thalamus
	name = MATERIAL_THALAMUS
	display_name = "THALAMSU"
	icon_base = "thalamus"
	icon_reinf = "reinf_cult"
	shard_type = SHARD_SHARD
	resilience = 16
	sheet_singular_name = "layer"
	sheet_plural_name = "layer"
	conductive = TRUE

/turf/simulated/wall/thalamus
	icon_state = "thalamus"
	var/previous_type = /turf/simulated/wall
	icon = 'icons/turf/wall_masks.dmi'

/turf/simulated/wall/thalamus/Initialize(mapload, reinforce)
	. = ..(mapload, MATERIAL_THALAMUS)

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
	ChangeTurf(/turf/simulated/floor/tiled/thalamus)
	var/turf/simulated/floor/tiled/thalamus/t_floor = src
	t_floor.previous_type = old_type

/turf/simulated/floor/tiled/thalamus/proc/dethalamify_floor()
	SEND_SIGNAL(src, SIGNAL_TURF_DETHALAMIFIED, src)
	ChangeTurf(previous_type)

/turf/proc/thalamify_wall()
	var/turf/simulated/wall/wall = src
	var/old_type = wall.type
	var/turf/simulated/wall/thalamus/t_wall = src
	if(!istype(wall))
		return

	if(wall.reinf_material)
		ChangeTurf(/turf/simulated/wall/thalamus)
		t_wall.previous_type = old_type
	else
		ChangeTurf(/turf/simulated/wall/thalamus)
		t_wall.previous_type = old_type

/turf/simulated/wall/thalamus/proc/dethalamify_wall()
	SEND_SIGNAL(src, SIGNAL_TURF_DETHALAMIFIED, src)
	ChangeTurf(previous_type)
