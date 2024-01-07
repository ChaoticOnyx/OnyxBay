/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon_state = "unloader-map"
	gameicon = "unloader"

	component_types = list(
		/obj/item/circuitboard/unloading_machine,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/scanning_module
	)

/obj/machinery/mineral/unloading_machine/pickup_item(datum/source, atom/movable/target, atom/old_loc)
	if(!..())
		return

	if(istype(target, /obj/structure/ore_box))
		var/obj/structure/ore_box/ore_box = target
		for(var/obj/item/I in ore_box)
			unload_item(I)

	else if(istype(target, /obj/item))
		unload_item(target)

/obj/machinery/mineral/unloading_machine/attack_hand(mob/user)
	if(stat & (NOPOWER | BROKEN)) // Unfortunately we can't simply call parent here as parent checks include POWEROFF flag.
		return

	if(user.lying || user.is_ic_dead())
		return

	if(!ishuman(user) && !issilicon(user))
		to_chat(usr, SPAN_WARNING("You don't have the dexterity to do this!"))
		return

	toggle()
	to_chat(user, SPAN_NOTICE("You toggle \the [src] [stat & POWEROFF ? "on" : "off"]."))
