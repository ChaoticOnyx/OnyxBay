#define MODE_TELEPORT 0
#define MODE_GATEWAY  1
#define MODE_TARGET   2

#define LINKED_GATES_MAX 3

#define MIN_MAX_GATE_LEVEL 8

/obj/machinery/computer/teleporter
	name = "Teleporter Control Console"
	desc = "Used to control a linked teleportation hub and station."
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "tele_console"
	icon_keyboard = null
	icon_screen = null
	circuit = /obj/item/circuitboard/teleporter

	light_color = "#7de1e1"

	var/id
	var/mode = MODE_TELEPORT
	var/calibrating = FALSE
	var/list/linked_consoles
	var/weakref/target_ref
	var/obj/machinery/teleporter_gate/gate

/obj/machinery/computer/teleporter/update_icon()
	overlays.Cut()
	if(gate && (get_dir(gate, src) == WEST))
		LAZYADD(overlays, image(icon, src, "tele_console_wiring"))

	icon_state = initial(icon_state)
	if(stat & (BROKEN | NOPOWER))
		set_light(0)
		return

	if(target_ref)
		flick(image(icon, "tele_console_boot"), src)
		set_light(0.25, 0.1, 2, 3.5, light_color)
	else
		set_light(0.1, 0.1, 2, 3.5, light_color)

	var/image/screen_overlay = image(icon, src, "tele_console_over-[target_ref ? 1 : 0]", EYE_GLOW_LAYER)
	screen_overlay.plane = EFFECTS_ABOVE_LIGHTING_PLANE
	screen_overlay.alpha = 150
	LAZYADD(overlays, screen_overlay)

	return

/obj/machinery/computer/teleporter/proc/link_gate()
	if(gate)
		return
	for(var/direction in GLOB.cardinal)
		gate = locate() in get_step(src, direction)
		if(gate)
			gate.link_console()
			break
	update_icon()

/obj/machinery/computer/teleporter/Initialize()
	. = ..()
	id = "[random_id(/obj/machinery/computer/teleporter, 1000, 9999)]"
	link_gate()

/obj/machinery/computer/teleporter/Destroy()
	if(gate)
		gate.console = null
		gate.update_icon()
		gate = null
	return ..()

/obj/machinery/computer/teleporter/dismantle()
	if(gate)
		gate.console = null
		gate.update_icon()
		gate = null
	return ..()

/obj/machinery/computer/teleporter/proc/can_link_gate()
	if(length(linked_consoles) >= LINKED_GATES_MAX)
		return FALSE
	if(gate?.accuracy + gate?.calc_acceleration < MIN_MAX_GATE_LEVEL)
		return FALSE
	return TRUE

/obj/machinery/computer/teleporter/attackby(obj/item/I, mob/living/user)
	if(isMultitool(I))
		var/obj/item/device/multitool/MT = get_multitool(user)
		if(panel_open)
			MT.set_buffer(src)
			to_chat(user, SPAN_NOTICE("You upload \the [src] data to \the [I.name]'s buffer."))
		else
			if(!can_link_gate())
				to_chat(user, SPAN_WARNING("You can't upload the data to \the [src]: max gate threshold was reached."))
				return
			var/atom/buffered_object = MT.get_buffer()
			if(buffered_object && istype(buffered_object, /obj/machinery/computer/teleporter) && src != buffered_object)
				LAZYADD(linked_consoles, buffered_object)
				MT.set_buffer(null)
				to_chat(user, SPAN_NOTICE("You upload the data from \the [I.name]'s buffer."))
		return

	return ..()

/obj/machinery/computer/teleporter/attack_hand(mob/user)
	. = ..()

	if(!.)
		tgui_interact(user)

/obj/machinery/computer/teleporter/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Teleporter", name)
		ui.open()

/obj/machinery/computer/teleporter/tgui_data(mob/user)
	var/atom/target
	if(target_ref)
		target = target_ref.resolve()
	if(!target)
		target_ref = null

	var/list/data = list()
	data["gate"] = gate ? TRUE : FALSE
	data["panel"] = panel_open
	data["calibrating"] = calibrating
	data["target"] = !target ? "None" : "[get_area(target)]"

	switch(mode)
		if(MODE_TELEPORT)
			data["mode"] = "Teleport"
		if(MODE_GATEWAY)
			data["mode"] = "Gate"
		if(MODE_TARGET)
			data["mode"] = "Target"

	if(gate?.engaged)
		data["engaged"] = TRUE
	else
		data["engaged"] = FALSE

	if(gate?.calibrated)
		data["calibrated"] = TRUE
	else
		data["calibrated"] = FALSE

	return data

