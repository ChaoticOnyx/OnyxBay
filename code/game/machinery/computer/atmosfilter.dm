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
	t += "<BR><HR><A href='?src=\ref[src];zlevel=1'>Deck 1</A></TT>"
	t += "<BR><HR><A href='?src=\ref[src];zlevel=2'>Deck 2</A></TT>"
	t += "<BR><HR><A href='?src=\ref[src];zlevel=3'>Deck 3</A></TT>"
	t += "<BR><HR><A href='?src=\ref[src];zlevel=4'>Deck 4</A></TT>"
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
		var/list/filters = list()
		for(var/obj/machinery/atmospherics/unary/vent_filter/F in A)
			filters += A
		usr << "[filters.len]"
	if(href_list["zlevel"])
		var/t = "<TT><B>Filter Monitoring</B><HR>"
		t += "<PRE><FONT SIZE=-1>"
		var/Z = href_list["zlevel"]
		for(var/area/A in world)
			var/turf/T = locate() in A
			if(!T)
				return
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

