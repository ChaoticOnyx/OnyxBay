/*Module Storage Unit/Closet!  Solid, only modules fit in it.*/
/obj/aiuploadcloset
	name = "AI Mainframe Module Storage Unit"
	icon = 'mainframe.dmi'
	icon_state = "right-closed"
	density = 1

	var/open = 0  /*It's closed!*/

/obj/aiuploadcloset/New()
	..()
	new /obj/item/weapon/aiModule/reset(src)
	new /obj/item/weapon/aiModule/safeguard(src)
	new /obj/item/weapon/aiModule/protectStation(src)
	new /obj/item/weapon/aiModule/quarantine(src)
	new /obj/item/weapon/aiModule/teleporterOffline(src)
	new /obj/item/weapon/aiModule/oneHuman(src)
	new /obj/item/weapon/aiModule/freeform(src)
	for(var/obj/item/weapon/aiModule/M in src)
		M.pixel_x = rand(-10, 10)
		M.pixel_y = rand(-10, 10)

/obj/aiuploadcloset/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/aiModule))
		user.drop_item()
		W.loc = get_turf(src)
	else
		return attack_hand(user)

/obj/aiuploadcloset/attack_hand(mob/user as mob)
	if(!open)
		var/temp_count
		for(var/obj/item/weapon/aiModule/M in src)
			M.loc = src.loc
			temp_count++

		user << "\blue You open the module storage unit, [temp_count > 0 ? "and take out all the modules." : "\red but it's empty!"]"
		open = 1
		icon_state = "right-open"

	else
		var/temp_count
		for(var/obj/item/weapon/aiModule/M in get_turf(src))
			M.loc = src
			temp_count++

		user << "\blue [temp_count > 0 ? "You put all the modules back into the module storage unit, and then close it." : "You close the module storage unit."]"
		open = 0
		icon_state = "right-closed"

/obj/aiuploadcloset/ex_act(severity)
	switch(severity)
		if (1)
			for(var/obj/item/weapon/aiModule/M in src)
				M.loc = src.loc
				M.ex_act(severity)
			del(src)
		if (2)
			if (prob(50))
				for(var/obj/item/weapon/aiModule/M in src)
					M.loc = src.loc
					M.ex_act(severity)
				del(src)
		if (3)
			if (prob(5))
				for(var/obj/item/weapon/aiModule/M in src)
					M.loc = src.loc
					M.ex_act(severity)
				del(src)