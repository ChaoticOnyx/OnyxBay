/datum/radiation
	var/activity = 0 BECQUEREL
	var/radiation_type = RADIATION_ALPHA_PARTICLE
	var/energy = 0

	/// Keeps initial value of activity, used primary in reagents.
	var/specific_activity = 0
	var/quality_factor = 1

/datum/radiation/New(activity, radiation_type, energy = null)
	ASSERT(activity >= 0)
	ASSERT(IS_VALID_RADIATION_TYPE(radiation_type))

	src.activity = activity
	src.radiation_type = radiation_type

	if(energy == null)
		switch(radiation_type)
			if(RADIATION_ALPHA_PARTICLE)
				src.energy = ALPHA_PARTICLE_ENERGY
			if(RADIATION_BETA_PARTICLE)
				src.energy = BETA_PARTICLE_ENERGY
			if(RADIATION_HAWKING)
				src.energy = HAWKING_RAY_ENERGY
			else
				CRASH("invalid radiation_type: [radiation_type]")
	else
		ASSERT(energy > 0)

		src.energy = energy

	switch(radiation_type)
		if(RADIATION_ALPHA_PARTICLE)
			src.quality_factor = 20
		if(RADIATION_BETA_PARTICLE)
			src.quality_factor = 1
		else
			quality_factor = 1

	specific_activity = activity

/datum/radiation/proc/copy(datum/radiation/target)
	target.activity = activity
	target.radiation_type = radiation_type
	target.energy = energy
	target.specific_activity = specific_activity
	target.quality_factor = quality_factor

	return target

/datum/radiation/proc/is_ionizing()
	return energy >= RADIATION_MIN_IONIZATION

/datum/radiation/proc/travel(atom/source, atom/target)
	var/atom/current_point = source
	var/turf/source_turf = get_turf(source)

	ASSERT(source.loc)
	ASSERT(target.loc)

	if(isobj(current_point))
		var/obj/current_obj = current_point
		energy = max(energy - RADIATION_CALC_OBJ_RESIST(src, current_obj), 0)
		current_point = current_point.loc

	var/dst = get_dist(get_turf(source), get_turf(target))

	if (dst > MAX_RADIATION_DIST)
		return FALSE

	energy /= RADIATION_DISTANCE_MULT(dst)

	if(!is_ionizing())
		return FALSE

	// Example of traverse: [beaker] -> [box] -> [human] -> [turf]
	while(!isturf(current_point) && current_point != target)
		if(!isobj(current_point) || current_point == source)
			current_point = current_point.loc
			continue

		var/obj/current_obj = current_point
		energy = max(energy - RADIATION_CALC_OBJ_RESIST(src, current_obj), 0)

		if(!is_ionizing())
			return FALSE

		current_point = current_point.loc

	// Example of traverse: [turf] -> [turf] -> [closet] -> [human]
	// or: [beaker] -> [human]
	while(current_point != null)
		var/dist = get_dist(current_point, target)

		if(dist == -1)
			break

		// On the same turf.
		if(dist == 0)
			var/obj/target_parent = target.loc

			while(!isturf(target_parent))
				if(!istype(target_parent))
					target_parent = target_parent.loc
					continue

				energy = max(energy - RADIATION_CALC_OBJ_RESIST(src, target_parent), 0)

				if(!is_ionizing())
					return FALSE

				target_parent = target_parent.loc

			return TRUE
		// Not on the same turf
		else
			var/turf/current_turf = get_turf(current_point)

			energy = max(energy - current_turf.calc_rad_resistance(src), 0)

			if(!is_ionizing())
				return FALSE

			if(source_turf != current_turf)
				for(var/obj/O in current_turf)
					if(O.density)
						energy = max(energy - RADIATION_CALC_OBJ_RESIST(src, O), 0)
						break

			current_point = get_step_towards(current_turf, target)

	return (is_ionizing())

/// Returns Gy
/datum/radiation/proc/calc_absorbed_dose(weight = AVERAGE_HUMAN_WEIGHT)
	return (activity * energy) / weight