/obj/machinery/computer/teleporter/proc/change_mode()
	mode = mode + 1 > 2 ? 0 : mode + 1
	set_teleport_target(null)

/obj/machinery/computer/teleporter/proc/finish_calibrating()
	calibrating = FALSE
	if(!gate)
		audible_message(SPAN_WARNING("Failure: Unable to detect gate."))
		return
	audible_message("Calibration complete.")
	gate.calibrated = TRUE
	gate.set_state(TRUE)
	update_icon()

/obj/machinery/computer/teleporter/proc/start_calibrating(auto = FALSE)
	if(auto && gate?.accuracy + gate?.calc_acceleration < MIN_MAX_GATE_LEVEL)
		return
	calibrating = TRUE
	audible_message("Processing hub calibration to target...")
	addtimer(CALLBACK(src, .proc/finish_calibrating), 2 SECONDS * (4 - gate.calc_acceleration))

/obj/machinery/computer/teleporter/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("toggle")
			if(!target_ref)
				return
			gate.set_state(!gate.engaged)
		if("togglemaint")
			panel_open = !panel_open
			to_chat(usr, "\The [src]'s maintanence panel is now [panel_open ? "opened" : "closed"].")
		if("modeset")
			gate.set_state(FALSE)
			gate.calibrated = FALSE
			change_mode()
		if("targetset")
			gate.set_state(FALSE)
			gate.calibrated = FALSE
			set_target(usr)
		if("calibrate")
			if(!target_ref)
				audible_message("Error: No target set to calibrate to.")
				return
			if(gate.calibrated)
				audible_message("Error: Hub is already calibrated!")
			start_calibrating()

	return TRUE

/obj/machinery/computer/teleporter/proc/is_suitable(turf/T)
	if(!T)
		return FALSE
	if(!(T.z in GLOB.using_map.get_levels_without_trait(ZTRAIT_SEALED)))
		return FALSE
	return TRUE

/obj/machinery/computer/teleporter/proc/set_teleport_target(atom/new_target)
	var/weakref/new_target_ref = weakref(new_target)
	if(target_ref == new_target_ref)
		return
	target_ref = new_target_ref
	update_icon()

/obj/machinery/computer/teleporter/proc/get_targets()
	var/list/targets = list()
	var/list/areaindex = list()

	switch(mode)
		if(MODE_TELEPORT)
			// TO-DO: refactor beacons to use their own global list.
			for(var/obj/item/device/radio/beacon/beacon in world)
				var/turf/T = get_turf(beacon)
				if(!is_suitable(T))
					continue
				LAZYADDASSOC(targets, avoid_assoc_duplicate_keys(T.loc.name, areaindex), beacon)
		if(MODE_TARGET)
			// TO-DO: refactor implants to use their own global list.
			for(var/obj/item/implant/tracking/implant in world)
				if(!implant.implanted || !ismob(implant.loc))
					continue
				var/mob/M = implant.loc
				if(M.is_ic_dead())
					if(M.timeofdeath + 10 MINUTES < world.time)
						continue
				var/turf/T = get_turf(M)
				if(!is_suitable(T))
					continue
				LAZYADDASSOC(targets, avoid_assoc_duplicate_keys(M.name, areaindex), implant)
		if(MODE_GATEWAY)
			for(var/obj/machinery/computer/teleporter/console as anything in linked_consoles)
				var/turf/T = get_turf(console)
				if(!is_suitable(T) || !console.gate)
					continue
				LAZYADDASSOC(targets, avoid_assoc_duplicate_keys(T.loc.name, areaindex), console)

	return targets

/obj/machinery/computer/teleporter/proc/set_target(mob/user)
	var/list/targets = get_targets()

	if(!length(targets))
		to_chat(user, SPAN_WARNING("No active targets to lock in!"))
		return

	var/desc = tgui_input_list(user, "Please select a location to lock in.", "Locking Computer", targets)
	if(isnull(desc))
		return

	var/atom/target = targets[desc]
	if(mode == MODE_GATEWAY)
		var/obj/machinery/computer/teleporter/target_console = target
		if(!target_console)
			return
		if(!target_console.gate)
			return
		target = target_console.gate

	set_teleport_target(target)
	log_game("[user] set \the [src] target to \the [targets[desc]].")

#undef MIN_MAX_GATE_LEVEL

#undef LINKED_GATES_MAX

#undef MODE_TARGET
#undef MODE_GATEWAY
#undef MODE_TELEPORT
