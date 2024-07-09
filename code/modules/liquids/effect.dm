/atom/movable/liquid_turf
	name = "liquid"
	icon = 'icons/effects/liquid.dmi'
	icon_state = "water-0"
	base_icon_state = "water"
	anchored = TRUE
	plane = DEFAULT_PLANE
	layer = SHALLOW_FLUID_LAYER
	color = "#DDF"

	//For being on fire
	light_inner_range = 0
	light_max_bright = 1
	light_color = LIGHT_COLOR_FIRE

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

	/// State-specific message chunks for examine_turf()
	var/static/list/liquid_state_messages = list(
		"[LIQUID_STATE_PUDDLE]" = "a puddle of $",
		"[LIQUID_STATE_ANKLES]" = "$ going [SPAN_WARNING("up to your ankles")]",
		"[LIQUID_STATE_WAIST]" = "$ going [SPAN_WARNING("up to your waist")]",
		"[LIQUID_STATE_SHOULDERS]" = "$ going [SPAN_WARNING("up to your shoulders")]",
		"[LIQUID_STATE_FULLTILE]" = "$ going [SPAN_WARNING("over your head")]",
	)

/atom/movable/liquid_turf/proc/check_fire(hotspotted = FALSE)
	var/my_burn_power = get_burn_power(hotspotted)
	if(!my_burn_power)
		if(fire_state)
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

/atom/movable/liquid_turf/proc/set_fire_state(new_state)
	fire_state = new_state
	switch(fire_state)
		if(LIQUID_FIRE_STATE_NONE)
			set_light(0)
		if(LIQUID_FIRE_STATE_SMALL)
			set_light(light_max_bright, 3)
		if(LIQUID_FIRE_STATE_MILD)
			set_light(light_max_bright, 3)
		if(LIQUID_FIRE_STATE_MEDIUM)
			set_light(light_max_bright, 3)
		if(LIQUID_FIRE_STATE_HUGE)
			set_light(light_max_bright, 3)
		if(LIQUID_FIRE_STATE_INFERNO)
			set_light(light_max_bright, 3)

	update_light()
	update_icon()

/atom/movable/liquid_turf/proc/get_burn_power(hotspotted = FALSE)
	if(!hotspotted && !fire_state)
		return FALSE

	var/total_burn_power = 0
	var/datum/reagent/R
	for(var/reagent_type in reagent_list)
		R = reagent_type
		var/burn_power = initial(R.liquid_fire_power)
		if(burn_power)
			total_burn_power += burn_power * reagent_list[reagent_type]
	if(!total_burn_power)
		return FALSE

	total_burn_power /= total_reagents
	if(total_burn_power <= REQUIRED_FIRE_POWER_PER_UNIT)
		return FALSE

	return total_burn_power

/atom/movable/liquid_turf/proc/extinguish()
	//. = ..()
	if(fire_state)
		set_fire_state(LIQUID_FIRE_STATE_NONE)

/atom/movable/liquid_turf/proc/process_fire()
	if(!fire_state)
		SSliquids.processing_fire -= my_turf
	var/old_state = fire_state
	if(!check_fire())
		SSliquids.processing_fire -= my_turf
	//Try spreading
	if(fire_state == old_state) //If an extinguisher made our fire smaller, dont spread, else it's too hard to put out
		for(var/turf/adjacent_turf in my_turf.get_adjacent_passable_turfs())
			if(adjacent_turf.liquids && !adjacent_turf.liquids.fire_state && adjacent_turf.liquids.check_fire(TRUE))
				SSliquids.processing_fire[adjacent_turf] = TRUE
	//Burn our resources
	var/datum/reagent/reagent
	var/burn_rate
	for(var/reagent_type in reagent_list)
		reagent = reagent_type
		burn_rate = initial(reagent.liquid_fire_burnrate)
		if(burn_rate)
			var/amt = reagent_list[reagent_type]
			if(burn_rate >= amt)
				reagent_list -= reagent_type
				total_reagents -= amt
			else
				reagent_list[reagent_type] -= burn_rate
				total_reagents -= burn_rate

	my_turf.hotspot_expose((20 CELSIUS + 50) + (50 * fire_state), 125)
	for(var/atom/content in my_turf.contents)
		if(!QDELETED(content))
			content.fire_act((20 CELSIUS + 50) + (50 * fire_state), 125)

	if(reagent_list.len == 0)
		qdel(src, TRUE)
	else
		has_cached_share = FALSE
		if(!my_turf.lgroup)
			calculate_height()
			set_reagent_color_for_liquid()

