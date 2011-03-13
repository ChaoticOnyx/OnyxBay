/obj/machinery/door/Bumped(atom/AM)
	if(p_open || operating || !density || !autoopen) return
	if(ismob(AM))
		var/mob/M = AM
		if(world.timeofday - AM.last_bumped <= 5) return
		if(M.client && !M:handcuffed) attack_hand(M)
	else if(istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM
		if(src.check_access(bot.botcard))
			if(density)
				open()
	else if(istype(AM, /obj/alien/facehugger))
		if(src.check_access(null))
			if(density)
				open()
// beepDERP
/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover, /obj/beam))
		return !opacity
	return !density

/obj/machinery/door/proc/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0

	var/turf/simulated/source = loc
	var/turf/simulated/north = get_step(source,NORTH)
	var/turf/simulated/south = get_step(source,SOUTH)
	var/turf/simulated/east = get_step(source,EAST)
	var/turf/simulated/west = get_step(source,WEST)

	if(need_rebuild)
		if(istype(source)) //Rebuild/update nearby group geometry
			if(source.parent)
				air_master.groups_to_rebuild += source.parent
			else
				air_master.tiles_to_update += source
		if(istype(north))
			if(north.parent)
				air_master.groups_to_rebuild += north.parent
			else
				air_master.tiles_to_update += north
		if(istype(south))
			if(south.parent)
				air_master.groups_to_rebuild += south.parent
			else
				air_master.tiles_to_update += south
		if(istype(east))
			if(east.parent)
				air_master.groups_to_rebuild += east.parent
			else
				air_master.tiles_to_update += east
		if(istype(west))
			if(west.parent)
				air_master.groups_to_rebuild += west.parent
			else
				air_master.tiles_to_update += west
	else
		if(istype(source)) air_master.tiles_to_update += source
		if(istype(north)) air_master.tiles_to_update += north
		if(istype(south)) air_master.tiles_to_update += south
		if(istype(east)) air_master.tiles_to_update += east
		if(istype(west)) air_master.tiles_to_update += west

	return 1

/obj/machinery/door
	var/Zombiedamage
	New()
		..()

		update_nearby_tiles(need_rebuild=1)

	Del()
		update_nearby_tiles()

		..()


/obj/machinery/door/meteorhit(obj/M as obj)
	src.open()
	return

