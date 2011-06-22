/** This is an NPC-controlled zombie. Its general purpose is to
	find and attack humans.

	The zombie's AI is separated into two loops:


	head's version of this code used A* search for when the target
	moved out of the zombie's range

	this has been removed for now, seeing as zombies are already
	very effective when randomly roaming and destroying
**/

#define cycle_pause 15 //min 1
#define viewrange 9 //min 2

#define ZOMBIE_SLEEP 0
#define ZOMBIE_ATTACK 1
#define ZOMBIE_IDLE 2

/mob/living/carbon/human/zombiebot
	name = "Zombie"
	real_name = "Zombie"
	desc = "A zombie, looks pretty scary!"
	a_intent = "hurt"
	density = 1
	var/list/path = new/list()

	var/frustration = 0
	var/atom/object_target
	var/reach_unable
	var/mob/living/carbon/target
	var/list/path_target = new/list()
	bot = 1
	var/list/path_idle = new/list()
	var/list/objects
	health = 100



	New()
		..()
		zombify()
		sleep(10)
		// main loop
		spawn while(stat != STAT_DEAD && bot)
			sleep(cycle_pause)
			src.process()
		name = "zombie"
		real_name  = "zombie"
		return

	// this is called when the target is within one tile
	// of distance from the zombie
	proc/attack_target()
		if(target.stat != STAT_ALIVE && prob(70))
			return
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
					return
				else
					var/obj/window/W = locate() in target.loc
					var/obj/window/WW = locate() in src.loc
					if(W)
						W.attack_hand(src)
						return 1
					else if(WW)
						WW.attack_hand(src)
						return 1
		else if(CanReachThrough(src.loc , target.loc,target))
			target.attack_hand(src)
			// sometimes push the enemy
			if(prob(30))
				step(src,direct)
			return 1
		else
			var/obj/window/W = locate() in target.loc
			var/obj/window/WW = locate() in src.loc
			if(W)
				W.attack_hand(src)
				return 1
			else if(WW)
				WW.attack_hand(src)
				return 1

	// main loop
	proc/process()
		set background = 1

		if (stat == STAT_DEAD)
			return 0
		if(weakened || paralysis || handcuffed || !canmove)
			return 1

		if(destroy_on_path())
			return 1

		if (!target)
			// no target, look for a new one

			// look for a target, taking into consideration their health
			// and distance from the zombie
			var/last_health = INFINITY
			var/last_dist = INFINITY

			for (var/mob/living/carbon/C in orange(viewrange-2,src.loc))
				var/dist = get_dist(src, C)

				// if the zombie can't directly see the human, they're
				// probably blocked off by a wall, so act as if the
				// human is further away
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

		// if we have found a target
		if(target)
			// change the target if there is another human that is closer
			for (var/mob/living/carbon/C in orange(2,src.loc))
				if (C.stat == STAT_DEAD || iszombie(C) || !can_see(src,C,viewrange))
					continue
				if(get_dist(src, target) >= get_dist(src, C) && prob(30))
					target = C
					break

			if(target.stat == STAT_DEAD || iszombie(target))
				target = null


			var/distance = get_dist(src, target)

			if(target in orange(viewrange,src))
				if(distance <= 1)
					if(attack_target())
						return 1
				if(step_towards_3d(src,target))
					return 1
			else
				target = null
				return 1

		// if there is no target in range, roam randomly
		else

			frustration--
			frustration = max(frustration, 0)

			if(stat == STAT_DEAD) return 0

			var/prev_loc = loc
			// make sure they don't walk into space
			if(!(locate(/turf/space) in get_step(src,dir)))
				step(src,dir)
			// if we couldn't move, pick a different direction
			// also change the direction at random sometimes
			if(loc == prev_loc || prob(20))
				sleep(5)
				dir = pick(NORTH,SOUTH,EAST,WEST)

			return 1

		// if we couldn't do anything, take a random step
		step_rand(src)
		dir = get_dir(src,target) // still face to the target
		frustration++

		return 1

	// destroy items on the path
	proc/destroy_on_path()
		// if we already have a target, use that
		if(object_target)
			if(!object_target.density)
				object_target = null
				frustration = 0
			else
				// we know the target has attack_hand
				// since we only use such objects as the target
				object_target:attack_hand(src)
				return 1

		// first, try to destroy airlocks and walls that are in the way
		if(locate(/obj/machinery/door/airlock) in get_step(src,src.dir))
			var/obj/machinery/door/airlock/D = locate() in get_step(src,src.dir)
			if(D)
				if(D.density && !(locate(/turf/space) in range(1,D)) )
					D.attack_hand(src)
					object_target = D
					return 1
		// before clawing through walls, try to find a direct path first
		if(frustration > 8 )
			if(istype(get_step(src,src.dir),/turf/simulated/wall))
				var/turf/simulated/wall/W = get_step(src,src.dir)
				if(W)
					if(W.density && !(locate(/turf/space) in range(1,W)))
						W.attack_hand(src)
						object_target = W
						return 1
		return 0

	death()
		..()
		target = null