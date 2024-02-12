//. Generic mineral machine with some useful procs & variables. ~ Max
/obj/machinery/mineral
	dir = SOUTH
	density = TRUE
	anchored = TRUE
	idle_power_usage = 15 WATTS
	active_power_usage = 50 WATTS
	icon = 'icons/obj/machines/mining_machines.dmi'
	stat = POWEROFF // So it is toggled of by default

	/// Holographic indicators of input & output turfs.
	var/weakref/holohelper
	/// The turf the machines listens to for items to pick up. Calls the `pickup_item()` proc.
	var/turf/input_turf = null
	/// Color used for EA of the machine
	var/ea_color
	///Path of the holographic helper overlay
	var/holodir_helper_path = /obj/effect/holodir_helper

/obj/machinery/mineral/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/mineral/LateInitialize()
	..()
	verbs += /obj/machinery/mineral/proc/toggle_holo
	register_signal(src, SIGNAL_MOVED, nameof(.proc/on_moved))
	update_icon()
	register_input_turf()

/obj/machinery/mineral/attackby(obj/item/W, mob/user)
	if(!(stat & POWEROFF))
		show_splash_text(user, "turn off first!")
		return

	if(default_deconstruction_screwdriver(user, W))
		return

	else if(default_deconstruction_crowbar(user, W))
		return

	else if(default_part_replacement(user, W))
		return

	else if(isWrench(W) && panel_open)
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
		set_dir(turn(dir, 90))
		unregister_input_turf()
		register_input_turf()

/// Just in case the machine was moved - we re-register the input turf
/obj/machinery/mineral/proc/on_moved()
	unregister_input_turf()
	register_input_turf()

/// This proc finds & stores the input turf which will be listened for incoming items.
/obj/machinery/mineral/proc/register_input_turf()
	input_turf = get_step(src, GLOB.flip_dir[dir])
	if(input_turf)
		register_signal(input_turf, SIGNAL_ENTERED, nameof(.proc/pickup_item))

/obj/machinery/mineral/proc/unregister_input_turf()
	if(input_turf)
		unregister_signal(input_turf, SIGNAL_ENTERED)
		input_turf = null

/// Base proc for pickup behaviour of subtypes.
/obj/machinery/mineral/proc/pickup_item(datum/source, atom/movable/target, atom/old_loc)
	if(stat & (NOPOWER|BROKEN|POWEROFF))
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
	var/turf/unload_turf = get_step(src, dir)
	if(unload_turf)
		item_to_unload.forceMove(unload_turf)

/obj/machinery/mineral/AltClick(mob/user)
	toggle_holo(user)

/obj/machinery/mineral/proc/toggle_holo()
	set name = "Toggle holo-helper"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return FALSE

	var/obj/effect/holodir_helper/hhelper = holohelper?.resolve()

	if(istype(hhelper))
		qdel(hhelper)

	show_splash_text(usr, "holo-projector enabled.")
	holohelper = weakref(new holodir_helper_path(loc, src))

/obj/machinery/mineral/power_change()
	. = ..()
	if(. && (stat & (NOPOWER|POWEROFF)))
		toggle(FALSE)

/// Generic proc to toggle mining machinery on/off. Can be used also as enable/disable() procs - just call it with the override_value true/false
/obj/machinery/mineral/proc/toggle(override_value = null)
	if(override_value == TRUE)
		stat |= POWEROFF
	else if(override_value == FALSE)
		stat &= ~POWEROFF
	else if(stat & POWEROFF)
		stat &= ~POWEROFF
	else
		stat |= POWEROFF

	if(stat & POWEROFF)
		STOP_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSmachines, src)
		check_input_turf()
	update_icon()

/obj/machinery/mineral/on_update_icon()
	ClearOverlays()

	icon_state = "[base_icon_state][(stat & (NOPOWER|POWEROFF)) ? "-off" : ""]"

	var/should_glow = update_glow()
	if(should_glow)
		AddOverlays(emissive_appearance(icon, "[base_icon_state]_ea"))

/obj/machinery/mineral/proc/update_glow()
	if(!ea_color || (stat & (NOPOWER|BROKEN|POWEROFF)))
		set_light(0)
		return FALSE

	set_light(1, 0, 3, 3.5, ea_color)
	return TRUE

/obj/machinery/mineral/Destroy()
	unregister_input_turf()
	unregister_signal(src, SIGNAL_MOVED)
	return ..()
