//Shield Generator - Emitters
//The shield emitters

/obj/machinery/shielding/emitter
	icon = 'shieldgen.dmi'

	var/list/obj/machinery/shielding/shield/shields = list( )


//TODO change this so it uses whether shield energy is available
/obj/machinery/shielding/emitter/powered(var/chan = EQUIP)
	return 1

/obj/machinery/shielding/emitter/plate
	icon_state = "plate"
	name = "Emitter Plate"
	desc = "A shield emitter"

/obj/machinery/shielding/emitter/proc/updateAreas()
	for(var/shield in shields)
		del(shield)
//	world << "Update"
	for(var/turf/space/S in range(src,10))
		UpdateTurf(S)
	for(var/turf/unsimulated/floor/hull/S in range(src,10))
		UpdateTurf(S)

/obj/machinery/shielding/emitter/proc/UpdateTurf(var/turf/S)
	for(var/atom/A in S.contents)
		if(A.type == /obj/machinery/shielding/shield)
	//		world << "Found, return"
			return
	for(var/dir in cardinal)
		var/turf/T = get_step(S,dir)
		if(T)
			if(T.type != /turf/space && T.type != /turf/unsimulated/floor/hull)
				var/obj/machinery/shielding/shield/Z = new /obj/machinery/shielding/shield(S)
				Z.emitter = src
				shields += Z

/proc/deshielding()
	for(var/obj/machinery/shielding/emitter/E in world)
		E.updateAreas()
