/**
 * # Destructive scanner
 *
 * Placed machine that handles destructive experiments (but can also do the normal ones)
 */
/obj/machinery/destructive_scanner
	name = "Experimental Destructive Scanner"
	desc = "A much larger version of the hand-held scanner, a charred label warns about its destructive capabilities."
	icon = 'icons/obj/machines/experisci.dmi'
	icon_state = "tube_open"
	circuit = /obj/item/circuitboard/machine/destructive_scanner
	layer = MOB_LAYER
	var/scanning = FALSE

/obj/machinery/destructive_scanner/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

// Late load to ensure the component initialization occurs after the machines are initialized
/obj/machinery/destructive_scanner/LateInitialize()
	. = ..()
	AddComponent(/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/scanning),\
		config_mode = EXPERIMENT_CONFIG_CLICK, \
		start_experiment_callback = CALLBACK(src, PROC_REF(activate)))

///Activates the machine; checks if it can actually scan, then starts.
/obj/machinery/destructive_scanner/proc/activate()
	var/atom/pickup_zone = drop_location()
	var/aggressive = FALSE
	for(var/mob/living/living_mob in pickup_zone)
		if(!emagged && ishuman(living_mob)) //Can only kill humans when emagged.
			playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
			say("Cannot scan with humans inside.")
			return
		aggressive = TRUE
	start_closing(aggressive)
	use_power(idle_power_usage)

///Closes the machine to kidnap everything in the turf into it.
/obj/machinery/destructive_scanner/proc/start_closing(aggressive)
	if(scanning)
		return
	var/atom/pickup_zone = drop_location()
	for(var/atom/movable/to_pickup in pickup_zone)
		to_pickup.forceMove(src)
	flick("tube_down", src)
	scanning = TRUE
	update_icon()
	playsound(src, 'sound/machines/destructive_scanner/TubeDown.ogg', 100)
	use_power(idle_power_usage)
	addtimer(CALLBACK(src, PROC_REF(start_scanning), aggressive), 1.2 SECONDS)

///Starts scanning the fancy scanning effects
/obj/machinery/destructive_scanner/proc/start_scanning(aggressive)
	if(aggressive)
		playsound(src, 'sound/machines/destructive_scanner/ScanDangerous.ogg', 100, extrarange = 5)
	else
		playsound(src, 'sound/machines/destructive_scanner/ScanSafe.ogg', 100)
	use_power(active_power_usage)
	addtimer(CALLBACK(src, PROC_REF(finish_scanning), aggressive), 6 SECONDS)


///Performs the actual scan, happens once the tube effects are done
/obj/machinery/destructive_scanner/proc/finish_scanning(aggressive)
	flick("tube_up", src)
	scanning = FALSE
	update_icon()
	playsound(src, 'sound/machines/destructive_scanner/TubeUp.ogg', 100)
	addtimer(CALLBACK(src, PROC_REF(open), aggressive), 1.2 SECONDS)

///Opens the machine to let out any contents. If the scan had mobs it'll gib them.
/obj/machinery/destructive_scanner/proc/open(aggressive)
	var/turf/this_turf = get_turf(src)
	var/list/scanned_atoms = list()

	for(var/atom/movable/movable_atom in contents)
		if(movable_atom in component_parts)
			continue
		scanned_atoms += movable_atom
		movable_atom.forceMove(this_turf)
		if(isliving(movable_atom))
			var/mob/living/fucked_up_thing = movable_atom
			fucked_up_thing.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
			fucked_up_thing.gib()

	SEND_SIGNAL(src, COMSIG_MACHINERY_DESTRUCTIVE_SCAN, scanned_atoms)


/obj/machinery/destructive_scanner/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	playsound(src, SFX_SPARKS, 75, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_notice("You disable the safety sensor BIOS on [src]."))

/obj/machinery/destructive_scanner/update_icon_state()
	. = ..()
	icon_state = scanning ? "tube_on" : "tube_open"

/obj/machinery/destructive_scanner/attackby(obj/item/object, mob/user, params)
	if (!scanning && default_deconstruction_screwdriver(user, "tube_open", "tube_open", object) || default_deconstruction_crowbar(object))
		update_icon()
		return
	return ..()
