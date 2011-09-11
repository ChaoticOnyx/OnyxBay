obj/item/weapon/pipe_segment
	name = "pipe segment"
	desc = "This is a segment of pipe."
	icon = 'regular.dmi'
	icon_state = "segment"
	m_amt = 7500

obj/item/weapon/pipe_segment/bent
	name = "90 degree pipe segment"
	desc = "This is a segment of pipe that has been bent 90 degrees."
	dir = 5


obj/item/weapon/pipe_segment/attack_hand(mob/user as mob)
	if(user.stat >= 2 || user.restrained())
		return
	if(anchored)
		user << "This pipe segment is wrenched in place and can't be picked up."
		return
	..()

obj/item/weapon/pipe_segment/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(user.stat >= 2 || user.restrained())
		return
	if(istype(W,/obj/item/weapon/weldingtool) && icon_state == "segment" && !anchored)
		user << "You weld a hole in the pipe segment"
		desc = "This is a segment of pipe with a hole in it about the right size for another segment of pipe to fit into."
		icon_state = "segment_weld"

	if(istype(W,/obj/item/weapon/pipe_segment) && icon_state == "segment_weld")
		user << "You put the two pipe segments together in a T shape"
		desc = "This is two pipe segments loosely put together in a T shape.  They could easily come apart."
		icon_state = "manifold"
		del(W)

	if(istype(W,/obj/item/weapon/weldingtool) && icon_state == "manifold")
		user << "You weld the two pipe segments together, forming a nice three-way manifold."
		desc = "This is a pipe manifold."
		icon_state = "manifold_weld"

	if(istype(W,/obj/item/weapon/wrench))
		var/turf/T = src.loc
		if(!istype(T,/turf/simulated))
			..()
			return
		if(anchored)
			anchored = 0
			user << "You wrench the pipe out of place."
		else
			for(var/obj/machinery/atmospherics/pipe/pipetest in T)
				if(pipetest.initialize_directions & src.dir)
					user << "There is already a pipe there!"
					return

			anchored = 1
			user << "You wrench the pipe into place"

	if(istype(W,/obj/item/weapon/weldingtool) && anchored == 1 && icon_state == "segment")
		var/obj/machinery/atmospherics/pipe/simple/newpipe = new/obj/machinery/atmospherics/pipe/simple(src.loc)
		var/turf/T = newpipe.loc
		if(T.intact)
			newpipe.level = 2
		else
			newpipe.level = 1
		newpipe.dir = src.dir
		switch(newpipe.dir)
			if(SOUTH,NORTH)
				newpipe.initialize_directions = SOUTH|NORTH
			if(WEST,EAST)
				newpipe.initialize_directions = WEST|EAST
			if(NORTHEAST)
				newpipe.initialize_directions = NORTH|EAST
			if(NORTHWEST)
				newpipe.initialize_directions = NORTH|WEST
			if(SOUTHEAST)
				newpipe.initialize_directions = SOUTH|EAST
			if(SOUTHWEST)
				newpipe.initialize_directions = SOUTH|WEST
		newpipe.initialize()
		if(newpipe.node1)
			newpipe.node1:initialize()
		if(newpipe.node2)
			newpipe.node2:initialize()
		//if(newpipe:node3)
		//	newpipe:node3:initialize()
		user << "You weld the pipe segment, finishing it's placement."
		del(src)

	if(istype(W,/obj/item/weapon/weldingtool) && anchored == 1 && icon_state == "manifold_weld")
		var/obj/machinery/atmospherics/pipe/manifold/newpipe = new/obj/machinery/atmospherics/pipe/manifold(src.loc)
		newpipe.dir = src.dir
		switch(newpipe.dir)
			if(NORTH)
				newpipe.initialize_directions = EAST|SOUTH|WEST
			if(SOUTH)
				newpipe.initialize_directions = WEST|NORTH|EAST
			if(EAST)
				newpipe.initialize_directions = SOUTH|WEST|NORTH
			if(WEST)
				newpipe.initialize_directions = NORTH|EAST|SOUTH

		newpipe.initialize()
		world << "durr"
		if(newpipe.node1)
			newpipe.node1:initialize()
		if(newpipe.node2)
			newpipe.node2:initialize()
		if(newpipe:node3)
			newpipe:node3:initialize()
		del(src)

/obj/item/weapon/pipe_segment/verb/rotate()
	set src in view(1)
	if ( usr.stat || usr.restrained() )
		return
	switch(dir)
		if(1)
			dir = 4
		if(2)
			dir = 8
		if(4)
			dir = 2
		if(8)
			dir = 1
		if(5)
			dir = 6
		if(6)
			dir = 10
		if(10)
			dir = 9
		if(9)
			dir = 5




