/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon_state = "unloader"

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
	if(..())
		return

	toggle()
	to_chat(user, SPAN_NOTICE("You toggle \the [src] [active ? "on" : "off"]."))
