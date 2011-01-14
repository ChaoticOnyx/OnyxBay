/obj/machinery/computer/diseaseanalyser
	name = "Disease Analyser"
	icon = 'computer.dmi'
	icon_state = "gas"
	brightnessred = 0
	brightnessgreen = 2
	brightnessblue = 2

	var/scanning = 0

	var/obj/item/weapon/virusdish/dish = null


/obj/machinery/computer/diseaseanalyser/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/diseaseanalyser/M = new /obj/item/weapon/circuitboard/diseaseanalyser( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/diseaseanalyser/M = new /obj/item/weapon/circuitboard/diseaseanalyser( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		if(!dish)

			dish = I
			c.drop_item()
			I.loc = src

	//else
	src.attack_hand(user)
	return

/obj/machinery/computer/diseaseanalyser/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/diseaseanalyser/attack_paw(var/mob/user as mob)

	return src.attack_hand(user)
	return

/obj/machinery/computer/diseaseanalyser/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat
	if(scanning)
		dat = "Scanning in progress"
	else if(dish)
		dat = "Virus dish inserted"
		if(dish.virus2)
			if(dish.growth >= 50)
				dat += "<BR><A href='?src=\ref[src];scan=1'>Begin scanning</a>"
			else
				dat += "<BR>Insufficent cells to attempt to do indepth analysis"
		else
			dat += "<BR>No virus found in dish"

		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject disk</a>"
	else
		dat += "Please insert dish"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/diseaseanalyser/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	src.updateDialog()

	if(scanning)
		scanning -= 1
		if(scanning == 0)
			var/r = "GNAv2 based virus lifeform"
			r += "<BR>Infection rate : [dish.virus2.infectionchance * 10]"
			r += "<BR>Spread form : [dish.virus2.spreadtype]"
			r += "<BR>Progress Speed : [dish.virus2.stageprob * 10]"
			for(var/datum/disease2/effectholder/E in dish.virus2.effects)
				r += "<BR>Effect:[E.effect.name]. Strength : [E.multiplier * 8]. Verosity : [E.chance * 15]. Type : [5-E.stage]."
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src.loc)
			P.info = r
			dish.info = r
			dish.analysed = 1

			for(var/mob/O in hearers(src, null))
				O.show_message("The [src.name] prints a sheet of paper", 2)



	return

/obj/machinery/computer/diseaseanalyser/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if (href_list["scan"])
			scanning = 10
			dish.growth -= 10
		else if(href_list["eject"])
			dish.loc = src.loc
			dish = null

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


