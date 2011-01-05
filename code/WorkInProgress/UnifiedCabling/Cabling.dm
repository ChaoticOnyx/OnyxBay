// =
// = The Unified (-Type-Tree) Cable Network System
// = Written by Sukasa with assistance from Googolplexed
// =
// = Cleans up the type tree and reduces future code maintenance
// = Also makes it easy to add new cable & network types
// =

// Unified Cable Network System - Generic Cable Class

/obj/cabling
	icon_state = "0-1"
	layer = 2.5
	level = 1
	anchored = 1

	var/Direction1 = 0
	var/Direction2 = 0
	var/list/ConnectableTypes = list( /obj/machinery )
	var/NetworkControllerType = /datum/UnifiedNetworkController
	var/DropCablePieceType = null
	var/EquivalentCableType = /obj/cabling


/obj/cabling/New(var/Location, var/NewDirection1 = -1, var/NewDirection2 = -1)

	if (!Location)
		return

	..(Location)

	var/Dash = findtext(icon_state, "-")

	Direction1 = text2num( copytext( icon_state, 1, Dash ) )
	Direction2 = text2num( copytext( icon_state, Dash + 1 ) )

	if (NewDirection1 != -1)
		Direction1 = NewDirection1

	if (NewDirection2 != -1)
		Direction2 = NewDirection2

	if(level == 1)
		var/turf/T = src.loc
		hide(T.intact)

	if (ticker)
		var/list/P = AllConnections(get_step_3d(Location, Direction1), 1) | AllConnections(get_step_3d(Location, Direction2), 1)

		if(locate(/obj/cabling) in P)
			var/obj/cabling/Cable = locate(/obj/cabling) in P
			var/datum/UnifiedNetwork/NewNetwork = Cable.Networks[Cable.EquivalentCableType]
			NewNetwork.CableBuilt(src, P)
		else
			var/datum/UnifiedNetwork/NewNetwork = CreateUnifiedNetwork(EquivalentCableType)
			NewNetwork.BuildFrom(src, NetworkControllerType)
	return


/obj/cabling/proc/UserTouched(var/mob/User)
		var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
		Network.Controller.CableTouched(src, User)


/obj/cabling/hide(var/intact)
	if(!istype(loc, /turf/space) && level == 1)
		invisibility = intact ? 101 : 0
	UpdateIcon()


/obj/cabling/proc/UpdateIcon()
	icon_state = "[Direction1]-[Direction2][invisibility?"-f":""]"
	return


/obj/cabling/Del()
	if (!defer_cables_rebuild)
		var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
		if (Network)
			Network.CutCable(src)
	else
		if(Debug)
			check_diary()
			diary << "Deferring U.C. deletion at \[[x], [y], [z]]: #[NetworkNumber]"
	..()


/obj/cabling/proc/CableConnections(var/turf/Target, var/IncludeAlreadyConnected = 0)
	var/list/Cables = list()
	var/Direction = get_dir_3d(Target, src)

	for(var/obj/cabling/Cable in Target)
		if ((!IncludeAlreadyConnected || !Cable.NetworkNumber[EquivalentCableType]) && Cable.EquivalentCableType == EquivalentCableType)
			if (Cable.Direction1 == Direction || Cable.Direction2 == Direction)
				Cables += Cable

	Cables -= src

	return Cables


/obj/cabling/proc/AllConnections(var/turf/Target, var/IncludeAlreadyConnected = 0)
	var/list/Connections = list( )
	var/Direction = get_dir_3d(Target, src)

	for(var/obj/cabling/Cable in Target)
		if ((IncludeAlreadyConnected || !Cable.NetworkNumber[EquivalentCableType]) && Cable.EquivalentCableType == EquivalentCableType)
			if (Cable.Direction1 == Direction || Cable.Direction2 == Direction)
				Connections += Cable

	Direction = reverse_dir_3d(Direction)

	for(var/obj/O in Target)
		if (istype(O, /obj/cabling))
			continue
		if ((IncludeAlreadyConnected || !O.NetworkNumber[EquivalentCableType]) && CanConnect(O))
			if (Direction == Direction1 || Direction == Direction2)
				Connections += O

	Connections -= src
	return Connections


/obj/cabling/proc/CanConnect(var/obj/ConnectTo)
	for(var/Type in ConnectableTypes)
		if(istype(ConnectTo, Type))
			return 1
		else
	return 0


/obj/cabling/attackby(var/obj/item/weapon/W, var/mob/User)
	var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
	add_fingerprint(User)

	var/turf/T = src.loc

	if(T.intact && level == 1)
		return

	if(istype(W, /obj/item/weapon/wirecutters))

		UserTouched(User)

		if (DropCablePieceType)
			DropCablePieces()

		for(var/mob/O in viewers(src, null))
			O.show_message("\red [User] disconnects the [name].", 1)

		Network.Controller.CableCut(src, User)

		del src

	else if(istype(W, /obj/item/weapon/CableCoil))
		var/obj/item/weapon/CableCoil/Coil = W

		Coil.JoinCable(src, User)

	else if(istype(W, /obj/item/device))

		Network.Controller.DeviceUsed(W, src, User)


/obj/cabling/proc/DropCablePieces()
	if (DropCablePieceType)
		new DropCablePieceType(loc, Direction1 ? 2 : 1)


/obj/cabling/ex_act(severity)
	switch(severity)
		if(1.0)
			var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
			Network.UnhandledExplosionDamage = 1
			del(src)
		if(2.0)
			if (prob(50))
				DropCablePieces()
				var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
				Network.UnhandledExplosionDamage = 1
				del(src)

		if(3.0)
			if (prob(25))
				DropCablePieces()
				var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
				Network.UnhandledExplosionDamage = 1
				del(src)
	return

/obj/cabling/proc/ObjectBuilt(var/obj/Object)
	var/Direction = get_dir_3d(src, Object)
	if (Direction1 != Direction && Direction2 != Direction)
		return
	if(CanConnect(Object))
	//	world << "Can Connect, adding"
		var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
		Network.AddNode(Object, src)

/obj/New()
	..()
	if (ticker)
		for(var/Direction in list(0) | cardinal8)
			for (var/obj/cabling/Cable in get_step(src, Direction))
				Cable.ObjectBuilt(src)
