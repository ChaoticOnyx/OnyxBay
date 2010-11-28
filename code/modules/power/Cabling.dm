/obj/cabling/power
	icon = 'power_cond.dmi'

	ConnectableTypes = list( /obj/machinery/power, /obj/grille )
	NetworkControllerType = /datum/UnifiedNetworkController/PowernetController
	DropCablePieceType = /obj/item/weapon/CableCoil/power
	EquivalentCableType = /obj/cabling/power

/obj/item/weapon/CableCoil/power
	icon_state = "redcoil3"
	CoilColour = "red"
	BaseName  = "Electrical"
	ShortDesc = "A piece of electrical cable"
	LongDesc  = "A long piece of electrical cable"
	CoilDesc  = "A Spool of electrical cable"
	CableType = /obj/cabling/power