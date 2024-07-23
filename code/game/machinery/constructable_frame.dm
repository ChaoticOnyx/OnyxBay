#define STAGE_CABLE 0
#define STAGE_CIRCUIT 1
#define STAGE_COMPONENTS 2

/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = TRUE
	anchored = TRUE
	use_power = POWER_USE_OFF
	atom_flags = ATOM_FLAG_CLIMBABLE
	var/obj/item/circuitboard/circuit
	var/list/components = list()
	var/list/req_components = list()
	var/state = STAGE_CABLE

/obj/machinery/constructable_frame/proc/deconstruct_frame(obj/item/weldingtool/WT, mob/user, amount=1)
	if(!WT.use_tool(src, user, delay = 2 SECONDS, amount = 5))
		return

	if(QDELETED(src) || !user)
		return

	to_chat(user, SPAN("notice", "You deconstruct \the [src]"))
	new /obj/item/stack/material/steel(loc, amount)
	qdel(src)

/obj/machinery/constructable_frame/proc/wrench_frame(mob/user)
	playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(do_after(user, 20, src, luck_check_type = LUCK_CHECK_ENG))
		to_chat(user, SPAN_NOTICE("You [anchored ? "unwrench" : "wrench"] \the [src] [anchored ? "from" : "into"] place."))
		anchored = !anchored

/obj/machinery/constructable_frame/machine_frame/on_update_icon()
	switch(state)
		if(STAGE_CABLE)
			icon_state = "box_0"
		if(STAGE_CIRCUIT)
			icon_state = "box_1"
		if(STAGE_COMPONENTS)
			icon_state = "box_2"

/obj/machinery/constructable_frame/machine_frame/proc/update_desc()
	desc = initial(desc)
	if(!isnull(req_components) && req_components.len)
		var/list/comp_list = list()
		for(var/component in req_components)
			var/amount = req_components[component]
			if(amount > 0) // We don't want to display something like: "0 micro-manipulator". - Max
				LAZYADD(comp_list, "[num2text(amount)] [initial(component["name"])]")
		var/new_desc = length(comp_list) ? "Requires [english_list(comp_list)]." : "Requires nothing."
		desc += SPAN("notice", new_desc)

/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/I, mob/user)
	switch(state)
		if(STAGE_CABLE)
			if(anchored && isWelder(I))
				deconstruct_frame(I, user, 5)
			else if(isWrench(I))
				wrench_frame(user)
			else if(isCoil(I))
				add_cable(I, user)
		if(STAGE_CIRCUIT)
			if(isWrench(I))
				wrench_frame(user)
			else if(isWirecutter(I))
				remove_cable(user)
			else if(anchored && istype(I, /obj/item/circuitboard))
				add_board(I, user)
		if(STAGE_COMPONENTS)
			if(isCrowbar(I))
				remove_board(user)
			else if(isScrewdriver(I))
				try_to_complete_construction()
			else if(istype(I, /obj/item))
				try_to_add_component(I, user)

/obj/machinery/constructable_frame/machine_frame/proc/add_cable(obj/item/stack/cable_coil/C, mob/user)
	if (C.get_amount() < 5)
		to_chat(user, SPAN("warning", "You need at least five lengths of cable to add them to \the [src]."))
		return
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	to_chat(user, SPAN("notice", "You start to add cables to \the [src]."))
	if(do_after(user, 20, src, luck_check_type = LUCK_CHECK_ENG) && state == STAGE_CABLE)
		if(C.use(5))
			to_chat(user, SPAN("notice", "You add cables to \the [src]."))
			state = STAGE_CIRCUIT
			update_icon()

/obj/machinery/constructable_frame/machine_frame/proc/remove_cable(mob/user)
	playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
	to_chat(user, SPAN("notice", "You remove the cables."))
	new /obj/item/stack/cable_coil(loc, 5)
	state = STAGE_CABLE
	update_icon()

/obj/machinery/constructable_frame/machine_frame/proc/refresh_components(mob/user)
	LAZYINITLIST(components)
	req_components = circuit.req_components.Copy()
	for(var/component in circuit.req_components)
		LAZYSET(req_components, component, circuit.req_components[component])
	update_desc()
	to_chat(user, desc)

/obj/machinery/constructable_frame/machine_frame/proc/add_board(obj/item/circuitboard/C, mob/user)
	if(C.board_type == "machine")
		if(!user.drop(C, src))
			return
		circuit = C
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, SPAN("notice"," You add \the [C] to \the [src]."))
		state = STAGE_COMPONENTS
		refresh_components(user)
		update_icon()
	else
		to_chat(user, SPAN("warning", "\The [src] does not accept circuit boards of this type!"))

/obj/machinery/constructable_frame/machine_frame/proc/remove_board(mob/user)
	playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
	if(!components.len)
		to_chat(user, SPAN("notice", "You remove \the [circuit]."))
	else
		to_chat(user, SPAN("notice", "You remove \the [circuit] and other components."))
		for(var/obj/item/I in components)
			I.forceMove(get_turf(src))
	circuit.forceMove(get_turf(src))
	circuit = null
	LAZYCLEARLIST(req_components)
	LAZYCLEARLIST(components)
	state = STAGE_CIRCUIT
	update_desc()
	update_icon()

/obj/machinery/constructable_frame/machine_frame/proc/try_to_add_component(obj/item/I, mob/user)
	for(var/component in req_components)
		if(istype(I, component) && req_components[component] > 0)
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
			if(istype(I, /obj/item/stack))
				var/obj/item/stack/S = I
				if(S.get_amount() > 1)
					var/amount = min(S.amount, req_components[component]) // Tries to take as much as it needs.
					S = S.split(amount, TRUE)
					if(!istype(S)) // Stacks that use charge may have a hard time splitting on some occasions; covering that just to be sure.
						to_chat(user, SPAN("warning", "Insufficient amount."))
						return
					S.forceMove(src)
					LAZYADD(components, S)
					req_components[component] -= amount
					update_desc()
					break
			if(user.drop(I, src))
				LAZYADD(components, I)
				req_components[component] -= 1 // TO-DO: add an ability to add components via RPED. - Max
				update_desc()
				break
	to_chat(user, desc)
	if(I && I.loc != src && !istype(I, /obj/item/stack))
		to_chat(user, SPAN("warning", "You cannot add \the [I] to \the [src]!"))

/obj/machinery/constructable_frame/machine_frame/proc/check_components()
	for(var/component in req_components)
		if(req_components[component] > 0)
			return FALSE
	return TRUE

/obj/machinery/constructable_frame/machine_frame/proc/try_to_complete_construction()
	if(check_components())
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		var/obj/machinery/new_machine = new circuit.build_path(loc, dir)
		if(new_machine.component_parts)
			QDEL_LIST(new_machine.component_parts)
		else
			LAZYINITLIST(new_machine.component_parts)
		circuit.construct(new_machine)
		if(circuit.contain_parts) // things like disposal don't want their parts in them
			for(var/obj/O in components)
				O.forceMove(new_machine)
				LAZYADD(new_machine.component_parts, O)
			circuit.forceMove(new_machine)
		else // Yay, nullspace!! - Max
			for(var/obj/O in components)
				O.loc = null
				new_machine.component_parts.Add(O)
			circuit.loc = null
		LAZYADD(new_machine.component_parts, circuit)
		new_machine.RefreshParts()
		qdel(src)

#undef STAGE_CABLE
#undef STAGE_CIRCUIT
#undef STAGE_COMPONENTS
