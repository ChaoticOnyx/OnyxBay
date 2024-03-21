/obj/effect/abstract/liquid_turf
	name = "liquid"
	icon = 'icons/effects/liquid.dmi'
	icon_state = "water-0"
	anchored = TRUE
	plane = FLOOR_PLANE
	layer = SHALLOW_FLUID_LAYER
	color = "#DDF"

	//For being on fire
	var/light_range = 0
	var/light_power = 1
	light_color = "#FAA019"

	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/height = 1
	var/only_big_diffs = 1
	var/turf/my_turf
	var/liquid_state = LIQUID_STATE_PUDDLE
	var/has_cached_share = FALSE

	var/attrition = 0

	var/immutable = FALSE

	var/list/reagent_list = list()
	var/total_reagents = 0
	var/temp = 20 CELSIUS

	var/fire_state = LIQUID_FIRE_STATE_NONE

	var/no_effects = FALSE


/obj/effect/abstract/liquid_turf/proc/check_fire(hotspotted = FALSE)
	var/my_burn_power = get_burn_power(hotspotted)
	if(!my_burn_power)
		if(fire_state)
			//Set state to 0
			set_fire_state(LIQUID_FIRE_STATE_NONE)
		return FALSE
	//Calculate appropriate state
	var/new_state = LIQUID_FIRE_STATE_SMALL
	switch(my_burn_power)
		if(0 to 7)
			new_state = LIQUID_FIRE_STATE_SMALL
		if(7 to 8)
			new_state = LIQUID_FIRE_STATE_MILD
		if(8 to 9)
			new_state = LIQUID_FIRE_STATE_MEDIUM
		if(9 to 10)
			new_state = LIQUID_FIRE_STATE_HUGE
		if(10 to INFINITY)
			new_state = LIQUID_FIRE_STATE_INFERNO

	if(fire_state != new_state)
		set_fire_state(new_state)

	return TRUE

/obj/effect/abstract/liquid_turf/proc/set_fire_state(new_state)
	fire_state = new_state
	switch(fire_state)
		if(LIQUID_FIRE_STATE_NONE)
			light_outer_range = 0
		if(LIQUID_FIRE_STATE_SMALL)
			light_outer_range = LIGHT_RANGE_FIRE
		if(LIQUID_FIRE_STATE_MILD)
			light_outer_range = LIGHT_RANGE_FIRE
		if(LIQUID_FIRE_STATE_MEDIUM)
			light_outer_range = LIGHT_RANGE_FIRE
		if(LIQUID_FIRE_STATE_HUGE)
			light_outer_range = LIGHT_RANGE_FIRE
		if(LIQUID_FIRE_STATE_INFERNO)
			light_outer_range = LIGHT_RANGE_FIRE
	update_light()
	update_overlays()

/obj/effect/abstract/liquid_turf/proc/get_burn_power(hotspotted = FALSE)
	//We are not on fire and werent ignited by a hotspot exposure, no fire pls
	if(!hotspotted && !fire_state)
		return FALSE
	var/total_burn_power = 0
	var/datum/reagent/R //Faster declaration
	for(var/reagent_type in reagent_list)
		R = reagent_type
		var/burn_power = initial(R.liquid_fire_power)
		if(burn_power)
			total_burn_power += burn_power * reagent_list[reagent_type]
	if(!total_burn_power)
		return FALSE
	total_burn_power /= total_reagents //We get burn power per unit.
	if(total_burn_power <= REQUIRED_FIRE_POWER_PER_UNIT)
		return FALSE
	//Finally, we burn
	return total_burn_power