/atom/movable/liquid_turf/proc/process_evaporation()
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
/atom/movable/liquid_turf/proc/make_liquid_overlay(overlay_state, overlay_layer, overlay_plane)
	PRIVATE_PROC(TRUE)

	return mutable_appearance(
		'icons/effects/liquid_overlays.dmi',
		overlay_state,
		layer = overlay_layer,
		plane = overlay_plane,
		flags = DEFAULT_APPEARANCE_FLAGS
	)

/**
 * Returns a list of over and underlays for different liquid states.
 *
 * Arguments:
 * * state - the stage number.
 * * has_top - if this stage has a top.
 */
/atom/movable/liquid_turf/proc/make_state_layer(state, has_top)
	PRIVATE_PROC(TRUE)

	. = list(make_liquid_overlay("stage[state]_bottom", DEEP_FLUID_LAYER, DEFAULT_PLANE))

	if(!has_top)
		return

	. += make_liquid_overlay("stage[state]_top", BELOW_OBJ_LAYER, DEFAULT_PLANE)

/atom/movable/liquid_turf/proc/set_new_liquid_state(new_state)
	liquid_state = new_state
	update_icon()

/atom/movable/liquid_turf/on_update_icon()
	ClearOverlays()
	if(no_effects)
		return

	switch(liquid_state)
		if(LIQUID_STATE_ANKLES)
			AddOverlays(make_state_layer(1, has_top = TRUE))
		if(LIQUID_STATE_WAIST)
			AddOverlays(make_state_layer(2, has_top = TRUE))
		if(LIQUID_STATE_SHOULDERS)
			AddOverlays(make_state_layer(3, has_top = TRUE))
		if(LIQUID_STATE_FULLTILE)
			AddOverlays(make_state_layer(4, has_top = FALSE))

	var/mutable_appearance/shine = mutable_appearance(icon, "shine", flags = RESET_COLOR|RESET_ALPHA, alpha = 32)
	shine.blend_mode = BLEND_ADD
	AddOverlays(shine)

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

	AddOverlays(mutable_appearance(icon, fire_icon_state, ABOVE_WINDOW_LAYER, src, DEFAULT_PLANE, flags = RESET_COLOR|RESET_ALPHA))
	AddOverlays(emissive_appearance(icon, fire_icon_state, src, alpha = src.alpha))

//Takes a flat of our reagents and returns it, possibly qdeling our liquids
/atom/movable/liquid_turf/proc/take_reagents_flat(flat_amount)
	var/datum/reagents/tempr = new /datum/reagents(10000, GLOB.temp_reagents_holder)
	if(flat_amount >= total_reagents)
		tempr.add_reagent_list(reagent_list, safety = TRUE)
		qdel(src, TRUE)
	else
		var/fraction = flat_amount/total_reagents
		var/passed_list = list()
		for(var/reagent_type in reagent_list)
			var/amount = fraction * reagent_list[reagent_type]
			reagent_list[reagent_type] -= amount
			total_reagents -= amount
			passed_list[reagent_type] = amount
		tempr.add_reagent_list(passed_list, safety = TRUE)
		has_cached_share = FALSE
	//tempr.chem_temp = temp
	return tempr

/atom/movable/liquid_turf/immutable/take_reagents_flat(flat_amount)
	return simulate_reagents_flat(flat_amount)

