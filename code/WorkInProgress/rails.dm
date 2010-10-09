obj/rail
	name = "Rail Track"
	icon = 'rail.dmi'
	var/obj/rail/node1
	var/obj/rail/node2
	var/node1_dir
	var/node2_dir
obj/rail/north
	icon_state = "rail_12"
	node1_dir = NORTH
	node2_dir = SOUTH
obj/rail/south
	icon_state = "rail_21"
	node1_dir = SOUTH
	node2_dir = NORTH
obj/rail/west
	icon_state = "rail_48"
	node1_dir = WEST
	node2_dir = EAST
obj/rail/east
	icon_state = "rail_48"
	node1_dir = EAST
	node2_dir = WEST
obj/rail/northwest
	icon_state = "rail_81"
	node1_dir = NORTH
	node2_dir = WEST
obj/rail/northeast
	icon_state = "rail_41"
	node1_dir = EAST
	node2_dir = NORTH
obj/rail/southwest
	icon_state = "rail_82"
	node1_dir = WEST
	node2_dir = SOUTH
obj/rail/southeast
	icon_state = "rail_42"
	node1_dir = SOUTH
	node2_dir = EAST
obj/rail/New()
	sleep(1)
	updatetrack()
obj/rail/verb/update()
	set src in view(5)
	updatetrack()
obj/rail/proc/updatetrack()
	var/turf/t1 = get_step(src,node1_dir)
	var/turf/t2 = get_step(src,node2_dir)
	if(locate(/obj/rail) in t1)
		node1 = locate() in t1
	if(locate(/obj/rail) in t2)
		node2 = locate() in t2
	updateicon()
obj/rail/proc/updateicon()
	var/dir1
	var/dir2
	if(node1)
		dir1 = node1_dir
	if(node2)
		dir2 = node2_dir
	src.icon_state = "rail_[dir1][dir2]"

obj/railcart
	name = "Cart"
	icon = 'rail.dmi'
	icon_state = "cart"
	var/on = 0
	var/way = 1 // 0 /not moving 1 moving backwards 2moving forwards
obj/railcart/verb/start()
	set src in view(2)
	on = 1
	process()

obj/railcart/proc/process()
	while(on)
		var/obj/rail/target
		var/turf/oldloc
		if(way == 1)
			if(locate(/obj/rail) in src.loc)
				target = locate() in src.loc
				target = target.node1
				step(src,get_dir(src,target))
				sleep(5)
			else
				on = 0
				return
	/*


	N1
	|
	N2
	N1-N2 <--


	*/