/obj/effect/abstract/liquid_turf/proc/process_fire()
	if(!fire_state)
		SSliquids.processing_fire -= my_turf
		set_fire_state(LIQUID_FIRE_STATE_NONE)
	var/old_state = fire_state
	if(!check_fire())
		SSliquids.processing_fire -= my_turf
	//Try spreading
	if(fire_state == old_state) //If an extinguisher made our fire smaller, dont spread, else it's too hard to put out
		for(var/turf/T in my_turf.atmos_adjacent_turfs)
			if(T.liquids && !T.liquids.fire_state && T.liquids.check_fire(TRUE))
				SSliquids.processing_fire[T] = TRUE
	//Burn our resources
	var/datum/reagent/R //Faster declaration
	var/burn_rate
	for(var/reagent_type in reagent_list)
		R = reagent_type
		burn_rate = initial(R.liquid_fire_burnrate)
		if(burn_rate)
			var/amt = reagent_list[reagent_type]
			if(burn_rate >= amt)
				reagent_list -= reagent_type
				total_reagents -= amt
			else
				reagent_list[reagent_type] -= burn_rate
				total_reagents -= burn_rate

	my_turf.hotspot_expose((20 CELSIUS+50) + (50*fire_state), 125)
	for(var/A in my_turf.contents)
		var/atom/AT = A
		if(!QDELETED(AT))
			AT.fire_act((20 CELSIUS+50) + (50*fire_state), 125)

	if(reagent_list.len == 0)
		qdel(src, TRUE)
	else
		has_cached_share = FALSE
		if(!my_turf.lgroup)
			calculate_height()
			set_reagent_color_for_liquid()

/obj/effect/abstract/liquid_turf/proc/process_evaporation()
	if(immutable)
		SSliquids.evaporation_queue -= my_turf
		return
	//We're in a group. dont try and evaporate
	if(my_turf.lgroup)
		SSliquids.evaporation_queue -= my_turf
		return
	if(liquid_state != LIQUID_STATE_PUDDLE)
		SSliquids.evaporation_queue -= my_turf
		return
	//See if any of our reagents evaporates
	var/any_change = FALSE
	var/datum/reagent/R //Faster declaration
	for(var/reagent_type in reagent_list)
		R = reagent_type
		//We evaporate. bye bye
		if(initial(R.evaporates))
			total_reagents -= reagent_list[reagent_type]
			reagent_list -= reagent_type
			any_change = TRUE
	if(!any_change)
		SSliquids.evaporation_queue -= my_turf
		return
	//No total reagents. Commit death
	if(reagent_list.len == 0)
		qdel(src, TRUE)
	//Reagents still left. Recalculte height and color and remove us from the queue
	else
		has_cached_share = FALSE
		SSliquids.evaporation_queue -= my_turf
		calculate_height()
		set_reagent_color_for_liquid()

/**
 * Makes and returns the liquid effect overlay.
 *
 * Arguments:
 * * overlay_state - the icon state of the new overlay
 * * overlay_layer - the layer
 * * overlay_plane - the plane
 */
/obj/effect/abstract/liquid_turf/proc/make_liquid_overlay(overlay_state, overlay_layer, overlay_plane)
	PRIVATE_PROC(TRUE)

	return mutable_appearance(
		'icons/effects/liquid_overlays.dmi',
		overlay_state
	)

/**
 * Returns a list of over and underlays for different liquid states.
 *
 * Arguments:
 * * state - the stage number.
 * * has_top - if this stage has a top.
 */
/obj/effect/abstract/liquid_turf/proc/make_state_layer(state, has_top)
	PRIVATE_PROC(TRUE)

	. = list(make_liquid_overlay("stage[state]_bottom", DEEP_FLUID_LAYER, DEFAULT_PLANE))

	if(!has_top)
		return

	. += make_liquid_overlay("stage[state]_top", BELOW_OBJ_LAYER, DEFAULT_PLANE)

/obj/effect/abstract/liquid_turf/proc/set_new_liquid_state(new_state)
	liquid_state = new_state
	update_overlays()

/obj/effect/abstract/liquid_turf/proc/update_overlays()

	if(no_effects)
		return
	src.overlays.Cut()
	var/mutable_appearance/liquid_state_overlay
	switch(liquid_state)
		if(LIQUID_STATE_ANKLES)
			liquid_state_overlay+= make_state_layer(1, has_top = TRUE)
		if(LIQUID_STATE_WAIST)
			liquid_state_overlay += make_state_layer(2, has_top = TRUE)
		if(LIQUID_STATE_SHOULDERS)
			liquid_state_overlay += make_state_layer(3, has_top = TRUE)
		if(LIQUID_STATE_FULLTILE)
			liquid_state_overlay += make_state_layer(4, has_top = FALSE)

	src.overlays += liquid_state_overlay

	var/mutable_appearance/shine = mutable_appearance(icon, "shine", flags = RESET_COLOR|RESET_ALPHA)
	shine.alpha = 32
	src.overlays += shine

	//Add a fire overlay too

	if(fire_state == LIQUID_FIRE_STATE_NONE)
		return

	var/fire_icon_state
	switch(fire_state)
		if(LIQUID_FIRE_STATE_SMALL)
			fire_icon_state = "fire_small"
		if(LIQUID_FIRE_STATE_MILD)
			fire_icon_state = "fire_small"
		if(LIQUID_FIRE_STATE_MEDIUM)
			fire_icon_state = "fire_medium"
		if(LIQUID_FIRE_STATE_HUGE)
			fire_icon_state = "fire_big"
		if(LIQUID_FIRE_STATE_INFERNO)
			fire_icon_state = "fire_big"

	src.overlays += mutable_appearance(icon, fire_icon_state, appearance_flags = RESET_COLOR|RESET_ALPHA)

