// =
// = The Unified (-Type-Tree) Cable Network System
// = Written by Sukasa with assistance from Googolplexed
// =
// = Cleans up the type tree and reduces future code maintenance
// = Also makes it easy to add new cable & network types
// =

// Unified Cable Network System - Master Network Construction Functions

/proc/MakeUnifiedNetworks() //Stick this in your pipe and smoke it, Exadv1!
	for (var/obj/cabling/Cable in world)
		if (!Cable.Networks[Cable.type])
			var/datum/UnifiedNetwork/NewNetwork = CreateUnifiedNetwork(Cable.type)
			NewNetwork.BuildFrom(Cable, Cable.NetworkControllerType)

/proc/HandleUNExplosionDamage()
	//TODO