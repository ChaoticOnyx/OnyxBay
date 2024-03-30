SUBSYSTEM_DEF(prometheus)
	name = "Prometheus"
	wait = 5 SECONDS
	priority = SS_PRIORITY_PROMETHEUS
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_ALL

/datum/controller/subsystem/prometheus/fire(resumed = 0)
	rustg_prom_gauge_float_set(PROM_MASTER_TICK_DRIFT, Master.tickdrift * 100, null)

	rustg_prom_gauge_int_set(PROM_TOTAL_PLAYERS, length(GLOB.player_list), null)

	for(var/datum/controller/subsystem/S in Master.subsystems)
		rustg_prom_gauge_float_set(PROM_SUBSYSTEM_TICK_OVERRUN, S.tick_overrun, list("name" = S.name))
		rustg_prom_gauge_float_set(PROM_SUBSYSTEM_TICKS_TO_RUN, S.ticks, list("name" = S.name))
		rustg_prom_gauge_float_set(PROM_SUBSYSTEM_TICK_USAGE, S.tick_usage, list("name" = S.name))
		rustg_prom_gauge_float_set(PROM_SUBSYSTEM_COST, S.cost / 1000, list("name" = S.name))
