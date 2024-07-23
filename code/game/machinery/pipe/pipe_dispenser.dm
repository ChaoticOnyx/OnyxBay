/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	layer = BELOW_OBJ_LAYER
	density = 1
	anchored = 1
	var/unwrenched = FALSE
	var/wait = 0

	var/static/list/designs_icons = list()

	var/list/allowed_categories = list(
		"Regular pipes",
		"Supply pipes",
		"Scrubbers pipes",
		"Fuel pipes",
		"Devices",
		"Heat Exchange"
	)

/obj/machinery/pipedispenser/attack_hand(mob/user)
	. = ..()
	tgui_interact(user)

/obj/machinery/pipedispenser/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "PipeDispenser", name)
		ui.open()

/obj/machinery/pipedispenser/tgui_static_data(mob/user)
	var/list/data = list()

	data["categories"] = list()
	for(var/category in GLOB.pipe_dispenser_recipes)
		if(!(category in allowed_categories))
			continue

		if(!islist(designs_icons[category]))
			designs_icons[category] = list()

		var/list/pipes = list()
		for(var/pipe_design in GLOB.pipe_dispenser_recipes[category]) // Fuck the guy who coded pipes.
			var/pipe_index = GLOB.pipe_dispenser_recipes[category][pipe_design]
			var/pipe_dir = SOUTH // Fuck the guy who coded pipes.
			if(pipe_index == 1 || pipe_index == 30 || pipe_index == 32 || pipe_index == 46 || pipe_index == 3)
				pipe_dir = 5

			if(!designs_icons[category][pipe_design])
				if(category == "Devices" && pipe_index == 1)
					var/obj/item/pipe_meter/meter = new (src)
					designs_icons[category][pipe_design] = icon(icon = meter.icon, icon_state = meter.icon_state, dir = SOUTH, frame = 1)
					qdel(meter)

				else if(category != "Disposal Pipes")
					var/obj/item/pipe/P = new (src, pipe_index, pipe_dir)
					P.update()
					var/icon/pipe_icon = icon(icon = P.icon, icon_state = P.icon_state, dir = pipe_dir, frame = 1)
					if(!isnull(P.color))
						pipe_icon.Blend(P.color, ICON_MULTIPLY)
					designs_icons[category][pipe_design] = pipe_icon
					qdel(P)

				else if(GLOB.pipe_dispenser_recipes[category][pipe_design] == 15)
					var/obj/machinery/disposal_switch/d_switch = new (src)
					designs_icons[category][pipe_design] = icon(icon = d_switch.icon, icon_state = d_switch.icon_state, dir = pipe_dir, frame = 1)
					qdel(d_switch)

				else
					var/subtype = null
					if(pipe_index == 9) // Fuck the guy who coded pipes.
						subtype = 1
					else if(pipe_index == 10)
						subtype = 2

					var/obj/structure/disposalconstruct/C = new (src, GLOB.pipe_dispenser_recipes[category][pipe_design], subtype)
					C.update()
					designs_icons[category][pipe_design] = icon(icon = C.icon, icon_state = C.icon_state, dir = SOUTH, frame = 1)
					qdel(C)

			pipes += list(list("pipe_name" = pipe_design, "pipe_index" = GLOB.pipe_dispenser_recipes[category][pipe_design], "pipe_icon" = icon2base64html(designs_icons[category][pipe_design])))

		data["categories"] += list(list("cat_name" = category, "recipes" = pipes))

	return data

/obj/machinery/pipedispenser/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("spawn_pipe")
			var/category = params["category"]
			var/pipe_index = text2num(params["pipe_index"])
			var/pipe_dir = 1 // Fuck the guy who coded pipes.
			if(pipe_index == 1 || pipe_index == 30 || pipe_index == 32 || pipe_index == 46 || pipe_index == 3)
				pipe_dir = 5

			if(category == "Devices" && pipe_index == 1)
				dispense_pipe(usr, get_turf(src), new /obj/item/pipe_meter(src))
				return TRUE
			else if(category == "Disposal Pipes")
				if(pipe_index == 15)
					dispense_pipe(usr, get_turf(src), new /obj/machinery/disposal_switch (src))
					return TRUE
				else
					var/subtype = null
					if(pipe_index == 9) // Fuck the guy who coded pipes.
						subtype = 1
					else if(pipe_index == 10)
						subtype = 2

					var/obj/structure/disposalconstruct/C = new (src, pipe_index, subtype)
					C.update()
					dispense_pipe(usr, get_turf(src), C)
					return TRUE
			else
				var/obj/item/pipe/P = new (src, pipe_index, pipe_dir)
				P.update()
				dispense_pipe(usr, get_turf(src), P)
				return TRUE

/obj/machinery/pipedispenser/proc/dispense_pipe(mob/living/user, turf/location, obj/item/new_pipe)
	if(istype(user) && user.Adjacent(src))
		user.pick_or_drop(new_pipe, get_turf(src))
	else
		new_pipe.forceMove(get_turf(src))

/obj/machinery/pipedispenser/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter))
		if(!user.drop(W))
			return
		to_chat(usr, "<span class='notice'>You put \the [W] back into \the [src].</span>")
		add_fingerprint(usr)
		qdel(W)
		return

	else if(isWrench(W))
		add_fingerprint(usr)
		if(unwrenched==0)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You begin to unfasten \the [src] from the floor...</span>")
			if (do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
				user.visible_message( \
					"<span class='notice'>\The [user] unfastens \the [src].</span>", \
					"<span class='notice'>You have unfastened \the [src]. Now it can be pulled somewhere else.</span>", \
					"You hear ratchet.")
				src.anchored = 0
				src.stat |= MAINT
				src.unwrenched = 1
				if(usr.machine==src)
					close_browser(usr, "window=pipedispenser")
		else /*if (unwrenched==1)*/
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You begin to fasten \the [src] to the floor...</span>")
			if (do_after(user, 20, src, luck_check_type = LUCK_CHECK_ENG))
				user.visible_message( \
					"<span class='notice'>\The [user] fastens \the [src].</span>", \
					"<span class='notice'>You have fastened \the [src]. Now it can dispense pipes.</span>", \
					"You hear ratchet.")
				src.anchored = 1
				src.stat &= ~MAINT
				src.unwrenched = 0
				power_change()
	else
		return ..()

/obj/machinery/pipedispenser/disposal
	name = "Disposal Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1.0
	allowed_categories = list(
		"Disposal Pipes"
	)

//Allow you to drag-drop disposal pipes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(obj/structure/disposalconstruct/pipe, mob/user)
	if(!CanPhysicallyInteract(user))
		return

	if(!istype(pipe) || get_dist(src, pipe) > 1 )
		return

	if(pipe.anchored)
		return

	qdel(pipe)

/obj/machinery/pipedispenser/disposal/attack_hand(user as mob)
	if(..())
		return


// adding a pipe dispensers that spawn unhooked from the ground
/obj/machinery/pipedispenser/orderable
	anchored = 0
	unwrenched = 1

/obj/machinery/pipedispenser/disposal/orderable
	anchored = 0
	unwrenched = 1
