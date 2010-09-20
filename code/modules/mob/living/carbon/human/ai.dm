#define cycle_pause 15 //min 1
#define viewrange 7 //min 2




// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
// Includes spacetiles
/*/turf/proc/CardinalTurfsWithAccessSpace(var/obj/item/weapon/card/id/ID)
	var/L[] = new()
	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src, d)
		if((istype(T) || istype(T,/turf/space))&& !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L*/




/mob/living/carbon/human/zombiebot
	name = "Zombie"
	real_name = "Zombie"
	desc = "An zombie, looks pretty scary!"
	a_intent = "hurt"
	var/state = 0
	density = 1
	var/list/path = new/list()

	var/frustration = 0
	var/mob/living/carbon/target
	var/list/path_target = new/list()
	bot = 1
	var/turf/trg_idle
	var/list/path_idle = new/list()
	var/list/objects
	health = 100





	New()
		..()
		zombify()
		src.process()
		name = "zombie"
		real_name  = "zombie"
		return
	verb/follow()
		set src in view()
		set name = "follow me"
		if(stat == 2) return
		if(!iszombie(usr))
			usr << text("\red <B>The zombie ignores you.</B>")
			return
		if(state != 2)
			usr << text("\red <B>The zombie is too busy to follow you.</B>")
			return
		usr << text("\green <B>The zombie will now try to follow you.</B>")
		trg_idle = usr
		path_idle = new/list()
		return

	verb/stop()
		set src in view()
		set name = "stop following"
		if(stat == 2) return
		if(!iszombie(usr))
			usr << text("\red <B>The zombie ignores you.</B>")
			return
		if(state != 2)
			usr << text("\red <B>The zombie is too busy to follow you.</B>")
			return
		usr << text("\green <B>The zombie stops following you.</B>")
		set_null()
		return




	proc/call_to(var/mob/user)
		if(stat == 2 || !iszombie(user) || state != 2) return
		trg_idle = user
		path_idle = new/list()
		return

	proc/set_attack()
		state = 1
		if(path_idle.len) path_idle = new/list()
		trg_idle = null

	proc/set_idle()
		state = 2
		if (path_target.len) path_target = new/list()
		target = null
		frustration = 0

	proc/set_null()
		state = 0
		if (path_target.len) path_target = new/list()
		if (path_idle.len) path_idle = new/list()
		target = null
		trg_idle = null
		frustration = 0

	proc/process()
		set background = 1
		var/quick_move = 0

		if (stat == 2)
			return
		if(weakened || paralysis || handcuffed || !canmove)
			set_null()
			spawn(cycle_pause) src.process()
			return
		if (!target)
			if (path_target.len) path_target = new/list()

			var/last_health = INFINITY

			for (var/mob/living/carbon/C in range(viewrange-2,src.loc))
				if (C.stat == 2 || iszombie(C) || !can_see(src,C,viewrange))
					continue
				if(C:stunned || C:paralysis || C:weakened)
					target = C
					break
				if(C:health < last_health)
					last_health = C:health
					target = C

			if(target)
				set_attack()
				state = 1
				trg_idle = null
			else
				if(state != 2)
					state = 2
					set_idle()
					idle()

		else if(target)
			var/turf/distance = get_dist(src, target)
			set_attack()

			if(can_see(src,target,viewrange))
				if(distance <= 1)
					var/direct = get_dir(src, target)
					if ( (direct - 1) & direct)
						var/turf/Step_1
						var/turf/Step_2
						switch(direct)
							if(EAST|NORTH)
								Step_1 = get_step(src, NORTH)
								Step_2 = get_step(src, EAST)

							if(EAST|SOUTH)
								Step_1 = get_step(src, SOUTH)
								Step_2 = get_step(src, EAST)

							if(NORTH|WEST)
								Step_1 = get_step(src, NORTH)
								Step_2 = get_step(src, WEST)

							if(SOUTH|WEST)
								Step_1 = get_step(src, SOUTH)
								Step_2 = get_step(src, WEST)

						if(Step_1 && Step_2)
							var/check_1 = 1
							var/check_2 = 1

							check_1 = CanReachThrough(get_turf(src), Step_1, target) && CanReachThrough(Step_1, get_turf(target), target)

							check_2 = CanReachThrough(get_turf(src), Step_2, target) && CanReachThrough(Step_2, get_turf(target), target)

							if(check_1 || check_2)
								target.attack_hand(src)
								set_null()
								spawn(cycle_pause) src.process()
								return
							else
								var/obj/window/W = locate() in target.loc
								var/obj/window/WW = locate() in src.loc
								if(W)
									W.attack_hand(src)
									set_null()
									spawn(cycle_pause) src.process()
									return
								else if(WW)
									WW.attack_hand(src)
									set_null()
									spawn(cycle_pause) src.process()
									return
					else if(CanReachThrough(src.loc , target.loc,target))
						target.attack_hand(src)
						set_null()
						spawn(cycle_pause) src.process()
						return
					else
						var/obj/window/W = locate() in target.loc
						var/obj/window/WW = locate() in src.loc
						if(W)
							W.attack_hand(src)
							set_null()
							spawn(cycle_pause) src.process()
							return
						else if(WW)
							WW.attack_hand(src)
							set_null()
							spawn(cycle_pause) src.process()
							return
				step_towards_3d(src,target)
			else
				if( !path_target.len )

					path_attack(target)
					if(!path_target.len)
						set_null()
						spawn(cycle_pause) src.process()
						return
				else
					var/turf/next = path_target[1]

					if(next in range(1,src))
						path_attack(target)

					if(!path_target.len)
						src.frustration += 5
					else
						next = path_target[1]
						path_target -= next
						step_towards_3d(src,src,get_step_towards_3d2(src,next))

			if (get_dist(src, src.target) >= distance) src.frustration++
			else src.frustration--
			if(frustration >= 35) set_null()

		if(quick_move)
			spawn(cycle_pause)
				src.process()
		else
			spawn(cycle_pause)
				src.process()

	proc/idle()
		set background = 1
		if(state != 2 || stat == 2 || target) return
		if(locate(/obj/machinery/door/airlock) in range(1,src.loc))
			var/obj/machinery/door/airlock/D = locate() in range(2,src.loc)
			if(D)
				if(D.density)
					D.attack_hand(src)
					spawn(cycle_pause) src.idle()
					return
		if(!trg_idle)