//Takes a flat of our reagents and returns it, possibly qdeling our liquids
/obj/effect/abstract/liquid_turf/proc/take_reagents_flat(flat_amount)
	var/datum/reagents/tempr = new /datum/reagents(10000, GLOB.temp_reagents_holder)
	if(flat_amount >= total_reagents)
		tempr.add_noreact_reagent_list(reagent_list)
		qdel(src, TRUE)
	else
		var/fraction = flat_amount/total_reagents
		var/passed_list = list()
		for(var/reagent_type in reagent_list)
			var/amount = fraction * reagent_list[reagent_type]
			reagent_list[reagent_type] -= amount
			total_reagents -= amount
			passed_list[reagent_type] = amount
		tempr.add_noreact_reagent_list(passed_list)
		has_cached_share = FALSE

	return tempr

/obj/effect/abstract/liquid_turf/immutable/take_reagents_flat(flat_amount)
	return simulate_reagents_flat(flat_amount)

//Returns a reagents holder with all the reagents with a higher volume than the threshold
/obj/effect/abstract/liquid_turf/proc/simulate_reagents_threshold(amount_threshold)
	var/datum/reagents/tempr = new /datum/reagents(10000, GLOB.temp_reagents_holder)
	var/passed_list = list()
	for(var/reagent_type in reagent_list)
		var/amount = reagent_list[reagent_type]
		if(amount_threshold && amount < amount_threshold)
			continue
		passed_list[reagent_type] = amount
	tempr.add_noreact_reagent_list(passed_list)

	return tempr

//Returns a flat of our reagents without any effects on the liquids
/obj/effect/abstract/liquid_turf/proc/simulate_reagents_flat(flat_amount)
	var/datum/reagents/tempr = new /datum/reagents(10000, GLOB.temp_reagents_holder)
	if(flat_amount >= total_reagents)
		tempr.add_noreact_reagent_list(reagent_list)
	else
		var/fraction = flat_amount/total_reagents
		var/passed_list = list()
		for(var/reagent_type in reagent_list)
			var/amount = fraction * reagent_list[reagent_type]
			passed_list[reagent_type] = amount
		tempr.add_noreact_reagent_list(passed_list)

	return tempr

/obj/effect/abstract/liquid_turf/fire_act(temperature, volume)
	if(!fire_state)
		if(check_fire(TRUE))
			SSliquids.processing_fire[my_turf] = TRUE

/obj/effect/abstract/liquid_turf/proc/set_reagent_color_for_liquid()
	color = mix_color_from_reagent_list(reagent_list)

/obj/effect/abstract/liquid_turf/proc/calculate_height()
	var/new_height = CEILING(total_reagents, 1)/LIQUID_HEIGHT_DIVISOR
	set_height(new_height)
	var/determined_new_state
	//We add the turf height if it's positive to state calculations
	if(my_turf.turf_height > 0)
		new_height += my_turf.turf_height
	switch(new_height)
		if(0 to LIQUID_ANKLES_LEVEL_HEIGHT-1)
			determined_new_state = LIQUID_STATE_PUDDLE
		if(LIQUID_ANKLES_LEVEL_HEIGHT to LIQUID_WAIST_LEVEL_HEIGHT-1)
			determined_new_state = LIQUID_STATE_ANKLES
		if(LIQUID_WAIST_LEVEL_HEIGHT to LIQUID_SHOULDERS_LEVEL_HEIGHT-1)
			determined_new_state = LIQUID_STATE_WAIST
		if(LIQUID_SHOULDERS_LEVEL_HEIGHT to LIQUID_FULLTILE_LEVEL_HEIGHT-1)
			determined_new_state = LIQUID_STATE_SHOULDERS
		if(LIQUID_FULLTILE_LEVEL_HEIGHT to INFINITY)
			determined_new_state = LIQUID_STATE_FULLTILE
	if(determined_new_state != liquid_state)
		set_new_liquid_state(determined_new_state)

