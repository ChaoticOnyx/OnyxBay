// =
// = The Unified (-Type-Tree) Cable Network System
// = Written by Sukasa with assistance from Googolplexed
// =
// = Cleans up the type tree and reduces future code maintenance
// = Also makes it easy to add new cable & network types
// =

// Unified Cable Network System - Base Network Controller Class

/datum/UnifiedNetworkController
	var/datum/UnifiedNetwork/Network = null

	New(var/datum/UnifiedNetwork/NewNetwork)
		..()
		Network = NewNetwork

	proc

		AttachNode(var/obj/Node)
			return

		DetachNode(var/obj/Node)
			return

		AddCable(var/obj/cabling/Cable)
			return

		RemoveCable(var/obj/cabling/Cable)
			return

		StartSplit(var/datum/UnifiedNetwork/NewNetwork)
			return

		FinishSplit(var/datum/UnifiedNetwork/NewNetwork)
			return

		CableCut(var/obj/cabling/Cable)
			return

		Initialize()
			return

		BeginMerge(var/datum/UnifiedNetwork/TargetNetwork)
			return

		FinishMerge()
			return