#define START_PROCESSING_IN_LIST(Datum, List) \
if (Datum.is_processing) {\
	if(Datum.is_processing != "SSmachines.[#List]")\
	{\
		util_crash_with("Failed to start processing. [log_info_line(Datum)] is already being processed by [Datum.is_processing] but queue attempt occured on SSmachines.[#List]."); \
	}\
} else {\
	Datum.is_processing = "SSmachines.[#List]";\
	SSmachines.List += Datum;\
}

#define STOP_PROCESSING_IN_LIST(Datum, List) \
if(Datum.is_processing) {\
	if(SSmachines.List.Remove(Datum)) {\
		Datum.is_processing = null;\
	} else {\
		util_crash_with("Failed to stop processing. [log_info_line(Datum)] is being processed by [is_processing] and not found in SSmachines.[#List]"); \
	}\
}

#define SSMACHINES_DEFERREDPOWERNETS 1
#define SSMACHINES_POWERNETS 2
#define SSMACHINES_PREMACHINERY 3
#define SSMACHINES_MACHINERY 4

#define START_PROCESSING_PIPENET(Datum) START_PROCESSING_IN_LIST(Datum, pipenets)
#define STOP_PROCESSING_PIPENET(Datum) STOP_PROCESSING_IN_LIST(Datum, pipenets)

#define START_PROCESSING_POWERNET(Datum) START_PROCESSING_IN_LIST(Datum, powernets)
#define STOP_PROCESSING_POWERNET(Datum) STOP_PROCESSING_IN_LIST(Datum, powernets)

#define START_PROCESSING_POWER_OBJECT(Datum) START_PROCESSING_IN_LIST(Datum, power_objects)
#define STOP_PROCESSING_POWER_OBJECT(Datum) STOP_PROCESSING_IN_LIST(Datum, power_objects)

SUBSYSTEM_DEF(machines)
/datum/controller/subsystem/machines
	name = "Machines"

	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_MACHINERY

	flags = SS_KEEP_TIMING

	var/list/processing = list()
	var/list/currentrun = list()
	var/list/powernets = list()
	var/list/deferred_powernet_rebuilds = list()

	var/currentpart = SSMACHINES_DEFERREDPOWERNETS

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	..()

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()
	setup_powernets_for_cables(cable_list)

/datum/controller/subsystem/machines/proc/setup_powernets_for_cables(list/cables)
	for(var/obj/structure/cable/PC in cables)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)


/datum/controller/subsystem/machines/stat_entry()
	var/msg = list()
	msg += "M:[processing.len]|"
	msg += "PN:[powernets.len]"
	..(jointext(msg, null))

/datum/controller/subsystem/machines/proc/process_defered_powernets(resumed = 0)
	if(!resumed)
		src.currentrun = deferred_powernet_rebuilds.Copy()
	//cache for sanid speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/O = currentrun[currentrun.len]
		currentrun.len--
		if(O && !QDELETED(O))
			var/datum/powernet/newPN = new() // create a new powernet...
			propagate_network(O, newPN)//... and propagate it to the other side of the cable
		deferred_powernet_rebuilds.Remove(O)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/process_powernets(resumed = 0)
	if(!resumed)
		src.currentrun = powernets.Copy()
	//cache for sanid speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/powernet/P = currentrun[currentrun.len]
		currentrun.len--
		if(P)
			P.reset() // reset the power state
		else
			powernets.Remove(P)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/process_machines(resumed = 0)
	var/seconds = wait * 0.1
	if(!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/thing = currentrun[currentrun.len]
		currentrun.len--
		if(!QDELETED(thing) && thing.Process(seconds) != PROCESS_KILL)
			if(thing.use_power)
				thing.auto_use_power() //add back the power state
		else
			processing -= thing
			if(!QDELETED(thing))
				thing.is_processing = FALSE
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/fire(resumed = 0)
	if(currentpart == SSMACHINES_DEFERREDPOWERNETS || !resumed)
		process_defered_powernets(resumed)
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSMACHINES_POWERNETS

	if(currentpart == SSMACHINES_POWERNETS || !resumed)
		process_powernets(resumed)
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSMACHINES_MACHINERY
	if(currentpart == SSMACHINES_MACHINERY || !resumed)
		process_machines(resumed)
		if(state != SS_RUNNING)
			return
		resumed = 0
	currentpart = SSMACHINES_DEFERREDPOWERNETS

/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	for(var/A in cables)
		var/obj/structure/cable/PC = A
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/Recover()
	if (istype(SSmachines.processing))
		processing = SSmachines.processing
	if (istype(SSmachines.powernets))
		powernets = SSmachines.powernets
