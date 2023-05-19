/datum/event/camera_damage
	id = "camera_damage"
	name = "Camera Damage"
	description = "Random camera will get damaged"

	mtth = 1 HOURS
	difficulty = 15

/datum/event/camera_damage/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (12 MINUTES))
	. = max(1 HOUR, .)

/datum/event/camera_damage/on_fire()
	var/obj/machinery/camera/C = acquire_random_camera()
	if(!C)
		return

	var/severity_range = pick(0, 7, 15)

	for(var/obj/machinery/camera/cam in range(severity_range,C))
		if(is_valid_camera(cam))
			if(prob(2))
				cam.destroy()
			else
				if(!cam.wires.IsIndexCut(CAMERA_WIRE_POWER))
					cam.wires.CutWireIndex(CAMERA_WIRE_POWER)
				if(!cam.wires.IsIndexCut(CAMERA_WIRE_ALARM) && prob(10))
					cam.wires.CutWireIndex(CAMERA_WIRE_ALARM)

/datum/event/camera_damage/proc/acquire_random_camera(remaining_attempts = 5)
	if(!cameranet.cameras.len)
		return
	if(!remaining_attempts)
		return

	var/obj/machinery/camera/C = pick(cameranet.cameras)
	if(is_valid_camera(C))
		return C
	return acquire_random_camera(remaining_attempts - 1)

/datum/event/camera_damage/proc/is_valid_camera(obj/machinery/camera/C)
	// Only return a functional camera, not installed in a silicon, and that exists somewhere players have access
	var/turf/T = get_turf(C)
	return T && C.can_use() && !istype(C.loc, /mob/living/silicon) && (T.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
