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
	var/list/linked_consoles
	var/weakref/target_ref
	var/obj/machinery/teleporter_gate/gate

/obj/machinery/computer/teleporter/on_update_icon()
	ClearOverlays()

	if(gate && (get_dir(gate, src) == WEST))
		AddOverlays(OVERLAY(icon, "tele_console_wiring"))

	icon_state = initial(icon_state)
	if(target_ref)
		flick("tele_console_boot", src)
		icon_state = "[icon_state]_on"

	var/should_glow = update_glow()
	if(should_glow)
		AddOverlays(emissive_appearance(icon, "tele_console_ea-[target_ref ? 1 : 0]"))

	return

/obj/machinery/computer/teleporter/update_glow()
	. = ..()

	if(. && !target_ref)
		set_light(0.1, 0.1, 2, 3.5, light_color)

	return .

/obj/machinery/computer/teleporter/proc/link_gate()
	if(gate)
		return
	for(var/direction in GLOB.cardinal)
		gate = locate() in get_step(src, direction)
		if(gate)
			gate.link_console()
			break
	queue_icon_update()

/obj/machinery/computer/teleporter/Initialize()
	. = ..()
	id = "[random_id(/obj/machinery/computer/teleporter, 1000, 9999)]"
	link_gate()

/obj/machinery/computer/teleporter/Destroy()
	if(gate)
		gate.console = null
		gate.queue_icon_update()
		gate = null
	return ..()

/obj/machinery/computer/teleporter/dismantle()
	if(gate)
		gate.console = null
		gate.queue_icon_update()
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
	data["id"] = id
	data["gate"] = gate ? TRUE : FALSE
	data["panel"] = panel_open
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

	return data

/obj/machinery/computer/teleporter/proc/change_mode()
	mode = mode + 1 > 2 ? 0 : mode + 1
	set_teleport_target(null)

/obj/machinery/computer/teleporter/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("toggle")
			if(!target_ref)
				return TRUE

			gate.set_state(!gate.engaged)
		if("togglemaint")
			panel_open = !panel_open
			to_chat(usr, "\The [src]'s maintanence panel is now [panel_open ? "opened" : "closed"].")
		if("idset")
			var/new_id = sanitize(params["value"], MAX_NAME_LEN)
			if(!length(new_id))
				return TRUE

			id = new_id
		if("modeset")
			gate.set_state(FALSE)
			change_mode()
		if("targetset")
			gate.set_state(FALSE)
			set_target(usr)

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
	queue_icon_update()

/obj/machinery/computer/teleporter/proc/get_targets()
	var/list/targets = list()
	var/list/areaindex = list()

	switch(mode)
		if(MODE_TELEPORT)
			for(var/obj/item/device/bluespace_beacon/beacon as anything in GLOB.bluespace_beacons)
				var/turf/T = get_turf(beacon)
				if(!is_suitable(T))
					continue

				LAZYSET(targets, avoid_assoc_duplicate_keys(T.loc.name, areaindex), beacon)
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
				LAZYSET(targets, avoid_assoc_duplicate_keys(M.name, areaindex), implant)
		if(MODE_GATEWAY)
			for(var/obj/machinery/computer/teleporter/console as anything in linked_consoles)
				var/turf/T = get_turf(console)
				if(!is_suitable(T) || !console.gate)
					continue
				LAZYSET(targets, avoid_assoc_duplicate_keys(T.loc.name, areaindex), console)

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
