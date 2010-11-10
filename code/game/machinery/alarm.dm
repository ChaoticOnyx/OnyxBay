/obj/machinery/alarm
	var/const/ALERT_ATMOSPHERE_L = ONE_ATMOSPHERE*0.9
	var/const/ALERT_ATMOSPHERE_U = ONE_ATMOSPHERE*1.1
	var/const/UNSAFE_ATMOSPHERE_L = ONE_ATMOSPHERE*0.8
	var/const/UNSAFE_ATMOSPHERE_U = ONE_ATMOSPHERE*1.2
	var/const/ALERT_O2_L = MOLES_O2STANDARD*0.9
	var/const/ALERT_O2_U = MOLES_O2STANDARD*1.1
	var/const/UNSAFE_O2_L = MOLES_O2STANDARD*0.8
	var/const/ALERT_TEMPERATURE_L = T20C-10
	var/const/ALERT_TEMPERATURE_U = T20C+10
	var/const/UNSAFE_TEMPERATURE_L = T20C-20
	var/const/UNSAFE_TEMPERATURE_U = T20C+20
	var/safe_old = 2
	var/obj/machinery/atmospherics/pipe/vent/vent_connected

/obj/machinery/alarm/New()
	..()


	if(!alarm_zone)
		var/area/A = get_area(loc)
		if(A.name)
			alarm_zone = A.name
		else
			alarm_zone = "Unregistered"

	spawn(2)
		for(var/obj/machinery/atmospherics/pipe/vent/V in get_area(loc))
			if(cmptextEx(vent_connected,V.vent_id))
				vent_connected = V

/obj/machinery/alarm/process()
	if (src.skipprocess)
		src.skipprocess--
		return

	var/turf/location = src.loc
	var/area/A = get_area(location)
	var/safe = 2
	var/alert_info = 0

	if(stat & (NOPOWER|BROKEN))
		icon_state = "alarmp"
		return

	use_power(5, ENVIRON)

	if (!( istype(location, /turf) ))
		return 0

	var/datum/gas_mixture/environment = location.return_air(1)

	var/environment_pressure = environment.return_pressure()

	if((environment_pressure < ALERT_ATMOSPHERE_L) || (environment_pressure > ALERT_ATMOSPHERE_U))
		//Pressure sensor
		alert_info = 1
		if((environment_pressure < UNSAFE_ATMOSPHERE_L) || (environment_pressure > UNSAFE_ATMOSPHERE_U))
			safe = 0
		else safe = 1

	if(safe && ((environment.oxygen < ALERT_O2_L) || (environment.oxygen > ALERT_O2_U)))
		//Oxygen Levels Sensor
		alert_info = 2
		if(environment.oxygen < UNSAFE_O2_L)
			safe = 0
		else safe = 1

	if(safe && ((environment.temperature < ALERT_TEMPERATURE_L) || (environment.temperature > ALERT_TEMPERATURE_U)))
		//Temperature Sensor
		alert_info = 3
		if((environment.temperature < UNSAFE_TEMPERATURE_L) || (environment.temperature > UNSAFE_TEMPERATURE_U))
			safe = 0
		else safe = 1

	if(safe && (environment.carbon_dioxide > 0.05))
		//CO2 Levels Sensor
		alert_info = 4
		if(environment.carbon_dioxide > 0.1)
			safe = 0
		else safe = 1

	if(safe && (environment.toxins > 1))
		//Plasma Levels Sensor
		alert_info = 5
		safe = 0


	if(safe == 2) src.skipprocess = 1
	else if(alarm_frequency)
		post_alert(safe, alert_info)
	if (safe != safe_old || !A.air_doors_activated)
		src.icon_state = "alarm[!safe]"
		if(!safe && !A.air_doors_activated)
			air_doors_close()
		else if (safe && A.air_doors_activated)
			air_doors_open()
	safe_old = safe
	updateUsrDialog()
	return

