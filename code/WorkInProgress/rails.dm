obj/rail
	name = "Rail Track"
	icon = 'rail.dmi'
	var/obj/rail/node1
	var/obj/rail/node2
	var/node1_dir
	var/node2_dir
obj/rail/New()
	sleep(1)
	updatetrack()
obj/rail/verb/update()
	set src in view(5)
	updatetrack()
obj/rail/proc/updatetrack()
	for(var/dir in cardinal)
		var/turf/T = get_step(src,dir)
		var/obj/rail/R = locate(/obj/rail/) in T
		if(R)
			if(node1 == null && node2 != R)
				node1 = R
				continue
			else if(node2 == null && node1 != R)
				node2 = R
	node1_dir = get_dir(src,node1)
	node2_dir = get_dir(src,node2)
	updateicon()
obj/rail/proc/updateicon()
	var/num
	var/num2
	if(!num || !num2)
		if(!num)
			num += get_dir(src,node1)
		if(!num2)
			num2 += get_dir(src,node2)
	icon_state = "rail_[num][num2]"
	usr << "rail-[num][num2]"

obj/railcart
	name = "Cart"
	icon = 'rail.dmi'
	icon_state = "cart"
	var/obj/rail/oldloc
	var/on = 0
	var/list/path_list = list()
	var/way = 1 // 0 /not moving 1 moving backwards 2moving forwards
obj/railcart/verb/start()
	set src in view(2)
	on = 1
	process()

obj/railcart/proc/process()
/*	while(on)
		var/obj/rail/R = locate() in src.loc
		if(!R)
			return
		usr << "GETTING DIRS"
		var/dir1
		var/dir2
		if(src.dir == 1)
		world << "IM COMEING FROM [R] trying to go to [R.node1]"


*/
	/*	if(R.node1 != oldloc)
			step_to(src,R.node1,0)
			oldloc = R.node1
		else if(R.node2 != oldloc)
			step_to(src,R.node2,0)
			oldloc = R.node2
		else
			for(var/mob/M in view(10,src))
				M << "EMERGENCY SHUTDOWN"
			on = 0*/
		sleep(10)

