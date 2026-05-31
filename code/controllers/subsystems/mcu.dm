SUBSYSTEM_DEF(mcu)
	name = "MCU"
	priority = SS_PRIORITY_MCU
	flags = SS_NO_FIRE

	var/total_running = 0
	var/total_mcu = 0

/datum/controller/subsystem/mcu/stat_entry()
	var/msg = "TR:[total_running] "
	msg += "TM:[total_mcu]"

	..(msg)
