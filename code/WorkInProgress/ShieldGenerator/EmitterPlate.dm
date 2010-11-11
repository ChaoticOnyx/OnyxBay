//Shield Generator - Emitters
//The shield emitters

/obj/machinery/shielding/emitter
	icon = 'shieldgen.dmi'
	anchored = 1
	var/online = 0
	var/obj/machinery/shielding/capacitor/capac
	var/list/obj/machinery/shielding/shield/shields = list( )
	var/count


//TODO change this so it uses whether shield energy is available
/obj/machinery/shielding/emitter/powered(var/chan = EQUIP)
	return 1

/obj/machinery/shielding/emitter/plate
	icon_state = "plate"
	name = "Emitter Plate"
	desc = "A shield emitter"
/obj/machinery/shielding/emitter/New()
	..()
	//updateAreas()
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
/obj/machinery/shielding/emitter/process()
	if(online)
		usecharge()
/*/obj/machinery/shielding/emitter/verb/derp()
	set src in view()
	var/con = 10 * shields.len
	usr << con
mob/verb/checkusage()
	var/she
	var/am
	for(var/obj/machinery/shielding/emitter/S in snet.mach)
		she += S.shields.len
		am++
	usr << she ** 1.5
	usr << she
	usr << am*/
/obj/machinery/shielding/emitter/proc/usecharge()
	if(online)
		derp
		var/con = shields.len * 0.50
		for(var/obj/machinery/shielding/capacitor/S in snet.mach)
			if(src.z == S.z)
				if(S.charge >= con)
					S.charge -= con
					return
				else if(S.charge <= con && S.charge > 0)
					con -= S.charge
					S.charge = 0
					goto derp

		for(var/obj/machinery/shielding/capacitor/S in snet.mach)
			if(S.charge >= con)
				S.charge -= con
				return
			else if(S.charge <= con && S.charge > 0)
				con -= S.charge
				S.charge = 0
				goto derp
		if(online)
			src.online = 0
	/*	if(power.len >= 1)
			var/obj/machinery/shielding/capacitor/K
			derp3
			for(var/obj/machinery/shielding/capacitor/S in power)
				if(!K)
					K = S
					continue
				if(K.charge < S.charge)
					K = S
			if(K.charge)
				if(K.charge >= con)
					K.charge -= con
					return
				else
					con -= K.charge
					K.charge = 0
					if(power2)
						goto derp3
					else
						goto derp
					return
		else if(power2.len >= 1)
			var/obj/machinery/shielding/capacitor/K
			derp2
			for(var/obj/machinery/shielding/capacitor/S in power2)
				if(!K)
					K = S
					continue
				if(K.charge < S.charge)
					K = S
			if(K.charge)
				if(K.charge >= con)
					K.charge -= con
					return
				else
					con -= K.charge
					K.charge = 0
					if(power2)
						goto derp2
					else
						goto derp
					return*/
