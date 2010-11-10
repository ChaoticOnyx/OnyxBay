// ===

/area/New()

	src.icon = 'alert.dmi'
	spawn(1)
	//world.log << "New: [src] [tag]"
		if(name == "Space")			// override defaults for space
			ul_Lighting = 0
		ul_Prep()
		if(findtext(tag,":UL") != 0)
			related += src
			return

		master = src
		related = list(src)

		src.icon = 'alert.dmi'
		src.layer = 10

		if(name == "Space")			// override defaults for space
			requires_power = 0

		if(!requires_power)
			power_light = 1
			power_equip = 1
			power_environ = 1
			//luminosity = 1
			ul_Lighting = 0			// *DAL*
		else
			luminosity = 0
			//ul_SetLuminosity(0)		// *DAL*


		spawn(15)
			src.power_change()		// all machines set to current power level, also updates lighting icon
			alldoors = get_doors(src)

/area/Del()
	related -= src
	..()

/area/proc/poweralert(var/state, var/source)
	if (state != poweralm)
		poweralm = state
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras += C
		for (var/mob/living/silicon/aiPlayer in world)
			if (state == 1)
				aiPlayer.cancelAlarm("Power", src, source)
			else
				aiPlayer.triggerAlarm("Power", src, cameras, source)
	return

