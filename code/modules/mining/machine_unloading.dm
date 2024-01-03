/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"

/obj/machinery/mineral/unloading_machine/pickup_item(datum/source, atom/movable/target, atom/old_loc)
	if(istype(target, /obj/structure/ore_box))
		var/obj/structure/ore_box/ore_box = target
		for(var/obj/item/I in ore_box)
			unload_item(I)

	else if(istype(target, /obj/item))
		unload_item(target)
