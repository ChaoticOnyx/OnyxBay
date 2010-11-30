/obj/computercable
	level = 1
	anchored = 1
	name = "Network Cable"
	desc = "A flexible cable designed for use in the Neithernet Protocol."
	icon = 'netcable.dmi'
	icon_state = "1-2"
	var/cnetnum = 0
	var/d1 = 0
	var/d2 = 1
	var/cabletype = ""
	layer = 2.5
	//layer = 10

/obj/item/weapon/computercable_coil
	name = "Network Cable Coil"
	var/amount = 30
	icon = 'netcable.dmi'
	icon_state = "coil"
	desc = "A coil of Network cable."
	w_class = 2
	flags = TABLEPASS|USEDELAY|FPRINT

/obj/item/weapon/computercable_coil/cut
	icon_state = "coil2"
	desc = "A cut-off piece of Network Cable"

// attach a wire to a power machine - leads from the turf you are standing on


/obj/machinery/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/weapon/computercable_coil))

		var/obj/item/weapon/computercable_coil/coil = W

		var/turf/T = user.loc

		if(T.intact || !(istype(T, /turf/simulated/floor) || istype(T, /turf/unsimulated/floor)))
			return

		if(get_dist(src, user) > 1)
			return

		if(!directwiredCnet)		// only for attaching to directwired machines
			return

		var/dirn = get_dir(user, src)


		for(var/obj/computercable/LC in T)
			if(LC.d1 == dirn || LC.d2 == dirn)
				user << "There's already a cable at that position."
				return

		var/obj/computercable/NC = new(T)
		NC.d1 = 0
		NC.d2 = dirn
		NC.add_fingerprint()
		NC.updateicon()
		NC.update_network()
		coil.use(1)
		return
	else
		..()
	return


// the power cable object

obj/computercable/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable

	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1, findtext(icon_state, "-", dash + 1) ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1) hide(T.intact)


/obj/computercable/Del()		// called when a cable is deleted

	if(!defer_powernet_rebuild)	// set if network will be rebuilt manually

		if(cnetnum && computernets && computernets.len >= cnetnum)		// make sure cable & powernet data is valid
			var/datum/computernet/PN = computernets[cnetnum]
			PN.cut_cable(src)									// updated the powernets
	..()													// then go ahead and delete the cable

/obj/computercable/hide(var/i)

	invisibility = i ? 101 : 0
	updateicon()

/obj/computercable/proc/updateicon()
	if(invisibility)
		icon_state = "[d1]-[d2][cabletype]-f"
	else
		icon_state = "[d1]-[d2][cabletype]"


/obj/computercable/attackby(obj/item/weapon/W, mob/user)

	var/turf/T = src.loc
	if(T.intact)
		return

	if(istype(W, /obj/item/weapon/wirecutters))

		if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/weapon/computercable_coil(T, 2)
		else
			new/obj/item/weapon/computercable_coil(T, 1)

		for(var/mob/O in viewers(src, null))
			O.show_message("\red [user] cuts the networking cable.", 1)

		del(src)

	else if(istype(W, /obj/item/weapon/computercable_coil))
		var/obj/item/weapon/computercable_coil/coil = W

		coil.cable_join(src, user)
		//note do shock in cable_join
	else
		shock(user, 10)

	src.add_fingerprint(user)

/obj/computercable/proc/shock(mob/user, prb)
	return

/obj/computercable/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				new/obj/item/weapon/computercable_coil(src.loc, src.d1 ? 2 : 1)
				del(src)

		if(3.0)
			if (prob(25))
				new/obj/item/weapon/computercable_coil(src.loc, src.d1 ? 2 : 1)
				del(src)
	return

// the cable coil object, used for laying cable

/obj/item/weapon/computercable_coil/New(loc, length = 30)
	src.amount = length
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()
	..(loc)

/obj/item/weapon/computercable_coil/cut/New(loc)
	..(loc)
	src.amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()

/obj/item/weapon/computercable_coil/proc/updateicon()
	if(amount == 1)
		icon_state = "coil1"
		name = "cable piece"
	else if(amount == 2)
		icon_state = "coil2"
		name = "cable piece"
	else
		icon_state = "coil"
		name = "cable coil"

/obj/item/weapon/computercable_coil/examine()
	set src in view(1)

	if(amount == 1)
		usr << "A short piece of power cable."
	else if(amount == 1)
		usr << "A piece of power cable."
	else
		usr << "A coil of power cable. There are [amount] lengths of cable in the coil."

/obj/item/weapon/computercable_coil/attackby(obj/item/weapon/W, mob/user)
	if( istype(W, /obj/item/weapon/wirecutters) && src.amount > 1)
		src.amount--
		new/obj/item/weapon/computercable_coil(user.loc, 1)
		user << "You cut a piece off the cable coil."
		src.updateicon()
		return

	else if( istype(W, /obj/item/weapon/computercable_coil) )
		var/obj/item/weapon/computercable_coil/C = W
		if(C.amount == 30)
			user << "The coil is too long, you cannot add any more cable to it."
			return

		if( (C.amount + src.amount <= 30) )
			C.amount += src.amount
			user << "You join the cable coils together."
			C.updateicon()
			del(src)
			return

		else
			user << "You transfer [30 - src.amount ] length\s of cable from one coil to the other."
			src.amount -= (30-C.amount)
			src.updateicon()
			C.amount = 30
			C.updateicon()
			return

