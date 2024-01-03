//. Generic mineral machine with some useful procs & variables. ~ Max
/obj/machinery/mineral
	dir = NORTH
	density = TRUE
	anchored = TRUE
	/// Whether holographic indicators of input & output turfs are active or not.
	var/holo_active = FALSE
	/// The current direction of `input_turf`, in relation to the machine.
	var/input_dir = NORTH
	/// The current direction, in relation to the machine, that items will be output to.
	var/output_dir = SOUTH
	/// The turf the machines listens to for items to pick up. Calls the `pickup_item()` proc.
	var/turf/input_turf = null

/obj/machinery/mineral/Initialize()
	. = ..()
	verbs += /obj/machinery/mineral/proc/toggle_holo
	register_input_turf()

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
	pass()

/obj/machinery/mineral/proc/unload_item(atom/movable/item_to_unload)
	item_to_unload.forceMove(drop_location())
	var/turf/unload_turf = get_step(src, output_dir)
	if(unload_turf)
		item_to_unload.forceMove(unload_turf)

/obj/machinery/mineral/Move()
	. = ..()
	unregister_input_turf()
	register_input_turf()

/obj/machinery/mineral/update_icon()
	ClearOverlays()
	if(holo_active)
		var/image/I = image('icons/obj/machines/holo_dirs.dmi', "holo-arrows")
		I.pixel_x = -16
		I.pixel_y = -16
		I.alpha = 210
		AddOverlays(I)

/obj/machinery/mineral/proc/toggle_holo()
	set name = "Toggle holo-helper"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return FALSE

	holo_active = !holo_active
	to_chat(SPAN_NOTICE("[usr] toggles holo-projector [holo_active ? "on" : "off"]."))
	update_icon()

/obj/machinery/mineral/Destroy()
	unregister_input_turf()
	return ..()
