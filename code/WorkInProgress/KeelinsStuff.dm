/obj/signpost
	icon = 'old_or_unused.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		switch(alert("Travel back to Luna?",,"Yes","No"))
			if("Yes")
				user.loc.loc.Exited(user)
				user.loc = pick(latejoin)
			if("No")
				return

/area/beach
	name = "Keelin's private beach"
	icon_state = "null"
	luminosity = 1
	requires_power = 0
	var/sound/mysound = null

	New()
		..()
		var/sound/S = new/sound()
		mysound = S
		S.file = 'shore.ogg'
		S.repeat = 1
		S.wait = 0
		S.channel = 123
		S.volume = 100
		S.priority = 255
		S.status = SOUND_UPDATE
		process()

	Entered(atom/movable/Obj,atom/OldLoc)
		if(ismob(Obj))
			if(Obj:client)
				mysound.status = SOUND_UPDATE
				Obj << mysound
		return

	Exited(atom/movable/Obj)
		if(ismob(Obj))
			if(Obj:client)
				mysound.status = SOUND_PAUSED | SOUND_UPDATE
				Obj << mysound

	proc/process()
		set background = 1

		var/sound/S = null
		var/sound_delay = 0
		if(prob(25))
			S = sound(file=pick('seag1.ogg','seag2.ogg','seag3.ogg'), volume=100)
			sound_delay = rand(0, 50)

		for(var/mob/living/carbon/human/H in src)
			if(H.s_tone > -55)
				H.s_tone--
				H.update_body()
			if(H.client)
				mysound.status = SOUND_UPDATE
				H << mysound
				if(S)
					spawn(sound_delay)
						H << S

		spawn(60) .()

/obj/item/weapon/beach_ball
	icon = 'beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "clown"
	density = 0
	anchored = 0
	w_class = 1.0
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = FPRINT | USEDELAY | TABLEPASS | CONDUCT
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		user.drop_item()
		src.throw_at(target, throw_range, throw_speed)

/obj/item/weapon/hand_labeler
	icon = 'old_or_unused.dmi'
	icon_state = "labeler"
	item_state = "flight"
	name = "Hand labeler"
	var/label = null
	var/labels_left = 10

/obj/item/weapon/hand_labeler/afterattack(atom/A, mob/user as mob)
	if(A==loc)		// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(!labels_left)
		user << "\red No labels left."
		return
	if(!label || !length(label))
		user << "\red No text set."
		return
	if(length(A.name) + length(label) > 25)
		user << "\red Label too big."
		return

	for(var/mob/M in viewers())
		M << "\blue [user] puts a label on [A]."
	A.name = "[A.name] ([label])"

/obj/item/weapon/hand_labeler/attack_self()
	var/str = input(usr,"Label text?","Set label","")
	if(!str || !length(str))
		usr << "\red Invalid text."
		return
	if(length(str) > 10)
		usr << "\red Text too long."
		return
	label = str
	usr << "\blue You set the text to '[str]'."

/proc/testa()
	fake_attack(usr)

/proc/testb()
	fake_attack(input(usr) as mob in world)

/obj/fake_attacker
	icon = null
	icon_state = null
	name = ""
	desc = ""
	density = 0
	anchored = 1
	opacity = 0
	var/mob/living/carbon/human/my_target = null
	var/weapon_name = null
	var/obj/item/weap = null
	var/image/stand_icon = null
	var/image/currentimage = null
	var/icon/base = null
	var/s_tone
	var/mob/living/clone = null
	var/image/left
	var/image/right
	var/image/up
	var/collapse
	var/image/down

	var/health = 100
/obj/fake_attacker/attackby(var/obj/item/weapon/P as obj, mob/user as mob)
	step_away(src,my_target,2)
	for(var/mob/M in oviewers(world.view,my_target))
		M << "\red <B>[my_target] flails around wildly.</B>"
	my_target.show_message("\red <B>[src] has been attacked by [my_target] </B>", 1) //Lazy.

	//src.health -= P.power


	return

/obj/fake_attacker/HasEntered(var/mob/M, somenumber)
	if(M == my_target)
		step_away(src,my_target,2)
		if(prob(30))
			for(var/mob/O in oviewers(world.view , my_target))
				O << "\red <B>[my_target] stumbles around.</B>"

/obj/fake_attacker/New()
	spawn(300)
		my_target.hallucinations -= src
		del(src)
	step_away(src,my_target,2)
	proccess()


