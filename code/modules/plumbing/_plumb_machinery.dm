/obj/machinery/plumbing
	name = "pipe thing"
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	density = TRUE
	active_power_usage = 10 KILO WATTS

	///Plumbing machinery always has reagents.
	var/buffer = 50

/obj/machinery/plumbing/Initialize(mapload, bolt = TRUE)
	. = ..()
	anchored = bolt
	wrenched_change()
	create_reagents(buffer)
	AddElement(/datum/element/simple_rotation)

	SSmachines.machinery -= src
	STOP_PROCESSING(SSmachines, src)
	START_PROCESSING(SSplumbing, src)

/obj/machinery/plumbing/wrenched_change()
	. = ..()
	if(!anchored)
		STOP_PROCESSING(SSplumbing, src)
	else
		START_PROCESSING(SSplumbing, src)

/obj/machinery/plumbing/create_reagents(max_vol, flags)
	if(!ispath(reagents))
		qdel(reagents)
	reagents = new /datum/reagents(max_vol, src)

/obj/machinery/plumbing/examine(mob/user)
	. = ..()
	if(isobserver(user) || !in_range(src, user))
		return

	. += SPAN_NOTICE("The maximum volume display reads: <b>[reagents.maximum_volume]u capacity</b>. Contains:")
	if(reagents.total_volume)
		for(var/datum/reagent/reg as anything in reagents.reagent_list)
			. += SPAN_NOTICE("[round(reg.volume, 0.0001)]u of [reg.name]")
	else
		. += SPAN_NOTICE("Nothing.")

	if(anchored)
		. += SPAN_NOTICE("It's anchored in place.")
	else
		. += SPAN_WARNING("Needs to be anchored to start operations.")
		. += SPAN_NOTICE("It can be welded apart.")

	. += SPAN_NOTICE("A plunger can be used to flush out reagents.")

/obj/machinery/plumbing/plunger_act(obj/item/plunger/P, mob/living/user)
	visible_message(SPAN_NOTICE("[user] starts plunging \the [src]."), SPAN_NOTICE("You hear sound of plunging."))
	if(!do_after(user, 3 SECONDS, src) || QDELETED(src))
		return

	visible_message(SPAN_NOTICE("[user] emptied [src]'s internal reservoir."), SPAN_NOTICE("You hear sound of running liquid."))
	reagents?.splash(get_turf(src), reagents?.total_volume)

/obj/machinery/plumbing/tank
	name = "chemical tank"
	desc = "A massive chemical holding tank."
	icon_state = "tank"
	buffer = 400

/obj/machinery/plumbing/tank/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/tank, bolt, layer)
