/datum/extension/ship_engine/ion_thruster
	expected_type = /obj/machinery/ion_thruster

/datum/extension/ship_engine/ion_thruster/burn(partial = 1)
	var/obj/machinery/ion_thruster/thruster = holder
	if(istype(thruster) && thruster.get_thrust(partial))
		return get_exhaust_velocity() * thruster.thrust_effectiveness
	return 0

/datum/extension/ship_engine/ion_thruster/get_exhaust_velocity()
	. = 300 // Arbitrary value based on being slightly less than a default configuration gas engine.

/datum/extension/ship_engine/ion_thruster/get_specific_wet_mass()
	. = 1.5 // Arbitrary value based on being slightly less than a default configuration gas engine.

/datum/extension/ship_engine/ion_thruster/has_fuel()
	var/obj/machinery/ion_thruster/thruster = holder
	. = istype(thruster) && !(thruster.stat & NOPOWER)

/datum/extension/ship_engine/ion_thruster/get_status()
	. = list()
	. += ..()
	var/obj/machinery/ion_thruster/thruster = holder
	if(!istype(thruster))
		. += "Hardware failure - check machinery."
	else if(thruster.stat & NOPOWER)
		. += "Insufficient power or hardware offline."
	else
		. += "Online."
	return jointext(.,"<br>")

/obj/machinery/ion_thruster
	name = "ion thruster"
	desc = "An advanced propulsion device, using energy and minute amounts of gas to generate thrust."
	icon = 'icons/obj/ship_engine.dmi'
	icon_state = "nozzle2"
	density = TRUE
	power_channel = STATIC_ENVIRON
	idle_power_usage = 100
	anchored = TRUE
	use_power = POWER_USE_IDLE

	// TODO: modify these with upgraded parts?
	var/thrust_limit = 1
	var/thrust_cost = 750
	var/thrust_effectiveness = 1

/obj/machinery/ion_thruster/attackby(obj/item/I, mob/user)
	if(isMultitool(I) && !panel_open)
		var/datum/extension/ship_engine/engine = get_extension(src, /datum/extension/ship_engine)
		if(engine.sync_to_ship())
			to_chat(user, SPAN_NOTICE("\The [src] emits a ping as it syncs its controls to a nearby ship."))
		else
			to_chat(user, SPAN_WARNING("\The [src] flashes an error!"))
		return TRUE

	. = ..()

/obj/machinery/ion_thruster/proc/get_thrust()
	if(!use_power || (stat & NOPOWER))
		return 0
	return thrust_limit

/obj/machinery/ion_thruster/on_update_icon()
	ClearOverlays()
	if(!(stat & (NOPOWER | BROKEN)))
		AddOverlays(emissive_appearance(icon, "ion_glow"))

/obj/machinery/ion_thruster/power_change()
	. = ..()
	queue_icon_update()

/obj/machinery/ion_thruster/Initialize()
	. = ..()
	set_extension(src, /datum/extension/ship_engine/ion_thruster, "ion thruster")

/obj/item/stock_parts/circuitboard/engine/ion
	name = "circuitboard (ion thruster)"
	//board_type = "machine"
	//icon = 'icons/obj/modules/module_controller.dmi'
	origin_tech = @'{"powerstorage":1,"engineering":2}'
