/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"

/obj/machinery/mineral/unloading_machine/Process()
	if(!input_turf || !output_turf)
		locate_turfs()

	if (locate(/obj/structure/ore_box, input_turf))
		var/obj/structure/ore_box/BOX = locate(/obj/structure/ore_box, input_turf)
		var/i = 0
		for (var/obj/item/ore/O in BOX.contents)
			BOX.contents -= O
			O.loc = output_turf
			i++
			if (i>=10)
				return
	if (locate(/obj/item, input_turf))
		var/obj/item/O
		var/i
		for (i = 0; i<10; i++)
			O = locate(/obj/item, input_turf)
			if (O)
				O.loc = output_turf
			else
				return

	return
