#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/holodeckcontrol
	name = T_BOARD("holodeck control console")
	build_path = /obj/machinery/computer/holodeck
	origin_tech = list(TECH_DATA = 2, TECH_BLUESPACE = 2)

	/// Whether console was emagged.
	var/emagged = FALSE
	/// Whether console had safeties disabled.
	var/safety_disabled = FALSE

/obj/item/circuitboard/holodeckcontrol/construct(obj/machinery/computer/holodeck/holo_control)
	. = ..()

	if(!.)
		return

	holo_control.emagged = emagged
	holo_control.safety_disabled = safety_disabled

/obj/item/circuitboard/holodeckcontrol/deconstruct(obj/machinery/computer/holodeck/holo_control)
	. = ..()

	if(!.)
		return

	emagged = holo_control.emagged
	safety_disabled = holo_control.safety_disabled