/// Returns Sv
/datum/radiation/proc/calc_equivalent_dose(weight = AVERAGE_HUMAN_WEIGHT)
	return calc_absorbed_dose(weight) * quality_factor

/turf/proc/calc_rad_resistance(datum/radiation/info)
	if(!density && length(return_air().gas) == 0)
		return 0

	var/resist = get_rad_resist_value(rad_resist_type, info.radiation_type)

	if(resist == 1.0)
		return resist

	for(var/obj/O in src)
		if(O.density)
			resist += get_rad_resist_value(O.rad_resist_type, info.radiation_type)

	return Clamp(resist, 0.0, 1.0)

/// This is used when radiation is exposed from the outside.
///
/// When something is exposing radiation inside of the mob - use `radiation` variable directly.
/atom/proc/rad_act(datum/radiation_source/rad_source)
	return 1

/mob/living/rad_act(datum/radiation_source/rad_source)
	if(!rad_source.info.is_ionizing())
		return

	// 1. Simulate ray traverse.
	var/datum/radiation/R = rad_source.travel(src)

	// 2. If rays have too small energy after traversing - ignore it.
	if(!R.is_ionizing())
		return

	// 3. Calculate energy resistance from skin.
	R.energy -= get_rad_resist_value(rad_resist_type, R.radiation_type)

	if(!R.is_ionizing())
		return

	// 4. Calculate the dose and apply
	radiation += R.calc_equivalent_dose(AVERAGE_HUMAN_WEIGHT)

/mob/living/carbon/human/rad_act(datum/radiation_source/rad_source)

	if(HAS_TRAIT(src, TRAIT_RADIMMUNE))
		return

	// `body_coverage` with clothing which coats all parts of the body with 100% resistance to a certain radiation should not give more than 1.0
	var/static/list/slots_info = list(
		list(HEAD, 0.02),
		list(FACE, 0.16),
		list(EYES, 0.02),
		list(UPPER_TORSO, 0.15),
		list(LOWER_TORSO, 0.15),
		list(LEG_LEFT, 0.13),
		list(LEG_RIGHT, 0.13),
		list(FOOT_LEFT, 0.02),
		list(FOOT_RIGHT, 0.02),
		list(ARM_LEFT, 0.08),
		list(ARM_RIGHT, 0.08),
		list(HAND_LEFT, 0.02),
		list(HAND_RIGHT, 0.02)
	)

	if(!rad_source.info.is_ionizing())
		return

	// 1. Simulate particle traverse.
	var/datum/radiation/R = rad_source.travel(src)

	// 2. If particles have too small energy after traversing - ignore it.
	if(!R.is_ionizing())
		return
	var/energy_remain = R.energy
	var/activity_remain = R.activity

	var/slots_resist = list()

	// 3. Calculate resists for all slots.
	for(var/obj/item/clothing/C in src.get_equipped_items())
		for(var/slot_info in slots_info)
			var/slot = slot_info[1]
			var/resist = 0

			if(C.body_parts_covered & slot)
				resist = get_rad_resist_value(C.rad_resist_type, R.radiation_type)

			if(slots_resist["[slot]"] == null)
				slots_resist["[slot]"] = resist
			else
				slots_resist["[slot]"] += resist

	for(var/slot_info in slots_info)
		var/slot = slot_info[1]
		var/size = slot_info[2]

		var/slot_resist = slots_resist["[slot]"]
		var/slot_energy = energy_remain
		var/particles_count = activity_remain * size

		// 4. Calculate energy resistance from slots.
		slot_energy -= slot_resist

		// 5. Calculate energy resistance from skin.
		var/skin_resist = get_rad_resist_value(rad_resist_type, R.radiation_type)

		if(slot == FACE && slot_resist == 0.0)
			skin_resist *= 0.2

		slot_energy -= skin_resist

		if(slot_energy <= (10 ELECTRONVOLT))
			continue

		// 6. Calculate the dose and apply
		R.energy = slot_energy
		R.activity = particles_count
		radiation += R.calc_equivalent_dose(AVERAGE_HUMAN_WEIGHT)
