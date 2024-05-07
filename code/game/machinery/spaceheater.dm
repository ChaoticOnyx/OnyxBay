/obj/machinery/space_heater
	use_power = POWER_USE_OFF
	anchored = 0
	density = 1
	icon = 'icons/obj/atmos.dmi'
	icon_state = "sheater-off"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set anything, or anyone, on fire."
	var/obj/item/cell/cell
	var/on = 0
	var/set_temperature = 20 CELSIUS
	var/active = 0
	var/heating_power = 40 KILO WATTS
	atom_flags = ATOM_FLAG_CLIMBABLE
	clicksound = SFX_USE_LARGE_SWITCH
	turf_height_offset = 16
	var/min_temperature = 0 CELSIUS
	var/max_temperature = 90 CELSIUS

/obj/machinery/space_heater/New()
	..()
	cell = new /obj/item/cell/high(src)
	update_icon()

/obj/machinery/space_heater/on_update_icon(rebuild_overlay = 0)
	if(!on)
		icon_state = "sheater-off"
	else if(active > 0)
		icon_state = "sheater-heat"
	else if(active < 0)
		icon_state = "sheater-cool"
	else
		icon_state = "sheater-standby"

	if(rebuild_overlay)
		ClearOverlays()
		if(panel_open)
			AddOverlays("sheater-open")

/obj/machinery/space_heater/examine(mob/user, infix)
	. = ..()

	. += "The heater is [on ? "on" : "off"] and the hatch is [panel_open ? "open" : "closed"]."
	if(panel_open)
		. += "The power cell is [cell ? "installed" : "missing"]."
	else
		. += "The charge meter reads [cell ? round(CELL_PERCENT(cell),1) : 0]%"
	return

/obj/machinery/space_heater/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/space_heater/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/cell))
		if(panel_open)
			if(cell)
				to_chat(user, "There is already a power cell inside.")
				return
			else
				// insert cell
				var/obj/item/cell/C = usr.get_active_hand()
				if(user.drop(C, src))
					cell = C
					C.add_fingerprint(user)

					user.visible_message("<span class='notice'>[user] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
					power_change()
		else
			to_chat(user, "The hatch must be open to insert a power cell.")
			return
	else if(isScrewdriver(I))
		panel_open = !panel_open
		user.visible_message("<span class='notice'>[user] [panel_open ? "opens" : "closes"] the hatch on the [src].</span>", "<span class='notice'>You [panel_open ? "open" : "close"] the hatch on the [src].</span>")
		update_icon(1)
		if(!panel_open && user.machine == src)
			close_browser(user, "window=spaceheater")
			user.unset_machine()
	else
		..()
		if(I.mod_weight >= 0.75)
			shake_animation(stime = 4)
	return

/obj/machinery/space_heater/attack_hand(mob/user)
	. = ..()
	if(panel_open)
		tgui_interact(user)
	else
		on = !on
		user.visible_message(SPAN_NOTICE("[user] switches [on ? "on" : "off"] \the [src]."), \
			SPAN_NOTICE("You switch [on ? "on" : "off"] \the [src]."))
		update_icon()

/obj/machinery/space_heater/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SpaceHeater", src)
		ui.open()

/obj/machinery/space_heater/tgui_data(mob/user)
	var/list/data = list(
		"cell" = istype(cell),
		"charge" = istype(cell) ? round(cell.percent(), 1) : 0,
		"temperature" = set_temperature,
		"minTemperature" = min_temperature,
		"maxTemperature" = max_temperature,
	)
	return data

/obj/machinery/space_heater/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("changeTemperature")
			var/new_temperature = params["useKelvin"] ? text2num(params["newTemp"]) : CONV_CELSIUS_KELVIN(text2num(params["newTemp"]))
			set_temperature = dd_range(min_temperature, max_temperature, new_temperature)
			return TRUE

		if("cell")
			if(!panel_open)
				return

			switch(istype(cell))
				if(TRUE)
					cell.update_icon()
					usr.pick_or_drop(cell, usr.loc)
					cell.add_fingerprint(usr)
					usr.visible_message(SPAN_NOTICE("[usr] removes \the [cell] from  \the [src]."), SPAN_NOTICE("You remove \the [cell] from \the [src]."))
					cell = null

				if(FALSE)
					var/obj/item/cell/C = usr.get_active_hand()
					if(!istype(C))
						return

					C.add_fingerprint(usr)
					usr.drop(C, src)
					cell = C
					usr.visible_message(SPAN_NOTICE("[usr] inserts \a [cell] into \the [src]."), SPAN_NOTICE("You insert \the [cell] into \the [src]."))

			return TRUE

/obj/machinery/space_heater/Process()
	if(on)
		if(powered() || (cell && cell.charge))
			var/datum/gas_mixture/env = loc.return_air()
			if(env && abs(env.temperature - set_temperature) <= 0.1)
				active = 0
			else
				var/transfer_moles = 0.25 * env.total_moles
				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				if(removed)
					var/heat_transfer = removed.get_thermal_energy_change(set_temperature)
					var/power_draw
					if(heat_transfer > 0)	//heating air
						heat_transfer = min( heat_transfer , heating_power ) //limit by the power rating of the heater

						removed.add_thermal_energy(heat_transfer)
						power_draw = heat_transfer
					else	//cooling air
						heat_transfer = abs(heat_transfer)

						//Assume the heat is being pumped into the hull which is fixed at 20 C
						var/cop = removed.temperature/(20 CELSIUS)	//coefficient of performance from thermodynamics -> power used = heat_transfer/cop
						heat_transfer = min(heat_transfer, cop * heating_power)	//limit heat transfer by available power

						heat_transfer = removed.add_thermal_energy(-heat_transfer)	//get the actual heat transfer

						power_draw = abs(heat_transfer)/cop
					if(!powered())
						cell.use(power_draw*CELLRATE)
					else
						use_power_oneoff(power_draw)
					active = heat_transfer

				env.merge(removed)
		else
			on = 0
			active = 0
			power_change()
		update_icon()
