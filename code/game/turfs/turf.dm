/turf
	icon = 'icons/turf/floors.dmi'
	level = 1

	layer = TURF_LAYER
	plane = TURF_PLANE
	vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_ID

	var/turf_flags

	var/holy = FALSE

	// Initial air contents (in moles)
	var/list/initial_gas

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//Properties for both
	var/temperature = 20 CELSIUS // Initial turf temperature.
	var/blocks_air = 0           // Does this turf contain air/let air through?

	var/list/explosion_throw_details

	// General properties.
	var/icon_old = null
	var/pathweight = 1          // How much does it cost to pathfind over this turf?
	var/blessed = 0             // Has the turf been blessed?

	var/rad_resist_type = /datum/rad_resist/turf

	var/list/decals

	var/changing_turf

	var/footstep_sound = SFX_FOOTSTEP_PLATING

	var/turf_height = 0 // "Vertical" offset. Mostly used for mobs and dropped items.

	/// Whether this turf can be used inside a blank holodeck i.e reinforced tile.
	var/holodeck_compatible = FALSE

	/// If this turf contained an RCD'able object (or IS one, for walls)
	/// but is now destroyed, this will preserve the value.
	/// See __DEFINES/construction.dm for RCD_MEMORY_*.
	var/rcd_memory

/datum/rad_resist/turf
	alpha_particle_resist = 38 MEGA ELECTRONVOLT
	beta_particle_resist = 50 KILO ELECTRONVOLT
	hawking_resist = 81 MILLI ELECTRONVOLT

/turf/Initialize(mapload, ...)
	. = ..()
	if(dynamic_lighting)
		luminosity = 0
	else
		luminosity = 1

	RecalculateOpacity()

/turf/Destroy()
	if(!changing_turf)
		util_crash_with("Improper turf qdel. Do not qdel turfs directly.")

	changing_turf = FALSE
	remove_cleanables()
	..()
	return QDEL_HINT_IWILLGC

/turf/ex_act(severity)
	return 0

/turf/proc/is_solid_structure()
	return 1

/turf/proc/handle_crawling(mob/user)
	if(!user)
		return

	if(!user.lying || user.anchored || user.restrained() || !ishuman(user)) //Because do_after's aren't actually interrupted by most things unfortunately.
		return

	var/area/A = get_area(src)
	if((istype(A) && !(A.has_gravity)) || istype(src, /turf/space))
		return

	for(var/obj/item/grab/G in user.grabbed_by)
		if(G.stop_move())
			return

	if(do_after(user, 15 + (user.weakened * 2), src, incapacitation_flags = ~INCAPACITATION_FORCELYING))
		if(step_towards(user, src))
			user.visible_message(SPAN_WARNING("<font size=1>[user] crawls on \the [src]!</font>"))

/turf/attack_hand(mob/user)
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	if(!user.pulling)
		// QOL feature, clicking on turf can toogle doors
		var/obj/machinery/door/airlock/AL = locate(/obj/machinery/door/airlock) in contents
		if(AL)
			AL.attack_hand(user)
			return TRUE
		var/obj/machinery/door/firedoor/FD = locate(/obj/machinery/door/firedoor) in contents
		if(FD)
			FD.attack_hand(user)
			return TRUE

	if(user.restrained())
		return 0
	if(QDELETED(user.pulling) || user.pulling.anchored || !isturf(user.pulling.loc))
		return 0
	if(user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1)
		return 0

	if(ismob(user.pulling))
		var/mob/M = user.pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.start_pulling(t)
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
		if(isobj(user.pulling))
			var/obj/O = user.pulling
			user.setClickCooldown(DEFAULT_QUICK_COOLDOWN + O.pull_slowdown)
	return 1

/turf/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/storage))
		var/obj/item/storage/S = W
		if(S.use_to_pickup && S.collection_mode)
			S.gather_all(src, user)
	return ..()

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)

	..()

	if (!mover || !isturf(mover.loc) || isobserver(mover))
		return 1

	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover.loc)
		if(!(obstacle.atom_flags & ATOM_FLAG_CHECKS_BORDER) && (mover != obstacle) && (forget != obstacle))
			if(!obstacle.CheckExit(mover, src))
				mover.Bump(obstacle, 1)
				return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in mover.loc)
		if((border_obstacle.atom_flags & ATOM_FLAG_CHECKS_BORDER) && (mover != border_obstacle) && (forget != border_obstacle))
			if(!border_obstacle.CheckExit(mover, src))
				mover.Bump(border_obstacle, 1)
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in src)
		if(border_obstacle.atom_flags & ATOM_FLAG_CHECKS_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in src)
		if(!(obstacle.atom_flags & ATOM_FLAG_CHECKS_BORDER))
			if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
				mover.Bump(obstacle, 1)
				return 0
	return 1 //Nothing found to block so return success!

