/obj/machinery/shielding
	var/datum/shieldnetwork = null
	var/tmp/shieldnetnum = 0
/obj/machinery/shielding/New()
	..()
var/datum/shieldnetwork/snet
var/datum/shieldnetwork/snet34
datum/shieldnetwork
	var/netnum
	var/list/mach = list()
datum/shieldnetwork/proc/makenetwork()
	src.netnum = 12
	for(var/obj/machinery/shielding/S in world)
		if(istype(S,/obj/machinery/shielding/shield))
			continue
		src.mach += S
		S.shieldnetnum = 12
		S.shieldnetwork = src
		if(istype(S,/obj/machinery/shielding/emitter))
			S:updateAreas()
	return 1
datum/shieldnetwork/proc/startshields()
	for(var/obj/machinery/shielding/emitter/E in mach)
		E.online = 1
datum/shieldnetwork/proc/stopshields()
	for(var/obj/machinery/shielding/emitter/E in mach)
		E.online = 0