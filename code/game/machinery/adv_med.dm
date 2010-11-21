// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/mob/living/carbon/occupant
	var/locked
	name = "Body scanner"
	icon = 'Cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1

/obj/machinery/bodyscanner/allow_drop()
	return 0

/obj/machinery/bodyscanner/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)

	if (usr.stat != 0)
		return
	if (src.occupant)
		usr << "\blue <B>The scanner is already occupied!</B>"
		return
	if (usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "sleeper_1"
	for(var/obj/O in src)
		//O = null
		del(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(30)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "sleeper_0"
	return

/obj/machinery/bodyscanner/attackby(obj/item/weapon/grab/G as obj, user as mob)
	if ((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		user << "\blue <B>The scanner is already occupied!</B>"
		return
	if (G.affecting.abiotic())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	var/mob/M = G.affecting
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "sleeper_1"
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(154)
	src.add_fingerprint(user)
	//G = null
	del(G)
	return

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/bodyscanner/blob_act()
	if(prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/machinery/body_scanconsole/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/body_scanconsole/blob_act()

	if(prob(50))
		del(src)

/obj/machinery/body_scanconsole/power_change()
	if(stat & BROKEN)
		icon_state = "broken"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "c_unpowered"
			stat |= NOPOWER

/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/delete
	var/temphtml
	name = "Advanced medical scanner console"
	icon = 'computer.dmi'
	icon_state = "scanner"
	density = 1
	anchored = 1


/obj/machinery/body_scanconsole/New()
	..()
	spawn( 5 )
		src.connected = locate(/obj/machinery/bodyscanner, get_step(src, WEST))
		return
	return

/obj/machinery/body_scanconsole/process() //not really used right now
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(250) // power stuff

//	var/mob/M //occupant
//	if (!( src.status )) //remove this
//		return
//	if ((src.connected && src.connected.occupant)) //connected & occupant ok
//		M = src.connected.occupant
//	else
//		if (istype(M, /mob))
//		//do stuff
//		else
///			src.temphtml = "Process terminated due to lack of occupant in scanning chamber."
//			src.status = null
//	src.updateDialog()
//	return


/obj/machinery/body_scanconsole/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_hand(user as mob)
	if(..())
		return
	var/dat
	if (src.delete && src.temphtml) //Window in buffer but its just simple message, so nothing
		src.delete = src.delete
	else if (!src.delete && src.temphtml) //Window in buffer - its a menu, dont add clear message
		dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Main Menu</A>", src.temphtml, src)
	else
		if (src.connected) //Is something connected?
			var/mob/living/carbon/occupant = src.connected.occupant
			dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>" //Blah obvious
			if (occupant) //is there REALLY someone in there?
				if (!istype(occupant,/mob/living/carbon/human))
					sleep(1)
				var/t1
				switch(occupant.stat) // obvious, see what their status is
					if(0)
						t1 = "Conscious"
					if(1)
						t1 = "Unconscious"
					else
						t1 = "*dead*"
				if(occupant:zombie == 1)
					t1 = "*dead*"
				if (istype(occupant,/mob/living/carbon/monkey))
					dat = "<font color='red'>This device can only scan human occupants.</FONT><BR>"
					return
				dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
				dat += text("<font color='green'>Radiation Level: []%</FONT><BR><BR>", occupant.radiation)
				if(occupant:zombie == 1)
					dat += text("<font color='red'>Unknown infectious agent detected.</FONT><BR><BR>",)
				dat += "<table border='1'>"
				dat += "<tr>"
				dat += "<th>Organ</th>"
				dat += "<th>Burn Damage</th>"
				dat += "<th>Brute Damage</th>"
				dat += "<th>Other Wounds</th>"
				dat += "</tr>"
				for(var/datum/organ/external/e in occupant.GetOrgans())
					dat += "<tr>"
					var/AN = ""
					var/open = ""
					var/infected = ""
//					var/split = ""
					var/imp = ""
					var/bled = ""
					if(e.wounds.len >= 1)
						bled = "Bleeding:"
					if(e.broken)
						AN = "[e.wound]:"
					if(e.open)
						open = "OPEN:"
					if(!e.clean)
						infected = "UNCLEAN:"
//					if(e.split)
//						split = ":SPLT"
					if(e.implant)
						imp = "IMPLANT:"
					if(!AN && !open && !infected & !imp)
						AN = "None"
					dat += "<td>[e.display_name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[bled][AN][open][infected][imp]</font></td>"
					//dat += text("<td><font color='red'>[e.display_name]</td><td>BRN:[e.burn_dam]</td><td>BRT:[e.brute_dam]</td><td>[AN][open][infected][imp]</font></td>")
				dat += "</tr>"
				dat += "</table>"

		else
			dat = "<font color='red'> Error: No DNA Modifier connected. </FONT>"
	user << browse(dat, "window=scannernew;size=550x625")
	return