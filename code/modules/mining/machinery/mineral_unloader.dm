/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon_state = "unloader"
	input_turf =  WEST
	output_turf = EAST

/obj/machinery/mineral/unloading_machine/New()
	..()
	component_parts = list(
		new /obj/item/stock_parts/manipulator(src),
		new /obj/item/stock_parts/manipulator(src),
		new /obj/item/circuitboard/mining_unloader(src)
		)

/obj/machinery/mineral/unloading_machine/Process()
	if(input_turf && output_turf)
		var/ore_this_tick = 25
		for(var/obj/structure/ore_box/unloading in input_turf)
			for(var/obj/item/ore/_ore in unloading)
				_ore.dropInto(output_turf)
				if(--ore_this_tick<=0) return
		for(var/obj/item/_ore in input_turf)
			if(_ore.simulated && !_ore.anchored)
				_ore.dropInto(output_turf)
				if(--ore_this_tick<=0) return
