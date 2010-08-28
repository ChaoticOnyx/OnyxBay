/obj/machinery/computer/travel
	name = "Propulsion Control"
	icon = 'computer.dmi'
	icon_state = "id"
	req_access = list(access_captain)

/obj/machinery/computer/travel/attackby(I as obj, user as mob)
/*	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/robotics/M = new /obj/item/weapon/circuitboard/robotics( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/M = new /obj/item/weapon/circuitboard( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
*/
	//else
	src.attack_hand(user)
	return


/obj/machinery/computer/travel/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/travel/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)
	return

/obj/machinery/computer/travel/attack_hand(var/mob/user as mob)
	if(..())
		return
	var/Dest
	var/Type = pick("Junk","Junk","Solar")
	switch(Type)
		if("Junk")
			Dest = pick("junk2","junk2","junk2","junk0","junk0","junk1")
		else if("Solar")
			Dest = pick("solar2","solar2","solar2","solar1","solar1","solar0")
	user << "Loaded maps\\travel\\[Dest].dmm"
	QML_loadMap("maps\\travel\\[Dest].dmm", 1, 70, 2)
	return

/obj/machinery/computer/engine/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	src.updateDialog()
	return



