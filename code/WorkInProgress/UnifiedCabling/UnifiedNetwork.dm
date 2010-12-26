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
	var/datum/UnifiedNetworkController/Controller 	= null
	var/UnhandledExplosionDamage 					= 0
	var/NetworkNumber 								= 0
	var/list/Nodes 									= list( )
	var/list/Cables 								= list( )


/datum/UnifiedNetwork/proc/CutCable(var/obj/cabling/Cable)

	var/list/ConnectedCables = Cable.CableConnections(get_step_3d(Cable, Cable.Direction1)) | Cable.CableConnections(get_step_3d(Cable, Cable.Direction2))

	Controller.RemoveCable(Cable)

	if(!ConnectedCables.len)
		Cables -= Cable
		if (!Cables.len)
			for(var/obj/Node in Nodes)
				if(!Node.NetworkNumber)
					Controller.DetachNode(Node)
					Node.Networks[Cable.EquivalentCableType] = null
					Node.NetworkNumber[Cable.EquivalentCableType] = 0

			Controller.Finalize()
			del Controller
			del src

		return

	for(var/obj/C in Cables)
		C.NetworkNumber[Cable.EquivalentCableType] = 0
	for(var/obj/N in Nodes)
		N.NetworkNumber[Cable.EquivalentCableType] = 0

	Cable.loc = null
	Cables -= Cable

	PropagateNetwork(ConnectedCables[1], NetworkNumber)

	ConnectedCables -= ConnectedCables[1]

	for(var/obj/cabling/O in ConnectedCables)
		if(O.NetworkNumber[Cable.EquivalentCableType] == 0)

			var/datum/UnifiedNetwork/NewNetwork = CreateUnifiedNetwork(Cable.EquivalentCableType)

			PropagateNetwork(O, NewNetwork.NetworkNumber)

			Controller.StartSplit(NewNetwork)

			for(var/obj/cabling/C in Cables)
				if(!C.NetworkNumber[Cable.EquivalentCableType])
					NewNetwork.AddCable(C)

			for(var/obj/Node in Nodes)
				if(!Node.NetworkNumber[Cable.EquivalentCableType])
					NewNetwork.AddNode(Node)

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

	var/list/Connections   = list( )
	var/list/Possibilities = list(Start)

	while (Possibilities.len)
		for (var/obj/cabling/Cable in Possibilities.Copy())
			Possibilities |= Cable.AllConnections(get_step_3d(Cable, Cable.Direction1))
			Possibilities |= Cable.AllConnections(get_step_3d(Cable, Cable.Direction2))

		for (var/obj/Component in Possibilities.Copy())
			if (Component.NetworkNumber[Start.EquivalentCableType] != NewNetworkNumber)
				Component.NetworkNumber[Start.EquivalentCableType] = NewNetworkNumber
				Component.Networks[Start.EquivalentCableType] = src
				Connections += Component
				if (!istype(Component, /obj/cabling))
					Possibilities -= Component
			else
				Possibilities -= Component

	world.log << "Created Unified Network (Type [Start.EquivalentCableType]) with [Connections.len] Components from [Start.x], [Start.y], [Start.z]"
	return Connections

/datum/UnifiedNetwork/proc/AddNode(var/obj/NewNode, var/obj/cabling/Cable)
	//world << "Adding [NewNode.name] to \[[Cable.EquivalentCableType]\] Network [NetworkNumber]"
	var/datum/UnifiedNetwork/CurrentNetwork = NewNode.Networks[Cable.EquivalentCableType]

	if (CurrentNetwork == src)
		return

	if (CurrentNetwork)
		CurrentNetwork.Controller.DetachNode(NewNode)

	NewNode.NetworkNumber[Cable.EquivalentCableType] = NetworkNumber
	NewNode.Networks[Cable.EquivalentCableType] = src

	if (CurrentNetwork)
		CurrentNetwork.Nodes -= NewNode

	Nodes += NewNode
	Controller.AttachNode(NewNode)
	return

/datum/UnifiedNetwork/proc/AddCable(var/obj/cabling/Cable)

	var/datum/UnifiedNetwork/CurrentNetwork = Cable.Networks[Cable.EquivalentCableType]
	if (CurrentNetwork == src)
		return

	if (CurrentNetwork)
		CurrentNetwork.Controller.RemoveCable(Cable)
	Cable.NetworkNumber[Cable.EquivalentCableType] = NetworkNumber
	Cable.Networks[Cable.EquivalentCableType] = src
	if (CurrentNetwork)
		CurrentNetwork.Cables -= Cable
	Cables += Cable
	Controller.AddCable(Cable)
	return

/datum/UnifiedNetwork/proc/CableBuilt(var/obj/cabling/Cable, var/list/Connections)
	var/list/MergeCables = list()

	for(var/obj/cabling/C in Connections)
		MergeCables += C

	for (var/obj/cabling/C in MergeCables)
		if (C.Networks[C.EquivalentCableType] != src)
			var/datum/UnifiedNetwork/OtherNetwork = C.Networks[C.EquivalentCableType]
			Controller.BeginMerge(OtherNetwork, 0)
			OtherNetwork.Controller.BeginMerge(src, 1)

			for (var/obj/cabling/CC in OtherNetwork.Cables)
				AddCable(CC)

			for (var/obj/M in OtherNetwork.Nodes)
				AddNode(M)

			Controller.FinishMerge()
			OtherNetwork.Controller.FinishMerge()
			OtherNetwork.Controller.Finalize()

			del OtherNetwork.Controller
			del OtherNetwork

	for(var/obj/Object in Connections - MergeCables)
		AddNode(Object)

	Controller.AddCable(Cable)
	Cable.NetworkNumber[Cable.EquivalentCableType] = NetworkNumber
	Cable.Networks[Cable.EquivalentCableType] = src

	return
