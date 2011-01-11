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
		src.inside = pick("/obj/item/weapon/crystal","/obj/item/weapon/sword",
							"/obj/item/weapon/axe","/obj/item/weapon/crystal",
							"/obj/item/weapon/pen","obj/item/weapon/crystal")

/obj/item/weapon/crystal
	name = "Crystal"
	icon = 'rubble.dmi'
	icon_state = "crystal"



/obj/item/weapon/talkingcrystal
	name = "Crystal"
	icon = 'rubble.dmi'
	icon_state = "crystal2"
	var/list/words = list()
	var/lastsaid
/obj/item/weapon/talkingcrystal/New()
	..()
	processing_items += src
	return
/obj/item/weapon/talkingcrystal/CatchMessage(msg,mob/source)
	var/Z = findtext(msg," ")
	if(Z)
		if(rand(50))
			Z = 1
	if(length(msg) < 10)
		Z = 1
	var/Y = findtext(msg," ",Z)
	if(!Y)
		Y = 1
	var/X = copytext(msg,Z,Y)
	words += X
	for(var/mob/O in viewers(src))
		O.show_message("\blue The crystal hums for bit then stops...", 1)
/obj/item/weapon/talkingcrystal/proc/SaySomething()
	var/msg
	var/list/prevwords = list()
	var/limit = rand(7)
	for(var/y,y <= limit,y++)
		var/text = " [pick(words)]"
		if(!prevwords.Find(text))
			msg += text
			prevwords += text
			continue
		else
			continue
	for(var/mob/M in viewers(src))
		M << "\blue You hear \"[msg]\" from the [src]"
	lastsaid = world.timeofday + rand(900,1600)
/obj/item/weapon/talkingcrystal/process()
	if(prob(25) && world.timeofday >= lastsaid && words.len >= 1)
		SaySomething()
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
		explosion(find_loc(src), 1, 1, 1, 1, 1)
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



