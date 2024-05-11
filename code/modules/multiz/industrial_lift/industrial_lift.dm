
//Booleans in arguments are confusing, so I made them defines.
#define LOCKED 1
#define UNLOCKED 0

///Collect and command
/datum/lift_master
	var/list/lift_platforms
	/// Typepath list of what to ignore smashing through, controls all lifts
	var/list/ignored_smashthroughs = list(
		/obj/machinery/power/supermatter,
		/obj/machinery/holosign
	)
	var/moving_status = ELEVATOR_IDLE

/datum/lift_master/New(obj/structure/industrial_lift/lift_platform)
	Rebuild_lift_plaform(lift_platform)

/datum/lift_master/Destroy()
	for(var/l in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = l
		lift_platform.lift_master_datum = null
	lift_platforms = null
	return ..()


/datum/lift_master/proc/add_lift_platforms(obj/structure/industrial_lift/new_lift_platform)
	if(new_lift_platform in lift_platforms)
		return
	new_lift_platform.lift_master_datum = src
	LAZYADD(lift_platforms, new_lift_platform)
	register_signal(new_lift_platform, SIGNAL_QDELETING, nameof(.proc/remove_lift_platforms))

/datum/lift_master/proc/remove_lift_platforms(obj/structure/industrial_lift/old_lift_platform)
	SHOULD_NOT_SLEEP(TRUE)

	if(!(old_lift_platform in lift_platforms))
		return
	old_lift_platform.lift_master_datum = null
	LAZYREMOVE(lift_platforms, old_lift_platform)
	unregister_signal(old_lift_platform, SIGNAL_QDELETING)

///Collect all bordered platforms
/datum/lift_master/proc/Rebuild_lift_plaform(obj/structure/industrial_lift/base_lift_platform)
	add_lift_platforms(base_lift_platform)
	var/list/possible_expansions = list(base_lift_platform)
	while(possible_expansions.len)
		for(var/b in possible_expansions)
			var/obj/structure/industrial_lift/borderline = b
			var/list/result = borderline.lift_platform_expansion(src)
			if(length(result))
				for(var/p in result)
					if(lift_platforms.Find(p))
						continue
					var/obj/structure/industrial_lift/lift_platform = p
					add_lift_platforms(lift_platform)
					possible_expansions |= lift_platform
			possible_expansions -= borderline

//General use for console
/datum/lift_master/proc/use(result)
	var/datum/lift_master/master = src
	switch(result)
		if("Up")
			// We have to make sure that they don't do illegal actions by not having their radial menu refresh from someone else moving the lift.
			if(!Check_lift_move(UP))
				return
			moving_status = ELEVATOR_INTRANSIT
			playsound(master.lift_platforms[1],'sound/machines/elevator_loop.ogg', 70, TRUE)
			spawn(4 SECOND)
				MoveLift(UP)
		if("Down")
			if(!Check_lift_move(DOWN))
				return
			moving_status = ELEVATOR_INTRANSIT
			playsound(master.lift_platforms[1],'sound/machines/elevator_loop.ogg', 70, TRUE)
			spawn(4 SECOND)
				MoveLift(DOWN)
		if("Cancel")
			moving_status = ELEVATOR_IDLE
			return
/**
 * Moves the lift UP or DOWN, this is what users invoke with their hand.
 * This is a SAFE proc, ensuring every part of the lift moves SANELY.
 * It also locks controls for the (miniscule) duration of the movement, so the elevator cannot be broken by spamming.
 * Arguments:
 * going - UP or DOWN directions, where the lift should go. Keep in mind by this point checks of whether it should go up or down have already been done.
 * user - Whomever made the lift movement.
 */
/datum/lift_master/proc/MoveLift(going, mob/user)
	set_controls(LOCKED)
	for(var/p in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = p
		lift_platform.travel(going)
	set_controls(UNLOCKED)

/**
 * Moves the lift, this is what users invoke with their hand.
 * This is a SAFE proc, ensuring every part of the lift moves SANELY.
 * It also locks controls for the (miniscule) duration of the movement, so the elevator cannot be broken by spamming.
 */
/datum/lift_master/proc/MoveLiftHorizontal(going, z, gliding_amount = 8)
	var/max_x = 1
	var/max_y = 1
	var/min_x = world.maxx
	var/min_y = world.maxy


	set_controls(LOCKED)
	for(var/p in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = p
		max_x = max(max_x, lift_platform.x)
		max_y = max(max_y, lift_platform.y)
		min_x = min(min_x, lift_platform.x)
		min_y = min(min_y, lift_platform.y)

	//This must be safe way to border tile to tile move of bordered platforms, that excludes platform overlapping.
	if( going & WEST )
		//Go along the X axis from min to max, from left to right
		for(var/x in min_x to max_x)
			if( going & NORTH )
				//Go along the Y axis from max to min, from up to down
				for(var/y in max_y to min_y step -1)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform?.travel(going, gliding_amount)
			else
				//Go along the Y axis from min to max, from down to up
				for(var/y in min_y to max_y)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform?.travel(going, gliding_amount)
	else
		//Go along the X axis from max to min, from right to left
		for(var/x in max_x to min_x step -1)
			if( going & NORTH )
				//Go along the Y axis from max to min, from up to down
				for(var/y in max_y to min_y step -1)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform?.travel(going, gliding_amount)
			else
				//Go along the Y axis from min to max, from down to up
				for(var/y in min_y to max_y)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform?.travel(going, gliding_amount)
	set_controls(UNLOCKED)

///Check destination turfs
/datum/lift_master/proc/Check_lift_move(check_dir)
	if(moving_status == ELEVATOR_INTRANSIT)
		return FALSE
	for(var/l in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = l
		var/turf/T = get_step(lift_platform, check_dir)
		if(!T)//the edges of multi-z maps
			return FALSE
		if(check_dir == UP && !istype(T, /turf/simulated/open)) // We don't want to go through the ceiling!
			return FALSE
		if(check_dir == DOWN && !istype(get_turf(lift_platform), /turf/simulated/open)) // No going through the floor!
			return FALSE
	return TRUE

//Elevator shaft
/turf/simulated/open/elevatorshaft
	icon = 'icons/turf/floors.dmi'
	icon_state = "elevatorshaft"

/**
 * Sets all lift parts's controls_locked variable. Used to prevent moving mid movement, or cooldowns.
 */
/datum/lift_master/proc/set_controls(state)
	moving_status = state==LOCKED?ELEVATOR_INTRANSIT:ELEVATOR_IDLE
	for(var/l in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = l
		lift_platform.controls_locked = state


GLOBAL_LIST_EMPTY(lifts)
/obj/structure/industrial_lift
	name = "lift platform"
	desc = "A lightweight lift platform. It moves up and down."
	icon = 'icons/obj/catwalks.dmi'
	icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	layer = LATTICE_LAYER //under pipes



	var/id = null //ONLY SET THIS TO ONE OF THE LIFT'S PARTS. THEY'RE CONNECTED! ONLY ONE NEEDS THE SIGNAL!
	var/pass_through_floors = FALSE //if true, the elevator works through floors
	var/controls_locked = FALSE //if true, the lift cannot be manually moved.
	var/list/atom/movable/lift_load //things to move
	var/datum/lift_master/lift_master_datum    //control from

/obj/structure/industrial_lift/Initialize(mapload)
	. = ..()
	GLOB.lifts.Add(src)
	var/static/list/loc_connections = list(
		SIGNAL_EXITED =nameof(.proc/AtomExitHandler),
		SIGNAL_ENTERED = nameof(.proc/AtomEnterHandler),
		SIGNAL_ATOM_INITIALIZED_ON = nameof(.proc/AddItemOnLift)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	register_signal(src, SIGNAL_MOVABLE_BUMP, nameof(.proc/GracefullyBreak))

	if(!lift_master_datum)
		lift_master_datum = new(src)

/obj/structure/industrial_lift/LateInitialize()
	. = ..()
	for(var/AM in src.loc.contents)
		if(!istype(AM,/obj/structure/industrial_lift))
			AddItemOnLift(AM)

/obj/structure/industrial_lift/proc/UncrossedRemoveItemFromLift(atom/movable/gone, direction)
	SHOULD_NOT_SLEEP(TRUE)
	RemoveItemFromLift(gone)


//IDK how to do it better so...
/obj/structure/industrial_lift/proc/AtomExitHandler(turf/T, atom/AM)
	UncrossedRemoveItemFromLift(AM)

/obj/structure/industrial_lift/proc/AtomEnterHandler(turf/T, atom/AM)
	AddItemOnLift(AM)
///////////////////////////////////
/obj/structure/industrial_lift/proc/AddItemOnLift(atom/AM)
	SHOULD_NOT_SLEEP(TRUE)
	if(AM.invisibility == 101) //prevents the tram from stealing things like landmarks
		return
	if(AM in lift_load)
		return
	LAZYADD(lift_load, AM)
	register_signal(AM, SIGNAL_QDELETING, nameof(.proc/RemoveItemFromLift))

/obj/structure/industrial_lift/proc/RemoveItemFromLift(atom/movable/potential_rider)
	SHOULD_NOT_SLEEP(TRUE)
	if(!(potential_rider in lift_load))
		return
	LAZYREMOVE(lift_load, potential_rider)
	unregister_signal(potential_rider, SIGNAL_QDELETING)

/obj/structure/industrial_lift/proc/CheckItemsOnLift()
	for(var/AM in loc.contents)
		if(!istype(AM,/obj/structure/industrial_lift) && !(AM in lift_load))
			AddItemOnLift(AM)
/**
 * Signal for when the tram runs into a field of which it cannot go through.
 * Stops the train's travel fully, sends a message, and destroys the train.
 * Arguments:
 * bumped_atom - The atom this tram bumped into
 */
/obj/structure/industrial_lift/proc/GracefullyBreak(atom/bumped_atom)
	if(istype(bumped_atom, /obj/machinery/containment_field))
		return
	if(istype(bumped_atom, /obj/machinery/shieldwall))
		return

	bumped_atom.visible_message(SPAN_DANGER("[src] crashes into the field violently!"))

/obj/structure/industrial_lift/proc/lift_platform_expansion(datum/lift_master/lift_master_datum)
	. = list()
	for(var/direction in GLOB.cardinal)
		var/obj/structure/industrial_lift/neighbor = locate() in get_step(src, direction)
		if(!neighbor)
			continue
		. += neighbor

/obj/structure/industrial_lift/proc/smash_things(turf/destination, going)
	for(var/obj/structure/victim_structure in destination.contents)
		if(QDELETED(victim_structure))
			continue
		if(!is_type_in_list(victim_structure, lift_master_datum.ignored_smashthroughs))
			qdel(victim_structure)

	for(var/obj/machinery/victim_machine in destination.contents)
		if(QDELETED(victim_machine))
			continue
		if(is_type_in_list(victim_machine, lift_master_datum.ignored_smashthroughs))
			continue
		if(victim_machine.layer >= ABOVE_OBJ_LAYER) //avoids stuff that is probably flush with the ground
			playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
			visible_message(SPAN_DANGER("[src] smashes through [victim_machine]!"))
			qdel(victim_machine)

/obj/structure/industrial_lift/proc/travel(going, gliding_amount = 8)
	var/list/things_to_move = isnull(lift_load)?list():lift_load.Copy()
	var/turf/destination
	if(!isturf(going))
		destination = get_step(src, going)
	else
		destination = going

	if(istype(destination, /turf/simulated/wall))
		var/turf/simulated/wall/C = destination
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(2, 0, C)
		sparks.start()
		C.dismantle_wall(TRUE,FALSE,FALSE)
		for(var/mob/M in range(8, src))
			shake_camera(M, 2, 3)
		playsound(C, 'sound/effects/meteorimpact.ogg', 100, TRUE)

	if(going == DOWN)
		for(var/mob/living/crushed in destination.contents)
			to_chat(crushed, SPAN_DANGER("You are crushed by [src]!"))
			crushed.gib(FALSE,FALSE,FALSE)//the nicest kind of gibbing, keeping everything intact.

		smash_things(destination, going)

	else if(going != UP) //can't really crush something upwards

		var/atom/throw_target = get_edge_target_turf(src, turn(going, pick(45, -45))) //finds a spot to throw the victim at for daring to be hit by a tram
		smash_things(destination, going)

		for(var/mob/living/collided in destination.contents)
			if(is_type_in_list(collided, lift_master_datum.ignored_smashthroughs))
				continue
			to_chat(collided, SPAN_DANGER("[src] collides into you!"))
			playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
			var/damage = rand(5, 10)
			collided.apply_damage(2 * damage, BRUTE, BP_HEAD)
			collided.apply_damage(2 * damage, BRUTE, BP_CHEST)
			collided.apply_damage(0.5 * damage, BRUTE, BP_L_LEG)
			collided.apply_damage(0.5 * damage, BRUTE, BP_R_LEG)
			collided.apply_damage(0.5 * damage, BRUTE, BP_L_ARM)
			collided.apply_damage(0.5 * damage, BRUTE, BP_R_ARM)

			if(QDELETED(collided)) //in case it was a mob that dels on death
				continue
			var/turf/T = get_turf(src)
			T.add_blood(collided)
			//if going EAST, will turn to the NORTHEAST or SOUTHEAST and throw the ran over guy away
			collided.throw_at(throw_target, 200, 0.5)

	set_glide_size(gliding_amount)
	forceMove(destination)
	for(var/atom/movable/thing as anything in things_to_move)
		thing.set_glide_size(gliding_amount) //matches the glide size of the moving platform to stop them from jittering on it.
		thing.forceMove(destination)
	CheckItemsOnLift()
/**
 * Proc to ensure that the radial menu closes when it should.
 * Arguments:
 * * user - The person that opened the menu.
 * * starting_loc - The location of the lift when the menu was opened, used to prevent the menu from being interacted with after the lift was moved by someone else.
 *
 * Returns:
 * * boolean, FALSE if the menu should be closed, TRUE if the menu is clear to stay opened.
 */
/obj/structure/industrial_lift/proc/check_menu(mob/user, starting_loc)
	if(user.incapacitated() || !user.Adjacent(src) || starting_loc != src.loc)
		return FALSE
	return TRUE

/obj/structure/industrial_lift/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	//use(user)

//ai probably shouldn't get to use lifts but they sure are great for admins to crush people with
/obj/structure/industrial_lift/attack_ghost(mob/user)
	. = ..()
	if(.)
		return

/obj/structure/industrial_lift/attackby(obj/item/W, mob/user, params)
	return //use(user)

/obj/structure/industrial_lift/attack_robot(mob/living/silicon/robot/R)
	if(R.Adjacent(src))
		return //use(R)

/**
 * Shows a message indicating that the lift has moved up or down.
 * Arguments:
 * * going_up - Boolean on whether or not we're going up, to adjust the message appropriately.
 * * user - The mob that caused the lift to move, for the visible message.
 */
/obj/structure/industrial_lift/proc/show_fluff_message(going_up, mob/user)
	if(going_up)
		user.visible_message(SPAN_NOTICE("[user] moves the lift upwards."), SPAN_NOTICE("You move the lift upwards."))
	else
		user.visible_message(SPAN_NOTICE("[user] moves the lift downwards."), SPAN_NOTICE("You move the lift downwards."))

/obj/structure/industrial_lift/Destroy()
	GLOB.lifts.Remove(src)
	QDEL_NULL(lift_master_datum)
	var/list/border_lift_platforms = lift_platform_expansion()
	Move(null)
	for(var/border_lift in border_lift_platforms)
		lift_master_datum = new(border_lift)
	return ..()