//Returns a reagents holder with all the reagents with a higher volume than the threshold
/atom/movable/liquid_turf/proc/simulate_reagents_threshold(amount_threshold)
	var/datum/reagents/tempr = new /datum/reagents(10000, GLOB.temp_reagents_holder)
	var/passed_list = list()
	for(var/reagent_type in reagent_list)
		var/amount = reagent_list[reagent_type]
		if(amount_threshold && amount < amount_threshold)
			continue
		passed_list[reagent_type] = amount
	tempr.add_reagent_list(passed_list, safety = TRUE)
	//tempr.chem_temp = temp
	return tempr

//Returns a flat of our reagents without any effects on the liquids
/atom/movable/liquid_turf/proc/simulate_reagents_flat(flat_amount)
	var/datum/reagents/tempr = new /datum/reagents(10000, GLOB.temp_reagents_holder)
	if(flat_amount >= total_reagents)
		tempr.add_reagent_list(reagent_list, safety = TRUE)
	else
		var/fraction = flat_amount/total_reagents
		var/passed_list = list()
		for(var/reagent_type in reagent_list)
			var/amount = fraction * reagent_list[reagent_type]
			passed_list[reagent_type] = amount
		tempr.add_reagent_list(passed_list, safety = TRUE)
	//tempr.chem_temp = temp
	return tempr

/atom/movable/liquid_turf/fire_act()
	if(!fire_state)
		if(check_fire(TRUE))
			SSliquids.processing_fire[my_turf] = TRUE

	return ..()

/atom/movable/liquid_turf/proc/set_reagent_color_for_liquid()
	color = mix_color_from_reagent_list(reagent_list)

/atom/movable/liquid_turf/proc/calculate_height()
	var/new_height = CEILING(total_reagents, 1) / LIQUID_HEIGHT_DIVISOR
	set_height(new_height)
	var/determined_new_state
	switch(new_height)
		if(0 to LIQUID_ANKLES_LEVEL_HEIGHT - 1)
			determined_new_state = LIQUID_STATE_PUDDLE
		if(LIQUID_ANKLES_LEVEL_HEIGHT to LIQUID_WAIST_LEVEL_HEIGHT - 1)
			determined_new_state = LIQUID_STATE_ANKLES
		if(LIQUID_WAIST_LEVEL_HEIGHT to LIQUID_SHOULDERS_LEVEL_HEIGHT - 1)
			determined_new_state = LIQUID_STATE_WAIST
		if(LIQUID_SHOULDERS_LEVEL_HEIGHT to LIQUID_FULLTILE_LEVEL_HEIGHT - 1)
			determined_new_state = LIQUID_STATE_SHOULDERS
		if(LIQUID_FULLTILE_LEVEL_HEIGHT to INFINITY)
			determined_new_state = LIQUID_STATE_FULLTILE
	if(determined_new_state != liquid_state)
		set_new_liquid_state(determined_new_state)

/atom/movable/liquid_turf/immutable/calculate_height()
	var/new_height = CEILING(total_reagents, 1) / LIQUID_HEIGHT_DIVISOR
	set_height(new_height)
	var/determined_new_state
	switch(new_height)
		if(0 to LIQUID_ANKLES_LEVEL_HEIGHT-  1)
			determined_new_state = LIQUID_STATE_PUDDLE
		if(LIQUID_ANKLES_LEVEL_HEIGHT to LIQUID_WAIST_LEVEL_HEIGHT - 1)
			determined_new_state = LIQUID_STATE_ANKLES
		if(LIQUID_WAIST_LEVEL_HEIGHT to LIQUID_SHOULDERS_LEVEL_HEIGHT - 1)
			determined_new_state = LIQUID_STATE_WAIST
		if(LIQUID_SHOULDERS_LEVEL_HEIGHT to LIQUID_FULLTILE_LEVEL_HEIGHT - 1)
			determined_new_state = LIQUID_STATE_SHOULDERS
		if(LIQUID_FULLTILE_LEVEL_HEIGHT to INFINITY)
			determined_new_state = LIQUID_STATE_FULLTILE
	if(determined_new_state != liquid_state)
		set_new_liquid_state(determined_new_state)

