/obj/machinery/capsule/resleever
	name = "neural lace resleever"
	desc = "It's a machine that allows neural laces to be sleeved into new bodies."
	idle_power_usage = 4
	active_power_usage = 4000
	req_access = list(access_medical)

	component_types = list(
		/obj/item/circuitboard/resleever,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/console_screen
	)

	var/obj/item/organ/internal/stack/lace = null

	var/resleeving = FALSE
	var/timer = null
	var/remaining_time = 0

	var/lace_name = null

/obj/machinery/capsule/resleever/Destroy()
	eject_lace()
	return ..()

/obj/machinery/capsule/resleever/Process()
	if(occupant)
		occupant.Paralyse(4) // We need to always keep the occupant sleeping if they're in here.
	if(stat & (NOPOWER|BROKEN) || !anchored)
		if(timer)
			deltimer(timer)
		update_use_power(POWER_USE_OFF)
		return
	if(resleeving)
		update_use_power(POWER_USE_ACTIVE)
		if(!timer)
			timer = addtimer(CALLBACK(src, .proc/finish_sleeving), remaining_time > 0 ? remaining_time : 2 MINUTES, TIMER_STOPPABLE)
		remaining_time = timeleft(timer)
	update_use_power(POWER_USE_OFF)
	return

/obj/machinery/capsule/resleever/is_occupant_ejectable()
	if(resleeving)
		return FALSE
	return ..()

/obj/machinery/capsule/resleever/proc/is_lace_ejectable()
	if(isnull(lace) || !resleeving)
		return FALSE
	return TRUE

/obj/machinery/capsule/resleever/proc/can_start_sleeving()
	if(lace && occupant)
		if(!resleeving)
			return TRUE
	return FALSE

/obj/machinery/capsule/resleever/attack_hand(mob/user)
	..()
	tgui_interact(user)

/obj/machinery/capsule/resleever/ui_status(mob/user, datum/ui_state/state)
	if(!anchored || inoperable())
		return UI_CLOSE
	return ..()

/obj/machinery/capsule/resleever/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "ReSleever", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/capsule/resleever/tgui_data()
	var/list/data = list(
		"name" = occupant_name,
		"lace" = lace_name,
		"isOccupiedEjectable" = is_occupant_ejectable(),
		"is_lace_ejectable" = is_lace_ejectable(),
		"active" = resleeving,
		"remaining" = remaining_time,
		"timetosleeve" = 2 MINUTES,
		"ready" = can_start_sleeving()
	)

	return data

/obj/machinery/capsule/resleever/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("begin")
			sleeve()
			resleeving = TRUE
		if("eject")
			go_out()
		if("ejectlace")
			eject_lace()
	update_icon()
	return TRUE

/obj/machinery/capsule/resleever/proc/finish_sleeving()
	remaining_time = 0
	resleeving = FALSE
	update_use_power(POWER_USE_IDLE)
	go_out()
	playsound(loc, 'sound/machines/ping.ogg', 100, 1)
	visible_message("\The [src] pings as it completes its procedure!")

/obj/machinery/capsule/resleever/proc/sleeve()
	if(lace && occupant)
		var/obj/item/organ/O = occupant.get_organ(lace.parent_organ)
		if(istype(O))
			lace.status &= ~ORGAN_CUT_AWAY // Ensure the lace is properly attached.
			lace.replaced(occupant, O)
			lace = null
			lace_name = null
	else
		return

/obj/machinery/capsule/resleever/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/organ/internal/stack))
		if(isnull(lace))
			to_chat(user, SPAN_NOTICE("You insert \the [I] into \the [src]."))
			user.drop_from_inventory(I)
			lace = I
			I.forceMove(src)
			lace_name = lace.backup ? lace.backup.name : "None"
			return
		else
			to_chat(user, SPAN_WARNING("\The [src] already has a neural lace inside it!"))
			return
	if(isWrench(I))
		if(isnull(occupant))
			anchored = !anchored
			visible_message("[user] [anchored ? "secures" : "unsecures"] \the [src] from the floor.", \
						"You [anchored ? "secure" : "unsecure"] \the [src] from the floor.")
			playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
		else
			to_chat(user, SPAN_WARNING("Can not do that while \the [src] is occupied."))

/obj/machinery/capsule/resleever/proc/eject_lace()
	if(isnull(lace))
		return
	lace.forceMove(loc)
	lace = null
	lace_name = null