/area/proc/firealert()
	if(src.name == "Space") //no fire alarms in space
		return
	if (!( src.fire ))
		src.fire = 1
		//src.updateicon()				//Commented by Strumpetplaya - Alarm Change, no longer necessary.
		src.mouse_opacity = 0
		//if(!alldoors)
		//	alldoors = get_doors(src)
		for(var/obj/machinery/door/firedoor/D in alldoors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = CLOSED
				else if(!D.density)
					spawn(0)
					D.close()
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras += C
		for (var/mob/living/silicon/ai/aiPlayer in world)
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for (var/obj/machinery/computer/atmosphere/alerts/a in world)
			a.triggerAlarm("Fire", src, cameras, src)
	return


//firereset() Edited by Strumpetplaya
/area/proc/firereset()
	if (src.fire)
		src.fire = 0
		src.mouse_opacity = 0
		src.updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			var/AName = src.name
			var/turf/ANorth = locate(D.x,D.y+1,D.z)
			var/area/ANorthA = ANorth.loc
			var/turf/AEast = locate(D.x+1,D.y,D.z)
			var/area/AEastA = AEast.loc
			var/turf/ASouth = locate(D.x,D.y-1,D.z)
			var/area/ASouthA = ASouth.loc
			var/turf/AWest = locate(D.x-1,D.y,D.z)
			var/area/AWestA = AWest.loc

			if(ANorth.density != 1 && ANorthA.name != AName)
				if(ANorthA.fire != 1)
					if(!D.blocked)
						if(D.operating)
							D.nextstate = OPEN
						else if(D.density)
							spawn(0)
							D.open()
				if(ANorthA.fire == 1)
					var/obj/LightTest = locate(/obj/alertlighting/firelight) in D.loc
					if(isnull(LightTest))
						var/obj/alertlighting/firelight/F = new/obj/alertlighting/firelight(D.loc)
						var/image/imagelight = image('alert.dmi',F,icon_state = "blue")
						world << imagelight

			else if(AEast.density != 1 && AEastA.name != AName)
				if(AEastA.fire != 1)
					if(!D.blocked)
						if(D.operating)
							D.nextstate = OPEN
						else if(D.density)
							spawn(0)
							D.open()
				if(AEastA.fire == 1)
					var/obj/LightTest = locate(/obj/alertlighting/firelight) in D.loc
					if(isnull(LightTest))
						var/obj/alertlighting/firelight/F = new/obj/alertlighting/firelight(D.loc)
						var/image/imagelight = image('alert.dmi',F,icon_state = "blue")
						world << imagelight

			else if(ASouth.density != 1 && ASouthA.name != AName)
				if(ASouthA.fire != 1)
					if(!D.blocked)
						if(D.operating)
							D.nextstate = OPEN
						else if(D.density)
							spawn(0)
							D.open()
				if(ASouthA.fire == 1)
					var/obj/LightTest = locate(/obj/alertlighting/firelight) in D.loc
					if(isnull(LightTest))
						var/obj/alertlighting/firelight/F = new/obj/alertlighting/firelight(D.loc)
						var/image/imagelight = image('alert.dmi',F,icon_state = "blue")
						world << imagelight

			else if(AWest.density != 1 && AWestA.name != AName)
				if(AWestA.fire != 1)
					if(!D.blocked)
						if(D.operating)
							D.nextstate = OPEN
						else if(D.density)
							spawn(0)
							D.open()
				if(AWestA.fire == 1)
					var/obj/LightTest = locate(/obj/alertlighting/firelight) in D.loc
					if(isnull(LightTest))
						var/obj/alertlighting/firelight/F = new/obj/alertlighting/firelight(D.loc)
						var/image/imagelight = image('alert.dmi',F,icon_state = "blue")
						world << imagelight
			else
				if(src.fire != 1)
					if(!D.blocked)
						if(D.operating)
							D.nextstate = OPEN
						else if(D.density)
							spawn(0)
							D.open()

/area/proc/partyalert()
	if(src.name == "Space") //no parties in space!!!
		return
	if (!( src.party ))
		src.party = 1
		src.updateicon()
		src.mouse_opacity = 0
	return

/area/proc/partyreset()
	if (src.party)
		src.party = 0
		src.mouse_opacity = 0
		src.updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
					D.open()
	return

/area/proc/activate_air_doors(stayclosed)
	if(src.name == "Space") //no atmo alarms in space
		return
	if (!src.air_doors_activated)			//Edited by Strumpetplaya - Removed "( ) && !air_door_close_delay" from If Statement.
		if(stayclosed)
			air_door_close_delay = 1
			spawn(stayclosed*10)
				air_door_close_delay = 0
		src.air_doors_activated = 1
		//src.updateicon()					//Commented by Strumpetplaya - Alarm Change, not necessary.
		src.mouse_opacity = 0
	//	if(!alldoors)
		//	alldoors = get_doors(src)
		for(var/obj/machinery/door/airlock/D in alldoors)
			if((!D.arePowerSystemsOn()) || (D.stat & NOPOWER)) continue
			if(!D.density)
				spawn(0)
				D.close()
				sleep(10)
				if(D.density)
					D.locked = 1
					D.air_locked = 1
					D.update_icon()
				if(D.operating)
					spawn(10)
						D.close()
						spawn(10)
							if(D.density)
								D.locked = 1
								D.air_locked = 1
								D.update_icon()
			else if(!D.locked) //Don't lock already bolted doors.
				D.locked = 1
				D.air_locked = 1
				D.update_icon()
		if(!fire)
			for(var/obj/machinery/door/firedoor/D in alldoors)
				if(!D.blocked)
					if(D.operating)
						D.nextstate = CLOSED
					else if(!D.density)
						spawn(0)
						D.close()

			//else
			//	D.air_locked = 0 //Ensure we're getting the right doors here.
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras += C
		for (var/mob/living/silicon/ai/aiPlayer in world)
			aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
		for (var/obj/machinery/computer/atmosphere/alerts/a in world)
			a.triggerAlarm("Atmosphere", src, cameras, src)
			//deactivate_air_doors()
	return




/area/proc/deactivate_air_doors(stayopen)
	if (src.air_doors_activated)			//Edited by Strumpetplaya - Removed " && !air_door_close_delay" from If statement.
		if(stayopen)
			air_door_close_delay = 1
			spawn(stayopen*10)
				air_door_close_delay = 0
		src.air_doors_activated = 0
		src.mouse_opacity = 0
		src.updateicon()
	//	if(!alldoors)
		//	alldoors = get_doors(src)
		for(var/obj/machinery/door/airlock/D in src)
			var/AName = src.name
			var/turf/ANorth = locate(D.x,D.y+1,D.z)
			var/area/ANorthA = ANorth.loc
			var/turf/AEast = locate(D.x+1,D.y,D.z)
			var/area/AEastA = AEast.loc
			var/turf/ASouth = locate(D.x,D.y-1,D.z)
			var/area/ASouthA = ASouth.loc
			var/turf/AWest = locate(D.x-1,D.y,D.z)
			var/area/AWestA = AWest.loc

			//world << "If [ANorth.name] density ([ANorth.density]) != and [ANorthA.name] != [AName] then open the damn door."
			if(ANorth.density != 1 && ANorthA.name != AName)
				if(ANorthA.air_doors_activated != 1)
					if((!D.arePowerSystemsOn()) || (D.stat & NOPOWER)) continue
						//D.air_locked = 0
					if(D.air_locked) //Don't mess with doors locked for other reasons.
						if(D.density)
							D.locked = 0
							D.air_locked =0
							D.update_icon()
							//world << "opened North"
				if(ANorthA.air_doors_activated == 1)
					var/obj/LightTest = locate(/obj/alertlighting/atmoslight) in D.loc
					if(isnull(LightTest))
						var/obj/alertlighting/atmoslight/F = new/obj/alertlighting/atmoslight(D.loc)
						var/image/imagelight = image('alert.dmi',F,icon_state = "blueold")
						world << imagelight

			else if(AEast.density != 1 && AEastA.name != AName)
				if(AEastA.air_doors_activated != 1)
					if((!D.arePowerSystemsOn()) || (D.stat & NOPOWER)) continue
						//D.air_locked = 0
					if(D.air_locked) //Don't mess with doors locked for other reasons.
						if(D.density)
							D.locked = 0
							D.air_locked =0
							D.update_icon()
							//world << "opened East"
				if(AEastA.air_doors_activated == 1)
					var/obj/LightTest = locate(/obj/alertlighting/atmoslight) in D.loc
					if(isnull(LightTest))
						var/obj/alertlighting/atmoslight/F = new/obj/alertlighting/atmoslight(D.loc)
						var/image/imagelight = image('alert.dmi',F,icon_state = "blueold")
						world << imagelight
						//world << "Image should be placed"

			else if(ASouth.density != 1 && ASouthA.name != AName)
				if(ASouthA.air_doors_activated != 1)
					if((!D.arePowerSystemsOn()) || (D.stat & NOPOWER)) continue
						//D.air_locked = 0
					if(D.air_locked) //Don't mess with doors locked for other reasons.
						if(D.density)
							D.locked = 0
							D.air_locked =0
							D.update_icon()
							//world << "opened South"
				if(ASouthA.air_doors_activated == 1)
					var/obj/LightTest = locate(/obj/alertlighting/atmoslight) in D.loc
					if(isnull(LightTest))
						var/obj/alertlighting/atmoslight/F = new/obj/alertlighting/atmoslight(D.loc)
						var/image/imagelight = image('alert.dmi',F,icon_state = "blueold")
						world << imagelight

			else if(AWest.density != 1 && AWestA.name != AName)
				if(AWestA.air_doors_activated != 1)
					if((!D.arePowerSystemsOn()) || (D.stat & NOPOWER)) continue
						//D.air_locked = 0
					if(D.air_locked) //Don't mess with doors locked for other reasons.
						if(D.density)
							D.locked = 0
							D.air_locked =0
							D.update_icon()
							//world << "opened West"
				if(AWestA.air_doors_activated == 1)
					var/obj/LightTest = locate(/obj/alertlighting/atmoslight) in D.loc
					if(isnull(LightTest))
						var/obj/alertlighting/atmoslight/F = new/obj/alertlighting/atmoslight(D.loc)
						var/image/imagelight = image('alert.dmi',F,icon_state = "blueold")
						world << imagelight
			else
				if(src.air_doors_activated != 1)
					if((!D.arePowerSystemsOn()) || (D.stat & NOPOWER)) continue
						//D.air_locked = 0
					if(D.air_locked) //Don't mess with doors locked for other reasons.
						if(D.density)
							D.locked = 0
							D.air_locked =0
							D.update_icon()
/*	COMMENTED OUT BY STRUMPETPLAYA - ALARM GCHANGE
		for(var/obj/machinery/door/airlock/D in alldoors)
			if((!D.arePowerSystemsOn()) || (D.stat & NOPOWER)) continue
				//D.air_locked = 0
			if(D.air_locked) //Don't mess with doors locked for other reasons.
				if(D.density)
					D.locked = 0
					D.air_locked =0
					D.update_icon()
*/
		if(!fire)
			for(var/obj/machinery/door/firedoor/D in alldoors)
				if(!D.blocked)
					if(D.operating)
						D.nextstate = OPEN
					else if(D.density)
						spawn(0)
						D.open()
		for (var/mob/living/silicon/ai/aiPlayer in world)
			aiPlayer.cancelAlarm("Atmosphere", src, src)
		for (var/obj/machinery/computer/atmosphere/alerts/a in world)
			a.cancelAlarm("Atmosphere", src, src)
	return



/*This is how the above proc was before Strumpetplaya's alarm changes
/area/proc/deactivate_air_doors(stayopen)
	if (src.air_doors_activated && !air_door_close_delay)
		if(stayopen)
			air_door_close_delay = 1
			spawn(stayopen*10)
				air_door_close_delay = 0
		src.air_doors_activated = 0
		src.mouse_opacity = 0
		src.updateicon()
	//	if(!alldoors)
		//	alldoors = get_doors(src)
		for(var/obj/machinery/door/airlock/D in alldoors)
			if((!D.arePowerSystemsOn()) || (D.stat & NOPOWER)) continue
				//D.air_locked = 0
			if(D.air_locked) //Don't mess with doors locked for other reasons.
				if(D.density)
					D.locked = 0
					D.air_locked =0
					D.update_icon()
		if(!fire)
			for(var/obj/machinery/door/firedoor/D in alldoors)
				if(!D.blocked)
					if(D.operating)
						D.nextstate = OPEN
					else if(D.density)
						spawn(0)
						D.open()
		for (var/mob/living/silicon/ai/aiPlayer in world)
			aiPlayer.cancelAlarm("Atmosphere", src, src)
		for (var/obj/machinery/computer/atmosphere/alerts/a in world)
			a.cancelAlarm("Atmosphere", src, src)
	return
*/





/area/proc/updateicon()
	if ((fire || eject || party) && power_environ)
		if(fire && !eject && !party)
			//icon_state = "blue"				//Commented by Strumpetplaya - Need to find out where this is still getting called from.  Disabling for now.
		else if(!fire && eject && !party)
			icon_state = "red"
		else if(party && !fire && !eject)
			icon_state = "party"
		else
			icon_state = "blue-red"
	else if(air_doors_activated && power_environ)
		//icon_state = "blueold"				//Commented by Strumpetplaya - Need to find out where this is still getting called from.  Disabling for now.
	else
		icon_state = null
/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel

	if(!master.requires_power)
		return 1
	switch(chan)
		if(EQUIP)
			return master.power_equip
		if(LIGHT)
			return master.power_light
		if(ENVIRON)
			return master.power_environ

	return 0

// called when power status changes

/area/proc/power_change()

	for(var/area/RA in related)
		for(var/obj/machinery/M in RA)	// for each machine in the area
			M.power_change()				// reverify power status (to update icons etc.)

		RA.updateicon()


/area/proc/usage(var/chan)

	var/used = 0
	switch(chan)
		if(LIGHT)
			used += master.used_light
		if(EQUIP)
			used += master.used_equip
		if(ENVIRON)
			used += master.used_environ
		if(TOTAL)
			used += master.used_light + master.used_equip + master.used_environ

	return used

/area/proc/clear_usage()

	master.used_equip = 0
	master.used_light = 0
	master.used_environ = 0

/area/proc/use_power(var/amount, var/chan)

	switch(chan)
		if(EQUIP)
			master.used_equip += amount
		if(LIGHT)
			master.used_light += amount
		if(ENVIRON)
			master.used_environ += amount


proc/get_doors(area/A) //Luckily for the CPU, this generally is only run once per area.
	set background = 1
	. = list()
	for(var/area/AR in A.related)
		for(var/obj/machinery/door/D in AR)
			. += D


			//If at least one area that is different from this one is found, execute the rest of this code.
			/*var/area/B
			for(B in orange(T,1))
				if(B != A && !(B in A.related))
					break
			if(!B) continue
			var/list/z_doors_list = list()
			for(var/obj/machinery/door/D in T)
				z_doors_list += D
				z_doors_list[D] = D.density
				D.density = 0
			for(var/turf/X in T.GetBasicCardinals())
				if(X.loc == A || (X.loc in A.related)) continue //Don't bother with turfs already in the area.
				var/list/doors_list = list()
				for(var/obj/machinery/door/O in X)
					if(istype(O,/obj/machinery/door/firedoor))
						var/obj/machinery/door/airlock/maintenance/M = locate() in X
						if(M)
							continue
					doors_list += O
					doors_list[O] = O.density
					O.density = 0
				if(!T.CanPass(null,X,0,0))
					for(var/obj/machinery/door/O in doors_list)
						O.density = doors_list[O]
					continue
				for(var/obj/machinery/door/O in doors_list)
					. += O
					O.density = doors_list[O]*/
			//for(var/obj/machinery/door/D in T)
			//	D.density = z_doors_list[D]