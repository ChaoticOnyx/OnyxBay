/obj/item/mcu_module/vga
	name = "monochrome display module"
	desc = "A monochrome display module for displaying text and graphics, has an embedded keyboard and a mouse."

	icon_state = "vga"

	device_type = Z_DEVICE_TYPE_VGA
	power_usage = 5

	var/supports_color = FALSE
	var/__width = 320
	var/__height = 240

/obj/item/mcu_module/vga/__interact(mob/user)
	attack_self(user)
	return TRUE

/obj/item/mcu_module/vga/attack_self(mob/user)
	tgui_interact(user)

/obj/item/mcu_module/vga/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Vga", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/item/mcu_module/vga/tgui_static_data(mob/user)
	var/list/data = list(
		"width" = __width,
		"height" = __height,
		"supports_color" = supports_color,
		"max_messages_per_sec" = config.ws.rate_limit_messages_per_sec,
	)

	return data

/obj/item/mcu_module/vga/tgui_act(action, params)
	. = ..()

	if(.)
		return TRUE

	var/obj/item/device/mcu/M = __host?.resolve()
	if(M == null || !M.is_on())
		return FALSE

	switch(action)
		if("key")
			var/t = params["t"]
			var/sc = params["sc"]
			var/mod = params["mod"]

			if(!isnum(t) || !isnum(sc) || !isnum(mod))
				return FALSE

			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_VGA_B2N_CMD_KEYBOARD_EVENT, t, sc, mod) == TRUE)

			return TRUE
		if("mouse")
			var/t = params["t"]
			var/b = params["b"]
			var/dx = params["dx"]
			var/dy = params["dy"]
			var/sdx = params["sdx"]
			var/sdy = params["sdy"]

			if(!isnum(t) || !isnum(b) || !isnum(dx) || !isnum(dy) || !isnum(sdx) || !isnum(sdy))
				return FALSE

			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_VGA_B2N_CMD_MOUSE_EVENT, t, b, dx, dy, sdx, sdy) == TRUE)

			return TRUE

	return FALSE

/obj/item/mcu_module/vga/__syscall(cmd, ...)
	var/obj/item/device/mcu/M = __host.resolve()

	switch(cmd)
		if(Z_VGA_N2B_CMD_VBLANK)
			var/list/uis = SStgui.get_all_open_uis(src)
			
			for(var/datum/tgui/ui in uis)
				var/conn_id = ui.window?.get_connection()
				if(isnull(conn_id))
					continue
				
				ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_VGA_B2N_CMD_SEND_SCREEN, conn_id))
			
			return TRUE

		if(Z_VGA_N2B_CMD_SET_RESOLUTION)
			__width = args[2]
			__height = args[3]

			var/new_data = list(
				"width" = __width,
				"height" = __height,
				"supports_color" = supports_color,
				"max_messages_per_sec" = config.ws.rate_limit_messages_per_sec,
			)

			var/list/uis = SStgui.get_all_open_uis(src)
			for(var/datum/tgui/ui in uis)
				ui.send_update(new_data)

			return TRUE

	return FALSE

/obj/item/mcu_module/vga/truecolor
	name = "TrueColor display module"
	desc = "A TrueColor display module for displaying fancy graphics, has an embedded keyboard and a mouse."

	supports_color = TRUE
	power_usage = 10
