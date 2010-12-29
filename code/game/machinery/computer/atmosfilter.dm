// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet

/obj/machinery/computer/atmosphere/monitor/attack_ai(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/atmosphere/monitor/attack_hand(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)
/obj/machinery/computer/atmosphere/monitor/
	name = "Filter Adjuster"
	icon = 'computer.dmi'
	icon_state = "gas"
/obj/machinery/computer/atmosphere/monitor/proc/interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=powcomp")
			return


	user.machine = src
	var/t = "<TT><B>Filter Monitoring</B><HR>"
	t += "<BR><HR><A href='?src=\ref[src];zlevel=4'>Deck 1</A></TT>"
	t += "<BR><HR><A href='?src=\ref[src];zlevel=3'>Deck 2</A></TT>"
	t += "<BR><HR><A href='?src=\ref[src];zlevel=2'>Deck 3</A></TT>"
	t += "<BR><HR><A href='?src=\ref[src];zlevel=1'>Deck 4</A></TT>"
	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A></TT>"
	user << browse(t, "window=powcomp;size=420x700")
	onclose(user, "powcomp")


/obj/machinery/computer/atmosphere/monitor/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=powcomp")
		usr.machine = null
		return
	if(href_list["inspect"])
		var/area/A = locate(href_list["inspect"])
		if(!isarea(A))
			world << "NOT AN AREA"
			return
		var/t = "<TT><B>Filter Monitoring</B><HR>"
		var/count
		for(var/obj/machinery/atmospherics/unary/vent_filter/vent in A)
			count++
			t += "<BR><big>Filter [count] -  [A.name]</big>"
			t += "<BR><A href='?src=\ref[src];nofil=\ref[vent]'>Toggle Nitrogen</A><br>Status:[vent.no_fil ? "Scrubbing" : "Releasing"]"
			t += "<BR><A href='?src=\ref[src];o2fil=\ref[vent]'>Toggle Oxygen</A><br>Status:[vent.o2_fil ? "Scrubbing" : "Releasing"]"
			t += "<BR><A href='?src=\ref[src];co2_fil=\ref[vent]'>Toggle Carbon Dioxide</A><br>Status:[vent.co2_fil ? "Scrubbing" : "Releasing"]"
			t += "<BR><A href='?src=\ref[src];toxins_fil=\ref[vent]'>Toggle Plasma</A><br>Status:[vent.toxins_fil ? "Scrubbing" : "Releasing"]"
			t += "<BR><A href='?src=\ref[src];trace=\ref[vent]'>Toggle Trace gases</A><br>Status:[vent.trace_fil ? "Scrubbing" : "Releasing"]"
		t += "<br><A href='?src=\ref[src];inspect=\ref[A]'>Update</A><br>"
		usr << browse(t, "window=powcomp;size=420x700")
	if(href_list["zlevel"])
		var/t = "<TT><B>Filter Monitoring</B><HR>"
		t += "<PRE><FONT SIZE=-1>"
		var/Z = text2num(href_list["zlevel"])
		//world << "LEVEL = [Z]"
		for(var/area/A in world)
			var/turf/T = locate() in A.contents
			if(!T)
				continue
			if(T.z == Z)
				var/list/filters = list()
				if(A.applyalertstatus)
					for(var/obj/machinery/atmospherics/unary/vent_filter/F in A)
						filters += A
					if(filters.len <= 0)
						continue
					else
						t += "<A href='?src=\ref[src];inspect=\ref[A]'>[A.name]</A>Filter Count:[filters.len]<br>"
		t += "</FONT></PRE>"
		usr << browse(t, "window=powcomp;size=420x700")
	if(href_list["nofil"])
		var/obj/machinery/atmospherics/unary/vent_filter/vent = locate(href_list["nofil"])
		vent.no_fil = !vent.no_fil
	if(href_list["o2fil"])
		var/obj/machinery/atmospherics/unary/vent_filter/vent = locate(href_list["o2fil"])
		vent.o2_fil = !vent.o2_fil
	if(href_list["co2_fil"])
		var/obj/machinery/atmospherics/unary/vent_filter/vent = locate(href_list["co2_fil"])
		vent.co2_fil = !vent.co2_fil
	if(href_list["toxins_fil"])
		var/obj/machinery/atmospherics/unary/vent_filter/vent = locate(href_list["toxins_fil"])
		vent.toxins_fil = !vent.toxins_fil
	if(href_list["trace"])
		var/obj/machinery/atmospherics/unary/vent_filter/vent = locate(href_list["trace"])
		vent.trace_fil = !vent.trace_fil
/obj/machinery/computer/atmosphere/monitor/process()
	if(!(stat & (NOPOWER|BROKEN)) )
		use_power(250)

//	src.updateDialog()


/obj/machinery/computer/atmosphere/monitor/power_change()

	if(stat & BROKEN)
		icon_state = "broken"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
				stat |= NOPOWER

