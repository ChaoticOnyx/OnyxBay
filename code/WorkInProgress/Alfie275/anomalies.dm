/obj/item/weapon/anomaly
	name = "Strange rock"
	icon = 'rubble.dmi'
	icon_state = "strange"
	var/obj/inside
	var/method // 0 = fire 1+ = acid
	var/rock = 10
	var/ahealth = 10

	New()
		var/datum/reagents/r = new/datum/reagents(50)
		src.reagents = r
		r.my_atom = src
		src.method = rand(2)
		src.inside = pick("/obj/item/weapon/crystal","/obj/item/weapon/fossil/bone",
							"/obj/item/weapon/fossil/shell","/obj/item/weapon/crystal",
							"/obj/item/weapon/fossil/skull","obj/item/weapon/crystal")

/obj/item/weapon/crystal
	name = "Crystal"
	icon = 'rubble.dmi'
	icon_state = "crystal"
	desc = "A beautiful crystal."

/obj/item/weapon/fossil
	name = "Fossil"
	icon = 'fossil.dmi'
	icon_state = "bone"
	desc = "It's a fossil."

/obj/item/weapon/fossil/bone
	name = "Fossilised bone"
	icon_state = "bone"
	desc = "It's a fossilised bone from an unknown creature."

/obj/item/weapon/fossil/shell
	name = "Fossilised shell"
	icon_state = "shell"
	desc = "It's a fossilised shell from some sort of space mollusc."

/obj/item/weapon/fossil/skull
	name = "Fossilised skull"
	icon_state = "skull"
	desc = "It's a fossilised skull, it has a human appearance but has two horns."

/obj/item/weapon/anomaly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/weldingtool/))
		if(src.method)
			src.ahealth -= 3
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red A hissing sound comes from within the rock.", 1)
		else
			src.rock -= 3
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\blue The surface of the rock burns a little.",1)
	if(src.ahealth<1)
		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red The rock explodes.",1)
		var/turf/t = find_loc(src)
		t.hotspot_expose(SPARK_TEMP,125)
		explosion(t, -1, -1, 5, 3, 1)
		del src
	if(src.rock<1)
		var/obj/o = new src.inside
		o.loc = get_turf(src)
		for(var/mob/O in viewers(world.view, user))
			O.show_message("\blue The rock burns away revealing \a [o.name].",1)
		del src


/obj/item/weapon/anomaly/proc/acid(var/volume)
	if(!src.method)
		src.ahealth -= volume
		for(var/mob/O in viewers(world.view, get_turf(src)))
			O.show_message("\red A fizzing sound comes from within the rock.",1)
	else
		src.rock -= volume
		for(var/mob/O in viewers(world.view, get_turf(src)))
			O.show_message("\blue The surface of the rock fizzes.",1)

	if(src.ahealth<1)
		for(var/mob/O in viewers(world.view, get_turf(src)))
			O.show_message("\red The rock collapses.",1)
		new/obj/item/weapon/ore(get_turf(src))
		del src
	if(src.rock<1)
		var/obj/o = new src.inside
		o.loc = get_turf(src)
		for(var/mob/O in viewers(world.view, get_turf(src)))
			O.show_message("\blue The rock fizzes away revealing \a [o.name].",1)

		del src
