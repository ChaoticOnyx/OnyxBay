#define DESTINATION_SPREAD_MAX 6
#define DESTINATION_SPREAD_MIN 1

/obj/machinery/teleporter_gate
	name = "Teleporter Gate"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele_gate_off"
	icon = 'icons/obj/machines/teleporter.dmi'
	density = TRUE
	anchored = TRUE
	idle_power_usage = 10 WATTS
	active_power_usage = 2 KILO WATTS

	light_color = "#7de1e1"

	var/engaged = FALSE
	var/calibrated = FALSE
	var/accuracy
	var/calc_acceleration
	var/obj/machinery/computer/teleporter/console

	component_types = list(
	/obj/item/stock_parts/matter_bin = 2,
	/obj/item/stock_parts/capacitor = 2
	)

/obj/machinery/teleporter_gate/update_icon()
	overlays.Cut()
	if(console && (get_dir(console, src) == EAST))
		LAZYADD(overlays, image(icon, src, "tele_gate_wiring"))

	if(!engaged || stat & (BROKEN | NOPOWER))
		icon_state = "tele_gate_off"
		set_light(0)
	else
		flick(image(icon, "tele_gate_boot"), src)
		icon_state = "tele_gate_on"
		LAZYADD(overlays, image(icon, "tele_gate_galaxy"))
		set_light(0.25, 0.1, 2, 3.5, light_color)

	return

/obj/machinery/teleporter_gate/proc/link_console()
	if(console)
		return
	for(var/direction in GLOB.cardinal)
		console = locate() in get_step(src, direction)
		if(console)
			console.link_gate()
			break
	update_icon()

/obj/machinery/teleporter_gate/RefreshParts()
	var/acc_modifier
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		acc_modifier += B.rating
	accuracy = acc_modifier

	var/calc_modifier
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		calc_modifier += C.rating
	calc_acceleration = calc_modifier / 2

	return ..()

/obj/machinery/teleporter_gate/Initialize()
	. = ..()
	link_console()
	RefreshParts()

/obj/machinery/teleporter_gate/Destroy()
	if(console)
		console.gate = null
		console.update_icon()
		console = null
	return ..()

/obj/machinery/teleporter_gate/dismantle()
	if(console)
		console.gate = null
		console.update_icon()
		console = null
	return ..()

/obj/machinery/teleporter_gate/attackby(obj/item/I, mob/user)
	if(!engaged && default_deconstruction_screwdriver(user, I, FALSE))
		return
	if(default_deconstruction_crowbar(user, I))
		return
	return ..()

/obj/machinery/teleporter_gate/proc/is_ready()
	return !panel_open && engaged && !(stat & (BROKEN | NOPOWER)) && console && !(console.stat & (BROKEN | NOPOWER))

/obj/machinery/teleporter_gate/proc/teleport(atom/movable/AM)
	if(QDELETED(console))
		return

	var/atom/target
	if(console.target_ref)
		target = console.target_ref.resolve()
	if(!target)
		visible_message(SPAN_WARNING("Failure: Cannot authenticate locked on coordinates. Please reinstate coordinate matrix."))

	if(istype(AM))
		use_power_oneoff(5 KILO WATTS)
		do_teleport(AM, target, calibrated ? 0 : clamp(DESTINATION_SPREAD_MIN, 10 - accuracy, DESTINATION_SPREAD_MAX))
		calibrated = FALSE
		console?.update_icon()

	return

/obj/machinery/teleporter_gate/Bumped(AM)
	if(is_ready())
		teleport(AM)
