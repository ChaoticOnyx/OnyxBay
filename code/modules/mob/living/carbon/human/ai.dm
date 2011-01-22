#define cycle_pause 15 //min 1
#define viewrange 9 //min 2




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


#define ZOMBIE_SLEEP 0
#define ZOMBIE_ATTACK 1
#define ZOMBIE_IDLE 2

/mob/living/carbon/human/zombiebot
	name = "Zombie"
	real_name = "Zombie"
	desc = "A zombie, looks pretty scary!"
	a_intent = "hurt"
	var/state = ZOMBIE_SLEEP
	density = 1
	var/list/path = new/list()

	var/frustration = 0
	var/reach_unable
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
		if(stat == STAT_DEAD) return
		if(!iszombie(usr))
			usr << text("\red <B>The zombie ignores you.</B>")
			return
		if(state != ZOMBIE_IDLE)
			usr << text("\red <B>The zombie is too busy to follow you.</B>")
			return
		usr << text("\green <B>The zombie will now try to follow you.</B>")
		trg_idle = usr
		path_idle = new/list()
		return

	verb/stop()
		set src in view()
		set name = "stop following"
		if(stat == STAT_DEAD) return
		if(!iszombie(usr))
			usr << text("\red <B>The zombie ignores you.</B>")
			return
		if(state != ZOMBIE_IDLE)
			usr << text("\red <B>The zombie is too busy to follow you.</B>")
			return
		usr << text("\green <B>The zombie stops following you.</B>")
		set_null()
		return




	proc/call_to(var/mob/user)
		if(stat == STAT_DEAD || !iszombie(user) || state != ZOMBIE_IDLE) return
		trg_idle = user
		path_idle = new/list()
		return

	proc/set_attack()
		state = ZOMBIE_ATTACK
		if(path_idle.len) path_idle = new/list()
		trg_idle = null

	proc/set_idle()
		state = ZOMBIE_IDLE
		if (path_target.len) path_target = new/list()
		target = null
		frustration = 0

	proc/set_null()
		state = ZOMBIE_SLEEP
		if (path_target.len) path_target = new/list()
		if (path_idle.len) path_idle = new/list()
		target = null
		trg_idle = null
		frustration = 0

	proc/process()
		set background = 1
		var/quick_move = 0

		if (stat == STAT_DEAD)
			return
		if(weakened || paralysis || handcuffed || !canmove)
			set_null()
			spawn(cycle_pause) src.process()
			return
		if (!target)
			if (path_target.len) path_target = new/list()

			var/last_health = INFINITY
			var/last_dist = INFINITY

			for (var/mob/living/carbon/C in range(viewrange-2,src.loc))
				var/dist = get_dist(src, C)
				if(!(C in view(src, viewrange)))
					dist += 3
				if (C.stat == STAT_DEAD || iszombie(C) || !can_see(src,C,viewrange))
					continue
				if(C.stunned || C.paralysis || C.weakened)
					target = C
					break
				if(C.health < last_health && dist <= last_dist) if(!prob(30))
					last_health = C.health
					last_dist = dist
					target = C

			if(target)
				set_attack()
				trg_idle = null
			else
				if(state != ZOMBIE_IDLE)
					state = ZOMBIE_IDLE
					set_idle()
					idle()

		else if(target)
			for (var/mob/living/carbon/C in range(2,src.loc))
				if (C.stat == STAT_DEAD || iszombie(C) || !can_see(src,C,viewrange))
					continue
				if(get_dist(src, target) >= get_dist(src, C) && prob(30))
					target = C
					break


			var/distance = get_dist(src, target)
			set_attack()

			if(target in range(src,viewrange))
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
				set_null()
				/*if( !path_target.len )

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
						step_towards_3d(src,src,get_step_towards_3d2(src,next))*/

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
		if(state != ZOMBIE_IDLE || stat == STAT_DEAD || target) return
		if(locate(/obj/machinery/door/airlock) in range(1,src.loc))
			var/obj/machinery/door/airlock/D = locate() in range(1,src.loc)
			if(D)
				if(D.density)
					D.attack_hand(src)
					spawn(cycle_pause) src.idle()
					return
		if(!trg_idle) if(locate(/turf/simulated/wall) in get_step(src,src.dir))
			var/turf/simulated/wall/W = locate() in range(1,src.loc)
			if(W)
				if(W.density)
					W.attack_hand(src)
					spawn(cycle_pause) src.idle()
					return
		if(prob(20))
			step_rand(src)
		else
			if(locate(/turf/space) in get_step(src,dir))
				spawn(5) src.idle()
				return
			step(src,dir)
		spawn(cycle_pause) src.idle() // let them move a little faster when random-walking
		return

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