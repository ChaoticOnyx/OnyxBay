mob/living/npc/vermin
	var/list/edible = list(/obj/item/weapon/crowbar)
	var/hunger = 0

mob/living/npc/vermin/Act()
	var/isidle = 1
	if(hunger)
		hunger--
	if(hunger >= 70)
		world << "REPLICATEING"
		Replicate()
	if(findtarget)
		if(findtarget in view(1,src))
			Eat(findtarget)
			if(path_target.len >= 1)
				path_target = list()
			isidle = 0
		else if(findtarget in viewers(src))
			if(!path_target.len)
				MoveAstar(findtarget)
				if(path_target.len <= 0)
					path_target = list()
					return
			var/turf/next = path_target[1]
			step_towards_3d(src,get_step_towards_3d2(next))
			path_target -= next
			isidle = 0
	else
		for(var/atom/movable/A in oview(10,src))
			if(edible.Find(A.type))
				findtarget = A
				if(!path_target.len)
					MoveAstar(findtarget)
					if(path_target.len <= 0)
						path_target = list()
						return
				var/turf/next = path_target[1]
				step_towards_3d(src,get_step_towards_3d2(next))
				path_target -= next
				isidle = 0
	if(isidle)
		DoIdle()
mob/living/npc/vermin/proc/Eat(atom/A)
	var/yum = 10
	hunger += yum
	hunger = max(0,hunger)
	findtarget = null
	if(istype(A,/atom/movable))
		var/atom/movable/B = A
		B.loc = src
		for(var/mob/M in viewers(src))
			M << "[src] gobbles up \the [A]"
	else
		for(var/mob/M in viewers(src))
			M << "[src] gobbles up \the [A]"
		del(A)
mob/living/npc/vermin/proc/Replicate()
	hunger -= 70
	world << "hunger is now [hunger]"
	var/obj/egg/E = new(src.loc,src.type)
	world << "spawned [E]"
mob/living/npc/vermin/crab
	name = "Space Crab"
	icon = 'beach.dmi'
	icon_state = "crab"

/obj/egg
	name = "An egg"
	icon = 'beach.dmi'
	icon_state = "segg"
	var/spawntype
obj/egg/New(Location,type)
	..()
	if(type)
		spawntype = type
	if(!spawntype)
		del(src)
	spawn(300) src.open()
obj/egg/proc/open()
	new spawntype(src.loc)
	del(src)