/atom/movable/liquid_turf/proc/set_height(new_height)
	var/prev_height = height
	height = new_height
	if(abs(height - prev_height) > WATER_HEIGH_DIFFERENCE_DELTA_SPLASH)
		//Splash
		if(prob(WATER_HEIGH_DIFFERENCE_SOUND_CHANCE))
			var/sound_to_play = pick(list(
				'sound/effects/water/water_wade1.ogg',
				'sound/effects/water/water_wade2.ogg',
				'sound/effects/water/water_wade3.ogg',
				'sound/effects/water/water_wade4.ogg'
				))
			playsound(my_turf, sound_to_play, 60, 0)
		var/obj/splashy = new /obj/effect/temp_visual/liquid_splash(my_turf)
		splashy.color = color
		if(height >= LIQUID_WAIST_LEVEL_HEIGHT)
			//Push things into some direction, like space wind
			var/turf/dest_turf
			var/last_height = height
			for(var/turf in my_turf.get_adjacent_passable_turfs())
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
							var/mob/living/carbon/human/C = AM
							if(!(C.shoes && C.shoes.item_flags))
								step(C, dir)
								if(prob(60) && C.lying)
									to_chat(C, SPAN_DANGER("The current knocks you down!"))
									C.SetParalysis(60)
						else
							step(AM, dir)

/atom/movable/liquid_turf/immutable/set_height(new_height)
	height = new_height

/atom/movable/liquid_turf/proc/movable_entered(datum/source, atom/movable/AM)
	//SIGNAL_HANDLER
	var/turf/T = source
	if(isobserver(AM))
		return //ghosts, camera eyes, etc. don't make water splashy splashy
	if(liquid_state >= LIQUID_STATE_ANKLES)
		if(prob(30))
			var/sound_to_play = pick(list(
				'sound/effects/water/water_wade1.ogg',
				'sound/effects/water/water_wade2.ogg',
				'sound/effects/water/water_wade3.ogg',
				'sound/effects/water/water_wade4.ogg'
				))
			playsound(T, sound_to_play, 50, 0)

	var/mob/living/L = AM
	if(istype(L))
		switch(liquid_state)
			if(LIQUID_STATE_ANKLES)
				if(L.lying && prob(50))
					var/amt = rand(10, 15)
					L.adjust_wet_stacks(amt / 10, take_reagents_flat(amt))

				else if(prob(5) && ishuman(L)) // Bypassing making clothes wet via wet_stacks as small puddles do not normally make mobs wet.
					var/mob/living/carbon/human/H = L
					var/obj/item/clothing/shoes/S = H.shoes
					var/amt = rand(5, 10)
					S?.make_wet(take_reagents_flat(amt), amt)

			if(LIQUID_STATE_WAIST)
				var/amt = rand(15, 20)
				L.adjust_wet_stacks(amt / 10, take_reagents_flat(amt))
			if(LIQUID_STATE_SHOULDERS)
				if(prob(50))
					var/amt = rand(20, 25)
					L.adjust_wet_stacks(amt / 10, take_reagents_flat(amt))
			if(LIQUID_STATE_FULLTILE)
				var/amt = rand(20, 30)
				L.adjust_wet_stacks(amt / 10, take_reagents_flat(amt))

	else if (isliving(AM))
		var/mob/living/living = AM
		if(prob(7))
			living.slip(T, 60)
	if(fire_state)
		AM.fire_act((20 CELSIUS + 50) + (50 * fire_state), 125)

/atom/movable/liquid_turf/proc/mob_fall(datum/source, mob/M)
	//SIGNAL_HANDLER
	var/turf/T = source
	if(liquid_state >= LIQUID_STATE_ANKLES && has_gravity(T))
		//playsound(T, 'modular_skyrat/modules/liquids/sound/effects/splash.ogg', 50, 0)
		if(iscarbon(M))
			var/mob/living/carbon/falling_carbon = M

			// No point in giving reagents to the deceased. It can cause some runtimes.
			if(falling_carbon.stat >= DEAD)
				return

			if(falling_carbon.wear_mask && (falling_carbon.wear_mask.body_parts_covered & FACE))
				to_chat(falling_carbon, SPAN_DANGER("You fall in the [reagents_to_text()]!"))
			else
				var/datum/reagents/tempr = take_reagents_flat(CHOKE_REAGENTS_INGEST_ON_FALL_AMOUNT)
				tempr.trans_to(falling_carbon, tempr.total_volume)
				qdel(tempr)
				falling_carbon.adjustOxyLoss(5)
				M.emote("cough")
				to_chat(falling_carbon, SPAN_DANGER("You fall in and swallow some [reagents_to_text()]!"))
		else
			to_chat(M, SPAN_DANGER("You fall in the [reagents_to_text()]!"))

