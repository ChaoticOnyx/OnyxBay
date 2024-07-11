/*
All the important duct code:
/code/datums/components/plumbing/plumbing.dm
/code/datums/ductnet.dm
*/
/obj/machinery/duct
	name = "fluid duct"
	icon = 'icons/obj/plumbing/fluid_ducts.dmi'
	icon_state = "nduct"
	layer = EXPOSED_PIPE_LAYER
	use_power = NO_POWER_USE

	///bitfield with the directions we're connected in
	var/connects
	///set to TRUE to disable smart duct behaviour
	var/dumb = FALSE
	///wheter we allow our connects to be changed after initialization or not
	var/lock_connects = FALSE
	///our ductnet, wich tracks what we're connected to
	var/datum/ductnet/duct
	///amount we can transfer per process. note that the ductnet can carry as much as the lowest capacity duct
	var/capacity = 10

	///the color of our duct
	var/duct_color = COLOR_VERY_LIGHT_GRAY
	///TRUE to ignore colors, so yeah we also connect with other colors without issue
	var/ignore_colors = FALSE
	///1,2,4,8,16
	var/duct_layer = DUCT_LAYER_DEFAULT
	///whether we allow our layers to be altered
	var/lock_layers = FALSE
	///TRUE to let colors connect when forced with a wrench, false to just not do that at all
	var/color_to_color_support = TRUE
	///wheter to even bother with plumbing code or not
	var/active = TRUE
	///track ducts we're connected to. Mainly for ducts we connect to that we normally wouldn't, like different layers and colors, for when we regenerate the ducts
	var/list/neighbours = list()
	///what stack to drop when disconnected. Must be /obj/item/stack/ducts or a subtype
	var/drop_on_wrench = /obj/item/stack/ducts

/obj/machinery/duct/Initialize(mapload, no_anchor, color_of_duct = null, layer_of_duct = null, force_connects, force_ignore_colors)
	. = ..()

	if(force_connects)
		connects = force_connects //skip change_connects() because we're still initializing and we need to set our connects at one point
	if(!lock_layers && layer_of_duct)
		duct_layer = layer_of_duct
	if(force_ignore_colors)
		ignore_colors = force_ignore_colors
	if(!ignore_colors && color_of_duct)
		duct_color = color_of_duct
	if(duct_color)
		var/icon/new_icon = icon(icon, icon_state)
		icon_state = new_icon.ColorTone(duct_color)
	if(no_anchor)
		active = FALSE
		set_anchored(FALSE)

	else if(!can_anchor())
		if(mapload)
			util_crash_with("Overlapping ducts detected at X:[x], Y:[y], Z:[z], unanchoring one.")
		return INITIALIZE_HINT_QDEL

	handle_layer()

	attempt_connect()
	//AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

///start looking around us for stuff to connect to
/obj/machinery/duct/proc/attempt_connect()
	for(var/direction in GLOB.cardinal)
		if(dumb && !(direction & connects))
			continue

		for(var/atom/movable/duct_candidate in get_step(src, direction))
			if(connect_network(duct_candidate, direction))
				add_connects(direction)
				duct_candidate.update_icon()
	update_icon()

///see if whatever we found can be connected to
/obj/machinery/duct/proc/connect_network(atom/movable/plumbable, direction)
	if(istype(plumbable, /obj/machinery/duct))
		return connect_duct(plumbable, direction)

	for(var/datum/component/plumbing/plumber as anything in plumbable.get_components(/datum/component/plumbing))
		. += connect_plumber(plumber, direction)

///connect to a duct
/obj/machinery/duct/proc/connect_duct(obj/machinery/duct/other, direction)
	var/opposite_dir = GLOB.flip_dir[direction]
	if(!active || !other.active)
		return

	if(!dumb && other.dumb && !(opposite_dir & other.connects))
		return
	if(dumb && other.dumb && !(connects & other.connects))
		return

	if((duct == other.duct) && duct)
		add_neighbour(other, direction)

		other.add_connects(opposite_dir)
		other.update_icon()
		return TRUE

	if(!(other in neighbours))
		if((duct_color != other.duct_color) && !(ignore_colors || other.ignore_colors))
			return
		if(!(duct_layer & other.duct_layer))
			return

	if(other.duct)
		if(duct)
			duct.assimilate(other.duct)
		else
			other.duct.add_duct(src)
	else
		if(duct)
			duct.add_duct(other)
		else
			create_duct()
			duct.add_duct(other)

	add_neighbour(other, direction)

	INVOKE_ASYNC(other, nameof(/obj/machinery/duct.proc/attempt_connect))

	return TRUE

