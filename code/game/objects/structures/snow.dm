/obj/structure/snow
	name = "snow"
	desc = "An extremely toxic precipitation."
	icon = 'icons/obj/snow2.dmi'
	icon_state = "snow1"
	anchored = 1
	density = 0
	layer = 2.45
	var/mineral = "metal"

/obj/structure/snow/Initialize()
	. = ..()
	for(var/obj/structure/snow/C in get_turf(src))
		if(C != src)
			qdel(C)
	update_icon()
	redraw_nearby_snows()


/obj/structure/snow/Destroy()
	redraw_nearby_snows()
	return ..()

/obj/structure/snow/proc/redraw_nearby_snows()
	for(var/direction in GLOB.alldirs)
		var/obj/structure/snow/L = locate() in get_step(src, direction)
		if(L)
			L.update_icon() //so siding get updated properly


/obj/structure/snow/update_icon()
	var/connectdir = 0
	for(var/direction in GLOB.cardinal)
		if(locate(/obj/structure/snow, get_step(src, direction)))
			connectdir |= direction

	//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
	var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW
	var/dirs = list(1,2,4,8)
	var/i = 1
	for(var/diag in list(NORTHEAST, SOUTHEAST,NORTHWEST,SOUTHWEST))
		if((connectdir & diag) == diag)
			if(locate(/obj/structure/snow, get_step(src, diag)))
				diagonalconnect |= dirs[i]
		i += 1

	icon_state = "snow[connectdir]-[diagonalconnect]"


/obj/structure/snow/ex_act(severity)
	switch(severity)
		if(1)
			new /obj/item/stack/rods(src.loc)
			qdel(src)
		if(2)
			new /obj/item/stack/rods(src.loc)
			qdel(src)

/obj/structure/snow/attackby(obj/item/C as obj, mob/user as mob)
	if(isWelder(C))
		var/obj/item/weldingtool/WT = C
		if(WT.remove_fuel(0, user))
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			to_chat(user, "<span class='notice'>Slicing snow joints ...</span>")
			new /obj/item/stack/rods(src.loc)
			new /obj/item/stack/rods(src.loc)
			//Lattice would delete itself, but let's save ourselves a new obj
			if(istype(src.loc, /turf/space) || istype(src.loc, /turf/simulated/open))
				new /obj/structure/lattice/(src.loc)
			qdel(src)
