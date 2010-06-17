//Comm antenna.  Like the Comm Dish, but "short-range" (AI sat, syndicate, station, etc)

/obj/machinery/network/antenna
	name = "Communications Antenna"
	icon = 'antenna.dmi'
	icon_state = "1"
	var/obj/machinery/network/antenna/base/base = null
	cnetdontadd = 1
	nohack = 1
	anchored = 1

/obj/machinery/network/antenna/base
	name = "Communications Antenna Base"
	icon_state = "base"
	density = 1
	var/list/obj/machinery/network/antenna/parts = list()
	var/id = ""
	var/tmp/build
	cnetdontadd = 0

/obj/machinery/network/antenna/base/New()
	for(var/x = 1, x < 5, x ++)
		var/obj/machinery/network/antenna/A = new
		A.loc = locate(src.x, src.y + x, src.z)
		A.icon_state = "[x]"
		A.base = src
		src.parts += A
		src.base = null
	..()

/obj/machinery/network/antenna/base/NetworkIdentInfo()
	return "ANTENNA"

/obj/machinery/network/antenna/base/process()
	if (!src.computernet) stat |= POWEROFF
	if (stat & NOPOWER|POWEROFF) return
	if (stat & BROKEN)
		del src
		return
	use_power(240)

/obj/machinery/network/antenna/base/Del()
	for(var/obj/machinery/part in parts)
		if(part) del part
	..()
	makecomputernets()

/obj/machinery/network/antenna/Del()
	if (src.base)
		src.base.parts -= src
		del src.base
	..()