///connect to a plumbing object
/obj/machinery/duct/proc/connect_plumber(datum/component/plumbing/plumbing, direction)
	var/opposite_dir = GLOB.flip_dir[direction]

	if(!(duct_layer & plumbing.ducting_layer))
		return FALSE

	if(!plumbing.active)
		return

	var/comp_directions = plumbing.supply_connects + plumbing.demand_connects
	if(opposite_dir & comp_directions)
		if(!duct)
			create_duct()
		if(duct.add_plumber(plumbing, opposite_dir))
			neighbours[plumbing.parent] = direction
			return TRUE

///we disconnect ourself from our neighbours. we also destroy our ductnet and tell our neighbours to make a new one
/obj/machinery/duct/proc/disconnect_duct(skipanchor)
	if(!skipanchor)
		set_anchored(FALSE)
	active = FALSE
	if(duct)
		duct.remove_duct(src)
	lose_neighbours()
	reset_connects(0)
	update_icon()
	if(ispath(drop_on_wrench))
		var/obj/item/stack/ducts/duct_stack = new drop_on_wrench(drop_location())
		duct_stack.duct_color = GLOB.pipe_color_name[duct_color] || DUCT_COLOR_OMNI
		duct_stack.duct_layer = GLOB.plumbing_layer_names["[duct_layer]"] || GLOB.plumbing_layer_names["[DUCT_LAYER_DEFAULT]"]
		drop_on_wrench = null
	if(!QDELING(src))
		qdel(src)

/// Special proc to draw a new connect frame based on neighbours. not the norm so we can support multiple duct kinds
/obj/machinery/duct/proc/generate_connects()
	if(lock_connects)
		return
	connects = 0
	for(var/A in neighbours)
		connects |= neighbours[A]
	update_icon()

/// create a new duct datum
/obj/machinery/duct/proc/create_duct()
	duct = new()
	duct.add_duct(src)

/// add a duct as neighbour. this means we're connected and will connect again if we ever regenerate
/obj/machinery/duct/proc/add_neighbour(obj/machinery/duct/other, direction)
	if(!(other in neighbours))
		neighbours[other] = direction
	if(!(src in other.neighbours))
		other.neighbours[src] = GLOB.flip_dir[direction]

/// remove all our neighbours, and remove us from our neighbours aswell
/obj/machinery/duct/proc/lose_neighbours()
	for(var/obj/machinery/duct/other in neighbours)
		other.neighbours.Remove(src)
		other.generate_connects()
	neighbours = list()

/// add a connect direction
/obj/machinery/duct/proc/add_connects(new_connects)
	if(!lock_connects)
		connects |= new_connects

/// remove a connect direction
/obj/machinery/duct/proc/remove_connects(dead_connects)
	if(!lock_connects)
		connects &= ~dead_connects

/// remove our connects
/obj/machinery/duct/proc/reset_connects()
	if(!lock_connects)
		connects = 0

/// get a list of the ducts we can connect to if we are dumb
/obj/machinery/duct/proc/get_adjacent_ducts()
	var/list/adjacents = list()
	for(var/direction in GLOB.cardinal)
		if(direction & connects)
			for(var/obj/machinery/duct/other in get_step(src, direction))
				if((GLOB.flip_dir[direction] & other.connects) && other.active)
					adjacents += other
	return adjacents

/obj/machinery/duct/on_update_icon()
	var/temp_icon = initial(icon_state)
	for(var/direction in GLOB.cardinal)
		switch(direction & connects)
			if(NORTH)
				temp_icon += "_n"
			if(SOUTH)
				temp_icon += "_s"
			if(EAST)
				temp_icon += "_e"
			if(WEST)
				temp_icon += "_w"
	icon_state = temp_icon

///update the layer we are on
/obj/machinery/duct/proc/handle_layer()
	var/offset
	switch(duct_layer)
		if(FIRST_DUCT_LAYER)
			offset = -10
		if(SECOND_DUCT_LAYER)
			offset = -5
		if(THIRD_DUCT_LAYER)
			offset = 0
		if(FOURTH_DUCT_LAYER)
			offset = 5
		if(FIFTH_DUCT_LAYER)
			offset = 10
	pixel_x = offset
	pixel_y = offset

	layer = initial(layer) + duct_layer * 0.0003