/obj/effect/abstract/liquid_turf/immutable/calculate_height()
	var/new_height = CEILING(total_reagents, 1)/LIQUID_HEIGHT_DIVISOR
	set_height(new_height)
	var/determined_new_state
	switch(new_height)
		if(0 to LIQUID_ANKLES_LEVEL_HEIGHT-1)
			determined_new_state = LIQUID_STATE_PUDDLE
		if(LIQUID_ANKLES_LEVEL_HEIGHT to LIQUID_WAIST_LEVEL_HEIGHT-1)
			determined_new_state = LIQUID_STATE_ANKLES
		if(LIQUID_WAIST_LEVEL_HEIGHT to LIQUID_SHOULDERS_LEVEL_HEIGHT-1)
			determined_new_state = LIQUID_STATE_WAIST
		if(LIQUID_SHOULDERS_LEVEL_HEIGHT to LIQUID_FULLTILE_LEVEL_HEIGHT-1)
			determined_new_state = LIQUID_STATE_SHOULDERS
		if(LIQUID_FULLTILE_LEVEL_HEIGHT to INFINITY)
			determined_new_state = LIQUID_STATE_FULLTILE
	if(determined_new_state != liquid_state)
		set_new_liquid_state(determined_new_state)

/obj/effect/abstract/liquid_turf/proc/set_height(new_height)
	var/prev_height = height
	height = new_height
	if(abs(height - prev_height) > WATER_HEIGH_DIFFERENCE_DELTA_SPLASH)
		//Splash
		if(prob(WATER_HEIGH_DIFFERENCE_SOUND_CHANCE))
			var/sound_to_play = pick(list(
				'sound/effects/water_wade1.ogg',
				'sound/effects/water_wade2.ogg',
				'sound/effects/water_wade3.ogg',
				'sound/effects/water_wade4.ogg'
				))
			playsound(my_turf, sound_to_play, 60, 0)
		var/obj/splashy = new /obj/effect/liquid_splash(my_turf)
		splashy.color = color
		if(height >= LIQUID_WAIST_LEVEL_HEIGHT)
			//Push things into some direction, like space wind
			var/turf/dest_turf
			var/last_height = height
			for(var/turf in my_turf.atmos_adjacent_turfs)
				var/turf/T = turf
				if(T.z != my_turf.z)
					continue
				if(!T.liquids) //Automatic winner
					dest_turf = T
					break
				if(T.liquids.height < last_height)
					dest_turf = T
					last_height = T.liquids.height
			if(dest_turf)
				var/dir = get_dir(my_turf, dest_turf)
				var/atom/movable/AM
				for(var/thing in my_turf)
					AM = thing
					if(!AM.anchored && !AM.pulledby && !isobserver(AM))
						if(ishuman(AM))
							var/mob/living/carbon/human/H = AM
							if(!(H.shoes))
								step(H, dir)
								if(prob(60) && !H.lying)
									to_chat(H, SPAN_DANGER("The current knocks you down!"))
									H.Paralyse(60)
						else
							step(AM, dir)

/obj/effect/abstract/liquid_turf/immutable/set_height(new_height)
	height = new_height

/obj/effect/abstract/liquid_turf/proc/movable_entered(datum/source, atom/movable/AM)
	var/turf/T = source
	if(isobserver(AM))
		return //ghosts, camera eyes, etc. don't make water splashy splashy
	if(liquid_state >= LIQUID_STATE_ANKLES)
		if(prob(30))
			var/sound_to_play = pick(list(
				'sound/effects/water_wade1.ogg',
				'sound/effects/water_wade2.ogg',
				'sound/effects/water_wade3.ogg',
				'sound/effects/water_wade4.ogg'
				))
			playsound(T, sound_to_play, 50, 0)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			C.add_modifier(/datum/modifier/status_effect/water_affected)
	else if (isliving(AM))
		var/mob/living/L = AM
		if(prob(7))
			L.slip(T, 60)
	if(fire_state)
		AM.fire_act((20 CELSIUS+50) + (50*fire_state), 125)

