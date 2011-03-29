mob/living/npc/vermin
	var/hunger = 0
mob/living/npc/vermin/Healthcheck()
	if((bruteloss + fireloss + oxyloss) > 100)
		Die()
mob/living/npc/vermin/Act()
	var/isidle = 1
	if(hunger)
		hunger--
	if(hunger >= 70)
		Replicate()
	var/list/V = view(10,src)
	V = reverselist(V)
	if(findtarget)
		if(findtarget in view(1,src))
			Eat(findtarget)
			if(path_target.len >= 1)
				path_target = list()
			isidle = 0
		else if(findtarget in V)
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
			findtarget = null
			path_target = list()
	else
		for(var/obj/item/A in view(10,src))
			if(A.m_amt || A.g_amt)
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
	if(!findtarget)
		for(var/obj/item/A in oview(10,src))
			if(A.m_amt || A.g_amt)
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
	var/yum = 25
	hunger += yum
	hunger = max(0,hunger)
	findtarget = null
	if(istype(A,/atom/movable))
		for(var/mob/M in viewers(src))
			M << "[src] gobbles up \the [A]"
		del(A)
mob/living/npc/vermin/proc/Replicate()
	hunger -= 70
	new /obj/egg (src.loc,src.type)
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
	if(prob(1))
		new /mob/living/npc/mamacrab(src.loc)
		del(src)
		return
	new spawntype(src.loc)
	del(src)