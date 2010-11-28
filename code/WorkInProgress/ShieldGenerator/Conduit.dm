/obj/cabling/shield
	icon = 'shield_cable.dmi'

	ConnectableTypes = list( /obj/machinery/shielding )
	NetworkControllerType = /datum/UnifiedNetworkController/ShieldingNetworkController
	DropCablePieceType = /obj/item/weapon/CableCoil/shield
	EquivalentCableType = /obj/cabling/shield

/obj/item/weapon/CableCoil/shield
	icon_state = "bluecoil3"
	CoilColour = "blue"
	BaseName  = "Shielding"
	ShortDesc = "A piece of specialized low-capacitance shielding cable"
	LongDesc  = "A long piece of specialized low-capacitance shielding cable"
	CoilDesc  = "A Spool of specialized low-capacitance shielding cable"
	CableType = /obj/cabling/shield