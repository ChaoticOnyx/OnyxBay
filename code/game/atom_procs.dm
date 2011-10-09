/atom/proc/attack_hand(mob/user as mob)
	return

/atom/proc/attack_paw(mob/user as mob)
	return

/atom/proc/attack_ai(mob/user as mob)
	return

//for aliens, it works the same as monkeys except for alien -> mob interactions which will be defined in the
//appropiate mob files
/atom/proc/attack_alien(mob/user as mob)
	src.attack_paw(user)
	return

/atom/proc/hand_h(mob/user as mob)
	return

/atom/proc/hand_p(mob/user as mob)
	return

/atom/proc/hand_a(mob/user as mob)
	return

/atom/proc/hand_al(mob/user as mob)
	src.hand_p(user)
	return


/atom/proc/hitby(atom/movable/AM as mob|obj)
	return

/atom/proc/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/detective_scanner))
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O << "\red [src] has been scanned by [user] with the [W]"
	else
		if (!( istype(W, /obj/item/weapon/grab) ) || !(istype(W, /obj/item/weapon/cleaner)))
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O << "\red <B>[src] has been hit by [user] with [W]</B>"
	return

/atom/proc/add_fingerprint(mob/living/carbon/human/M as mob)
	if ((!( istype(M, /mob/living/carbon/human) ) || !( istype(M.dna, /datum/dna) )))
		return 0
	add_fibers(M)
	if (!( src.flags ) & 256)
		return
	if (M.gloves)
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "(Wearing gloves). Real name: [M.real_name], Key: [M.key]"
			src.fingerprintslast = M.key
		return 0
	if (M.mutations & mFingerprints)
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "(Has no fingerprints) Real name: [M.real_name], Key: [M.key]"
			src.fingerprintslast = M.key
		return 0
	if (!( src.fingerprints ))
		src.fingerprints = text("[]", md5(M.dna.uni_identity))
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "Real name: [M.real_name], Key: [M.key]"
			src.fingerprintslast = M.key
		return 1
	else
		var/list/L = params2list(src.fingerprints)
		L -= md5(M.dna.uni_identity)
		while(L.len >= 3)
			L -= L[1]
		L += md5(M.dna.uni_identity)
		src.fingerprints = list2params(L)

		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "Real name: [M.real_name], Key: [M.key]"
			src.fingerprintslast = M.key
	return


/atom/proc/add_blood(mob/living/carbon/human/M as mob)
	if (!( istype(M, /mob/living/carbon/human) ))
		return 0
	if (!( src.flags ) & 256)
		return
	if (!( src.blood_DNA ))
		if (istype(src, /obj/item))
			var/obj/item/source2 = src
			source2.icon_old = src.icon
			var/icon/I = new /icon(src.icon, src.icon_state)
			I.Blend(new /icon('blood.dmi', "thisisfuckingstupid"),ICON_ADD)
			I.Blend(new /icon('blood.dmi', "itemblood"),ICON_MULTIPLY)
			I.Blend(new /icon(src.icon, src.icon_state),ICON_UNDERLAY)
			src.icon = I
			src.blood_DNA = M.dna.unique_enzymes
			src.blood_type = M.b_type
		else if (istype(src, /turf/simulated))
			var/turf/simulated/source2 = src
			var/list/objsonturf = range(0,src)
			var/i
			for(i=1, i<=objsonturf.len, i++)
				if(istype(objsonturf[i],/obj/decal/cleanable/blood))
					return 0
			var/obj/decal/cleanable/blood/this = new /obj/decal/cleanable/blood(source2)
			this.blood_DNA = M.dna.unique_enzymes
			this.blood_type = M.b_type
			this.virus = M.virus
			if(M.virus2)
				this.virus2 = M.virus2.getcopy()
			this.blood_owner = M
		else if (istype(src, /mob/living/carbon/human))
			src.blood_DNA = M.dna.unique_enzymes
			src.blood_type = M.b_type
		else
			return 0
	else
		var/list/L = params2list(src.blood_DNA)
		L -= M.dna.unique_enzymes
		while(L.len >= 3)
			L -= L[1]
		L += M.dna.unique_enzymes
		src.blood_DNA = list2params(L)
	return 1