/obj/item/weapon/computercable_coil/proc/use(var/used)
	if(src.amount < used)
		return 0
	else if (src.amount == used)
		del(src)
	else
		amount -= used
		updateicon()
		return 1

// called when computercable_coil is clicked on a turf/station/floor

/obj/item/weapon/computercable_coil/proc/turf_place(turf/F, mob/user)

	if(!isturf(user.loc))
		return

	if(get_dist(F,user) > 1)
		user << "You can't lay cable at a place that far away."
		return

	if(F.intact)		// if floor is intact, complain
		user << "You can't lay cable there unless the floor tiles are removed."
		return

	else
		var/dirn

		if(user.loc == F)
			dirn = user.dir			// if laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(F, user)

		for(var/obj/computercable/LC in F)
			if(LC.d1 == dirn || LC.d2 == dirn)
				user << "There's already a cable at that position."
				return

		var/obj/computercable/C = new(F)
		C.d1 = 0
		C.d2 = dirn
		C.add_fingerprint(user)
		C.updateicon()
		C.update_network()
		use(1)
		//src.laying = 1
		//last = C


// called when computercable_coil is click on an installed obj/cable

/obj/item/weapon/computercable_coil/proc/cable_join(obj/cabling/C, mob/user)


	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		user << "You can't lay cable at a place that far away."
		return


	if(U == T)		// do nothing if we clicked a cable we're standing on
		return		// may change later if can think of something logical to do

	var/dirn = get_dir(C, user)

	if(C.d1 == dirn || C.d2 == dirn)		// one end of the clicked cable is pointing towards us
		if(U.intact)						// can't place a cable if the floor is complete
			user << "You can't lay cable there unless the floor tiles are removed."
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/computercable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					user << "There's already cabling there."
					return

			var/obj/computercable/NC = new(U)
			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint()
			NC.updateicon()
			NC.update_network()
			use(1)

			return
	else if(C.d1 == 0)		// exisiting cable doesn't point at our position, so see if it's a stub
							// if so, make it a full cable pointing from it's old direction to our dirn

		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn

		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/computercable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if(LC.d1 == nd1 || LC.d2 == nd1 || LC.d1 == nd2 || LC.d2 == nd2)	// make sure no cable matches either direction
				user << "There's already cabling there."
				return
		del(C)
		var/obj/computercable/NC = new(T)
		NC.d1 = nd1
		NC.d2 = nd2
		NC.add_fingerprint()
		NC.updateicon()
		NC.update_network()

		use(1)

		return





// called when a new cable is created
// can be 1 of 3 outcomes:
// 1. Isolated cable (or only connects to isolated machine) -> create new powernet
// 2. Joins to end or bridges loop of a single network (may also connect isolated machine) -> add to old network
// 3. Bridges gap between 2 networks -> merge the networks (must rebuild lists also)

/obj/computercable/proc/update_network()
	// easy way: do /makecomputernets again


	var/obj/computercable/C1 = cable_connected(get_step_3d(src, d1), src)

	var/obj/computercable/C2 = cable_connected(get_step_3d(src, d1), src)

	if (!C1 && !C2)

		var/datum/computernet/CN = new()

		computernets += CN
		CN.number = computernets.len
		src.cnetnum = CN.number

		for(var/obj/machinery/M in src.loc)
			if (!M in CN.nodes && !M.cnetnum)
				CN.nodes += M
				CN.nodes[M.computerID] = M
				M.cnetnum = CN.number
				M.computernet = CN

	else if ((!C1) ^ (!C2))
		C1 = C1 ? C1 : C2
		var/datum/computernet/CN = computernets[C1.cnetnum]
		CN.cables += src

		for(var/obj/machinery/M in src.loc)
			if (!M in CN.nodes && !M.cnetnum)
				CN.nodes += M
				CN.nodes[M.computerID] = M
				M.cnetnum = CN.number
				M.computernet = CN

		NetworkChange()

	else if (C1.cnetnum != C2.cnetnum)
		makecomputernets()
	else
		var/datum/computernet/CN = computernets[C1.cnetnum]
		CN.cables += src

		for(var/obj/machinery/M in src.loc)
			if (!M in CN.nodes && !M.cnetnum)
				CN.nodes += M
				CN.nodes[M.computerID] = M
				M.cnetnum = CN.number
				M.computernet = CN


/proc/cable_connected(var/turf/T, var/obj/source, var/d)

	for(var/obj/computercable/C in T)
		if (C.d1 == get_dir_3d(T, source.loc) || C.d2 == get_dir_3d(T, source.loc))
			return C

	return null