/obj/effect/abstract/liquid_turf/proc/mob_fall(datum/source, mob/M)
	var/turf/T = source
	if(liquid_state >= LIQUID_STATE_ANKLES && has_gravity(T))
		playsound(T, 'sound/effects/splash.ogg', 50, 0)
		if(iscarbon(M))
			var/mob/living/carbon/falling_carbon = M

			// No point in giving reagents to the deceased. It can cause some runtimes.
			if(falling_carbon.stat >= DEAD)
				return

			if(falling_carbon.wear_mask && falling_carbon.wear_mask.body_parts_covered & FACE)
				to_chat(falling_carbon, SPAN_DANGER("You fall in the [reagents_to_text()]!"))
			else
				var/datum/reagents/tempr = take_reagents_flat(CHOKE_REAGENTS_INGEST_ON_FALL_AMOUNT)
				tempr.trans_to_mob(falling_carbon, tempr.total_volume, type = CHEM_INGEST)

				qdel(tempr)
				falling_carbon.adjustOxyLoss(5)
				//C.emote("cough")
				INVOKE_ASYNC(falling_carbon, /mob/proc/emote, "cough")
				to_chat(falling_carbon, SPAN_DANGER("You fall in and swallow some [reagents_to_text()]!"))
		else
			to_chat(M, SPAN_DANGER("You fall in the [reagents_to_text()]!"))

/obj/effect/abstract/liquid_turf/Initialize(mapload)
	. = ..()
	if(!SSliquids)
		CRASH("Liquid Turf created with the liquids sybsystem not yet initialized!")
	if(!immutable)
		my_turf = get_turf(src)
		register_signal(my_turf, SIGNAL_ENTERED, .proc/movable_entered)
		register_signal(my_turf, SIGNAL_ATOM_FALL, .proc/mob_fall)
		SSliquids.add_active_turf(my_turf)

		SEND_SIGNAL(my_turf, SIGNAL_TURF_LIQUIDS_CREATION, src)

	update_overlays()
	if(z)
		src.smooth(get_turf(src))
		src.smooth_neighbors(get_turf(src))

/obj/effect/abstract/liquid_turf/Destroy(force)
	..()
	if(force)
		unregister_signal(my_turf, list(SIGNAL_ENTERED, SIGNAL_ATOM_FALL))
		if(my_turf.lgroup)
			my_turf.lgroup.remove_from_group(my_turf)
		if(SSliquids.evaporation_queue[my_turf])
			SSliquids.evaporation_queue -= my_turf
		if(SSliquids.processing_fire[my_turf])
			SSliquids.processing_fire -= my_turf
		//Is added because it could invoke a change to neighboring liquids
		SSliquids.add_active_turf(my_turf)
		my_turf.liquids = null
		src.smooth_neighbors(my_turf)
		my_turf = null
	else
		return QDEL_HINT_LETMELIVE
	return

/obj/effect/abstract/liquid_turf/immutable/Destroy(force)
	if(force)
		CRASH("Something tried to hard destroy an immutable liquid.")
	return ..()

//Exposes my turf with simulated reagents
/obj/effect/abstract/liquid_turf/proc/ExposeMyTurf()
	var/datum/reagents/tempr = simulate_reagents_threshold(LIQUID_REAGENT_THRESHOLD_TURF_EXPOSURE)
	tempr.touch_turf(my_turf)
	qdel(tempr)

/obj/effect/abstract/liquid_turf/proc/ChangeToNewTurf(turf/NewT)
	if(NewT.liquids)
		CRASH("Liquids tried to change to a new turf, that already had liquids on it!")

	unregister_signal(my_turf, list(SIGNAL_ENTERED, SIGNAL_ATOM_FALL))
	if(SSliquids.active_turfs[my_turf])
		SSliquids.active_turfs -= my_turf
		SSliquids.active_turfs[NewT] = TRUE
	if(SSliquids.evaporation_queue[my_turf])
		SSliquids.evaporation_queue -= my_turf
		SSliquids.evaporation_queue[NewT] = TRUE
	if(SSliquids.processing_fire[my_turf])
		SSliquids.processing_fire -= my_turf
		SSliquids.processing_fire[NewT] = TRUE
	my_turf.liquids = null
	my_turf = NewT
	NewT.liquids = src
	loc = NewT
	register_signal(my_turf, SIGNAL_ENTERED, .proc/movable_entered)
	register_signal(my_turf, SIGNAL_ATOM_FALL, .proc/mob_fall)