/atom/proc/clean_blood()

	if (!( src.flags ) & 256)
		return
	if ( src.blood_DNA )
		if (istype (src, /obj/item))
			var/obj/item/source2 = src
			source2.blood_DNA = null
			var/icon/I = new /icon(source2.icon_old, source2.icon_state)
			source2.icon = I
		else if (istype(src, /turf/simulated))
			var/obj/item/source2 = src
			source2.blood_DNA = null
			var/icon/I = new /icon(source2.icon_old, source2.icon_state)
			source2.icon = I
	return

/atom/MouseDrop(atom/B)
	if((usr.mutations & 1 || (in_range(src,usr,0) && in_range(B,usr,0))) && !src:anchored)
		step_towards(src, B)
		if(in_range(src,B))
			if(istype(src,/obj/item))
				B:attackby(src, usr)
				if(istype(B, /mob))
					src:attack(B, usr)
				src:afterattack(B, usr)
		var/obj/overlay/O = new /obj/overlay(locate(src.loc))
		if(usr.mutations & 1)
			O.name = "sparkles"
			O.anchored = 1
			O.density = 0
			O.layer = FLY_LAYER
			O.dir = pick(cardinal)
			O.icon = 'effects.dmi'
			O.icon_state = "nothing"
			flick("empdisable",O)
			spawn(5)
				del(O)
	spawn( 0 )
		if (istype(B))
			B.MouseDrop_T(src, usr)
		return

/atom/proc/MouseDrop_T()
        return

/atom/Click(location,control,params)
	//world << "atom.Click() on [src] by [usr] : src.type is [src.type]"

	if(usr.client.buildmode)
		build_click(usr, usr.client.buildmode, location, control, params, src)
		return

	return DblClick()

