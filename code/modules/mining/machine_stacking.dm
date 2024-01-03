/obj/machinery/computer/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"

	var/weakref/machine_ref
	icon_screen = null
	icon_keyboard = null

/obj/machinery/computer/stacking_unit_console/Initialize()
	. = ..()
	machine_ref = weakref(locate_unit(/obj/machinery/mineral/stacking_machine))

/obj/machinery/computer/stacking_unit_console/Destroy()
	machine_ref = null
	return ..()

/obj/machinery/computer/stacking_unit_console/attack_hand(mob/user)
	add_fingerprint(user)
	if(!machine_ref?.resolve())
		if(tgui_alert(user, "No connected ore stacking unit found. Do you wish to rescan?", "Error!", list("Yes","No")) == "Yes")
			machine_ref = weakref(locate_unit(/obj/machinery/mineral/stacking_machine))
			if(!machine_ref?.resolve())
				show_splash_text(user, "no ore processing units found!")
				return

	tgui_interact(user)

/obj/machinery/computer/stacking_unit_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StackingConsole", name)
		ui.open()

/obj/machinery/computer/stacking_unit_console/tgui_data(mob/user)
	var/list/data = list()

	var/obj/machinery/mineral/stacking_machine/stacking_machine = machine_ref.resolve()

	data["machine"] = stacking_machine ? TRUE : FALSE
	data["stacking_amount"] = null
	data["contents"] = list()
	if(stacking_machine)
		data["stacking_amount"] = stacking_machine.stack_amt
		for(var/stacktype in subtypesof(/obj/item/stack/material))
			var/obj/item/stack/S = stacktype
			if(stacking_machine.machine_storage[S.type] <= 0)
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

	switch(action)
		if("release")
			var/obj/item/stack/material/released_type = text2path(params["type"])
			stacking_machine.load_item(released_type)
			return TRUE

		if("adjust_stacking_amount")
			stacking_machine.stack_amt = max(1, text2num(params["stack_amount"])) // Clamp here to check for possible href exploit
			return TRUE

/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	/// List of stored materials
	var/list/machine_storage = list()
	/// Amount to store before releasing
	var/stack_amt = 50

/obj/machinery/mineral/stacking_machine/pickup_item(datum/source, atom/movable/target, atom/old_loc)
	if(!istype(target, /obj/item))
		return

	if(istype(target, /obj/item/stack/material))
		var/obj/item/stack/material/stack = target
		load_item(stack)
	else
		unload_item(target)

/obj/machinery/mineral/stacking_machine/proc/load_item(obj/item/stack/material/incoming_stack)
	if(QDELETED(incoming_stack))
		return

	var/key = incoming_stack.stacktype
	var/obj/item/stack/material/storage = machine_storage[key]
	if(!storage)
		machine_storage[key] = storage = new incoming_stack.type(src, 0)
	storage.amount += incoming_stack.amount
	incoming_stack.forceMove(null)
	INVOKE_ASYNC(incoming_stack, nameof(.proc/qdel), incoming_stack)

	while(storage.amount >= stack_amt)
		var/obj/item/stack/material/out = new incoming_stack.type()
		unload_item(out)
		storage.amount -= stack_amt
