/obj/machinery/anomaly/anomalyanalyser
	name = "Anomaly Analyser"
	icon = 'virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1
	var/scanning = 0
	var/analysing = 0
	var/spectral = 0
	var/pause = 0
	var/obj/item/weapon/anomalyfilter/f = null
	var/obj/item/weapon/anomaly/a= null
	var/maxid = 1



/obj/machinery/anomaly/anomalyanalyser/attackby(var/obj/I as obj, var/mob/user as mob)
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
			if(!a.id)
				a.id = maxid
				maxid++
				a.name = "Anomaly A-[a.id]"
	if(istype(I,/obj/item/weapon/anomalyfilter))
		if(!f)
			user << "You insert the [I.name]."
			user.drop_item()
			I.loc = src
			src.f = I


	//else
	src.attack_hand(user)
	return

/obj/machinery/anomaly/anomalyanalyser/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/anomaly/anomalyanalyser/attack_paw(var/mob/user as mob)

	return src.attack_hand(user)
	return

/obj/machinery/anomaly/anomalyanalyser/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat
	if(analysing)
		dat = "Analysing in progress"
	else if(scanning)
		dat = "Scanning in progress"
	else if(spectral)
		dat = "Spectral scan in progress"
	else
		if(a)
			dat = "[a.name] inserted"
			dat += "<BR><A href='?src=\ref[src];eject=1'>Eject</a>"
			dat += "<BR><A href='?src=\ref[src];analyse=1'>Analyse</a>"
			if(f)
				dat += "<BR><BR>[f.name] inserted"
				dat += "<BR><A href='?src=\ref[src];spectral=1'>High fidelity spectral scan</a>"
				dat += "<BR><A href='?src=\ref[src];ejectf=1'>Eject filter</a>"
			else
				dat += "<BR>Please insert filter for spectral scan"
		else
			dat = "Please insert anomaly"



	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return



/obj/machinery/anomaly/anomalyanalyser/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	src.updateDialog()


	if(analysing)
		analysing -= 1
		if(!analysing)
			state("The [src.name] pings")
			var/r = "[a.name]"
			r += "<BR>Range	: [a.e.range]"
			r += "<BR>Magnitude : [a.e.magnitude]"
			r += "<BR>Effect : [a.e.fluff]"
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src.loc)
			P.name = "Results"
			P.info = r
			icon_state = "analyser"

	if(spectral)
		spectral -= 1
		if(!spectral)
			state("The [src.name] beeps")
			f.effectname = a.e.effectname
			f.name = "Spectral filter A-[a.id]"
			f.desc = "Spectral filter for \"[a.e.fluff]\""
			f.loc = src.loc
			f = null
			icon_state = "analyser"

	return

/obj/machinery/anomaly/anomalyanalyser/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if (href_list["analyse"])
			analysing = 15
			icon_state = "analyser_processing"
		if (href_list["spectral"])
			spectral = 40
			icon_state = "analyser_processing"
		if (href_list["eject"])
			src.a.loc = src.loc
			src.a = null
		if (href_list["ejectf"])
			src.f.loc = src.loc
			src.f = null
		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/anomaly/anomalyanalyser/proc/state(var/msg)
	for(var/mob/O in hearers(src, null))
		O.show_message("\icon[src] \blue [msg]", 2)

/obj/item/weapon/anomalyfilter
	name = "Spectral filter"
	icon = 'items.dmi'
	icon_state = "datadisk0"
	var/effectname = null