/**
 * Creates a string of the reagents that make up this liquid.
 *
 * Puts the reagent(s) that make up the liquid into string form e.g. "plasma" or "plasma and water", or 'plasma, milk, and water' depending on how many reagents there are.
 *
 * Returns the reagents list string or a generic "liquid" if there are no reagents somehow
 *  */
/obj/effect/abstract/liquid_turf/proc/reagents_to_text()
	/// the total amount of different types of reagents in the liquid
	var/total_reagents = length(reagent_list)
	/// the amount of different types of reagents that have not been listed yet
	var/reagents_remaining = total_reagents
	/// the final string to be returned
	var/reagents_string = ""
	if(!reagents_remaining)
		return reagents_string += "liquid"

	do
		for(var/datum/reagent/reagent_type as anything in reagent_list)
			reagents_string += "[initial(reagent_type.name)]"
			reagents_remaining--
			if(!reagents_remaining)
				break
			// if we are at the last reagent in the list, preface its name with 'and'.
			// do not use a comma if there were only two reagents in the list
			if(total_reagents == 2)
				reagents_string += " and "
			else
				reagents_string += ", "
				if(reagents_remaining == 1)
					reagents_string += "and "
	while(reagents_remaining)

	return lowertext(reagents_string)

/obj/effect/liquid_splash
	icon = 'icons/effects/splash.dmi'
	icon_state = "splash"
	layer = FLY_LAYER

/obj/effect/liquid_splash/Initialize()
	. = ..()
	QDEL_IN(src, 5 SECONDS)

/obj/effect/abstract/liquid_turf/immutable
	immutable = TRUE
	var/list/starting_mixture = list(/datum/reagent/water = 600)
	var/starting_temp = 20 CELSIUS

//STRICTLY FOR IMMUTABLES DESPITE NOT BEING /immutable
/obj/effect/abstract/liquid_turf/proc/add_turf(turf/T)
	T.liquids = src
	T.vis_contents += src
	SSliquids.active_immutables[T] = TRUE
	register_signal(T, SIGNAL_ENTERED, .proc/movable_entered)
	register_signal(T, SIGNAL_ATOM_FALL, .proc/mob_fall)

/obj/effect/abstract/liquid_turf/proc/remove_turf(turf/T)
	SSliquids.active_immutables -= T
	T.liquids = null
	T.vis_contents -= src
	unregister_signal(T, list(SIGNAL_ENTERED, SIGNAL_ATOM_FALL))

/obj/effect/abstract/liquid_turf/immutable/ocean
	icon_state = "ocean"
	plane = DEFAULT_PLANE //Same as weather, etc.
	layer = OBJ_LAYER
	starting_temp = 20 CELSIUS-150
	no_effects = TRUE
	vis_flags = 0

/obj/effect/abstract/liquid_turf/immutable/ocean/warm
	starting_temp = 20 CELSIUS+20

/obj/effect/abstract/liquid_turf/immutable/Initialize(mapload)
	. = ..()
	reagent_list = starting_mixture.Copy()
	total_reagents = 0
	for(var/key in reagent_list)
		total_reagents += reagent_list[key]
	temp = starting_temp
	calculate_height()
	set_reagent_color_for_liquid()

/obj/effect/abstract/liquid_turf/proc/smooth_neighbors(smoothing_turf)
	for(var/direction in GLOB.alldirs)
		var/obj/effect/abstract/liquid_turf/L = locate() in get_step(smoothing_turf, direction)
		if(L)
			L.smooth(L.loc) //so siding get updated properly


/obj/effect/abstract/liquid_turf/proc/smooth(smoothing_turf)
	ASSERT(!isnull(smoothing_turf))
	var/connectdir = 0
	for(var/direction in GLOB.cardinal)
		if(locate(/obj/effect/abstract/liquid_turf) in get_step(smoothing_turf, direction))
			connectdir |= direction

	//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
	var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW
	var/dirs = list(1,2,4,8)
	var/i = 1
	for(var/diag in list(NORTHEAST, SOUTHEAST,NORTHWEST,SOUTHWEST))
		if((connectdir & diag) == diag)
			if(locate(/obj/effect/abstract/liquid_turf) in get_step(smoothing_turf, diag))
				diagonalconnect |= dirs[i]
		i += 1

	src.icon_state = "water-[connectdir]-[diagonalconnect]"
