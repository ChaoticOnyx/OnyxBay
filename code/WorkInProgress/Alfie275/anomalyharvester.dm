/obj/machinery/anomaly/anomalyharvester
	name = "Anomaly Power Collector"
	icon = 'virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1
	var/harvesting = 0
	var/obj/item/weapon/anomaly/a = null
	var/obj/item/weapon/anobattery/b = null
	var/obj/item/weapon/anomalyfilter/f = null


/obj/machinery/anomaly/anomalyharvester/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/diseasesplicer/M = new /obj/item/weapon/circuitboard/diseasesplicer( A )
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
				var/obj/item/weapon/circuitboard/diseasesplicer/M = new /obj/item/weapon/circuitboard/diseasesplicer( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	if(istype(I,/obj/item/weapon/anomaly))
		var/mob/living/carbon/c = user
		if(!a)

			a = I
			c.drop_item()
			a.loc.contents.Remove(a)
			a.loc = src
			for(var/mob/M in viewers(src))
				if(M == user)	continue
				M.show_message("\blue [user.name] inserts the [a.name] in the [src.name]", 3)
	if(istype(I,/obj/item/weapon/anomalyfilter))
		if(!f)
			user << "You insert the filter."
			user.drop_item()
			I.loc = src
			src.f = I
	if(istype(I,/obj/item/weapon/anobattery))
		if(!b)
			user << "You insert the battery."
			user.drop_item()
			I.loc = src
			src.b = I

	//else
	src.attack_hand(user)
	return

/obj/machinery/anomaly/anomalyharvester/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/anomaly/anomalyharvester/attack_paw(var/mob/user as mob)

	return src.attack_hand(user)
	return

/obj/machinery/anomaly/anomalyharvester/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat
	if(harvesting)
		dat = "Harvesting in progress"
	else
		if(a)
			dat = "[a.name] inserted"
			dat += "<BR><A href='?src=\ref[src];eject=1'>Eject anomaly</a>"
			if(b && f)
				dat += "<BR><A href='?src=\ref[src];harvest=1'>Harvest power</a>"
			else
				if(!b)
					dat += "<BR>Please insert battery"
				if(!f)
					dat += "<BR>Please insert filter"
		else
			dat += "Please insert anomaly"
		if(f)
			dat += "<BR>[f.name] inserted"
			dat += "<BR><A href='?src=\ref[src];ejectf=1'>Eject filter</a>"
		if(b)
			dat += "<BR>[b.name] inserted - [b.GetTotalPower()]/[b.capacity]"
			dat += "<BR>Effects:"
			for(var/v in b.e)
				var/datum/anomalyeffect/e = b.e["[v]"]
				dat += "<BR>	[e.fluff] - [b.power[e.effectname]]"
			dat += "<BR><A href='?src=\ref[src];ejectb=1'>Eject battery</a>"


	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return



/obj/machinery/anomaly/anomalyharvester/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	src.updateDialog()


	if(harvesting)
		harvesting -= 1
		if(harvesting<1)
			harvesting = 0

			var/datum/anomalyeffect/e = new a.e.type
			if(b.AddPower(e,min(a.e.magnitude*1.5*(1+(e.range*0.25)),b.capacity-b.GetTotalPower())))
				state("The [src.name] pings", "blue")
			else
				state("\red The [src.name] buzzes", "blue")
			icon_state = "analyser"

	return

/obj/machinery/anomaly/anomalyharvester/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if (href_list["harvest"])
			if(b.GetTotalPower()!=b.capacity)
				if(f.effectname == a.e.effectname)
					harvesting = min(a.e.magnitude/3,(b.capacity-b.GetTotalPower())/3)
					icon_state = "analyser_processing"
				else
					var/dat = "Error: Filter not suitable for power type."
					usr << browse(dat, "window=computer;size=400x500")
					onclose(usr, "computer")
			else
				var/dat = "Error: Battery full."
				usr << browse(dat, "window=computer;size=400x500")
				onclose(usr, "computer")
		if (href_list["eject"])
			src.a.loc = src.loc
			src.a = null
		if (href_list["ejectf"])
			src.f.loc = src.loc
			src.f = null
		if (href_list["ejectb"])
			src.b.loc = src.loc
			src.b = null

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

