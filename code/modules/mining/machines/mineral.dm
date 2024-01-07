#define HOLOHELPER_DECAY_TIME 10 SECONDS

//. Generic mineral machine with some useful procs & variables. ~ Max
/obj/machinery/mineral
	dir = SOUTH
	density = TRUE
	anchored = TRUE
	idle_power_usage = 15 WATTS
	active_power_usage = 50 WATTS
	icon = 'icons/obj/machines/mining_machines.dmi'
	stat = POWEROFF // So it is toggled of by default
	/// Variable used for icon_update() as by default mining machinery has a specific icon for mappers' comfort
	var/gameicon
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
	update_icon()
	verbs += /obj/machinery/mineral/proc/toggle_holo
	register_input_turf()

/obj/machinery/mineral/attackby(obj/item/W, mob/user)
	if(!(stat & POWEROFF))
		to_chat(user, SPAN_WARNING("Turn off the machine first!"))
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
		show_splash_text(user, "you rotate \the [src]!")
		unregister_input_turf()
		register_input_turf()

/// Just in case the machine was moved - we re-register the input turf
/obj/machinery/mineral/Move()
	. = ..()
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

	to_chat(SPAN_NOTICE("[usr] toggles holo-projector on"))
	holohelper = weakref(new holodir_helper_path(loc, src))

/obj/machinery/mineral/power_change()
	. = ..()
	if(. && (stat & (NOPOWER|POWEROFF)))
		toggle(FALSE)

/// Generic proc to toggle mining machinery on/off. Can be used also as enable/disable() procs - just set the override_value to true/false
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
	..()
	ClearOverlays()
	set_light(0)
	icon_state = "[gameicon][(stat & POWEROFF) ? "-off" : ""]"
	if(!(stat & POWEROFF) && ea_color)
		set_light(1, 0, 3, 3.5, ea_color)
		AddOverlays(emissive_appearance(icon, "[gameicon]_ea"))

/obj/machinery/mineral/Destroy()
	unregister_input_turf()
	return ..()

/obj/effect/holodir_helper
	icon = 'icons/effects/holo_dirs.dmi'
	icon_state = "holo-arrows"
	pixel_y = -16
	pixel_x = -16
	alpha = 210

/obj/effect/holodir_helper/Initialize(loc, atom/movable/parent_machine)
	. = ..()
	if(parent_machine)
		dir = parent_machine.dir
		register_signal(parent_machine, SIGNAL_DIR_SET, nameof(.proc/on_machinery_rotated))
		register_signal(parent_machine, SIGNAL_QDELETING, nameof(/datum.proc/qdel_self))
		update_icon()
		QDEL_IN(src, HOLOHELPER_DECAY_TIME)
	else
		return INITIALIZE_HINT_QDEL

/obj/effect/holodir_helper/on_update_icon()
	set_light(1, 0, 3, 3.5,  "#0090F8")
	AddOverlays(emissive_appearance(icon, "[icon_state]_ea"))

/obj/effect/holodir_helper/proc/on_machinery_rotated(atom, old_dir, dir)
	src.dir = dir

#undef HOLOHELPER_DECAY_TIME