/*			for(var/mob/living/M in orange(5,src))
				if(!M) break
				if(M.zombie || stat == 2) continue
				trg_idle = M
				path_idle(trg_idle)
				if(!can_see(src,trg_idle,viewrange))
					spawn(cycle_pause) src.idle()
					return
				if(trg_idle && path_idle)
					world << "FOUND HUMAN"
					step_towards_3d(src,trg_idle)
					spawn(cycle_pause) src.idle()
					return*/
			for(var/obj/machinery/door/airlock/D in oview(viewrange,src))
				if(!D) continue
				if(D.density)
					trg_idle = D
					path_idle(trg_idle)
					world << "FOUND DOOR"
					step_towards_3d(src,trg_idle)
					spawn(cycle_pause) src.idle()
					return
		if(trg_idle)
			if(path_idle.len)
				var/turf/next = path_idle[1]
				if(next in orange(1,src))
				//	world << "WALKING TO NEXT"
					step_towards_3d(src,get_step_towards_3d2(next))
					path_idle -= next

					spawn(cycle_pause) src.idle()
					return
				else
				//	world << "BROKEN PATH"
					set_null()
					spawn(cycle_pause) src.idle()
					return
			else
				//world << "NO PATH"
				set_null()
				spawn(cycle_pause) src.idle()
				return
		//world << "RANDOM STEP"
		step_rand(src)
		spawn(cycle_pause) src.idle()
		return

/*		else
			if(can_see(src,trg_idle,viewrange))
				switch(get_dist(src, trg_idle))
					if(1)
						if(istype(trg_idle,/obj/machinery/door/airlock/))
							step_towards_3d(src,get_step_towards_3d2(src , trg_idle))
					if(2 to INFINITY)
						step_towards_3d(src,get_step_towards_3d2(src , trg_idle))
						if(path_idle.len) path_idle = new/list()
					/*
					if(viewrange+1 to INFINITY)
						step_towards_3d(src,get_step_towards_3d2(src , trg_idle))
						if(path_idle.len) path_idle = new/list()
						quick_move = 1
					*/
			else
				if(trg_idle)
					var/dist = 99999
					for(var/obj/machinery/door/airlock/D in view(viewrange,src))
						var/num = get_dist(src.loc,D.loc
						if(num < dist)
							trg_idle = D


				if(!path_idle.len)
					spawn(cycle_pause) src.idle()
					return
				else
					quick_move = 1
*/
	proc/path_idle(var/atom/trg)
		path_idle = AStar(src.loc, get_turf(trg), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null,null)
		path_idle = reverselist(path_idle)

	proc/path_attack(var/atom/trg)
		target = trg
		path_target = AStar(src.loc, target.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null,null)
		path_target = reverselist(path_target)


	death()
		..()
		set_null()