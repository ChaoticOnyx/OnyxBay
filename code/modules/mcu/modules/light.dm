/obj/item/mcu_module/light
	name = "light module"
	desc = "A light module"
	icon_state = "light"

	device_type = Z_DEVICE_TYPE_LIGHT

/obj/item/mcu_module/light/think()
	var/obj/item/device/mcu/M = __host.resolve()

	if(QDELETED(M))
		return

	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_LIGHT_B2N_CMD_READY_STATUS, TRUE) == TRUE)

	return

/obj/item/mcu_module/light/proc/__update_light(hex, brightness)
	set_light(1, brightness / 4, brightness, 2, hex)
	power_usage = brightness ? brightness * 2 : 0

/obj/item/mcu_module/light/__power_off()
	set_light(0)
	power_usage = 0

/obj/item/mcu_module/light/__syscall(cmd, ...)
	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_APPEND_COUNTERS(M.id, 0, 1000, 0))

	switch(cmd)
		if(Z_LIGHT_N2B_CMD_SET)
			var/hex = args[2]
			var/brightness = args[3]

			__update_light(hex, brightness)

			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_LIGHT_B2N_CMD_READY_STATUS, FALSE) == TRUE)
			set_next_think(world.time + config.mcu.light_cooldown)

			return TRUE

	return FALSE

/obj/item/mcu_module/light/__reset(attached)
	set_next_think(0)
	__power_off()

	if(!attached)
		return

	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_LIGHT_B2N_CMD_READY_STATUS, TRUE) == TRUE)
