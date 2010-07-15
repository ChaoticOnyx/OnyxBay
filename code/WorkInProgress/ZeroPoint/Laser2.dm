/obj/machinery/engine/laser
	desc = "A powerful zero-point laser"
	var/visible = 1
	var/state = 1.0
	var/obj/beam/e_beam/first
	var/power = 500
	icon = 'engine.dmi'
	icon_state = "laser"
	anchored = 1
	var/id
	var/on = 0
/obj/machinery/engine/laser/process()
	if(on)
		if(!first)
			src.first = new /obj/beam/e_beam(src.loc)
			src.first.master = src
			src.first.dir = src.dir
			src.first.power = src.power
			step(first,first.dir)
			if(first)
				src.first.updatebeam()
		else
			src.first.updatebeam()
	else
		if(first)
			del first

/obj/machinery/engine/laser/proc/setpower(var/powera)
	src.power = powera
	if(first)
		first.setpower(src.power)


/obj/beam/e_beam
	name = "Laser beam"
	icon = 'projectiles.dmi'
	icon_state = "u_laser"
	var/obj/machinery/engine/laser/master = null
	var/obj/beam/e_beam/next = null
	var/power
	anchored = 1
/obj/beam/e_beam/New()
	sd_SetLuminosity(3)

/obj/beam/e_beam/proc/updatebeam()
	if(!next)
		var/obj/beam/e_beam/e = new /obj/beam/e_beam(src.loc)
		e.dir = src.dir
		src.next = e
		e.master = src.master
		e.power = src.power
		step(e,e.dir)
		if(src.loc.density == 0)
			for(var/obj/o in src.loc.contents)
				if(o.density == 1 || o == src.master || (!(istype(o,/obj/beam))) || istype(o,/mob) )
					del e
					return
			if(e)
				e.updatebeam()
		else
			del e
			return
	else
		next.updatebeam()

/obj/beam/e_beam/Bump()
	del(src)
	return

/obj/beam/e_beam/proc/setpower(var/powera)
	src.power = powera
	if(src.next)
		src.next.setpower(powera)

/obj/beam/e_beam/Bumped()
	src.hit()
	return

/obj/beam/e_beam/HasEntered(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	spawn( 0 )
		src.hit()
		return
	return

/obj/beam/e_beam/Del()
	del(src.next)
	..()
	return

/obj/beam/e_beam/proc/hit()
	del src
	return