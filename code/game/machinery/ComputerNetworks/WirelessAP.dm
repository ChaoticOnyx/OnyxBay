/obj/machinery/network/wirelessap
	name = "Wireless AP"
	icon = 'netobjs.dmi'
	icon_state = "ap"
	desc = "An access point for wireless network devices"
	anchored = 1
	density = 0
	var/datum/computernet/wirelessnet = null

/obj/machinery/network/wirelessap/proc/updateicon()
	icon_state = "ap" + (stat & BROKEN ? "-b" : (stat & NOPOWER ? "-p" : ""))

/obj/machinery/network/wirelessap/power_change()
	..()
	updateicon()

/obj/machinery/network/wirelessap/New()
	..()
	for(var/turf/T in range(100,src))
		if(!T.wireless.Find(src))
			T.wireless.Add(src)