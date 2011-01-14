code/game/machinery/washer.dm
/obj/machinery/washer
	name = "Laundromat"
	desc = "Cleans stuff"
	icon = 'washer.dmi'
	icon_state = "land01"
	density = 1
	opacity = 0
	var/active = 0 // if its on
	var/obj/item/weapon/reagent_containers/glass/powder = null //holder var for chemicals
	var/hacked = 0 //emaged
	var/wiregold = 1 //temp
	var/wireblue = 1 //temp
	var/wiregreen = 1 //temp
/obj/machinery/washer/examine()
	usr << "[src] has [powder.reagents.get_reagent_amount("cleaner")] unit's left"
/obj/machinery/washer/New()
	powder = new/obj/item/weapon/reagent_containers/glass/beaker
	powder.name = src.name
	return ..()
/obj/machinery/washer/attackby(obj/item/weapon/W)
	if(active)
		if(!wiregold)
			usr << "You turn the washer off"
			active = 0
			return
		usr << "You can't put something in it while its washing"
		return
	if(istype(W,/obj/item/weapon/reagent_containers/glass/))
		if(W.reagents.has_reagent("cleaner",1))
			if(!powder)
				src.powder =  W
				usr.drop_item()
				W.loc = src
				usr << "You add the [W] to the [src]!"
				for(var/mob/M in viewers())
					M << "[usr] adds [W] into the [src]"
				return 0
			else
				var/amm = W.reagents.get_reagent_amount("cleaner")
				powder.reagents.add_reagent("cleaner",amm)
				W.reagents.remove_reagent("cleaner",amm)
				usr << "You transfer [amm] units of cleaning solution to [src]"
				return 0
	if(istype(W,/obj/item/clothing/) || istype(W,/obj/item/weapon/storage/backpack/))
		if(active)
			usr << "You can't put something in it while its washing"
			return
		usr.drop_item()
		W.loc = src
		for(var/mob/M in viewers())
			M << "[usr] adds [W] into the [src]"
		return 0
	if(hacked)
		usr.drop_item()
		W.loc = src
		for(var/mob/M in viewers())
			M << "[usr] adds [W] into the [src]"
			return 0
	usr << "The [src] beeps when you try put in [W]"
	return ..()

/obj/machinery/washer/verb/empty()
	set name = "Empty"
	set src in oview(1)
	set category = null

	if(active)
		usr << "The door is locked"
	for(var/atom/movable/O in src.contents)
		O.loc = loc

/obj/machinery/washer/attack_hand()
	if(stat & (BROKEN|NOPOWER))
		return
	if(!wiregold)
		usr << "You turn the washer off"
		active = 0
		return
	if(!powder)
		usr << "You need to add a beaker."
	if(!(powder.reagents.has_reagent("cleaner",1)))
		usr << "You need more cleaning solution"
	wash()
/obj/machinery/washer/proc/wash()
	if(powder.reagents.has_reagent("cleaner",1))
		active = 1
		icon_state = "landanim"
		var/sound/S = sound('WashingMachine1.ogg')
		for(var/mob/MM in viewers(,src))
			MM << S
		if(!wiregold)
			spawn while(active)
				sleep(10)
				for(var/mob/M in src)
					M.oxyloss += rand(1,10)
					M.bruteloss += rand(1,10)
				if(locate(/mob) in src)
					for(var/mob/M in viewers())
						M.show_message("\red *THUMP*")
			icon_state = "land01"
			for(var/atom/movable/O in src)
				O.clean_blood()
				O.fingerprints = null
				O:contaminated = 0
				if(ismob(O))
					var/list/items = O:get_all_possessed_items()
					for(var/obj/OB in items)
						OB.clean_blood()
						OB.fingerprints = null
						OB.contaminated = 0
				if(istype(O,/obj/item/weapon/gun/energy))
					explode()
					del O
				O.loc = src.loc
			powder.reagents.remove_reagent("cleaner",1)
			return
		sleep(51)
		icon_state = "land01"
		for(var/atom/movable/O in src)
			O.clean_blood()
			O.fingerprints = null
			O:contaminated = 0
			if(ismob(O))
				O:oxyloss += rand(1,50)
				O:bruteloss += rand(10,50)
				var/list/items = O:get_all_possessed_items()
				for(var/obj/OB in items)
					OB.clean_blood()
					OB.fingerprints = null
					OB:contaminated = 0
					if(istype(OB,/obj/item/weapon/gun/energy))
						explode()
						del OB
			if(istype(O,/obj/item/weapon/gun/energy))
				explode()
				del O
			O.loc = src.loc
		active = 0
		powder.reagents.remove_reagent("cleaner",1)

/obj/machinery/washer/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if(prob(10))
				del(src)
				return
		else
	return

/obj/machinery/washer/proc/explode() //This needs tuning.

	var/turf/T = get_turf(src.loc)
	if(T)
		T.hotspot_expose(700,125)

		explosion(T, -1, -1, 2, 3, 1)
	active = 0
	return
/obj/machinery/washer/MouseDrop_T(mob/C as mob, mob/user as mob)
	if(user.stat)
		return
	if (active || !istype(C)|| C.anchored || get_dist(user, src) > 1 || get_dist(src,C) > 1 )
		return
	load(C)
	src.visible_message("[user] tries to put [C] into [src]")
/obj/machinery/washer/proc/load(var/atom/movable/C)
	if(!hacked && !istype(C,/obj/item/clothing/))
		src.visible_message("The [src] beeps when you try put in [C]")
		return

	if(get_dist(C, src) > 1)
		return
	C.loc = src.loc
	sleep(2)
	C.loc = src
	if(ismob(C))
		var/mob/M = C
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
/obj/machinery/washer/relaymove(mob/user as mob)
	if(user.stat || src.active)
		return
	src.go_out(user)
	return

/obj/machinery/washer/proc/go_out(mob/user)

	if (user.client)
		user.client.eye = user.client.mob
		user.client.perspective = MOB_PERSPECTIVE
	src.contents -= user
	user.loc = src.loc
	return