/obj/machinery/computer/stacking_unit_console
	name = "stacking machine console"
	icon_screen = "minerals"
	light_color = "#00b000"

	var/weakref/machine_ref

	circuit = /obj/item/circuitboard/stacking_machine_console

/obj/machinery/computer/stacking_unit_console/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/stacking_unit_console/LateInitialize()
	..()
	var/obj/machinery/mineral/stacking_machine/s_machine = locate_unit(/obj/machinery/mineral/stacking_machine)
	if(istype(s_machine))
		machine_ref = weakref(s_machine)

/obj/machinery/computer/stacking_unit_console/Destroy()
	machine_ref = null
	return ..()

/obj/machinery/computer/stacking_unit_console/attack_hand(mob/user)
	add_fingerprint(user)

	if(machine_ref?.resolve())
		tgui_interact(user)
		return

	var/response = tgui_alert(user, "No connected ore stacking unit found. Do you wish to rescan?", "Error!", list("Yes", "No"))
	if(response  == "Yes" && Adjacent(user))
		var/obj/machinery/mineral/stacking_machine/s_machine = locate_unit(/obj/machinery/mineral/stacking_machine)
		if(!s_machine)
			show_splash_text(user, "no ore stacking units found!", SPAN("warning", "\The [src] has failed to detect any ore stacking units!"))
			return

		machine_ref = weakref(s_machine)
		tgui_interact(user)

/obj/machinery/computer/stacking_unit_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StackingConsole", name)
		ui.open()

/obj/machinery/computer/stacking_unit_console/tgui_data(mob/user)
	var/list/data = list(
		"stacking_amount" = null,
		"contents" = list()
		)

	var/obj/machinery/mineral/stacking_machine/stacking_machine = machine_ref.resolve()
	if(!istype(stacking_machine))
		return data

	data["machine_state"] = !(stacking_machine.stat & POWEROFF)
	data["stacking_amount"] = stacking_machine.stack_amt

	for(var/stacktype in subtypesof(/obj/item/stack/material))
		var/obj/item/stack/S = stacktype
		if(!stacking_machine.machine_storage[S.type] || stacking_machine.machine_storage[S.type] <= 0)
			continue

		data["contents"] += list(list(
			"type" = S.type,
			"name" = initial(S.name),
			"amount" = stacking_machine.machine_storage[S.type],
		))

	return data

/obj/machinery/computer/stacking_unit_console/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/obj/machinery/mineral/stacking_machine/stacking_machine = machine_ref.resolve()
	if(!istype(stacking_machine))
		return TRUE

	switch(action)
		if("release")
			var/obj/item/stack/material/released_type = text2path(params["type"])
			stacking_machine.unload_item(released_type, stacking_machine.machine_storage[released_type])
			return TRUE

		if("adjust_stacking_amount")
			stacking_machine.stack_amt = max(1, text2num(params["stack_amount"])) // Clamp here to check for possible href exploit
			return TRUE

		if("toggle_machine")
			stacking_machine.toggle()
			return TRUE

/obj/machinery/mineral/stacking_machine
	name = "stacking machine"

	icon_state = "stacker-map"
	base_icon_state = "stacker"

	ea_color = "#0090F8"
	/// List of stored materials
	var/list/machine_storage = list()
	/// Amount to store before releasing
	var/stack_amt = 50

	component_types = list(
		/obj/item/circuitboard/stacking_machine,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/scanning_module
	)

/obj/machinery/mineral/stacking_machine/pickup_item(datum/source, atom/movable/target, atom/old_loc)
	if(!..())
		return

	if(!istype(target, /obj/item))
		return

	if(istype(target, /obj/item/stack/material))
		load_item(target)
	else
		var/turf/unload_turf = get_step(src, dir)
		if(unload_turf)
			target.forceMove(unload_turf)

/obj/machinery/mineral/stacking_machine/proc/load_item(obj/item/stack/material/incoming_stack)
	if(QDELETED(incoming_stack))
		return

	machine_storage[incoming_stack.stacktype] += incoming_stack.amount

	while(machine_storage[incoming_stack.stacktype] >= stack_amt)
		unload_item(incoming_stack.stacktype, stack_amt)

	qdel(incoming_stack)

/obj/machinery/mineral/stacking_machine/unload_item(type, amount)
	if(amount <= 0)
		return

	var/obj/item/stack/material/out = new type()
	out.amount = amount
	machine_storage[type] -= amount
	return ..(out)
