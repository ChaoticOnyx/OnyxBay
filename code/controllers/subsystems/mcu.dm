#define MCU_TMP_FOLDER "data/mcu"

SUBSYSTEM_DEF(mcu)
	name = "MCU"
	priority = SS_PRIORITY_MCU
	flags = SS_NO_FIRE

	var/last_fire_time = 0
	var/total_running = 0
	var/total_mcu = 0

/datum/controller/subsystem/mcu/Initialize()
	for(var/F in flist("[MCU_TMP_FOLDER]/elf/"))
		fdel("[MCU_TMP_FOLDER]/elf/[F]")

	last_fire_time = world.time
	loop()

	. = ..()

/datum/controller/subsystem/mcu/stat_entry()
	var/list/stats = json_decode(Z_MACHINES_STATS())

	// LW  - Last Wall: real host time spent in last tick (microseconds)
	//        WARNING if consistently > LB
	// LB  - Last Budget: max allowed host time for last tick (microseconds)
	//        = delta_us * BUDGET_PERCENT / 100
	// LOAD - Load Average: exponential moving average of (LW / LB)
	//        < 0.3  = idle, plenty of headroom
	//        0.3-0.7 = healthy
	//        0.7-0.9 = heavy, close to saturation
	//        > 0.9  = critical, machines are starving
	var/msg = "LW:[stats["last_wall_us"]]us "
	msg += "LB:[stats["last_budget_us"]]us "
	msg += "LOAD:[stats["load_avg"]] "
	msg += "TR:[total_running] "
	msg += "TM:[total_mcu]"

	..(msg)

/datum/controller/subsystem/mcu/proc/loop()
	set waitfor = FALSE

	while(src != null)
		if(!config.mcu.enable)
			sleep(world.tick_lag)
			continue

		var/delta_ds = world.time - last_fire_time
		last_fire_time = world.time

		if(delta_ds <= 0)
			sleep(world.tick_lag)
			continue

		Z_MACHINES_SET_BUDGET(config.mcu.budget_percent)
		var/delta_us = delta_ds * 100000
		Z_MACHINES_TICK(delta_us)

		sleep(world.tick_lag)
