/turf/proc/CanZPass(atom/A, direction, check_neighbor_canzpass = TRUE)
	if(direction == UP)
		if(!HasAbove(z))
			return FALSE
		if(check_neighbor_canzpass)
			var/turf/T = GetAbove(src)
			if(!T.CanZPass(A, DOWN, FALSE))
				return FALSE

	else if(direction == DOWN)
		if(!is_open() || !HasBelow(z) || (locate(/obj/structure/catwalk) in src))
			return FALSE
		if(check_neighbor_canzpass)
			var/turf/T = GetBelow(src)
			if(!T.CanZPass(A, UP, FALSE))
				return FALSE

	// Hate calling Enter() directly, but that's where obstacles are checked currently.
	return Enter(A, A)

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
/turf/simulated/open/hitby(atom/movable/AM, datum/thrownthing/TT)
	..()
	if(!QDELETED(AM))
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
		update_graphic()

		if(!below_is_open)
			AddOverlays(GLOB.over_OS_darkness)

		return 0
	return PROCESS_KILL

/turf/simulated/open/update_graphic()
	var/air_graphic = get_air_graphic()
	if(LAZYLEN(air_graphic))
		vis_contents = air_graphic
	else
		vis_contents = null

	var/turf/below = GetBelow(src)
	if(below)
		vis_contents += below

/turf/simulated/open/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/stack/rods))
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

	if(istype(C, /obj/item/stack/tile))
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

/turf/simulated/open/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_TURF && the_rcd.rcd_design_path == /turf/simulated/floor/plating)
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return list("delay" = 0, "cost" = 1)
		else
			return list("delay" = 0, "cost" = 3)

	return FALSE

/turf/simulated/open/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data["[RCD_DESIGN_MODE]"] == RCD_TURF)
		ChangeTurf(/turf/simulated/floor/plating)
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			qdel(L)
		return TRUE

	return FALSE

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
