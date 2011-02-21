obj/rail
	name = "Rail Track"
	icon = 'rail.dmi'
	anchored = 1
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
	//usr << "rail-[num][num2]"

obj/rail/attackby(var/obj/item/weapon/W as obj, var/mob/m as mob)
	if(istype(W,/obj/item/weapon/wrench))
		new/obj/item/weapon/track(loc)
		del src
		if(node1)
			node1.updatetrack()
		if(node2)
			node2.updatetrack()
		m << "You unbolt the track."


obj/railcart
	name = "Cart"
	icon = 'rail.dmi'
	icon_state = "cart"
	var/obj/rail/oldloc
	var/on = 0
	var/list/path_list = list()
	var/way = 1 // 0 /not moving 1 moving backwards 2moving forwards
	var/list/ontop = list()

obj/railcart/verb/start()
	set src in view(2)
	on()
	sleep(-1)
	process()

obj/railcart/verb/stop()
	set src in view(2)
	off()

obj/railcart/proc/on()
	on = 1
	density = 1
	for(var/obj/o in loc)
		if(o==src)
			continue
		if(!o.anchored)
			ontop+=o
			o.loc = loc
	for(var/mob/m in loc)
		if(!m.anchored)
			ontop+=m
			m.loc = loc
	icon_state = "cartmoving"


obj/railcart/proc/off()
	on = 0
	density = 0
	ontop = list()
	oldloc = null
	icon_state = "cart"

obj/railcart/Move(var/atom/NewLoc,var/Dir=0)
	var/turf/t = get_turf(NewLoc)
	if(!locate(/obj/rail) in t)
		off()
	return ..()

obj/railcart/attack_hand(mob/user as mob)
	if(on)
		off()
	else
		on()

obj/railcart/proc/process()
	while(on)
		for(var/atom/a in ontop)
			if(a.loc != loc)
				ontop -= a
		var/obj/rail/R = locate() in src.loc
		if(!R)
			return

		if(R.node1 != oldloc)
			Move(R.node1.loc)
			oldloc = R
			for(var/a as obj|mob in ontop)
				a:loc = loc

		else if(R.node2 != oldloc)
			Move(R.node2.loc)
			oldloc = R
			for(var/a as obj|mob in ontop)
				a:loc = loc
		else
			state("EMERGANCY STOP")
			off()
		sleep(-1)
		sleep(4)

obj/railcart/Bump(atom/obstacle)
	..()
	if(istype(obstacle,/obj/rail)|!obstacle.density|!obstacle)
		return
	off()
	state("EMERGANCY STOP")

obj/item/weapon/track
	name = "Track piece"
	m_amt = 250
	icon_state = "piece"
	icon = 'rail.dmi'


obj/item/weapon/track/attackby(var/obj/item/weapon/W as obj, var/mob/m as mob)
	if(istype(W,/obj/item/weapon/wrench))
		if(isturf(loc))
			m << "You bolt the track into place."
			var/obj/rail/R = new /obj/rail(get_turf(src))
			if(R.node1)
				R.node1.updatetrack()
			if(R.node2)
				R.node2.updatetrack()
			del src
		else
			m << "Put the track on the ground first!"
	..()