/atom/DblClick() //TODO: DEFERRED: REWRITE
	if (world.time <= usr:lastDblClick+2)
		//world << "BLOCKED atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		return
	else
		//world << "atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		usr:lastDblClick = world.time

	..()

	usr.log_m("Clicked on [src]")

	if(usr.in_throw_mode)
		return usr:throw_item(src)

	var/obj/item/W = null
	if(ismob(src) && istype(usr,/mob/living/silicon/ai))
		usr:ai_actual_track(src)
	if(istype(usr, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = usr
		W = R.selected_module()
		if(!W)
			var/count
			var/list/objects = list()
			if(usr:module_state_1)
				objects += usr:module_state_1
				count++
			if(usr:module_state_2)
				objects += usr:module_state_2
				count++
			if(usr:module_state_3)
				objects += usr:module_state_3
				count++
			if(count > 1)
				var/input = input("Please, select an item!", "Item", null, null) as obj in objects
				W = input
			else if(count != 0)
				for(var/obj in objects)
					W = obj
			else if(count == 0)
				W = null
	else
		W = usr.equipped()

	if (W == src && usr.stat == 0)
		spawn (0)
			W.attack_self(usr)
		return

	if (((usr.paralysis || usr.stunned || usr.weakened) && !istype(usr, /mob/living/silicon/ai)) || usr.stat != 0)
		return

	if ((!( src in usr.contents ) && (((!( isturf(src) ) && (!( isturf(src.loc) ) && (src.loc && !( isturf(src.loc.loc) )))) || !( isturf(usr.loc) )) && (src.loc != usr.loc && (!( istype(src, /obj/screen) ) && !( usr.contents.Find(src.loc) ))))))
		return

	var/t5
	if(istype(src, /obj/item)) t5 = in_range(src, usr, 0) || src.loc == usr
	else t5 = in_range(src, usr) || src.loc == usr

	if (istype(usr, /mob/living/silicon/ai))
		t5 = 1

	if (istype(usr, /mob/living/silicon/robot) && W == null)
		t5 = 1

	if (istype(src, /datum/organ) && src in usr.contents)
		return

	if (((t5 || (W && (W.flags & 16))) && !( istype(src, /obj/screen) )))
		if (usr.next_move < world.time)
			usr.prev_move = usr.next_move
			usr.next_move = world.time + 10
		else
			return

		if ((src.loc && (get_dist(src, usr) < 2 || src.loc == usr.loc)))
			var/direct = get_dir(usr, src)
			var/ok = 0
			if ( (direct - 1) & direct)
				var/turf/Step_1
				var/turf/Step_2
				switch(direct)
					if(EAST|NORTH)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, EAST)

					if(EAST|SOUTH)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, EAST)

					if(NORTH|WEST)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, WEST)

					if(SOUTH|WEST)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, WEST)

					else

				if(Step_1 && Step_2)
					var/check_1 = 1
					var/check_2 = 1

					check_1 = CanReachThrough(get_turf(usr), Step_1, src) && CanReachThrough(Step_1, get_turf(src), src)

					check_2 = CanReachThrough(get_turf(usr), Step_2, src) && CanReachThrough(Step_2, get_turf(src), src)

					ok = (check_1 || check_2)
			else

				ok = CanReachThrough(get_turf(usr), get_turf(src), src)

			if (!( ok ))
				return 0

		if ( !(usr.restrained()) )
			if (W)
				if (t5)
					src.alog(W,usr)
					src.attackby(W, usr)
				if (W)
					W.afterattack(src, usr, (t5 ? 1 : 0))
			else
				if (istype(usr, /mob/living/carbon/human))
					src.attack_hand(usr, usr.hand)
				else
					if (istype(usr, /mob/living/carbon/monkey))
						src.attack_paw(usr, usr.hand)
					else
						if (istype(usr, /mob/living/carbon/alien/humanoid))
							src.attack_alien(usr, usr.hand)
						else
							if (istype(usr, /mob/living/silicon))
								src.attack_ai(usr, usr.hand)
		else
			if (istype(usr, /mob/living/carbon/human))
				src.hand_h(usr, usr.hand)
			else
				if (istype(usr, /mob/living/carbon/monkey))
					src.hand_p(usr, usr.hand)
				else
					if (istype(usr, /mob/living/carbon/alien/humanoid))
						src.hand_al(usr, usr.hand)
					else
						if (istype(usr, /mob/living/silicon))
							src.hand_a(usr, usr.hand)

	else
		if (istype(src, /obj/screen))
			usr.prev_move = usr.next_move
			if (usr.next_move < world.time)
				usr.next_move = world.time + 10
			else
				return
			if (!( usr.restrained() ))
				if ((W && !( istype(src, /obj/screen) )))
					src.alog(W,usr)
					src.attackby(W, usr)

					if (W)
						W.afterattack(src, usr)
				else
					if (istype(usr, /mob/living/carbon/human))
						src.attack_hand(usr, usr.hand)
					else
						if (istype(usr, /mob/living/carbon/monkey))
							src.attack_paw(usr, usr.hand)
						else
							if (istype(usr, /mob/living/carbon/alien/humanoid))
								src.attack_alien(usr, usr.hand)
			else
				if (istype(usr, /mob/living/carbon/human))
					src.hand_h(usr, usr.hand)
				else
					if (istype(usr, /mob/living/carbon/monkey))
						src.hand_p(usr, usr.hand)
					else
						if (istype(usr, /mob/living/carbon/alien/humanoid))
							src.hand_al(usr, usr.hand)
	return

/atom/proc/CanReachThrough(turf/srcturf, turf/targetturf, atom/target)
	var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( srcturf )

	if(targetturf.density && targetturf != get_turf(target))
		return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in srcturf)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CheckExit(D, targetturf))
				del D
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in targetturf)
		if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
			if(!border_obstacle.CanPass(D, srcturf, 1, 0))
				del D
				return 0

	del D
	return 1
