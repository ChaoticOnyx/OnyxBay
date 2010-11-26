// =
// = The Unified (-Type-Tree) Cable Network System
// = Written by Sukasa with assistance from Googolplexed
// =
// = Cleans up the type tree and reduces future code maintenance
// = Also makes it easy to add new cable & network types
// =

// Unified Cable Network System - Generic Network Class

/proc/CreateUnifiedNetwork(var/CableType)
	var/datum/UnifiedNetwork/NewNetwork = new()
	var/list/NetworkList = AllNetworks[CableType]

	if (!NetworkList)
		NetworkList = list( )
		AllNetworks[CableType] = NetworkList

	NetworkList += NewNetwork
	NewNetwork.NetworkNumber = NetworkList.len

	return NewNetwork


/datum/UnifiedNetwork
	var/datum/UnifiedNetworkController/Controller = null

	var/NetworkNumber
	var/list/Nodes = list( )
	var/list/Cables = list( )


/datum/UnifiedNetwork/proc/CutCable(var/obj/cabling/Cable)

	var/list/ConnectedCables = Cable.CableConnections(get_step_3d(Cable, Cable.Direction1)) | Cable.CableConnections(get_step_3d(Cable, Cable.Direction2))

	Controller.RemoveCable(Cable)

	if(!ConnectedCables.len)
		Cables -= Cable
		if (!Cables.len)
			for(var/obj/Node in Nodes)
				if(!Node.NetworkNumber)
					Controller.DetachNode(Node)
					Node.Networks[Cable.type] = null
					Node.NetworkNumber[Cable.type] = 0

			Controller.Finalize()
			del Controller
			del src

		return

	for(var/obj/C in Cables)
		C.NetworkNumber[Cable.type] = 0
	for(var/obj/N in Nodes)
		N.NetworkNumber[Cable.type] = 0

	Cable.loc = null
	Cables -= Cable

	PropagateNetwork(ConnectedCables[1], NetworkNumber)

	ConnectedCables -= ConnectedCables[1]

	for(var/obj/cabling/O in ConnectedCables)
		if(O.NetworkNumber[Cable.type] == 0)

			var/datum/UnifiedNetwork/NewNetwork = CreateUnifiedNetwork(Cable.type)

			PropagateNetwork(O, NewNetwork.NetworkNumber)

			Controller.StartSplit(NewNetwork)

			for(var/obj/cabling/C in Cables)
				if(!C.NetworkNumber)
					Controller.RemoveCable(C)
					C.NetworkNumber[Cable.type] = NewNetwork.NetworkNumber
					C.Networks[Cable.type] = NewNetwork
					Cables -= C
					NewNetwork.Cables += C
					NewNetwork.Controller.AddCable(C)

			for(var/obj/Node in Nodes)
				if(!Node.NetworkNumber)
					Controller.DetachNode(Node)
					Node.NetworkNumber[Cable.type] = NewNetwork.NetworkNumber
					Node.Networks[Cable.type] = NewNetwork
					Nodes -= Node
					NewNetwork.Nodes += Node
					NewNetwork.Controller.AttachNode(Node)

			Controller.FinishSplit(NewNetwork)

			NewNetwork.Controller.Initialize()
	return


/datum/UnifiedNetwork/proc/BuildFrom(var/obj/cabling/Start, var/ControllerType = /datum/UnifiedNetworkController)
	var/list/Components = PropagateNetwork(Start, NetworkNumber)

	Controller = new ControllerType(src)

	for (var/obj/Component in Components)
		if (istype(Component, /obj/cabling))
			Cables += Component
			Controller.AddCable(Component)
		else
			Nodes += Component
			Controller.AttachNode(Component)

	Controller.Initialize()

	return


/datum/UnifiedNetwork/proc/PropagateNetwork(var/obj/cabling/Start, var/NewNetworkNumber)
	var/list/Connections = list()

	Start.NetworkNumber[Start.type] = NewNetworkNumber

	var/list/Possibilities = list(Start)

	while (Possibilities.len)
		for (var/obj/C in Possibilities.Copy())
			if (!istype(C, /obj/cabling))
				continue
			var/obj/cabling/CC = C
			Possibilities |= CC.AllConnections(get_step_3d(CC, CC.Direction1)) | CC.AllConnections(get_step_3d(CC, CC.Direction2))

		for (var/obj/C in Possibilities.Copy())
			if (C.NetworkNumber[C.type] != NewNetworkNumber)
				C.NetworkNumber[C.type] = NewNetworkNumber
				C.Networks[C.type] = src
				Connections += C
			Possibilities -= C

	return Connections


/datum/UnifiedNetwork/proc/CableBuilt(var/obj/cabling/Cable, var/list/Connections)
	if (Connections.len > 1)
		Connections -= Connections[1]
		for (var/obj/cabling/C in Connections)
			if (C.Networks[C.type] != src)
				var/datum/UnifiedNetwork/OtherNetwork = C.Networks[C.type]
				Controller.BeginMerge(OtherNetwork)
				OtherNetwork.Controller.BeginMerge(src)

				for (var/obj/cabling/CC in OtherNetwork.Cables)
					OtherNetwork.Controller.RemoveCable(CC)
					CC.NetworkNumber[Cable.type] = NetworkNumber
					CC.Networks[Cable.type] = src
					OtherNetwork.Cables -= CC
					Cables += CC
					Controller.AddCable(CC)

				for (var/obj/M in OtherNetwork.Nodes)
					OtherNetwork.Controller.DetachNode(M)
					M.NetworkNumber[Cable.type] = NetworkNumber
					M.Networks[Cable.type] = src
					OtherNetwork.Nodes -= M
					Nodes += M
					Controller.AttachNode(M)

				Controller.FinishMerge()
				OtherNetwork.Controller.FinishMerge()
				OtherNetwork.Controller.Finalize()

				del OtherNetwork.Controller
				del OtherNetwork

	Controller.AddCable(Cable)
	Cable.NetworkNumber[Cable.type] = NetworkNumber
	Cable.Networks[Cable.type] = src

	return