/obj/fake_attacker/proc/updateimage()
//	del src.currentimage


	if(src.dir == NORTH)
		del src.currentimage
		src.currentimage = new /image(up,src)
	else if(src.dir == SOUTH)
		del src.currentimage
		src.currentimage = new /image(down,src)
	else if(src.dir == EAST)
		del src.currentimage
		src.currentimage = new /image(right,src)
	else if(src.dir == WEST)
		del src.currentimage
		src.currentimage = new /image(left,src)
	my_target << currentimage


/obj/fake_attacker/proc/proccess()
	if(!my_target) spawn(5) .()
	if(src.health < 0)
		collapse()
		return
	if(get_dist(src,my_target) > 1)
		src.dir = get_dir(src,my_target)
		step_towards_3d(src,my_target)
		updateimage()
	else
		if(prob(15))
			if(weapon_name)
				my_target << sound(pick('genhit1.ogg', 'genhit2.ogg', 'genhit3.ogg'))
				my_target.show_message("\red <B>[my_target] has been attacked with [weapon_name] by [src.name] </B>", 1)
				my_target.halloss += 8
				if(prob(20)) my_target.eye_blurry += 3
				if(prob(33))
					if(!locate(/obj/overlay) in my_target.loc)
						fake_blood(my_target)
			else
				my_target << sound(pick('punch1.ogg','punch2.ogg','punch3.ogg','punch4.ogg'))
				my_target.show_message("\red <B>[src.name] has punched [my_target]!</B>", 1)
				my_target.halloss += 4
				if(prob(33))
					if(!locate(/obj/overlay) in my_target.loc)
						fake_blood(my_target)

	if(prob(15))
		step_away(src,my_target,2)
	spawn(5) .()

/obj/fake_attacker/proc/collapse()
	collapse = 1
	updateimage()

/proc/fake_blood(var/mob/target)
	var/obj/overlay/O = new/obj/overlay(target.loc)
	O.name = "blood"
	var/image/I = image('blood.dmi',O,"floor[rand(1,7)]",O.dir,1)
	target << I
	spawn(300)
		del(O)
	return

/proc/fake_attack(var/mob/target)
	var/list/possible_clones = new/list()
	var/mob/living/carbon/human/clone = null
	var/clone_weapon = null

	for(var/mob/living/carbon/human/H in world)
		if(H.stat || H.lying) continue
		possible_clones += H

	if(!possible_clones.len) return
	clone = pick(possible_clones)
	//var/obj/fake_attacker/F = new/obj/fake_attacker(outside_range(target))
	var/obj/fake_attacker/F = new/obj/fake_attacker(target.loc)
	if(clone.l_hand)
		clone_weapon = clone.l_hand.name
		F.weap = clone.l_hand
	else if (clone.r_hand)
		clone_weapon = clone.r_hand.name
		F.weap = clone.l_hand

	F.name = clone.name
	F.my_target = target
	F.weapon_name = clone_weapon
	target.hallucinations += F


	F.left = image(clone,dir = WEST)
	F.right = image(clone,dir = EAST)
	F.up = image(clone,dir = NORTH)
	F.down = image(clone,dir = SOUTH)

//	F.base = new /icon(clone.stand_icon)
//	F.currentimage = new /image(clone)

/*



	F.left = new /icon(clone.stand_icon,dir=WEST)
	for(var/icon/i in clone.overlays)
		F.left.Blend(i)
	F.up = new /icon(clone.stand_icon,dir=NORTH)
	for(var/icon/i in clone.overlays)
		F.up.Blend(i)
	F.down = new /icon(clone.stand_icon,dir=SOUTH)
	for(var/icon/i in clone.overlays)
		F.down.Blend(i)
	F.right = new /icon(clone.stand_icon,dir=EAST)
	for(var/icon/i in clone.overlays)
		F.right.Blend(i)

	target << F.up
	*/

	F.updateimage()
//var/image/O = image(clone,F)
//	target << O

