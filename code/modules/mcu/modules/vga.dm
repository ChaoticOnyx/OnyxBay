/obj/item/mcu_module/vga
	name = "monochrome display module"
	desc = "A monochrome display module for displaying text and graphics, has an embedded keyboard and a mouse."

	icon_state = "vga"

	device_type = Z_DEVICE_TYPE_VGA

	/// Base power at minimum resolution. W
	var/base_power = 8
	/// Additional power at maximum resolution (640x480). W
	var/max_resolution_power = 16
	/// Calculated total power usage. W
	power_usage = 1

	var/supports_color = FALSE
	var/__width = Z_VGA_MIN_WIDTH
	var/__height = Z_VGA_MIN_HEIGHT

/obj/item/mcu_module/vga/Initialize()
	. = ..()

	__update_power_usage()

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
		"turned_on" = FALSE,
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
			var/new_data = list(
				"width" = __width,
				"height" = __height,
				"supports_color" = supports_color,
				"max_messages_per_sec" = config.ws.rate_limit_messages_per_sec,
				"turned_on" = TRUE,
			)
			var/list/uis = SStgui.get_all_open_uis(src)
			
			for(var/datum/tgui/ui in uis)
				var/conn_id = ui.window?.get_connection()
				if(isnull(conn_id))
					continue
				
				ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_VGA_B2N_CMD_SEND_SCREEN, conn_id))
				ui.send_update(new_data)

			return TRUE
		if(Z_VGA_N2B_CMD_SET_RESOLUTION)
			__width = args[2]
			__height = args[3]
			__update_power_usage()

			var/new_data = list(
				"width" = __width,
				"height" = __height,
				"supports_color" = supports_color,
				"max_messages_per_sec" = config.ws.rate_limit_messages_per_sec,
				"turned_on" = TRUE,
			)

			var/list/uis = SStgui.get_all_open_uis(src)
			for(var/datum/tgui/ui in uis)
				ui.send_update(new_data)

			return TRUE

	return FALSE

/obj/item/mcu_module/vga/proc/__update_power_usage()
	// P = base + (max_additional) * (current_pixels / max_pixels)
	var/current_pixels = __width * __height
	var/pixel_ratio = current_pixels / Z_VGA_MAX_PIXELS
	
	power_usage = base_power + max_resolution_power * pixel_ratio

/obj/item/mcu_module/vga/__power_off()
	__on_off()

/obj/item/mcu_module/vga/__reset(attached)
	__on_off()

/obj/item/mcu_module/vga/proc/__on_off()
	var/new_data = list(
		"supports_color" = supports_color,
		"max_messages_per_sec" = config.ws.rate_limit_messages_per_sec,
		"turned_on" = FALSE,
	)

	var/list/uis = SStgui.get_all_open_uis(src)
	for(var/datum/tgui/ui in uis)
		ui.send_update(new_data)

/obj/item/mcu_module/vga/truecolor
	name = "TrueColor display module"
	desc = "A TrueColor display module for displaying fancy graphics, has an embedded keyboard and a mouse."

	supports_color = TRUE
	base_power = 16
	max_resolution_power = 24