/obj/machinery/alarm/proc/post_alert(alert_level, alert_type)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)

	if(!frequency) return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_zone
	alert_signal.data["type"] = "Atmospheric"
	alert_signal.data["subtype"] = alert_type

	if(alert_level==0)
		alert_signal.data["alert"] = "severe"
	else
		alert_signal.data["alert"] = "minor"

	frequency.post_signal(src, alert_signal)

/obj/machinery/alarm/attackby(W as obj, user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		stat ^= BROKEN
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] has []activated []!", user, (stat&BROKEN) ? "de" : "re", src), 1)
		return
	return ..()

/obj/machinery/alarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

///obj/machinery/alarm/Click()
//	return attack_hand(usr)

/obj/machinery/alarm/attack_hand(mob/user as mob)
	if(!(user in range(3,src)) && !istype(user, /mob/living/silicon/))
		user.machine = null
		return
	if(user.stat)
		return
	if(stat & (NOPOWER|BROKEN))
		return

	var/turf/location = loc
	if (!( istype(location, /turf) ))
		return

	var/datum/gas_mixture/environment = location.return_air(1)

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	var/dat = ""

	dat += "\blue <B>[alarm_zone] Atmosphere:</B><br>"
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		dat += "\blue Pressure: [round(pressure,0.1)] kPa<br>"
	else
		dat += "\red Pressure: [round(pressure,0.1)] kPa<br>"
	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			dat += "\blue Nitrogen: [round(n2_concentration*100)]%<br>"
		else
			dat += "\red Nitrogen: [round(n2_concentration*100)]%<br>"

		if(abs(o2_concentration - O2STANDARD) < 2)
			dat += "\blue Oxygen: [round(o2_concentration*100)]%<br>"
		else
			dat += "\red Oxygen: [round(o2_concentration*100)]%<br>"

		if(co2_concentration > 0.01)
			dat += "\red CO2: [round(co2_concentration*100)]%<br>"
		else
			dat += "\blue CO2: [round(co2_concentration*100)]%<br>"

		if(plasma_concentration > 0.01)
			dat += "\red Plasma: [round(plasma_concentration*100)]%<br>"

		if(unknown_concentration > 0.01)
			dat += "\red Unknown: [round(unknown_concentration*100)]%<br>"
		if(abs(environment.temperature - T20C) < 7)
			dat += "\blue Temperature: [round(environment.temperature-T0C)]&deg;C"
		else
			dat += "\red Temperature: [round(environment.temperature-T0C)]&deg;C"
	if((user in range(1,src)) || istype(user, /mob/living/silicon/))
		dat += "<BR><BR>"
		var/area/A = get_area(loc)
		if(!A.air_doors_activated)
			dat += "<A href='?src=\ref[src];activate_alarm=1'>Activate Emergency Seal</A>"
		else
			dat += "<A href='?src=\ref[src];deactivate_alarm=1'>Deactivate Emergency Seal</A>"
		dat += "<BR><BR>"
		if(vent_connected)
			if(!vent_connected.panic_fill)
				dat += "<A href='?src=\ref[src];activate_panic_fill=1'>Activate Panic Fill</A>"
			else
				dat += "<A href='?src=\ref[src];deactivate_panic_fill=1'>Deactivate Panic Fill</A>"
		else
			dat += "\red No vents connected!"
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=alarm'>Close</A>", user)
	user << browse(dat, "window=alarm;size=400x500")
	user.machine = src
	onclose(user, "alarm")

	return 1

/obj/machinery/alarm/Topic(href,href_list[])
	if(href_list["activate_alarm"])
		air_doors_close(1)
	if(href_list["deactivate_alarm"])
		air_doors_open(1)
	if(href_list["activate_panic_fill"])
		vent_connected.panic_fill = 1
	if(href_list["deactivate_panic_fill"])
		vent_connected.panic_fill = 0

	spawn(10)					//Added by Strumpetplaya - Alarm Changes - Moved Door Delay to here
		updateUsrDialog()





