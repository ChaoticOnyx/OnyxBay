/datum/radiation_info
	var/activity = 0 BECQUEREL
	var/ray_type = RADIATION_ALPHA_RAY
	var/energy = null

	/// Keeps initial value of activity, used primary in reagents.
	var/specific_activity = null
	var/quality_factor = 1

/datum/radiation_info/New(activity, ray_type, energy = null)
	ASSERT(activity >= 0)
	ASSERT(IS_VALID_RAD_RAY(ray_type))

	src.activity = activity
	src.ray_type = ray_type

	if(energy == null)
		switch(ray_type)
			if(RADIATION_ALPHA_RAY)
				src.energy = ALPHA_RAY_ENERGY
			if(RADIATION_BETA_RAY)
				src.energy = BETA_RAY_ENERGY
			if(RADIATION_GAMMA_RAY)
				src.energy = GAMMA_RAY_ENERGY
			if(RADIATION_HAWKING_RAY)
				src.energy = HAWKING_RAY_ENERGY
			else
				CRASH("invalid ray_type: [ray_type]")
	else
		ASSERT(energy > 0)

		src.energy = energy

	switch(ray_type)
		if(RADIATION_ALPHA_RAY)
			src.quality_factor = 20
		if(RADIATION_BETA_RAY)
			src.quality_factor = 1
		if(RADIATION_GAMMA_RAY)
			src.quality_factor = 1
		if(RADIATION_HAWKING_RAY)
			src.quality_factor = 5
		else
			CRASH("invalid ray_type: [ray_type]")

	specific_activity = activity

/// Returns J
/datum/radiation_info/proc/calc_energy(dist)
	var/result =  energy / (dist ** 2)

	if(result < INSUFFICIENT_RADIATON_ENERGY)
		return 0

	return result

/// Returns J
/datum/radiation_info/proc/calc_energy_rt(atom/source, atom/target)
	var/result_energy = energy
	var/atom/current_point = source

	ASSERT(source.loc)
	ASSERT(target.loc)

	if(isobj(current_point))
		var/obj/current_obj = current_point
		result_energy -= (result_energy * current_obj.calc_rad_resistance(src))
		current_point = current_point.loc

	result_energy = result_energy / (get_dist(get_turf(source), get_turf(target)) ** 2)

	if(result_energy < INSUFFICIENT_RADIATON_ENERGY)
		return 0

	// Example of traverse: [beaker] -> [box] -> [human] -> [turf]
	while(!isturf(current_point) && current_point != target)
		if(!isobj(current_point) || current_point == source)
			current_point = current_point.loc
			continue

		var/obj/current_obj = current_point
		result_energy -= (result_energy * current_obj.calc_rad_resistance(src))

		if(result_energy < INSUFFICIENT_RADIATON_ENERGY)
			return 0

		current_point = current_point.loc

	// Example of traverse: [turf] -> [turf] -> [closet] -> [human]
	// or: [beaker] -> [human]
	while(current_point != null)
		var/dist = get_dist(current_point, target)

		if(dist == -1)
			break

		// On the same turf.
		if(dist == 0)
			var/turf/target_turf = get_turf(current_point)
			result_energy -= (result_energy * target_turf.rad_resist[ray_type])

			if(result_energy < INSUFFICIENT_RADIATON_ENERGY)
				return 0

			var/obj/target_parent = target.loc

			while(!isturf(target_parent))
				if(!istype(target_parent))
					target_parent = target_parent.loc
					continue

				result_energy -= (result_energy * target_parent.calc_rad_resistance(src))

				if(result_energy < INSUFFICIENT_RADIATON_ENERGY)
					return 0

				target_parent = target_parent.loc

			return result_energy
		// Not on the same turf
		else
			var/turf/current_turf = get_turf(current_point)
			var/on_same_turf = get_turf(source) == current_turf

			if(!on_same_turf)
				result_energy -= (result_energy * current_turf.calc_rad_resistance(src))

			if(result_energy < INSUFFICIENT_RADIATON_ENERGY)
				return 0

			if(!on_same_turf)
				for(var/obj/O in current_turf)
					if(O.density)
						result_energy -= (result_energy * O.calc_rad_resistance(src))
						break

			current_point = get_step_towards(current_turf, target)

	return result_energy

/// Returns Gy
/datum/radiation_info/proc/calc_absorbed_dose_rt(atom/source, atom/target, weight = AVERAGE_HUMAN_WEIGHT)
	return (activity * calc_energy_rt(source, target)) / weight

/// Returns Gy
/datum/radiation_info/proc/calc_absorbed_dose(weight = AVERAGE_HUMAN_WEIGHT)
	return (activity * energy) / weight

/// Returns Sv
/datum/radiation_info/proc/calc_equivalent_dose_rt(atom/source, atom/target, weight = AVERAGE_HUMAN_WEIGHT)
	return calc_absorbed_dose_rt(source, target, weight) * quality_factor

/// Returns Sv
/datum/radiation_info/proc/calc_equivalent_dose(weight = AVERAGE_HUMAN_WEIGHT)
	return calc_absorbed_dose(weight) * quality_factor

/// Describes a point source of radiation.  Created either in response to a pulse of radiation, or over an irradiated atom.
/// Sources will decay over time, unless something is renewing their power!
/datum/radiation_source
	/// Location of the radiation source.
	var/atom/holder
	/// True for not affecting RAD_SHIELDED areas.
	var/respect_maint = FALSE
	/// True for power falloff with distance.
	var/flat = FALSE
	/// Cached maximum range, used for quick checks against mobs.
	var/range
	var/datum/radiation_info/info