/atom/movable/liquid_turf/Initialize(mapload)
	. = ..()
	if(!SSliquids)
		CRASH("Liquid Turf created with the liquids sybsystem not yet initialized!")
	if(!immutable)
		my_turf = loc
		register_signal(my_turf, SIGNAL_ENTERED, nameof(.proc/movable_entered))
		register_signal(my_turf, SIGNAL_ATOM_FALL, nameof(.proc/mob_fall))
		register_signal(my_turf, SIGNAL_EXAMINED, nameof(.proc/examine_turf))
		SSliquids.mark_active_turf(my_turf)

	if(isspaceturf(my_turf))
		qdel_self()
	update_icon()
	smooth(get_turf(src))
	smooth_neighbors(get_turf(src))

/atom/movable/liquid_turf/Destroy(force)
	if(force)
		unregister_signal(my_turf, list(SIGNAL_ENTERED, SIGNAL_ATOM_FALL, SIGNAL_EXAMINED))
		if(my_turf.lgroup)
			my_turf.lgroup.remove_from_group(my_turf)
		if(SSliquids.evaporation_queue[my_turf])
			SSliquids.evaporation_queue -= my_turf
		if(SSliquids.processing_fire[my_turf])
			SSliquids.processing_fire -= my_turf
		//Is added because it could invoke a change to neighboring liquids
		SSliquids.mark_active_turf(my_turf)
		my_turf.liquids = null
		my_turf = null
		smooth_neighbors(get_turf(src))
	else
		return QDEL_HINT_LETMELIVE

	return ..()

/atom/movable/liquid_turf/immutable/Destroy(force)
	if(force)
		util_crash_with("Something tried to hard destroy an immutable liquid.")
	return ..()

//Exposes my turf with simulated reagents
/atom/movable/liquid_turf/proc/ExposeMyTurf()
	var/datum/reagents/tempr = simulate_reagents_threshold(LIQUID_REAGENT_THRESHOLD_TURF_EXPOSURE)
	tempr.touch(my_turf)
	qdel(tempr)

/atom/movable/liquid_turf/proc/ChangeToNewTurf(turf/NewT)
	if(NewT.liquids)
		util_crash_with("Liquids tried to change to a new turf, that already had liquids on it!")

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
	register_signal(my_turf, SIGNAL_ENTERED, nameof(.proc/movable_entered))
	register_signal(my_turf, SIGNAL_ATOM_FALL, nameof(.proc/mob_fall))

/**
 * Handles COMSIG_ATOM_EXAMINE for the turf.
 *
 * Adds reagent info to examine text.
 * Arguments:
 * * source - the turf we're peekin at
 * * examiner - the user
 * * examine_text - the examine list
 *  */
