/obj/machinery/factory
	name = "Factory machine"
	desc = "It's some factory machine that does... Nothing"
	icon_state = "autolathe"
	layer = BELOW_OBJ_LAYER
	anchored = 1
	density = 1
	idle_power_usage = 40
	active_power_usage = 300

	var/list/accepting_types = list() // list of type of things that allowed into machine
	var/list/atom/movable/items_inside = list()
	var/max_items = 6
	var/exit_dir
	var/is_working = FALSE
	var/machining_time = 10 SECONDS
	var/product_timer

/obj/machinery/factory/Initialize()
	. = ..()
	exit_dir = dir // TODO: add ability to change dir and exit dir by wrench

/obj/machinery/factory/Destroy()
	. = ..()
	QDEL_LIST(items_inside)

// TODO: load inside thing, must be Bumped from allowed dir (installed frame dir).
/obj/machinery/factory/Bump(atom/movable/A)
	. = ..()
	if(get_dir(A, src) == dir && !(length(items_inside) == max_items) && is_type_in_list(A, accepting_types))
		items_inside.Add(A)
		A.forceMove(src)
		if(!product_timer)
			product_timer = addtimer(CALLBACK(src, .proc/process_item), machining_time, TIMER_STOPPABLE)

/obj/machinery/factory/hitby(atom/movable/AM, speed, nomsg)
	. = ..()
	if(istype(AM))
		return Bump(AM)

/obj/machinery/factory/Process()
	. = ..()
	if(!can_process_item() && product_timer)
		deltimer(product_timer)
		product_timer = null
	else if(length(items_inside) && !product_timer && can_process_item())
		product_timer = addtimer(CALLBACK(src, .proc/process_item), machining_time, TIMER_STOPPABLE)


// process the thing inside machinery
/obj/machinery/factory/proc/process_item(atom/movable/current_atom)
	if(!can_process_item())
		return
	if(isnull(current_atom))
		current_atom = items_inside[length(items_inside)]
	items_inside.Remove(current_atom)
	product_timer = addtimer(CALLBACK(src, .proc/process_item), machining_time, TIMER_STOPPABLE)
	return TRUE

/obj/machinery/factory/proc/can_process_item()
	return is_working || !(stat & (NOPOWER|BROKEN))

// TODO: place the result of work on exit turf (reverse dir of accept)
/obj/machinery/factory/proc/eject_product(atom/movable/product)
	var/turf/T = get_step(src, exit_dir)
	if(!T || T.density)
		product.forceMove(get_turf(src))
		return
	product.forceMove(T)

/obj/machinery/factory/proc/get_status_message()
	return "\The [src] is [is_working ? "online" : "offline"]"

// Procedure that accept manipulation comms from factory console
/obj/machinery/factory/proc/process_action(mob/user, href_list, obj/machinery/factory_console/console)
	if(href_list["toggle"])
		is_working = !is_working
		if(is_working)
			update_use_power(POWER_USE_ACTIVE)
		else
			update_use_power(POWER_USE_IDLE)

		if(product_timer)
			deltimer(product_timer)
			product_timer = null

	return get_status_message()

// Function that returns a list of avaliable action
/obj/machinery/factory/proc/get_actions()
	var/list/actions = list(
		"toggle" = "Toggle \the [src]"
		)
	return actions
