/turf/simulated/floor/ex_act(severity)
	//set src in oview(1)
	switch(severity)
		if(1.0)
			src.ChangeTurf(get_base_turf_by_area(src))
		if(2.0)
			switch(pick(40;1,40;2,3))
				if (1)
					if(prob(33)) new /obj/item/stack/material/steel(src)
					src.ReplaceWithLattice()
				if(2)
					src.ChangeTurf(get_base_turf_by_area(src))
				if(3)
					if(prob(33)) new /obj/item/stack/material/steel(src)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)

	var/temp_destroy = get_damage_temperature()
	if(!burnt && prob(5))
		burn_tile(exposed_temperature)
	else if(temp_destroy && exposed_temperature >= (temp_destroy + 100) && prob(1) && !is_plating())
		make_plating() //destroy the tile, exposing plating
		burn_tile(exposed_temperature)
	return

//should be a little bit lower than the temperature required to destroy the material
/turf/simulated/floor/proc/get_damage_temperature()
	return flooring ? flooring.damage_temperature : null

/turf/simulated/floor/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	var/dir_to = get_dir(src, adj_turf)

	for(var/obj/structure/window/W in src)
		if(W.dir == dir_to || W.is_full_window) //Same direction or diagonal (full tile)
			W.fire_act(adj_air, adj_temp, adj_volume)

	for(var/obj/structure/window_frame/WF in src)
		WF.fire_act(adj_air, adj_temp, adj_volume)

/turf/simulated/floor/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_TURF)
			var/obj/structure/girder/girder = locate() in src
			if(girder)
				return girder.rcd_vals(user, the_rcd)

			return rcd_result_with_memory(
				list("delay" = 2 SECONDS, "cost" = 16),
				src, RCD_MEMORY_WALL,
			)

		if(RCD_WINDOWFRAME) //default cost for building a window_frame
			var/cost = 5
			var/delay = 1 SECONDS
			if(the_rcd.rcd_design_path  == /obj/structure/window_frame/glass)
				cost = 10
				delay = 2.5 SECONDS
			else if(the_rcd.rcd_design_path  == /obj/structure/window_frame/rglass)
				cost = 20
				delay = 3 SECONDS
			else if(the_rcd.rcd_design_path == /obj/structure/window_frame/grille/glass)
				cost = 22
				delay = 3 SECONDS
			else if(the_rcd.rcd_design_path == /obj/structure/window_frame/grille/rglass)
				cost = 25
				delay = 4 SECONDS
			else if(the_rcd.rcd_design_path == /obj/structure/window/reinforced/full)
				cost = 15
				delay = 3 SECONDS

			return rcd_result_with_memory(
				list("delay" = delay, "cost" = cost),
				src, RCD_MEMORY_WINDOWGRILLE,
			)

		if(RCD_WINDOWSMALL)
			if(the_rcd.rcd_design_path == /obj/structure/window/basic)
				return list("delay" = 1.5 SECONDS, "cost" = 5)
			else if(the_rcd.rcd_design_path == /obj/structure/window/reinforced)
				return list("delay" = 1.8 SECONDS, "cost" = 8)

		if(RCD_AIRLOCK)
			if(ispath(the_rcd.rcd_design_path, /obj/machinery/door/airlock/glass))
				return list("delay" = 5 SECONDS, "cost" = 20)
			else
				return list("delay" = 5 SECONDS, "cost" = 16)

		if(RCD_STRUCTURE)
			var/static/list/structure_costs = list(
				/obj/structure/girder = list("delay" = 1.5 SECONDS, "cost" = 10),
				/obj/structure/computerframe = list("delay" = 2 SECONDS, "cost" = 20),
				/obj/machinery/constructable_frame = list("delay" = 2 SECONDS, "cost" = 20),
				/obj/machinery/vending_frame = list("delay" = 2 SECONDS, "cost" = 20),
				/obj/item/stool = list("delay" = 0.5 SECONDS, "cost" = 4),
				/obj/structure/table = list("delay" = 2 SECONDS, "cost" = 8),
				/obj/structure/bed = list("delay" = 2.5 SECONDS, "cost" = 8),
				/obj/structure/table = list("delay" = 2 SECONDS, "cost" = 4),
				/obj/structure/table/reinforced = list("delay" = 3 SECONDS, "cost" = 10),
			)

			var/list/design_data = structure_costs[the_rcd.rcd_design_path]
			if(!isnull(design_data))
				return design_data

			for(var/structure in structure_costs)
				if(ispath(the_rcd.rcd_design_path, structure))
					return structure_costs[structure]

			return FALSE

		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 5 SECONDS, "cost" = 33)

	return FALSE

