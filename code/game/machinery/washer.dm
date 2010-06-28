/obj/machinery/washer
	name = "Laundromat"
	desc = "Cleans shit"
	icon = 'washer.dmi'
	icon_state = "land01"
	density = 1
	opacity = 0
	var/active = 0
	var/obj/item/weapon/reagent_containers/glass/powder = null
	var/hacked = 0
/obj/machinery/washer/examine()
	usr << "[src] has [powder.reagents.get_reagent_amount("cleaner")]unit's left"
/obj/machinery/washer/New()
	powder = new/obj/item/weapon/reagent_containers/glass/beaker
	powder.name = src.name
	return ..()
/obj/machinery/washer/attackby(obj/item/weapon/W)
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
				return 0
	if(istype(W,/obj/item/clothing/))
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
/obj/machinery/washer/attack_hand()
	if(stat & (BROKEN|NOPOWER))
		return
	if(!powder)
		usr << "You need add a beaker."
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
		sleep(51)
		icon_state = "land01"
		for(var/atom/movable/O in src.contents)
			O.clean_blood()
			O.fingerprints = null
			if(ismob(O))
				O:oxyloss += rand(10,40)
			if(istype(O,/obj/item/weapon/gun/energy/taser_gun/) || istype(O,/obj/item/weapon/gun/energy/laser_gun/))
				explode()
				del O
			O.loc = src.loc
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

		explosion(T, -1, -1, 2, 3)

	del(src)
	return