/obj/machinery/door/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/attack_hand(mob/user as mob)
	return src.attackby(user, user)

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/attackby(obj/item/I as obj, mob/user as mob)
	if (src.operating)
		return
	src.add_fingerprint(user)

	if (istype(user, /mob/living/carbon/human) && user:zombie)
		user << "\blue You claw the airlock"
		Zombiedamage += rand(4,8)
		if(Zombiedamage > 80 || (locked && Zombiedamage > 200))
			src.locked = 0
			user << "\blue You break the circuitry"
			src.operating = -1
			flick("door_spark", src)
			sleep(6)
			forceopen()
			return 1
		operating = 1
		spawn(6) operating = 0
		return 1

	if (!src.requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null
	if (src.density && istype(I, /obj/item/weapon/card/emag))
		src.operating = -1
		flick("door_spark", src)
		sleep(6)
		open()
		return 1
	if (src.allowed(user))
		if (src.density)
			open()
		else
			close()
	else if (src.density)
		flick("door_deny", src)
	return
/obj/machinery/door/blob_act()
	if(prob(20))
		del(src)

/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if(prob(25))
				del(src)
			else
				src.forceopen()
				src.operating = -1
				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				flick("door_spark", src)

		if(3.0)
			if(prob(50))
				src.forceopen()
				src.operating = -1
				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				flick("door_spark", src)

/obj/machinery/door/proc/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"
	return

/obj/machinery/door/proc/animate(animation)
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(p_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			flick("door_deny", src)
	return

/obj/machinery/door/proc/open()
	if(!density)
		return 1
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1

	animate("opening")
	sleep(6)
	src.density = 0
	update_icon()

	src.ul_SetOpacity(0)
	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0

	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/proc/forceopen()
	return

/obj/machinery/door/proc/close()
	if(density)
		return 1
	if (src.operating)
		return
	src.operating = 1

	animate("closing")
	src.density = 1
	spawn(4)
		if(!istype(src, /obj/machinery/door/window))
			for(var/mob/living/L in src.loc) // Crush mobs and move them out of the way

				if(src.forcecrush) // Save an AI, crush a limb
					var/limbname = pick("l arm", "r arm", "l hand","r hand", "l foot", "r foot")
					var/limbdisplay

					for(var/organ in L:organs)
						var/datum/organ/external/temp = L:organs["[organ]"]
						if (istype(temp, /datum/organ/external) && temp.name == limbname)
							limbdisplay = temp.display_name // Take the name for down below
							temp.take_damage(60, 0) //OH GOD IT HURTS
							break

					L << "\red The airlock crushes your [limbdisplay]!"
					for(var/mob/O in viewers(L, null))
						O.show_message("\red The airlock crushes [L.name]'s [limbdisplay]!", 1)


				else
					L << "\red The airlock forces you out of the way!" //Lucky you
					for(var/mob/O in viewers(L, null))
						O.show_message("\red The airlock pushes [L.name] out of the way!", 1)

				var/list/lst = list(NORTH,SOUTH,EAST,WEST)
				var/turf/T = get_random_turf(L, lst)
				if(T)
					L.loc = T

			for(var/obj/item/I in src.loc) // Move items out of the way
				if(!I.anchored)
					var/list/lst = list(NORTH,SOUTH,EAST,WEST)
					var/turf/T = get_random_turf(I, lst)
					if(T)
						I.loc = T

	sleep(6)
	update_icon()

	if (src.visible && (!istype(src, /obj/machinery/door/airlock/glass)))
		src.ul_SetOpacity(1)
	if(operating == 1)
		operating = 0
	update_nearby_tiles()

/obj/machinery/door/proc/autoclose()
	var/obj/machinery/door/airlock/A = src
	if ((!A.density) && !( A.operating ) && !(A.locked) && !( A.welded ))
		close()
	else return

/////////////////////////////////////////////////// Unpowered doors

/obj/machinery/door/unpowered
	explosionstrength = 1
	autoclose = 0
	//var/locked = 0

/obj/machinery/door/unpowered/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/unpowered/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/unpowered/attack_hand(mob/user as mob)
	return src.attackby(null, user)

/obj/machinery/door/unpowered/attackby(obj/item/I as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (src.allowed(user))
		if (src.density && !locked)
			open()
		else
			close()
	return

/obj/machinery/door/unpowered/shuttle
	icon = 'shuttle.dmi'
	name = "door"
	icon_state = "door1"
	opacity = 1
	density = 1
	autoopen = 0

/obj/machinery/door/unpowered/shuttle/attackby(obj/item/I as obj, mob/user as mob)
	if (src.operating)
		return
	if(src.loc.loc.name == "Arrival Shuttle" || src.loc.loc.name == "supply shuttle" || src.loc.loc.name == "Docking Bay D" || src.loc.loc.name == "NanoTrasen shuttle")
		..()
		return
	if(!LaunchControl.online)
		if(src.density)
			var/area/A = user.loc.loc
			if(A.name == "Escape Pod A" || A.name == "Escape Pod B" || A.name == "Space")
				user.show_viewers(text("\blue [] opens the shuttle door.", user))
				src.add_fingerprint(user)
				open()
				spawn(100)
					if(!LaunchControl.online && !src.density)
						close()
		else
			src.add_fingerprint(user)
			close()
		return
	if(LaunchControl.online)
		src.add_fingerprint(user)
		if(src.density)
			open()
		else
			close()

// ***************************************
// Networking Support
// ***************************************
/*
/obj/machinery/door/NetworkIdentInfo()
	return "DOOR [!src.density ? "OPEN" : "CLOSED"]"

/obj/machinery/door/ReceiveNetworkPacket(message, sender)
	if(..())
		return 1
	var/list/PacketParts = GetPacketContentUppercased(message)
	if(PacketParts.len < 2)
		return 0
	if(check_password(PacketParts[1]))
		if(PacketHasStringAtIndex(PacketParts, 2, "OPEN"))
			spawn(0)
				open()
			return 1
		else if(PacketHasStringAtIndex(PacketParts, 2, "CLOSE"))
			spawn(0)
				close()
				return 1
	return 0

*/