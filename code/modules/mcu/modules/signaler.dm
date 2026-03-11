
/obj/item/mcu_module/signaler
	name = "signaler module"
	desc = "A signaler module for a MCU."
	icon_state = "signaler"

	device_type = Z_DEVICE_TYPE_SIGNALER

	var/datum/frequency/__radio_connection = null
	var/__code = 30

/obj/item/mcu_module/signaler/Destroy()
	if(__radio_connection != null)
		SSradio.remove_object(src, __radio_connection.frequency)

	. = ..()

/obj/item/mcu_module/signaler/receive_signal(datum/signal/signal)
	if(signal == null || __radio_connection == null || __host == null)
		return

	if(signal.encryption != __code)
		return

	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_SIGNALER_B2N_CMD_PULSE) == TRUE)

/obj/item/mcu_module/signaler/__syscall(cmd, ...)
	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_APPEND_COUNTERS(M.id, 0, 1000, 0))

	switch(cmd)
		if(Z_SIGNALER_N2B_CMD_SET)
			if(!SSradio)
				return FALSE
			
			var/frequency = args[2]
			var/code = args[3]

			if(frequency < RADIO_LOW_FREQ || frequency > RADIO_HIGH_FREQ)
				return FALSE

			if(code < 1 || code > 100)
				return FALSE

			if(__radio_connection != null)
				SSradio.remove_object(src, frequency)
			
			__radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)
			__code = code

			set_next_think(world.time + config.mcu.signaler_set_cooldown)
			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_SIGNALER_B2N_CMD_READY_STATUS, FALSE) == TRUE)

			return TRUE
		if(Z_SIGNALER_N2B_CMD_SEND)
			if(__radio_connection == null)
				return FALSE

			playsound(src.loc, 'sound/signals/signaler.ogg', 35)

			var/datum/signal/signal = new(list("message" = "ACTIVATE"), encryption = __code)
			__radio_connection.post_signal(src, signal)

			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_SIGNALER_B2N_CMD_READY_STATUS, FALSE) == TRUE)
			set_next_think(world.time + config.mcu.signaler_send_cooldown)

			return TRUE

	return FALSE

/obj/item/mcu_module/signaler/think()
	var/obj/item/device/mcu/M = __host.resolve()

	if(QDELETED(M))
		return

	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_SIGNALER_B2N_CMD_READY_STATUS, TRUE) == TRUE)

	return

/obj/item/mcu_module/signaler/__reset(attached)
	set_next_think(0)

	if(!attached)
		return

	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_SIGNALER_B2N_CMD_READY_STATUS, TRUE) == TRUE)