/// if you are updating this make to to update /turf/open/misc/rcd_act() too
/turf/simulated/floor/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_TURF)
			var/obj/structure/girder/girder = locate() in src
			if(girder)
				return girder.rcd_act(user, the_rcd, rcd_data)

			ChangeTurf(/turf/simulated/wall)
			return TRUE

		if(RCD_WINDOWFRAME)
			var/obj/structure/window_frame/window_frame_path = rcd_data["[RCD_DESIGN_PATH]"]
			if(!ispath(window_frame_path))
				CRASH("Invalid window path type in RCD: [window_frame_path]")

			new window_frame_path(src)

		if(RCD_WINDOWSMALL)
			//check if we are building a window
			var/obj/structure/window/window_path = rcd_data["[RCD_DESIGN_PATH]"]
			if(!ispath(window_path))
				CRASH("Invalid window path type in RCD: [window_path]")

			//allow directional windows to be built without grills
			if(!initial(window_path.is_full_window))
				new window_path(src, user.dir)
				return TRUE

			//build grills to deal with full tile windows
			if(locate(/obj/structure/grille) in src)
				return FALSE

			new /obj/structure/grille(src)
			return TRUE

		if(RCD_AIRLOCK)
			var/obj/machinery/door/airlock_type = rcd_data["[RCD_DESIGN_PATH]"]

			if(ispath(airlock_type, /obj/machinery/door/window))
				for(var/obj/machinery/door/door in src)
					if(istype(door, /obj/machinery/door/window))
						continue
					show_splash_text(user, "there's already a door!", "\icon[src] There's already a door!")
					return FALSE

				var/obj/structure/windoor_assembly/assembly = new (src, user.dir)
				assembly.secure = ispath(airlock_type, /obj/machinery/door/window/brigdoor)
				assembly.electronics = the_rcd.airlock_electronics.create_copy(assembly)
				assembly.finish_door()
				return TRUE

			for(var/obj/machinery/door/door in src)
				if(istype(door, /obj/machinery/door/firedoor))
					continue

				show_splash_text(user, "there's already a door!", "There's already a door!")
				return FALSE

			//create the assembly and let it finish itself
			var/obj/machinery/door/airlock/airlock = airlock_type
			var/assembly_path = airlock::assembly_type
			var/obj/structure/door_assembly/assembly = new assembly_path(src)
			if(initial(airlock_type.glass))
				assembly.glass = TRUE
				assembly.glass_type = airlock_type
			else
				assembly.airlock_type = airlock_type
			assembly.electronics = the_rcd.airlock_electronics.create_copy(assembly)
			assembly.finish_door()
			return TRUE

		if(RCD_STRUCTURE)
			var/atom/movable/design_type = rcd_data["[RCD_DESIGN_PATH]"]

			//map absolute types to basic subtypes
			var/atom/movable/locate_type = design_type
			if(locate(locate_type) in src)
				return FALSE

			var/atom/movable/design = new design_type(src)
			design.set_dir(user.dir)

			return TRUE

		if(RCD_DECONSTRUCT)
			if(rcd_proof)
				show_splash_text(user, "it's too thick!", "\icon[src] It's too thick!")
				return FALSE

			dismantle_floor()
			return TRUE

	return FALSE
