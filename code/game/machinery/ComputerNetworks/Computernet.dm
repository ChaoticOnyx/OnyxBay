/datum/computernet
	var/list/obj/computercable/cables = list()
	var/list/obj/nodes = list()
	var/number = 0
	var/id = null
	var/list/obj/machinery/network/router/routers = list()
	var/list/obj/machinery/sniffers = list()
	var/disrupted = 0 //1 if a Packet Killer is attached

/datum/computernet/New()
	..()
	id = uppertext(num2hex(GetNetId(), 3))

/datum/computernet/proc/GetNetId()
	var/I = 0
	while ((I==0) || usednetids.Find(I))
		I = rand(1, 4095) //001 - FFF
	usednetids += I
	return I

/datum/computernet/proc/propagate(packet, messagelist, sendingunit)

	if (disrupted)
		return 0

	if(messagelist[1] != src.id && messagelist[1] != "000") return

	var/list/recievers = list( )

	if(messagelist[2] != "MULTI") //If so, is this a multicast or single-reciever packet

		if(nodes[messagelist[2]]) //Single-reciever, can we find it on the network?
			var/obj/M = nodes[messagelist[2]]
			recievers += M
			M:receivemessage(packet, sendingunit)

	else //Multicast

		if (messagelist[3] == "***") //TO EVERYONE
			for (var/obj/M in nodes)
				recievers += M
				M:receivemessage(packet, sendingunit)

		else //To everyone of TypeId ___

			messagelist[3] = uppertext(messagelist[3])
			for (var/obj/M in nodes)
				if (messagelist[3] == M:typeID)
					recievers += M
					M:receivemessage(packet, sendingunit)

	for (var/obj/machinery/M in sniffers - recievers)
		M:receivemessage(packet, sendingunit) //Sniffers get it too

	return 1

/datum/computernet/proc/GetById(var/id)
	for(var/datum/computernet/CN in computernets)
		if (CN.id == id)
			return CN

/datum/computernet/proc/send(var/packet as text, var/obj/sendingunit)

	//Ok, lets break down the message into its key components
	var/list/messagelist = dd_text2list(packet," ",null)

	messagelist[1] = uppertext(messagelist[1]) //And filter the components
	messagelist[2] = uppertext(messagelist[2])

	if (messagelist[1] == "000" || messagelist[1] == id) //Check if it's the local net code, or if the netid is the loopback code
		src.propagate(packet, messagelist, sendingunit)

	else //No, it's on another net

		if ((id in routingtable.sourcenets) && (messagelist[1] in routingtable.sourcenets[id]))
			if (routingtable.sourcenets[src.id][messagelist[1]] == null)
				BuildRoutingPath(src, GetById(messagelist[1]))

			if (routingtable.sourcenets[src.id][messagelist[1]] == 0)
				return //But it can't get there from here, or better yet either this net or the dest net aren't in the routing table
				   	//If it's one of the latter, hopefully it was caused by a human typoing an id

			var/list/datum/computernet/nets = routingtable.sourcenets[src.id][messagelist[1]]

			for(var/datum/computernet/net in nets)
				if (!net.propagate(packet, messagelist, sendingunit))
					return