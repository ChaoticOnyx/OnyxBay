SUBSYSTEM_DEF(prometheus)
	name = "Prometheus"
	wait = 10 SECONDS
	priority = SS_PRIORITY_PROMETHEUS
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_ALL

/datum/controller/subsystem/prometheus/fire(resumed = 0)
	if(!config.general.prometheus_port)
		return

	// Master
	rustg_prom_gauge_float_set(PROM_MASTER_TICK_DRIFT, (Master.tickdrift / (world.time / world.tick_lag)) * 100, null)

	// Players
	rustg_prom_gauge_int_set(PROM_TOTAL_PLAYERS, length(GLOB.player_list), null)

	// Subsystems
	for(var/datum/controller/subsystem/S in Master.subsystems)
		rustg_prom_gauge_float_set(PROM_SUBSYSTEM_TICK_OVERRUN, S.tick_overrun, list("name" = S.name))
		rustg_prom_gauge_float_set(PROM_SUBSYSTEM_TICKS_TO_RUN, S.ticks, list("name" = S.name))
		rustg_prom_gauge_float_set(PROM_SUBSYSTEM_TICK_USAGE, S.tick_usage, list("name" = S.name))
		rustg_prom_gauge_float_set(PROM_SUBSYSTEM_COST, S.cost / 1000, list("name" = S.name))

	// GC
	var/total_gc = 0

	for(var/list/L in SSgarbage.queues)
		total_gc += length(L)

	rustg_prom_gauge_int_set(PROM_GC_QUEUED, total_gc, null)

	// Mobs
	rustg_prom_gauge_int_set(PROM_MOBS_TOTAL, length(SSmobs.mob_list), null)

	for(var/K in SSmobs.mob_types)
		rustg_prom_gauge_int_set(PROM_MOBS_INSTANCE_TOTAL, SSmobs.mob_types[K], list("name" = K))
