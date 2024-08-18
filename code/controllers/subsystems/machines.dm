#define SSMACHINES_PIPENETS 1
#define SSMACHINES_MACHINERY 2
#define SSMACHINES_POWERNETS 3

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

#define START_PROCESSING_PIPENET(Datum) START_PROCESSING_IN_LIST(Datum, pipenets)
#define STOP_PROCESSING_PIPENET(Datum) STOP_PROCESSING_IN_LIST(Datum, pipenets)

#define START_PROCESSING_POWERNET(Datum) START_PROCESSING_IN_LIST(Datum, powernets)
#define STOP_PROCESSING_POWERNET(Datum) STOP_PROCESSING_IN_LIST(Datum, powernets)

SUBSYSTEM_DEF(machines)
	name = "Machines"
	wait = 3 SECONDS

	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_MACHINERY

	flags = SS_KEEP_TIMING

	var/static/current_step = SSMACHINES_PIPENETS
	var/static/cost_pipenets = 0
	var/static/cost_machinery = 0
	var/static/cost_powernets = 0

	var/static/list/pipenets = list()
	var/static/list/machinery = list()
	var/static/list/powernets = list()

	var/static/list/processing = list()
	var/static/list/queue = list()

/datum/controller/subsystem/machines/Recover()
	current_step = SSMACHINES_PIPENETS
	queue.Cut()


/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	setup_atmos_machinery(machinery)
	fire(FALSE, TRUE)
	..()


/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()
	setup_powernets_for_cables(cable_list)


/datum/controller/subsystem/machines/proc/setup_powernets_for_cables(list/cables)
	for(var/obj/structure/cable/cable in cables)
		if(cable.powernet)
			continue
		var/datum/powernet/network = new
		network.add_cable(cable)
		propagate_network(cable, cable.powernet)


/datum/controller/subsystem/machines/proc/setup_atmos_machinery(list/machines)
	set background = TRUE
	var/list/atmos_machines = list()
	for(var/obj/machinery/atmospherics/machine in machines)
		atmos_machines += machine
	for(var/obj/machinery/atmospherics/machine as anything in atmos_machines)
		machine.atmos_init()
		CHECK_TICK
	for(var/obj/machinery/atmospherics/machine as anything in atmos_machines)
		machine.build_network()
		CHECK_TICK


/datum/controller/subsystem/machines/stat_entry()
	var/msg = "M:[processing.len] | PN:[powernets.len]"
	..(msg)


/datum/controller/subsystem/machines/fire(resumed, no_mc_tick)
	var/timer
	if(!resumed)
		current_step = SSMACHINES_PIPENETS

	if(current_step == SSMACHINES_PIPENETS)
		timer = world.tick_usage
		process_pipenets(resumed, no_mc_tick)
		cost_pipenets = MC_AVERAGE(cost_pipenets, (world.tick_usage - timer) * world.tick_lag)
		if(state != SS_RUNNING)
			return
		current_step = SSMACHINES_MACHINERY
		resumed = FALSE

	if(current_step == SSMACHINES_MACHINERY)
		timer = world.tick_usage
		process_machinery(resumed, no_mc_tick)
		cost_machinery = MC_AVERAGE(cost_machinery, (world.tick_usage - timer) * world.tick_lag)
		if(state != SS_RUNNING)
			return
		current_step = SSMACHINES_POWERNETS
		resumed = FALSE

	if(current_step == SSMACHINES_POWERNETS)
		timer = world.tick_usage
		process_powernets(resumed, no_mc_tick)
		cost_powernets = MC_AVERAGE(cost_powernets, (world.tick_usage - timer) * world.tick_lag)
		if(state != SS_RUNNING)
			return
		current_step = SSMACHINES_PIPENETS


/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	for(var/A in cables)
		var/obj/structure/cable/PC = A
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)


/datum/controller/subsystem/machines/proc/process_pipenets(resumed, no_mc_tick)
	if(!resumed)
		queue = pipenets.Copy()
	var/datum/pipe_network/network
	for(var/i = length(queue) to 1 step -1)
		network = queue[i]
		if(QDELETED(network))
			network?.is_processing = null
			pipenets -= network
			continue

		network.Process(wait)

		if(no_mc_tick)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			queue.Cut(i)
			return


/datum/controller/subsystem/machines/proc/process_machinery(resumed, no_mc_tick)
	if(!resumed)
		queue = processing.Copy()
	var/obj/machinery/machine
	for(var/i = length(queue) to 1 step -1)
		machine = queue[i]
		if(QDELETED(machine))
			machine?.is_processing = null
			processing -= machine
			continue

		if(machine.Process(wait) == PROCESS_KILL)
			STOP_PROCESSING(src, machine)

		if(no_mc_tick)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			queue.Cut(i)
			return


/datum/controller/subsystem/machines/proc/process_powernets(resumed, no_mc_tick)
	if(!resumed)
		queue = powernets.Copy()
	var/datum/powernet/network
	for(var/i = length(queue) to 1 step -1)
		network = queue[i]
		if(QDELETED(network))
			network?.is_processing = null
			powernets -= network
			continue

		network.reset(wait)

		if(no_mc_tick)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			queue.Cut(i)
			return

/datum/controller/subsystem/machines/proc/flicker_all_lights()
	for(var/obj/machinery/light/L in machinery)
		if(!(L.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			continue

		if(!prob(95))
			continue

		L.flicker(rand(2, 5))