/atom/proc/CanReachTrough2(turf/srcturf, turf/targetturf, atom/target)
// HORRIBLE
/*
	var/direct = get_dir(target, src)
	var/canpass1 = 0
	var/canpass2 = 0
	world << "[direct]"
	switch(direct)
		if(1)
			world << "NORTH || SOUTH || WEST || EAST"
			if(CanReachThrough(srcturf,targetturf,target))
				return 1
			else
				return 0
		if(2)
			world << "NORTH || SOUTH || WEST || EAST"
			if(CanReachThrough(srcturf,targetturf,target))
				return 1
			else
				return 0
		if(4)
			world << "NORTH || SOUTH || WEST || EAST"
			if(CanReachThrough(srcturf,targetturf,target))
				return 1
			else
				return 0
		if(8)
			world << "NORTH || SOUTH || WEST || EAST"
			if(CanReachThrough(srcturf,targetturf,target))
				return 1
			else
				return 0
		if(NORTHWEST)
			world << "NORTHWEST"
			var/turf/north = get_step(src,1)
			var/turf/west = get_step(north,8)
			canpass1 = north.TestEnter(target)
			canpass2 = west.TestEnter(target)
			if(canpass1 && canpass2)
				return 1
			else
				return 0
		if(NORTHEAST)
			world << "NORTHEAST"
			var/turf/north = get_step(src,1)
			var/turf/west = get_step(north,4)
			canpass1 = north.TestEnter(target)
			canpass2 = west.TestEnter(target)
			if(canpass1 && canpass2)
				return 1
			else
				return 0
		if(SOUTHEAST)
			world << "SOUTHEAST"
			var/turf/north = get_step(src,2)
			var/turf/west = get_step(north,4)
			canpass1 = north.TestEnter(target)
			canpass2 = west.TestEnter(target)
			if(canpass1 && canpass2)
				return 1
			else
				return 0
		if(SOUTHWEST)
			world << "SOUTHWEST"
			var/turf/north = get_step(src,2)
			var/turf/west = get_step(north,8)
			canpass1 = north.TestEnter(target)
			canpass2 = west.TestEnter(target)
			if(canpass1 && canpass2)
				return 1
			else
				return 0
			//HEADBACK

	var/direct = get_dir(usr, src)
	var/ok = 0
	if ( (direct - 1) & direct)
		var/turf/Step_1
		var/turf/Step_2
		switch(direct)
			if(EAST|NORTH)
				Step_1 = get_step(target, NORTH)
				Step_2 = get_step(target, EAST)
			if(EAST|SOUTH)
				Step_1 = get_step(target, SOUTH)
				Step_2 = get_step(target, EAST)
			if(NORTH|WEST)
				Step_1 = get_step(target, NORTH)
				Step_2 = get_step(target, WEST)
			if(SOUTH|WEST)
				Step_1 = get_step(target, SOUTH)
				Step_2 = get_step(target, WEST)
			else
		if(Step_1 && Step_2)
			var/check_1 = 1
			var/check_2 = 1
			check_1 = CanReachThrough(get_turf(target), Step_1, src) && CanReachThrough(Step_1, get_turf(src), src)
			check_2 = CanReachThrough(get_turf(target), Step_2, src) && CanReachThrough(Step_2, get_turf(src), src)
			if(check_1 && check_2)
				return 1
	else
		if(CanReachThrough(get_turf(target), get_turf(src), src))
			return 1


/turf/proc/TestEnter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover || !isturf(mover.loc))
		return 1


	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover.loc)
		if((obstacle.flags & ~ON_BORDER) && (mover != obstacle) && (forget != obstacle))
			if(!obstacle.CheckExit(mover, src))
				return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in mover.loc)
		if((border_obstacle.flags & ON_BORDER) && (mover != border_obstacle) && (forget != border_obstacle))
			if(!border_obstacle.CheckExit(mover, src))
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in src)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in src)
		if(obstacle.flags & ~ON_BORDER)
			if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
				return 0
	return 1 //Nothing found to block so return success!
*/
/atom/proc/alog(var/atom/device,var/mob/mb)
	src.logs += "[src.name] used by a [device.name] by [mb.real_name]([mb.key])"
	mb.log_m("[src.name] used by a [device.name]")



/atom/proc/addoverlay(var/overlays)
	src.overlayslist += overlays
	src.overlays += overlays

/atom/proc/removeoverlay(var/overlays)
	if (istype(overlays, /image)) // This is needed due to the way overlayss work. The overlays being passed to this proc is in most instances not the same object, so we need to compare their attributes
		var/image/I = overlays
		for (var/image/L in src.overlayslist)
			if (L.icon == I.icon && L.icon_state == I.icon_state && L.dir == I.dir && L.layer == I.layer)
				src.overlayslist -= L
				break
	else
		src.overlayslist -= overlays
	src.overlays -= overlays // Seems that the overlayss list is special and is able to remove them. Suspect it does similar to the if block above.

/atom/proc/clearoverlays()
	src.overlayslist = new/list()
	src.overlays = null

/atom/proc/addalloverlays(var/list/overlayss)
	src.overlayslist = overlayss
	src.overlays = overlayss