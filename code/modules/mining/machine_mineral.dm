//. Generic mineral machine with some useful procs & variables. ~ Max
/obj/machinery/mineral
	dir = NORTH
	density = TRUE
	anchored = TRUE
	idle_power_usage = 15 WATTS
	active_power_usage = 50 WATTS
	icon = 'icons/obj/machines/mining_machines.dmi'
	/// Whether holographic indicators of input & output turfs are active or not.
	var/holo_active = FALSE
	/// The current direction of `input_turf`, in relation to the machine.
	var/input_dir = SOUTH
	/// The current direction, in relation to the machine, that items will be output to.
	var/output_dir = NORTH
	/// The turf the machines listens to for items to pick up. Calls the `pickup_item()` proc.
	var/turf/input_turf = null
	/// State of the machine
	var/active = FALSE
	/// Color used for EA of the machine
	var/ea_color

/obj/machinery/mineral/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/mineral/LateInitialize()
	..()
	update_icon()
	verbs += /obj/machinery/mineral/proc/toggle_holo
	register_input_turf()

/obj/machinery/mineral/attackby(obj/item/W, mob/user)
	if(active)
		to_chat(user, SPAN_WARNING("Turn off the machine first!"))
		return

	if(default_deconstruction_screwdriver(user, W))
		return

	else if(default_part_replacement(user, W))
		return

	else if(isWrench(W) && panel_open)
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
		set_dir(turn(dir, 90))
		unregister_input_turf()
		register_input_turf()
		return

/// Just in case the machine was moved - we re-register the input turf
/obj/machinery/mineral/Move()
	. = ..()
	unregister_input_turf()
	register_input_turf()

/// This proc finds & stores the input turf which will be listened for incoming items.
/obj/machinery/mineral/proc/register_input_turf()
	input_turf = get_step(src, input_dir)
	if(input_turf)
		register_signal(input_turf, SIGNAL_ENTERED, nameof(.proc/pickup_item))

/obj/machinery/mineral/proc/unregister_input_turf()
	if(input_turf)
		unregister_signal(input_turf, SIGNAL_ENTERED)
		input_turf = null

/// Base proc for pickup behaviour of subtypes.
/obj/machinery/mineral/proc/pickup_item(datum/source, atom/movable/target, atom/old_loc)
	if(stat & (NOPOWER|BROKEN) || !active)
		return FALSE

	if(QDELETED(target))
		return FALSE

	return TRUE

/// Used to check input turf for items after the machine was toggled ON
/obj/machinery/mineral/proc/check_input_turf()
	if(!input_turf)
		return

	for(var/atom/movable/possible_target in input_turf.contents)
		pickup_item(input_turf, possible_target)

/obj/machinery/mineral/proc/unload_item(atom/movable/item_to_unload)
	item_to_unload.forceMove(drop_location())
	var/turf/unload_turf = get_step(src, output_dir)
	if(unload_turf)
		item_to_unload.forceMove(unload_turf)

/obj/machinery/mineral/proc/toggle_holo()
	set name = "Toggle holo-helper"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return FALSE

	holo_active = !holo_active
	to_chat(SPAN_NOTICE("[usr] toggles holo-projector [holo_active ? "on" : "off"]."))
	update_icon()

/obj/machinery/mineral/power_change()
	. = ..()
	if(. && (stat & NOPOWER) && active)
		toggle(FALSE)

/// Generic proc to toggle mining machinery on/off. Can be used also as enable/disable() procs - just set the override_value to true/false
/obj/machinery/mineral/proc/toggle(override_value = null)
	if(!isnull(override_value))
		active = override_value
	else
		active = !active

	if(active)
		START_PROCESSING(SSmachines, src)
		check_input_turf()
	else
		STOP_PROCESSING(SSmachines, src)
	update_icon()

/obj/machinery/mineral/on_update_icon()
	..()
	ClearOverlays()
	set_light(0)
	icon_state = "[initial(icon_state)][active ? "" : "-off"]"
	if(holo_active)
		var/image/I = image('icons/obj/machines/holo_dirs.dmi', "holo-arrows")
		I.pixel_x = -16
		I.pixel_y = -16
		I.alpha = 210
		AddOverlays(I)
	if(active && ea_color)
		set_light(1, 0, 3, 3.5, ea_color)
		AddOverlays(emissive_appearance(icon, "[icon_state]_ea"))

/obj/machinery/mineral/Destroy()
	unregister_input_turf()
	return ..()
