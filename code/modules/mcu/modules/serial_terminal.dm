#define MCU_SERIAL_TERMINAL_RX_BUFFER_SIZE 1024
#define MCU_SERIAL_TERMINAL_HISTORY_SIZE 2048


/obj/item/mcu_module/serial_terminal
	name = "serial terminal module"
	desc = "A serial terminal interface for MCU debugging and interaction."
	icon_state = "serial_terminal"

	device_type = Z_DEVICE_TYPE_SERIAL_TERMINAL

	var/list/buffer = list()
	var/buffer_start = 0
	var/raw_mode = FALSE

/obj/item/mcu_module/serial_terminal/__interact(mob/user)
	attack_self(user)
	return TRUE

/obj/item/mcu_module/serial_terminal/attack_self(mob/user)
	tgui_interact(user)

/obj/item/mcu_module/serial_terminal/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SerialTerminal", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/item/mcu_module/serial_terminal/tgui_data(mob/user)
	var/list/data = list()

	data["buffer"] = buffer
	data["bufferStart"] = buffer_start
	data["maxInputBytes"] = MCU_SERIAL_TERMINAL_RX_BUFFER_SIZE
	data["isActive"] = __host != null && __host.resolve().is_on()
	data["rawMode"] = raw_mode

	return data

/obj/item/mcu_module/serial_terminal/tgui_act(action, params)
	. = ..()

	if(.)
		return TRUE

	switch(action)
		if("send")
			var/obj/item/device/mcu/M = __host?.resolve()
			if(M == null || !M.is_on())
				return FALSE

			var/list/bytes = params["bytes"]

			if(!islist(bytes) || !length(bytes))
				return FALSE

			var/list/valid_bytes = list()

			for(var/i = 1 to length(bytes))
				var/byte = bytes[i]

				if(isnum(byte) && byte >= 0 && byte <= 255)
					valid_bytes += round(byte)

			if(!length(valid_bytes))
				return FALSE

			if(length(valid_bytes) > MCU_SERIAL_TERMINAL_RX_BUFFER_SIZE)
				valid_bytes.Cut(MCU_SERIAL_TERMINAL_RX_BUFFER_SIZE + 1)

			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_SERIAL_B2N_CMD_WRITE, valid_bytes) == TRUE)

			// In line mode, echo the sent bytes locally.
			// In raw mode, the application controls all output — no local echo.
			if(!raw_mode)
				__append_bytes(valid_bytes)

			return TRUE

	return FALSE

/obj/item/mcu_module/serial_terminal/proc/__append_bytes(list/bytes)
	buffer += bytes

	if(length(buffer) > MCU_SERIAL_TERMINAL_HISTORY_SIZE)
		var/to_cut = length(buffer) - MCU_SERIAL_TERMINAL_HISTORY_SIZE
		buffer.Cut(1, to_cut + 1)
		buffer_start += to_cut

/obj/item/mcu_module/serial_terminal/__syscall(cmd, ...)
	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_APPEND_COUNTERS(M.id, 0, 1000, 0))

	switch(cmd)
		if(Z_SERIAL_N2B_CMD_WRITE)
			var/list/bytes = args[2]
			__append_bytes(bytes)
			SStgui.update_uis(src)

			return TRUE

		if(Z_SERIAL_N2B_CMD_SET_RAW_MODE)
			raw_mode = args[2]

			return TRUE

	return FALSE

/obj/item/mcu_module/serial_terminal/__reset(attached)
	if(attached)
		buffer = list()
		buffer_start = 0
		raw_mode = FALSE

#undef MCU_SERIAL_TERMINAL_RX_BUFFER_SIZE
#undef MCU_SERIAL_TERMINAL_HISTORY_SIZE
#undef Z_SERIAL_N2B_CMD_SET_RAW_MODE
