/turf/proc/CanZPass(atom/A, direction)
	if(z == A.z) //moving FROM this turf
		return direction == UP //can't go below
	else
		if(direction == UP) //on a turf below, trying to enter
			return 0
		if(direction == DOWN) //on a turf above, trying to enter
			return !density

/turf/simulated/open/CanZPass(atom/A, direction)
	if(locate(/obj/structure/catwalk, src)||locate(/obj/structure/industrial_lift, src))
		if(z == A.z)
			if(direction == DOWN)
				return 0
		else if(direction == UP)
			return 0
	return 1

/turf/space/CanZPass(atom/A, direction)
	if(locate(/obj/structure/catwalk, src))
		if(z == A.z)
			if(direction == DOWN)
				return 0
		else if(direction == UP)
			return 0
	return 1

/turf/simulated/open
	name = "open space"
	icon = 'icons/turf/space.dmi'
	icon_state = ""
	plane = OPENSPACE_PLANE
	density = 0
	pathweight = 100000 //Seriously, don't try and path over this one numbnuts

	var/turf/below

/turf/simulated/open/post_change()
	..()
	update()

/turf/simulated/open/Initialize()
	. = ..()
	update()

/turf/simulated/open/attack_hand(mob/user)
	if(!isliving(user))
		return FALSE

	var/mob/living/L = user
	if(L.incapacitated())
		show_splash_text(user, "Can't climb!", SPAN_WARNING("You can't climb here!"))
		return FALSE

	if(!CanZPass(src, DOWN))
		show_splash_text(user, "Can't climb!", SPAN_WARNING("You can't climb here!"))
		return TRUE

	var/turf/below = GetBelow(src)
	if(!istype(below) || iswall(below) || !isfloor(below))
		show_splash_text(user, "Can't climb!", SPAN_WARNING("You can't climb here!"))
		return TRUE

	var/time_to_climb = rand(5 SECONDS, 8 SECONDS)
	user.visible_message(SPAN_WARNING("[user] starts to climb [src]."), SPAN_WARNING("You start to climb [src]..."))
	if(!do_mob(user, user, time_to_climb) || QDELETED(src))
		return TRUE

	/// Fuck you, movement handler.
	user.forceMove(below)
	user.pulling?.forceMove(below)
	user.start_pulling(user?.pulling)

/turf/simulated/open/proc/update()
	plane = OPENSPACE_PLANE
	if(below)
		unregister_signal(below, SIGNAL_TURF_CHANGED)
		unregister_signal(below, SIGNAL_EXITED)
		unregister_signal(below, SIGNAL_ENTERED)
	below = GetBelow(src)
	register_signal(below, SIGNAL_TURF_CHANGED, nameof(.proc/turf_change))
	register_signal(below, SIGNAL_EXITED, nameof(.proc/handle_move))
	register_signal(below, SIGNAL_ENTERED, nameof(.proc/handle_move))
	levelupdate()
	for(var/atom/movable/A in src)
		A.fall()
	SSopen_space.add_turf(src, 1)
	update_icon()


/turf/simulated/open/update_dirt()
	return 0

/turf/simulated/open/Entered(atom/movable/mover)
	..()
	mover.fall()

// Called when thrown object lands on this turf.
/turf/simulated/open/hitby(atom/movable/AM, speed)
	. = ..()
	AM.fall()


// override to make sure nothing is hidden
/turf/simulated/open/levelupdate()
	for(var/obj/O in src)
		O.hide(0)



/turf/simulated/open/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) <= 2)
		var/depth = 1
		for(var/T = GetBelow(src); isopenspace(T); T = GetBelow(T))
			depth += 1
		. += "It is about [depth] level\s deep."



/**
* Update icon and overlays of open space to be that of the turf below, plus any visible objects on that turf.
*/
/turf/simulated/open/on_update_icon()
	ClearOverlays()
	underlays.Cut()
	var/turf/below = GetBelow(src)
	if(below)
		var/below_is_open = isopenspace(below)
		vis_contents += below

		if(!below_is_open)
			AddOverlays(GLOB.over_OS_darkness)

		return 0
	return PROCESS_KILL


/turf/simulated/open/attackby(obj/item/C, mob/user)
	if (istype(C, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return L.attackby(C, user)
		var/obj/item/stack/rods/R = C
		if (R.use(1))
			to_chat(user, "<span class='notice'>You lay down the support lattice.</span>")
			playsound(src, 'sound/effects/fighting/Genhit.ogg', 50, 1)
			new /obj/structure/lattice(locate(src.x, src.y, src.z))
			//Update turfs
			SSopen_space.add_turf(src, 1)
		return

	if (istype(C, /obj/item/stack/tile))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/floor/S = C
			if (S.get_amount() < 1)
				return
			qdel(L)
			playsound(src, 'sound/effects/fighting/Genhit.ogg', 50, 1)
			S.use(1)
			if(istype(C, /obj/item/stack/tile/floor_rough))
				ChangeTurf(/turf/simulated/floor/plating/rough/airless)
			else
				ChangeTurf(/turf/simulated/floor/plating/airless)
			return
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support.</span>")

	//To lay cable.
	if(isCoil(C))
		var/obj/item/stack/cable_coil/coil = C
		coil.turf_place(src, user)
		return
	return

//Most things use is_plating to test if there is a cover tile on top (like regular floors)
/turf/simulated/open/is_plating()
	return 1

/turf/simulated/open/proc/handle_move(atom/current_loc, atom/movable/am, atom/changed_loc)
	//First handle objs and such
	if(!am.invisibility && isobj(am))
	//Update icons
		SSopen_space.add_turf(src, 1)
	//Check for mobs and create/destroy their shadows
	if(isliving(am))
		var/mob/living/M = am
		M.check_shadow()

/turf/simulated/open/proc/clean_up()
	//Unregister
	unregister_signal(below, SIGNAL_TURF_CHANGED)
	unregister_signal(below, SIGNAL_EXITED, nameof(.proc/handle_move))
	unregister_signal(below, SIGNAL_ENTERED)
	//Take care of shadow
	for(var/mob/zshadow/M in src)
		qdel(M)
	vis_contents = list()

//When turf changes, a bunch of things can take place
/turf/simulated/open/proc/turf_change(turf/affected)
	if(!isopenspace(affected))//If affected is openspace it will add itself
		SSopen_space.add_turf(src, 1)


//The two situations which require unregistering

/turf/simulated/open/ChangeTurf(turf/N, tell_universe = TRUE, force_lighting_update = FALSE)
	//We do not want to change any of the behaviour, just make sure this goes away
	src.clean_up()
	. = ..()

/turf/simulated/open/Destroy()
	src.clean_up()
	. = ..()