/datum/radiation_source/New(datum/radiation_info/info, atom/holder = null)
	src.info = info
	src.holder = holder

	update_energy(info.energy)

/datum/radiation_source/Destroy()
	SSradiation.sources -= src
	holder = null
	. = ..()

/datum/radiation_source/proc/update_energy(new_energy = null)
	if(new_energy == null)
		return // No change
	else if(new_energy <= 0)
		qdel(src) // Decayed to nothing
	else
		info.energy = new_energy
		if(!flat)
			range = min(round(sqrt(info.energy / INSUFFICIENT_RADIATON_ENERGY)), world.view * 2)

/// Returns J
/datum/radiation_source/proc/calc_energy_rt(atom/A)
	var/turf/from = flat ? get_turf(A) : holder

	return info.calc_energy_rt(from, A)

/// Returns J
/datum/radiation_source/proc/calc_energy(atom/A)
	var/turf/from = flat ? get_turf(A) : holder

	return info.calc_energy(get_dist(get_turf(A), from))

/// Returns Gy
/datum/radiation_source/proc/calc_absorbed_dose_rt(atom/target, weight = AVERAGE_HUMAN_WEIGHT)
	return info.calc_absorbed_dose_rt(holder, target, weight)

/// Returns Gy
/datum/radiation_source/proc/calc_absorbed_dose(weight = AVERAGE_HUMAN_WEIGHT)
	return info.calc_absorbed_dose(weight)

/// Returns Sv
/datum/radiation_source/proc/calc_equivalent_dose_rt(atom/target, weight = AVERAGE_HUMAN_WEIGHT)
	return info.calc_equivalent_dose(holder, target, weight)

/// Returns Sv
/datum/radiation_source/proc/calc_equivalent_dose(weight = AVERAGE_HUMAN_WEIGHT)
	return info.calc_equivalent_dose(weight)

/// Destroy self after specified time.
/datum/radiation_source/proc/schedule_decay(time)
	ASSERT(time > 0)

	addtimer(CALLBACK(src, .proc/Destroy), time, TIMER_UNIQUE)

/turf/proc/calc_rad_resistance(datum/radiation_info/info)
	if(!density && length(return_air().gas) == 0)
		return 0

	var/resist = rad_resist[info.ray_type]

	if(resist == 1.0)
		return resist

	for(var/obj/O in src)
		if(O.density)
			resist += O.rad_resist[info.ray_type]

	return Clamp(resist, 0.0, 1.0)

/obj/proc/calc_rad_resistance(datum/radiation_info/info)
	var/resist = rad_resist[info.ray_type]

	if(atom_flags & ATOM_FLAG_OPEN_CONTAINER)
		return 0

	return resist

/// This is used when radiation is exposed from the outside.
///
/// When something is exposing radiation inside of the mob - use `radiation` variable directly.
/atom/proc/rad_act(datum/radiation_source/rad_source)
	return 1

/mob/living/rad_act(datum/radiation_source/rad_source)
	// 1. Simulate ray traverse.
	var/energy_remain = rad_source.calc_energy_rt(src)

	// 2. If rays have too small energy after traversing - ignore it.
	if(energy_remain < INSUFFICIENT_RADIATON_ENERGY)
		return

	// 3. Calculate energy resistance from skin.
	energy_remain = max(0, energy_remain - (energy_remain * rad_resist[rad_source.info.ray_type]))

	if(energy_remain < INSUFFICIENT_RADIATON_ENERGY)
		return

	var/datum/radiation_info/new_info = new(rad_source.info.activity, rad_source.info.ray_type, energy_remain)

	// 4. Calculate the dose and apply
	radiation += new_info.calc_equivalent_dose(AVERAGE_HUMAN_WEIGHT)

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

	// 1. Simulate ray traverse.
	var/energy_remain = rad_source.calc_energy_rt(src)
	var/activity_remain = rad_source.info.activity

	// 2. If rays have too small energy after traversing - ignore it.
	if(energy_remain < INSUFFICIENT_RADIATON_ENERGY)
		return

	var/slots_resist = list()

	// 3. Calculate resists for all slots.
	for(var/obj/item/clothing/C in src.get_equipped_items())
		for(var/slot_info in slots_info)
			var/slot = slot_info[1]
			var/resist = 0

			if(C.body_parts_covered & slot)
				resist = C.rad_resist[rad_source.info.ray_type]

			if(slots_resist["[slot]"] == null)
				slots_resist["[slot]"] = resist
			else
				slots_resist["[slot]"] += resist

	var/datum/radiation_info/new_info = new(rad_source.info.activity, rad_source.info.ray_type, energy_remain)
	for(var/slot_info in slots_info)
		var/slot = slot_info[1]
		var/size = slot_info[2]

		var/slot_resist = Clamp(slots_resist["[slot]"], 0.0, 1.0)
		var/slot_energy = energy_remain
		var/particles_count = activity_remain * size

		// 4. Calculate energy resistance from slots.
		slot_energy = max(0, slot_energy - (slot_energy * slot_resist))

		// 5. Calculate energy resistance from skin.
		var/skin_resist = rad_resist[rad_source.info.ray_type]

		if(slot == FACE && slot_resist == 0.0)
			skin_resist *= 0.5

		slot_energy = max(0, slot_energy - (slot_energy * skin_resist))

		if(slot_energy < INSUFFICIENT_RADIATON_ENERGY)
			continue

		// 6. Calculate the dose and apply
		new_info.energy = slot_energy
		new_info.activity = particles_count
		radiation += new_info.calc_equivalent_dose(AVERAGE_HUMAN_WEIGHT)
