/obj/item/mcu_module/mining_block
	name = "mining block module"
	desc = "A mining block module"
	icon_state = "mining_block"

	device_type = Z_DEVICE_TYPE_MINING_BLOCK
	power_usage = 10

/obj/item/mcu_module/mining_block/cargo/proc/on_new_args(list/new_args)
	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_MINING_BLOCK_B2N_CMD_SET_ARGS, new_args[1], new_args[2], new_args[3], new_args[4]) == TRUE)

/obj/item/mcu_module/mining_block/cargo/__syscall(cmd, ...)
	switch(cmd)
		if(Z_MINING_BLOCK_N2B_CMD_FOUND)
			var/reward = SSmining.on_block_found()
			SSsupply.add_points_from_source(reward, "mining")

			return TRUE

	return FALSE

/obj/item/mcu_module/mining_block/cargo/__reset(attached)
	if(!attached)
		unregister_global_signal(SIGNAL_CARGO_MINING_NEW_ARGS)
		
		return

	register_global_signal(SIGNAL_CARGO_MINING_NEW_ARGS, nameof(.proc/on_new_args))

	var/list/cargo_args = SSmining.cargo_args

	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_MINING_BLOCK_B2N_CMD_SET_ARGS, cargo_args[1], cargo_args[2], cargo_args[3], cargo_args[4]) == TRUE)
