/datum/UnifiedNetworkController/PowernetController
	var/Power = 0
	var/Draw = 0
	var/OldDraw = 0
	var/OldPower = 0
	var/PowerAvailableLastTick = 0
	var/PowerPerAPC = 0
	var/RecoveredSurplus = 0

/datum/UnifiedNetworkController/PowernetController/Process()
	PowerAvailableLastTick = Power - Draw

	//world << "PowerNet Controller: [PowerAvailableLastTick] Unused Power, [Draw] Draw, [Power] Total Supply"

	var/NumAPCs = 0

	for(var/obj/machinery/power/terminal/Terminal in Network.Nodes)
		if(istype(Terminal.master, /obj/machinery/power/apc))
			NumAPCs++

	if (NumAPCs)
		PowerPerAPC = Power / NumAPCs

	if (PowerAvailableLastTick >= 100)
		for(var/obj/machinery/power/smes/S in Network.Nodes)
			S.restore()

	OldPower = Power
	OldDraw = Draw
	Power = 0
	Draw = 0
	RecoveredSurplus = 0


	return

/datum/UnifiedNetworkController/PowernetController/BeginMerge(var/datum/UnifiedNetwork/TargetNetwork, var/Slave)
	var/datum/UnifiedNetworkController/PowernetController/Controller = TargetNetwork.Controller
	if (!Slave)
		Power += Controller.Power
		Draw += Controller.Draw
		PowerAvailableLastTick += Controller.PowerAvailableLastTick
	return

/datum/UnifiedNetworkController/PowernetController/DeviceUsed(var/obj/item/device/Device, var/obj/cabling/Cable, var/mob/User)

	switch(Device.type)
		if(/obj/item/device/multitool)
			User << "Power available: [src.Power]"
			User << "Power Draw     : [src.Draw]"

	return

/datum/UnifiedNetworkController/PowernetController/CableTouched(var/obj/cabling/Cable, var/mob/User)
	return

/datum/UnifiedNetworkController/PowernetController/proc/SupplyPower(var/Amount)
	Power += Amount
	return

/datum/UnifiedNetworkController/PowernetController/proc/DrawPower(var/Amount)
	Draw += Amount
	return

/datum/UnifiedNetworkController/PowernetController/proc/SurplusPower()
	return PowerAvailableLastTick

/datum/UnifiedNetworkController/PowernetController/proc/TotalSupply()
	return OldPower

/datum/UnifiedNetworkController/PowernetController/proc/UnrecoveredSurplusPower()
	return PowerAvailableLastTick - RecoveredSurplus

/datum/UnifiedNetworkController/PowernetController/proc/RecoverSurplusPower(var/Amount)
	RecoveredSurplus += Amount
	return