obj/machinery/alarm/proc
	air_doors_close(manual)
		var/area/A = get_area(loc)
		for(var/obj/machinery/door/airlock/E in A.auxdoors)
			var/obj/LightTest = locate(/obj/alertlighting/atmoslight) in E.loc
			if(isnull(LightTest))
				var/obj/alertlighting/atmoslight/F = new/obj/alertlighting/atmoslight(E.loc)
				var/image/imagelight = image('alert.dmi',F,icon_state = "blueold")
				world << imagelight
			if((!E.arePowerSystemsOn()) || (E.stat & NOPOWER)) continue
			if(!E.density)
				spawn(0)
				E.close()
				sleep(10)
				if(E.density)
					E.locked = 1
					E.air_locked = 1
					E.update_icon()
			else if(!E.locked) //Don't lock already bolted doors.
				E.locked = 1
				E.air_locked = 1
				E.update_icon()
			if(!A.fire)
				for(var/obj/machinery/door/firedoor/D in E.loc)
					if(!D.blocked)
						if(D.operating)
							D.nextstate = CLOSED
						else if(!D.density)
							spawn(0)
							D.close()
		/*	if((!D.arePowerSystemsOn()) || (D.stat & NOPOWER)) continue
			if(!D.density)
				spawn(0)
				D.close()
				sleep(10)
				if(D.density)
					D.locked = 1
					D.air_locked = 1
					D.update_icon()
			else if(!D.locked) //Don't lock already bolted doors.
				D.locked = 1
				D.air_locked = 1
				D.update_icon()
		if(!fire)
			for(var/obj/machinery/door/firedoor/D in alldoors)
				if(!D.blocked)
					if(D.operating)
						D.nextstate = CLOSED
					else if(!D.density)
						spawn(0)
						D.close()
		*/
		for(var/area/RA in A.related)
			for(var/turf/T in RA)
				if(T.density != 1)
					var/obj/LightTest = locate(/obj/alertlighting/atmoslight) in T
					if(isnull(LightTest))
						var/obj/alertlighting/atmoslight/F = new/obj/alertlighting/atmoslight(T)
						var/image/imagelight = image('alert.dmi',F,icon_state = "blueold")
						world << imagelight
			RA.activate_air_doors(manual*5)

	air_doors_open(manual)
		var/area/A = get_area(loc)
		for(var/obj/machinery/door/airlock/E in A.auxdoors)
			var/area/B = get_area(E.loc)
			if(B.air_doors_activated != 1)
				var/turf/C = E.loc
				for (var/obj/alertlighting/atmoslight/G in C)
					del(G)
				if((!E.arePowerSystemsOn()) || (E.stat & NOPOWER)) continue
					//E.air_locked = 0
				if(E.air_locked) //Don't mess with doors locked for other reasons.
					if(E.density)
						E.locked = 0
						E.air_locked =0
						E.update_icon()
			if(!A.fire)
				for(var/obj/machinery/door/firedoor/D in E.loc)
					if(!D.blocked)
						if(D.operating)
							D.nextstate = OPEN
						else if(D.density)
							spawn(0)
							D.open()
		for(var/area/RA in A.related)
			for(var/turf/T in RA)
				if(T.density != 1)
					for (var/obj/alertlighting/atmoslight/F in T)
						del(F)
			RA.deactivate_air_doors(manual*5)





/* Commented By Strumpetplaya - This is how the procs above looked before my alarm changes.
obj/machinery/alarm/proc
	air_doors_close(manual)
		var/area/A = get_area(loc)
		for(var/area/RA in A.related)
			RA.activate_air_doors(manual*5)
	air_doors_open(manual)
		var/area/A = get_area(loc)
		for(var/area/RA in A.related)
			RA.deactivate_air_doors(manual*5)
*/