/atom/movable/liquid_turf/proc/examine_turf(turf/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	// This should always have reagents if this effect object exists, but as a sanity check...
	if(!length(reagent_list))
		return

	var/liquid_state_template = liquid_state_messages["[liquid_state]"]

	//examine_list += EXAMINE_SECTION_BREAK

	//if(examiner.can_see_reagents())
		//examine_list += EXAMINE_SECTION_BREAK

	if(length(reagent_list) == 1)
		// Single reagent text.
		var/datum/reagent/reagent_type = reagent_list[1]
		var/reagent_name = initial(reagent_type.name)
		var/volume = round(reagent_list[reagent_type], 0.01)

		examine_list += SPAN_NOTICE("There is [replacetext(liquid_state_template, "$", "[volume] units of [reagent_name]")] here.")
	else
		// Show each individual reagent
		examine_list += "There is [replacetext(liquid_state_template, "$", "the following")] here:"

		for(var/datum/reagent/reagent_type as anything in reagent_list)
			var/reagent_name = initial(reagent_type.name)
			var/volume = round(reagent_list[reagent_type], 0.01)
			examine_list += "&bull; [volume] units of [reagent_name]"

	examine_list += SPAN_NOTICE("The solution has a temperature of [temp]K.")
	//examine_list += EXAMINE_SECTION_BREAK
	return

	// Otherwise, just show the total volume
	//examine_list += SPAN_NOTICE("There is [replacetext(liquid_state_template, "$", "liquid")] here.")

/**
 * Creates a string of the reagents that make up this liquid.
 *
 * Puts the reagent(s) that make up the liquid into string form e.g. "plasma" or "plasma and water", or 'plasma, milk, and water' depending on how many reagents there are.
 *
 * Returns the reagents list string or a generic "liquid" if there are no reagents somehow
 *  */
/atom/movable/liquid_turf/proc/reagents_to_text()
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

/obj/effect/temp_visual/liquid_splash
	icon = 'icons/effects/splash.dmi'
	icon_state = "splash"
	layer = FLY_LAYER
	randomdir = FALSE

/atom/movable/liquid_turf/immutable
	immutable = TRUE
	var/list/starting_mixture = list(/datum/reagent/water = 600)
	var/starting_temp = 20 CELSIUS

//STRICTLY FOR IMMUTABLES DESPITE NOT BEING /immutable
/atom/movable/liquid_turf/proc/add_turf(turf/T)
	T.liquids = src
	T.vis_contents += src
	SSliquids.active_immutables[T] = TRUE
	register_signal(T, SIGNAL_ENTERED, nameof(.proc/movable_entered))
	register_signal(T, SIGNAL_ATOM_FALL, nameof(.proc/mob_fall))

/atom/movable/liquid_turf/proc/remove_turf(turf/T)
	SSliquids.active_immutables -= T
	T.liquids = null
	T.vis_contents -= src
	unregister_signal(T, list(SIGNAL_ENTERED, SIGNAL_ATOM_FALL))

/atom/movable/liquid_turf/immutable/Initialize(mapload)
	. = ..()
	reagent_list = starting_mixture.Copy()
	total_reagents = 0
	for(var/key in reagent_list)
		total_reagents += reagent_list[key]
	temp = starting_temp
	calculate_height()
	set_reagent_color_for_liquid()

/atom/movable/liquid_turf/proc/smooth_neighbors(smoothing_turf)
	for(var/direction in GLOB.alldirs)
		var/atom/movable/liquid_turf/L = locate() in get_step(smoothing_turf, direction)
		if(L)
			L.smooth(L.loc) //so siding get updated properly

#define ATOMS_TO_SMOOTH_WITH list(/atom/movable/liquid_turf, /turf/simulated/wall, /turf/unsimulated/wall, /obj/structure/window, /obj/structure/window_frame)

/atom/movable/liquid_turf/proc/smooth(smoothing_turf)
	ASSERT(!isnull(smoothing_turf))
	var/connectdir = 0
	for(var/direction in GLOB.cardinal)
		var/turf/dir_step = get_step(smoothing_turf, direction)
		for(var/path in ATOMS_TO_SMOOTH_WITH)
			if(!locate(path) in dir_step)
				continue

			connectdir |= direction
			break

	var/diagonalconnect = 0
	var/dirs = list(1,2,4,8)
	var/i = 1
	for(var/diag in list(NORTHEAST, SOUTHEAST,NORTHWEST,SOUTHWEST))
		if((connectdir & diag) == diag)
			var/turf/dir_step = get_step(smoothing_turf, diag)
			for(var/path in ATOMS_TO_SMOOTH_WITH)
				if(!locate(path) in dir_step)
					continue

				diagonalconnect |= dirs[i]
				break
		i += 1

	icon_state = "water-[connectdir]-[diagonalconnect]"

#undef ATOMS_TO_SMOOTH_WITH
