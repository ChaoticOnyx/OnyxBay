/obj/projectile/Bump(atom/A as mob|obj|turf|area)
	spawn(0)
		if(A)
			A.bullet_act(projectile_type, src)
			if(istype(A,/turf))
				for(var/obj/O in A)
					O.bullet_act(projectile_type, src)

		del(src)
	return

/obj/projectile/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover, /obj/projectile))
		return prob(95)
	else
		return 1

/obj/projectile/proc/process()
	if ((!( src.current ) || src.loc == src.current))
		src.current = locate(min(max(src.x + src.xo, 1), world.maxx), min(max(src.y + src.yo, 1), world.maxy), src.z)
	if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
		//SN src = null
		del(src)
		return
	var/temp_dir = get_dir(src, src.current) //Why is this even needed?
	step_towards(src, src.current)
	src.dir = temp_dir

	if(hits_lying)
		var/list/lying_people = list()
		for(var/mob/M in src.loc)
			lying_people += M
		if(lying_people.len)
			src.Bump(pick(lying_people))

	spawn(1)
		process()
		return
	return

/*Ze proper projectile defines*/

/var/const/PROJECTILE_TASER = 1
/var/const/PROJECTILE_LASER = 2
/var/const/PROJECTILE_BULLET = 3
/var/const/PROJECTILE_PULSE = 4
/var/const/PROJECTILE_BOLT = 5
/var/const/PROJECTILE_WEAKBULLET = 6
/var/const/PROJECTILE_TELEGUN = 7
/var/const/PROJECTILE_STUNBOLT = 8

/obj/projectile
	name = "projectile"
	icon = 'projectiles.dmi'
	icon_state = "default"
	density = 1
	anchored = 1
	var/yo = null
	var/xo = null
	var/current = null
	anchored = 1.0
	flags = TABLEPASS
	var/dirs = 4 //Valid args, 1; 4; 8.
	var/projectile_type = 0
	var/hits_lying = 0 //Does this projectile hit people who are lying down?
	var/pass_windows = 0 //Can this projectile pass through windows?

/obj/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	projectile_type = PROJECTILE_BULLET

/obj/projectile/bullet/weak
	projectile_type = PROJECTILE_WEAKBULLET


/obj/projectile/electrode
	name = "electrode"
	icon_state = "spark"
	dirs = 1
	projectile_type = PROJECTILE_TASER

/obj/projectile/teleshot
	name = "teleshot"
	icon_state = "spark"
	dirs = 0
	var/failchance = 5
	var/obj/item/target = null
	projectile_type = PROJECTILE_TELEGUN

/obj/projectile/cbbolt
	name = "crossbow bolt"
	icon_state = "cbbolt"
	projectile_type = PROJECTILE_BOLT

/obj/projectile/stunbolt
	name = "electrical bolt"
	icon_state = "stunbolt"
	projectile_type = PROJECTILE_STUNBOLT
	pass_windows = 1

/obj/projectile/laser
	name = "laser"
	icon_state = "laser"
	projectile_type = PROJECTILE_LASER
	hits_lying = 1
	pass_windows = 1

/obj/projectile/laser/pulse_laser
	name = "pulse laser"
	icon_state = "u_laser"


/obj/projectile
/obj/projectile/bullet/weak
/obj/projectile/electrode
/obj/projectile/teleshot
/obj/projectile/cbbolt

/obj/beam
/obj/projectile/laser
/obj/beam/i_beam

/*Extra thingummies, telegun mainly.*/

/obj/projectile/teleshot/Bump(atom/A as mob|obj|turf|area)
	if (src.target == null)
		var/list/turfs = list(	)
		for(var/turf/T in orange(10, src))
			if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
			if(T.y>world.maxy-4 || T.y<4)	continue
			turfs += T
		if(turfs)
			src.target = pick(turfs)
	if (!src.target)
		del(src)
		return
	spawn(0)
		if(A)
			var/turf/T = get_turf(A)
			for(var/atom/movable/M in T)
				if(istype(M, /obj/effects)) //sparks don't teleport
					continue
				if (M.anchored)
					continue
				if (istype(M, /atom/movable))
					var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
					s.set_up(5, 1, M)
					s.start()
					if(prob(src.failchance)) //oh dear a problem, put em in deep space
						do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), getZLevel(Z_SPACE)), 0)
					else
						do_teleport(M, src.target, 2)
		del(src)
	return


/*what are you doing here infared beam you aren't even a projectile*/

/obj/beam/i_beam
	name = "infared beam"
	icon = 'projectiles.dmi'
	icon_state = "ibeam"
	var/obj/beam/i_beam/next = null
	var/obj/item/device/infra/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
	anchored = 1.0
	flags = TABLEPASS

/obj/beam/i_beam/proc/hit()
	//world << "beam \ref[src]: hit"
	if (src.master)
		//world << "beam hit \ref[src]: calling master \ref[master].hit"
		src.master.hit()
	//SN src = null
	del(src)
	return

/obj/beam/i_beam/proc/vis_spread(v)
	//world << "i_beam \ref[src] : vis_spread"
	src.visible = v
	spawn( 0 )
		if (src.next)
			//world << "i_beam \ref[src] : is next [next.type] \ref[next], calling spread"
			src.next.vis_spread(v)
		return
	return

/obj/beam/i_beam/proc/process()
	//world << "i_beam \ref[src] : process"

	if ((src.loc.density || !( src.master )))
		//SN src = null
	//	world << "beam hit loc [loc] or no master [master], deleting"
		del(src)
		return
	//world << "proccess: [src.left] left"

	if (src.left > 0)
		src.left--
	if (src.left < 1)
		if (!( src.visible ))
			src.invisibility = 101
		else
			src.invisibility = 0
	else
		src.invisibility = 0


	//world << "now [src.left] left"
	var/obj/beam/i_beam/I = new /obj/beam/i_beam( src.loc )
	I.master = src.master
	I.density = 1
	I.dir = src.dir
	//world << "created new beam \ref[I] at [I.x] [I.y] [I.z]"
	step(I, I.dir)

	if (I)
		//world << "step worked, now at [I.x] [I.y] [I.z]"
		if (!( src.next ))
			//world << "no src.next"
			I.density = 0
			//world << "spreading"
			I.vis_spread(src.visible)
			src.next = I
			spawn( 0 )
				//world << "limit = [src.limit] "
				if ((I && src.limit > 0))
					I.limit = src.limit - 1
					//world << "calling next process"
					I.process()
				return
		else
			//world << "is a next: \ref[next], deleting beam \ref[I]"
			//I = null
			del(I)
	else
		//src.next = null
		//world << "step failed, deleting \ref[src.next]"
		del(src.next)
	spawn( 10 )
		src.process()
		return
	return

/obj/beam/i_beam/Bump()
	del(src)
	return

/obj/beam/i_beam/Bumped()
	src.hit()
	return

/obj/beam/i_beam/HasEntered(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	spawn( 0 )
		src.hit()
		return
	return

/obj/beam/i_beam/Del()
	del(src.next)
	..()
	return