/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(src.detecting)
		if(temperature > T0C+200)
			src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		src.detecting = !( src.detecting )
		if (src.detecting)
			user.visible_message("\red [user] has reconnected [src]'s detecting unit!", "You have reconnected [src]'s detecting unit.")
		else
			user.visible_message("\red [user] has disconnected [src]'s detecting unit!", "You have disconnected [src]'s detecting unit.")
	else
		src.alarm()
	src.add_fingerprint(user)
	return

/obj/machinery/firealarm/process()
	if(stat & (NOPOWER|BROKEN))
		return

	use_power(10, ENVIRON)

	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
		else
			alarm()
			src.time = 0
			src.timing = 0
		src.updateDialog()
	return

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		icon_state = "fire0"
	else
		spawn(rand(0,15))
			stat |= NOPOWER
			icon_state = "firep"

/obj/machinery/firealarm/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	var/area/A = src.loc
	var/d1
	var/d2
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		A = A.loc

		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Fire alarm</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", stars("Fire alarm"), d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
	return

/obj/machinery/firealarm/Topic(href, href_list)
	..()
	if (usr.stat || stat & (BROKEN|NOPOWER))
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["reset"])
			src.reset()
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						src.time += tp
						src.time = min(max(round(src.time), 0), 120)
		spawn(10)					//Added by Strumpetplaya - Alarm Changes - Try to curb alarm spamming
			updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=firealarm")
		return
	return

//reset() Edited by Strumpetplaya
/obj/machinery/firealarm/proc/reset()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/obj/machinery/door/firedoor/E in A.auxdoors)
		var/area/B = get_area(E.loc)
		if(B.fire != 1)
			var/turf/C = E.loc
			for (var/obj/alertlighting/firelight/G in C)
				del(G)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = OPEN
				else if(E.density)
					spawn(0)
					E.open()
	for(var/area/RA in A.related)
		for(var/turf/T in RA)
			if(T.density != 1)
				for (var/obj/alertlighting/firelight/F in T)
					del(F)

		RA.firereset()
	return



//alarm() Edited by Strumpetplaya
/obj/machinery/firealarm/proc/alarm()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/obj/machinery/door/firedoor/E in A.auxdoors)
		var/obj/LightTest = locate(/obj/alertlighting/firelight) in E.loc
		if(isnull(LightTest))
			var/obj/alertlighting/firelight/F = new/obj/alertlighting/firelight(E.loc)
			var/image/imagelight = image('alert.dmi',F,icon_state = "blue")
			world << imagelight
		if(!E.blocked)
			if(E.operating)
				E.nextstate = CLOSED
			else if(!E.density)
				spawn(0)
				E.close()
	for(var/area/RA in A.related)
		for(var/turf/T in RA)
			if(T.density != 1)
				var/obj/LightTest = locate(/obj/alertlighting/firelight) in T
				if(isnull(LightTest))
					var/obj/alertlighting/firelight/F = new/obj/alertlighting/firelight(T)
					var/image/imagelight = image('alert.dmi',F,icon_state = "blue")
					world << imagelight
		RA.firealert()
	//playsound(src.loc, 'signal.ogg', 75, 0)
	return





/obj/machinery/partyalarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)
/obj/machinery/partyalarm/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	var/area/A = src.loc
	var/d1
	var/d2
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		A = A.loc

		if (A.party)
			d1 = text("<A href='?src=\ref[];reset=1'>No Party :(</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>PARTY!!!</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Party Button</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("No Party :("))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("PARTY!!!"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", stars("Party Button"), d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	return

/obj/machinery/partyalarm/proc/reset()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	A.partyreset()
	return

/obj/machinery/partyalarm/proc/alarm()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	A.partyalert()
	return

/obj/machinery/partyalarm/Topic(href, href_list)
	..()
	if (usr.stat || stat & (BROKEN|NOPOWER))
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["reset"])
			src.reset()
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						src.time += tp
						src.time = min(max(round(src.time), 0), 120)
		src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=partyalarm")
		return
	return