/obj/machinery/duct/proc/set_anchored(anchorvalue)
	if(anchorvalue)
		active = TRUE
		attempt_connect()
	else
		disconnect_duct(TRUE)

///collection of all the sanity checks to prevent us from stacking ducts that shouldn't be stacked
/obj/machinery/duct/proc/can_anchor(turf/destination)
	if(!destination)
		destination = get_turf(src)

	for(var/obj/machinery/duct/other in destination)
		if(other.anchored && other != src && (duct_layer & other.duct_layer))
			return FALSE

	for(var/obj/machinery/machine in destination)
		for(var/datum/component/plumbing/plumber as anything in machine.get_components(/datum/component/plumbing))
			if(plumber.ducting_layer & duct_layer)
				return FALSE

	return TRUE

/obj/machinery/duct/Move(newloc, direct)
	. = ..()
	disconnect_duct()
	set_anchored(FALSE)

/obj/machinery/duct/Destroy()
	disconnect_duct()
	return ..()

/obj/machinery/duct/MouseDrop_T(atom/dropping, mob/living/user)
	if(!istype(dropping, /obj/machinery/duct))
		return

	var/obj/machinery/duct/other = dropping
	if(get_dist(src, other) != 1)
		return

	var/direction = get_dir(src, other)
	if(!(direction in GLOB.cardinal))
		return

	if(!(duct_layer & other.duct_layer))
		to_chat(user, SPAN_WARNING("The ducts must be on the same layer to connect them!"))
		return

	var/obj/item/held_item = user.get_active_item()
	if(held_item?.tool_behaviour != TOOL_WRENCH)
		to_chat(user, SPAN_WARNING("You need to be holding a wrench in your active hand to do that!"))
		return

	add_connects(direction)
	add_neighbour(other, direction)
	connect_network(other, direction)
	update_icon()
	held_item.play_tool_sound(src)
	to_chat(user, SPAN_NOTICE("You connect the two plumbing ducts."))

/obj/machinery/duct/attackby(obj/item/O, mob/user)
	if(isWrench(O))
		if(anchored || can_anchor())
			set_anchored(!anchored)
			user.visible_message( \
				"[user] [anchored ? null : "un"]fastens \the [src].", \
				SPAN_NOTICE("You [anchored ? null : "un"]fasten \the [src]."), \
				SPAN_NOTICE("You hear ratcheting."))

		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		return

	return ..()

/obj/item/stack/ducts
	name = "stack of duct"
	desc = "A stack of fluid ducts."
	singular_name = "duct"
	icon = 'icons/obj/plumbing/fluid_ducts.dmi'
	icon_state = "ducts"
	max_amount = 50
	///Color of our duct
	var/duct_color = "omni"
	///Default layer of our duct
	var/duct_layer = "Default Layer"

/obj/item/stack/ducts/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It's current color and layer are [duct_color] and [duct_layer]. Use in-hand to change.")

/obj/item/stack/ducts/attack_self(mob/user)
	var/new_layer = tgui_input_list(user, "Select a layer", "Layer", GLOB.plumbing_layers, duct_layer)
	if(loc != user)
		return

	if(new_layer)
		duct_layer = new_layer

	var/new_color = tgui_input_list(user, "Select a color", "Color", GLOB.pipe_paint_colors, duct_color)
	if(loc != user)
		return

	if(new_color)
		duct_color = new_color
		var/icon/new_icon = icon(icon, icon_state)
		icon_state = new_icon.ColorTone(GLOB.pipe_paint_colors[new_color])

/obj/item/stack/ducts/afterattack(atom/target, user, proximity)
	if(!proximity)
		return

	if(istype(target, /obj/machinery/duct))
		var/obj/machinery/duct/duct = target
		if(duct.anchored)
			to_chat(user, SPAN_WARNING("The duct must be unanchored before it can be picked up."))
			return


		var/obj/item/stack/ducts/stack = new(duct.loc, 1, FALSE)
		stack.add_to_stacks(user)
		qdel(duct)

		return

	check_attach_turf(target)

/obj/item/stack/ducts/proc/check_attach_turf(atom/target)
	var/turf/simulated/floor/open_turf = target
	if(istype(open_turf) && use(1))
		var/is_omni = duct_color == DUCT_COLOR_OMNI
		new /obj/machinery/duct(open_turf, FALSE, GLOB.pipe_paint_colors[duct_color], GLOB.plumbing_layers[duct_layer], null, is_omni)
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)

/obj/item/stack/ducts/fifty
	amount = 50