var/const/enterloopsanity = 100
/turf/Entered(atom/movable/AM, atom/OldLoc)
	. = ..()

	if(!istype(AM))
		return

	if(ismob(AM))
		var/mob/M = AM
		if(!M.check_solid_ground())
			inertial_drift(M)
			//we'll end up checking solid ground again but we still need to check the other things.
			//Ususally most people aren't in space anyways so hopefully this is acceptable.
			M.update_floating()
		else
			M.inertia_dir = 0
			M.make_floating(0) //we know we're not on solid ground so skip the checks to save a bit of processing
			M.update_height_offset(turf_height)

	else if(isobj(AM))
		var/obj/O = AM
		if(O.turf_height_offset)
			if(isturf(OldLoc))
				var/turf/old_turf = OldLoc
				old_turf.update_turf_height()
			update_turf_height()

/turf/proc/adjacent_fire_act(turf/simulated/floor/source, temperature, volume)
	return

/turf/proc/is_plating()
	return 0

/turf/proc/protects_atom(atom/A)
	return FALSE

/turf/proc/inertial_drift(atom/movable/A)
	if(!(A.last_move))	return
	if((istype(A, /mob/) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1)))
		var/mob/M = A
		if(M.Allow_Spacemove(1)) //if this mob can control their own movement in space then they shouldn't be drifting
			M.inertia_dir  = 0
			return
		spawn(5)
			if(M && !(M.anchored) && !(M.pulledby) && (M.loc == src))
				if(!M.inertia_dir)
					M.inertia_dir = M.last_move
				step(M, M.inertia_dir)
	return

/turf/proc/levelupdate()
	for(var/obj/O in src)
		O.hide(O.hides_under_flooring() && !is_plating())

/turf/proc/AdjacentTurfs(check_blockage = TRUE)
	. = list()
	for(var/turf/t in (trange(1,src) - src))
		if(check_blockage)
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					. += t
		else
			. += t

/turf/proc/CardinalTurfs(check_blockage = TRUE)
	. = list()
	for(var/ad in AdjacentTurfs(check_blockage))
		var/turf/T = ad
		if(T.x == src.x || T.y == src.y)
			. += T

/turf/proc/Distance(turf/t)
	if(get_dist(src,t) == 1)
		var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
		cost *= (pathweight+t.pathweight)/2
		return cost
	else
		return get_dist(src,t)

/turf/proc/AdjacentTurfsSpace()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L

/turf/proc/contains_dense_objects(check_mobs = TRUE)
	if(density)
		return TRUE
	for(var/atom/A in src)
		if(!check_mobs && ismob(A))
			continue
		if(A.density && !(A.atom_flags & ATOM_FLAG_CHECKS_BORDER))
			return TRUE
	return FALSE

//expects an atom containing the reagents used to clean the turf
/turf/proc/clean(atom/source, mob/user = null)
	if(source.reagents.has_reagent(/datum/reagent/water, 1) || source.reagents.has_reagent(/datum/reagent/space_cleaner, 1))
		clean_blood()
		remove_cleanables()
	else
		to_chat(user, "<span class='warning'>\The [source] is too dry to wash that.</span>")
	source.reagents.trans_to_turf(src, 1, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.

/turf/proc/remove_cleanables()
	for(var/obj/effect/O in src)
		if(istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
			qdel(O)

/turf/proc/update_blood_overlays()
	return

/turf/proc/remove_decals()
	if(decals && decals.len)
		decals.Cut()
		decals = null

// Called when turf is hit by a thrown object
/turf/hitby(atom/movable/AM, speed, nomsg)
	if(src.density)
		spawn(2)
			step(AM, turn(AM.last_move, 180))
		if(isliving(AM))
			var/mob/living/M = AM
			M.turf_collision(src, speed)

/turf/allow_drop()
	return TRUE

/turf/examine(mob/user, infix)
	. = ..()

	if(hasHUD(user, HUD_SCIENCE))
		. += "Stopping Power:"

		. += "α-particle: [fmt_siunit(CONV_JOULE_ELECTRONVOLT(get_rad_resist_value(rad_resist_type, RADIATION_ALPHA_PARTICLE)), "eV", 3)]"
		. += "β-particle: [fmt_siunit(CONV_JOULE_ELECTRONVOLT(get_rad_resist_value(rad_resist_type, RADIATION_BETA_PARTICLE)), "eV", 3)]"

/turf/proc/get_footstep_sound()
	if(footstep_sound)
		return pick(GLOB.sfx_list[footstep_sound])

/turf/proc/update_turf_height()
	var/max_height = initial(turf_height)
	for(var/obj/O in contents)
		if(O.turf_height_offset)
			max_height = max(max_height, O.turf_height_offset)
	turf_height = max_height
	for(var/mob/M in contents)
		M.update_height_offset(turf_height)