/proc/can_see(var/atom/source, var/atom/target, var/length=5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	while(current != target_turf)
		if(steps > length) return 0
		if(current.opacity) return 0
		for(var/atom/A in current)
			if(A.opacity) return 0
		current = get_step_towards(current, target_turf)
		steps++

	return 1


/mob/proc/get_equipped_items()
	var/list/items = new/list()

	if(hasvar(src,"back")) if(src:back) items += src:back
	if(hasvar(src,"belt")) if(src:belt) items += src:belt
	if(hasvar(src,"ears")) if(src:ears) items += src:ears
	if(hasvar(src,"glasses")) if(src:glasses) items += src:glasses
	if(hasvar(src,"gloves")) if(src:gloves) items += src:gloves
	if(hasvar(src,"head")) if(src:head) items += src:head
	if(hasvar(src,"shoes")) if(src:shoes) items += src:shoes
	if(hasvar(src,"wear_id")) if(src:wear_id) items += src:wear_id
	if(hasvar(src,"wear_mask")) if(src:wear_mask) items += src:wear_mask
	if(hasvar(src,"wear_suit")) if(src:wear_suit) items += src:wear_suit
//	if(hasvar(src,"w_radio")) if(src:w_radio) items += src:w_radio  commenting this out since headsets go on your ears now PLEASE DON'T BE MAD KEELIN
	if(hasvar(src,"w_uniform")) if(src:w_uniform) items += src:w_uniform

	//if(hasvar(src,"l_hand")) if(src:l_hand) items += src:l_hand
	//if(hasvar(src,"r_hand")) if(src:r_hand) items += src:r_hand

	return items
/mob/proc/get_all_possessed_items()
	var/list/items = new/list()

	if(hasvar(src,"back"))
		if(src:back)
			items += src:back
			for(var/obj/O in src:back.contents)
				items += O
				if(istype(O,/obj/item/weapon/storage/))
					items += O.contents
	if(hasvar(src,"belt"))
		if(src:belt)
			items += src:belt
			for(var/obj/O in src:belt.contents)
				items += O
				if(istype(O,/obj/item/weapon/storage/))
					items += O.contents
	if(hasvar(src,"ears"))
		if(src:ears)
			items += src:ears
	if(hasvar(src,"glasses"))
		if(src:glasses)
			items += src:glasses
	if(hasvar(src,"gloves"))
		if(src:gloves)
			items += src:gloves
	if(hasvar(src,"head")) if(src:head) items += src:head
	if(hasvar(src,"shoes")) if(src:shoes) items += src:shoes
	if(hasvar(src,"wear_id")) if(src:wear_id) items += src:wear_id
	if(hasvar(src,"wear_mask")) if(src:wear_mask) items += src:wear_mask
	if(hasvar(src,"wear_suit"))
		if(src:wear_suit)
			items += src:wear_suit
			for(var/obj/O in src:wear_suit.contents)
				items += O
				if(istype(O,/obj/item/weapon/storage/))
					items += O.contents
	if(hasvar(src,"w_uniform")) if(src:w_uniform) items += src:w_uniform
	if(hasvar(src,"l_hand"))
		if(src:l_hand)
			items += src:l_hand
			for(var/obj/O in src:l_hand.contents)
				items += O
				if(istype(O,/obj/item/weapon/storage/))
					items += O.contents
	if(hasvar(src,"r_hand"))
		if(src:r_hand)
			items += src:r_hand
			for(var/obj/O in src:r_hand.contents)
				items += O
				if(istype(O,/obj/item/weapon/storage/))
					items += O.contents

	return items

/proc/is_blocked_turf(var/turf/T)
	var/cant_pass = 0
	if(T.density) cant_pass = 1
	for(var/atom/A in T)
		if(A.density)//&&A.anchored
			cant_pass = 1
	return cant_pass

/proc/get_step_towards_3d2(var/atom/ref , var/atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref,trg))
	var/turf/temp = get_step_towards(ref,trg)

	if(is_blocked_turf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!is_blocked_turf(turf_last1))
				free_tile = turf_last1
				break
			if(!is_blocked_turf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1,dir_alt1)
			turf_last2 = get_step(turf_last2,dir_alt2)
			breakpoint++

		if(!free_tile) return get_step(ref, base_dir)
		else return get_step_towards(ref,free_tile)

	else return get_step(ref, base_dir)

/proc/do_mob(var/mob/user , var/mob/target, var/time = 30) //This is quite an ugly solution but i refuse to use the old request system.
	if(!user || !target) return 0
	var/user_loc = user.loc
	var/target_loc = target.loc
	var/holding = user.equipped()
	sleep(time)
	if ( user.loc == user_loc && target.loc == target_loc && user.equipped() == holding && !( user.stat ) && ( !user.stunned && !user.weakened && !user.paralysis && !user.lying ) )
		return 1
	else
		return 0

