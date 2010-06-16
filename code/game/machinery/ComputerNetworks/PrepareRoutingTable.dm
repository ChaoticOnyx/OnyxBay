/datum/rtable
	var/list/list/datum/computernet/sourcenets = list()

proc/BuildRoutingTable()
	set background = 1
	var/datum/rtable/R = new /datum/rtable()
	world.log << "Preparing routing table ([computernets.len] nets)"
	for (var/datum/computernet/srccnet in computernets)
		R.sourcenets[srccnet.id] = list()
		for(var/datum/computernet/destcnet in computernets)
			R.sourcenets[srccnet.id][destcnet.id] = null

	routingtable = R

proc/BuildRoutingPath(var/datum/computernet/srccnet, var/datum/computernet/destcnet, var/datum/rtable/R = routingtable)
	if (srccnet.routers.len == 0 || destcnet.routers.len == 0)
		R.sourcenets[srccnet.id][destcnet.id] = 0
		return

	var/list/datum/computernet/path = SubBuildRoutingPath(srccnet, destcnet, list())

	R.sourcenets[srccnet.id][destcnet.id] = path != null ? path : 0

proc/SubBuildRoutingPath(var/datum/computernet/curnet, var/datum/computernet/destcnet, var/list/ignore)
	if (!curnet)
		return null
	if (curnet == destcnet)
		return list(curnet)

	ignore += curnet

	var/list/best = null

	for (var/obj/machinery/network/router/R in curnet.routers)
		ignore += R
		for (var/datum/computernet/cnet in R.connectednets)
			if (cnet in ignore)
				continue

			var/list/results = SubBuildRoutingPath(cnet, destcnet, ignore)

			if (!results)
				continue

			results += curnet

			if (!best || best.len > results.len)
				best = results

	return best