/proc/do_after(mob/M as mob, time as num)
	var/turf/T = M.loc
	var/holding = M.equipped()
	sleep(time)
	if ((M.loc == T && M.equipped() == holding && !( M.stat )))
		return 1
	else
		return 0

/proc/hasvar(var/datum/A, var/varname)
	//Takes: Anything that could possibly have variables and a varname to check.
	//Returns: 1 if found, 0 if not.
	//Notes: Do i really need to explain this?
	if(A.vars.Find(lowertext(varname))) return 1
	else return 0

/proc/get_areas(var/areatype)
	//Takes: Area type as text string or as typepath OR an instance of the area.
	//Returns: A list of all areas of that type in the world.
	//Notes: Simple!
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/areas = new/list()
	for(var/area/N in world)
		if(istype(N, areatype)) areas += N
	return areas

/proc/get_area_turfs(var/areatype)
	//Takes: Area type as text string or as typepath OR an instance of the area.
	//Returns: A list of all turfs in areas of that type of that type in the world.
	//Notes: Simple!

	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/turf/T in N) turfs += T
	return turfs

/proc/get_area_all_atoms(var/areatype)
	//Takes: Area type as text string or as typepath OR an instance of the area.
	//Returns: A list of all atoms	(objs, turfs, mobs) in areas of that type of that type in the world.
	//Notes: Simple!

	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/atoms = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/atom/A in N)
				atoms += A
	return atoms

/proc/get_area_all_objects(var/areatype)
	//Takes: Area type as text string or as typepath OR an instance of the area.
	//Returns: A list of all objs in areas of that type of that type in the world.
	//Notes: Simple!

	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/objs = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/obj/A in N.contents)
				objs += A
	return objs

/datum/coords //Simple datum for storing coordinates.
	var/x_pos = null
	var/y_pos = null
	var/z_pos = null

/area/proc/move_contents_to(var/area/A, var/turftoleave=null)
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	stop_zones = 1

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)



	//Get some basic area info
	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for (var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y


	//Set up a list of the source turfs and their tile offsets in the area
	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)



	var/list/fromupdate = new/list()
	var/list/toupdate = new/list()

	moving:
		for (var/turf/T in refined_src)
			if(T.zone)
				T.zone.space_connections.len = 0
				for(var/zone/Z in T.zone.connections) //Disconnect everything! (We'll reconnect it later.)
					T.zone.connections -= Z
					T.zone.direct_connections -= Z
					Z.connections -= T.zone
					Z.direct_connections -= T.zone
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_zone = T.zone
					if(T.zone) T.zone.members -= T

					var/turf/X = new T.type(B)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.zone = old_zone
					if(X.zone)
						X.zone.members += X
						spawn(1) X.zone.space_connections -= X

					for(var/atom/movable/AM as mob|obj in T)
						AM.loc = X

					var/area/AR = X.loc

					if(AR.ul_Lighting)
						X.opacity = !X.opacity
						X.ul_SetOpacity(!X.opacity)

					toupdate += X





					if(turftoleave)

						var/turf/ttl = new turftoleave(T)

						var/area/AR2 = ttl.loc



						if(AR2.ul_Lighting)
							ttl.opacity = !ttl.opacity
							ttl.ul_SetOpacity(!ttl.opacity)

						fromupdate += ttl

					else
						if (locate(T.x,T.y,(T.z + 1)) && (!istype(locate(T.x,T.y,(T.z + 1)), /turf/space)))
							T.ReplaceWithHull()
						else
							T.ReplaceWithOpen()

					refined_src -= T
					refined_trg -= B
					continue moving

	var/list/doors = new/list()

	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			for(var/obj/machinery/door/D2 in T1)
				doors += D2
			if(T1.parent)
				air_master.groups_to_rebuild += T1.parent
			else
				air_master.tiles_to_update += T1
			if(T1.zone)
				T1.zone.space_connections.len = 0

	if(fromupdate.len)
		for(var/turf/simulated/T2 in fromupdate)
			for(var/obj/machinery/door/D2 in T2)
				doors += D2
			if(T2.parent)
				air_master.groups_to_rebuild += T2.parent
			else
				air_master.tiles_to_update += T2
			if(T2.zone)
				T2.zone.space_connections.len = 0

	for(var/obj/O in doors)
		O:update_nearby_tiles(1)

	spawn(10)
		stop_zones = 0

