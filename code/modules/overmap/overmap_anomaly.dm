/obj/effect/overmap_anomaly

/obj/structure/overmap/asteroid
	var/required_tier = 0

/obj/effect/overmap_anomaly/star
	name = "Star"
	icon = 'icons/overmap/stellarbodies/stars.dmi'
	icon_state = "purple"

/obj/effect/overmap_anomaly/visitable
	var/datum/map_generator/planet_generator/mapgen

/obj/effect/overmap_anomaly/visitable/planetoid
	name = "Planetoid"
	icon = 'icons/overmap/stellarbodies/planetoids.dmi'
	icon_state = "planet"
	/// Habitability variable that defines generation of weather, atmosphere and other stuff.
	var/habitability = HABITABILITY_DEAD

	/**
	 * Vars for procedural generation
	 */
	/// A list of gas and their proportion to enforce on this planet when generating the atmosphere.
	/// If a level's get_mandatory_gases() returns gases, they will be added to this. If null is randomly generated.
	var/list/forced_atmosphere_gen_gases
	/// Minimum amount of different atmospheric gases that may be generated for this planet, not counting the forced gases
	var/atmospheric_gen_gases_min = 1
	/// Maximum amount of different atmospheric gases that may be generated for this planet, not counting the forced gases
	var/atmospheric_gen_gases_max = 4
	/// Minimum possible base temperature range to pick from, when generating the atmosphere on this planet.
	var/atmosphere_gen_temperature_min = TCMB
	/// Maximum possible base temperature range to pick from, when generating the atmosphere on this planet.
	var/atmosphere_gen_temperature_max = 100 CELSIUS
	/// Minimum atmospheric pressure in the range to pick from for this planet template.
	var/atmosphere_gen_pressure_min = 0.5 * ONE_ATMOSPHERE
	/// Maximum atmospheric pressure in the range to pick from for this planet template.
	var/atmosphere_gen_pressure_max = 2 * ONE_ATMOSPHERE
	///The cached planet's atmosphere that sub-levels of this planet should use.
	var/datum/gas_mixture/atmosphere

/// Pregenerates important data such as its name, atmosphere
/obj/effect/overmap_anomaly/visitable/planetoid/proc/pregenerate(distance_from_star)
	pregen_name()
	pregen_habitability(distance_from_star)
	pregen_atmos(distance_from_star)

/obj/effect/overmap_anomaly/visitable/planetoid/proc/pregen_name()
	name = "[pick(GLOB.last_names)]-[pick(GLOB.greek_letters)]"

/// Takes distance from star (a number), the higher the number, the farther the planetoid is from the star.
/obj/effect/overmap_anomaly/visitable/planetoid/proc/pregen_habitability(distance_from_star)
	switch(distance_from_star)
		if(1)
			habitability = HABITABILITY_DEAD
		if(2)
			if(prob(50))
				habitability = HABITABILITY_BAD
			else
				habitability = HABITABILITY_DEAD
		if(3)
			switch(rand(1, 100))
				if(1 to 50)
					habitability = HABITABILITY_OKAY
				if(50 to 80)
					habitability = HABITABILITY_IDEAL
				if(81 to 100)
					habitability = HABITABILITY_BAD
		if(4)
			if(prob(50))
				habitability = HABITABILITY_OKAY
			else
				habitability = HABITABILITY_BAD
		else
			habitability = HABITABILITY_BAD

	switch(habitability)
		if(HABITABILITY_DEAD)
			icon_state = "barren[rand(1, 3)]"
			mapgen = /datum/map_generator/planet_generator/rock
		if(HABITABILITY_BAD)
			switch(rand(1, 100))
				if(1 to 40)
					icon_state = "lava[rand(1, 3)]"
					mapgen = /datum/map_generator/planet_generator/lava
				if(41 to 51)
					icon_state = "barren[rand(1, 3)]"
					mapgen = /datum/map_generator/planet_generator/rock
				if(52 to 72)
					icon_state = "waste[rand(1, 3)]"
					mapgen = /datum/map_generator/planet_generator/waste
				else
					icon_state = "ice[rand(1, 3)]"
					mapgen = /datum/map_generator/planet_generator/snow

		if(HABITABILITY_OKAY)
			icon_state = "earthlike[rand(1, 3)]"
			switch(rand(1, 100))
				if(1 to 30)
					mapgen = /datum/map_generator/planet_generator/swamp
				if(31 to 51)
					mapgen = /datum/map_generator/planet_generator/jungle
				if(52 to 76)
					mapgen = /datum/map_generator/planet_generator/beach
				else
					icon_state = "waste[rand(1, 3)]"
					mapgen = /datum/map_generator/planet_generator/snow

		if(HABITABILITY_IDEAL)
			icon_state = "earthlike[rand(1, 3)]"
			switch(rand(1, 100))
				if(1 to 20)
					mapgen = /datum/map_generator/planet_generator/swamp
				if(21 to 60)
					mapgen = /datum/map_generator/planet_generator/jungle
				else
					mapgen = /datum/map_generator/planet_generator/beach

/obj/effect/overmap_anomaly/visitable/planetoid/proc/pregen_atmos(distance_from_star)
	var/datum/gas_mixture/new_atmos = new
	var/target_temperature = generate_surface_temperature()
	var/target_pressure = generate_surface_pressure()

	var/total_moles = (target_pressure * CELL_VOLUME) / (target_temperature * R_IDEAL_GAS_EQUATION)
	var/available_moles = total_moles
	new_atmos.temperature = target_temperature

	// Forced gases get added in first
	var/forced_flag_check = 0
	for(var/gas in forced_atmosphere_gen_gases)
		forced_flag_check |= gas_data.flags[gas]
		new_atmos.gas[gas] = forced_atmosphere_gen_gases[gas] * total_moles
		//Subtract any forced gases from the total available moles amount
		available_moles = max(0, available_moles - new_atmos.gas[gas])

	//Sanity warning so people don't accidently set a combustible mixture as forced atmos
	if((forced_flag_check & XGM_GAS_OXIDIZER) && (forced_flag_check & XGM_GAS_FUEL))
		log_warning("The list of forced gases user-defined for [src]'s atmoshpere contains both an oxidizer and a fuel!")

	//Make a list of gas flags to avoid
	var/blacklisted_flags = forced_flag_check & (XGM_GAS_OXIDIZER | XGM_GAS_FUEL) //Prevents combustible mixtures

	//Habitable planets do not want any contaminants in the air
	if(habitability == HABITABILITY_OKAY || habitability == HABITABILITY_IDEAL)
		blacklisted_flags |= XGM_GAS_CONTAMINANT

		//Make sure temperature can't damage people on casual planets (Only when not forcing an atmosphere)
		var/datum/species/S = all_species["Human"]
		var/lower_temp = max(S.cold_level_1, atmosphere_gen_temperature_min)
		var/higher_temp = min(S.heat_level_1, atmosphere_gen_temperature_max)
		var/breathed_gas = S.breath_type
		var/breathed_min_pressure = S.breath_pressure

		//Adjust temperatures to be for the species
		new_atmos.temperature = clamp(new_atmos.temperature, lower_temp + rand(1,5), higher_temp - rand(1,5))

		//#TODO: Take into account if a species is aquatic?
		//Synths don't breath, so make sure we validate this here
		if(breathed_gas)
			//Calculate the minimum amount of moles of breathable gas needed by the default species
			new_atmos.gas[breathed_gas] = (breathed_min_pressure * CELL_VOLUME) / (new_atmos.temperature * R_IDEAL_GAS_EQUATION)

	//Pick the list of possible gases we can use in our random atmosphere, if we are set to generate any
	if(atmospheric_gen_gases_min > 0 && atmospheric_gen_gases_max > 0)
		var/list/candidate_gases = gas_data.gases.Copy()
		if(length(candidate_gases))
			//All the toggled flags of the gases we added this far. Used to avoid mixing dangerous gases.
			var/current_merged_flags = 0
			var/number_gases         = rand(atmospheric_gen_gases_min, atmospheric_gen_gases_max)
			var/i                    = 1

			while((i <= number_gases) && (available_moles > 0) && length(candidate_gases))
				var/picked_gas = util_pick_weight(candidate_gases)	//pick a gas
				candidate_gases -= picked_gas

				// Make sure atmosphere is not flammable
				if(((current_merged_flags & XGM_GAS_OXIDIZER) && (gas_data.flags[picked_gas] & XGM_GAS_FUEL)) || \
					((current_merged_flags & XGM_GAS_FUEL) && (gas_data.flags[picked_gas] & XGM_GAS_OXIDIZER)))
					continue

				current_merged_flags |=gas_data.flags[picked_gas]
				var/min_percent = 10
				var/max_percent = 90
				var/part = available_moles * (rand(min_percent, max_percent) / 100) //allocate percentage to it
				if(i == number_gases || !length(candidate_gases)) //if it's last gas, let it have all remaining moles
					part = available_moles
				new_atmos.gas[picked_gas] += part
				available_moles = max(available_moles - part, 0)
				i++

	new_atmos.update_values()
	atmosphere = new_atmos

/// Generates a valid surface temperature for the planet's atmosphere matching its habitability class
/obj/effect/overmap_anomaly/visitable/planetoid/proc/generate_surface_temperature()
	. = rand(atmosphere_gen_temperature_min, atmosphere_gen_temperature_max)

	if(habitability == HABITABILITY_OKAY || habitability == HABITABILITY_IDEAL)
		var/datum/species/S = all_species["Human"]
		if(habitability == HABITABILITY_IDEAL)
			. = clamp(., S.cold_discomfort_level + rand(1,5), S.heat_discomfort_level - rand(1,5)) //Clamp between comfortable levels since we're ideal
		else
			. = clamp(., S.cold_level_1 + 1, S.heat_level_1 - 10) //clamp between values species starts taking damages at

/// Generates surface pressure for the planet's atmosphere matching it's habitability class
/obj/effect/overmap_anomaly/visitable/planetoid/proc/generate_surface_pressure()
	. = rand(atmosphere_gen_pressure_min, atmosphere_gen_pressure_max)

	// Adjust for species habitability
	if(habitability == HABITABILITY_OKAY || habitability == HABITABILITY_IDEAL)
		var/datum/species/S = all_species["Human"]
		var/breathed_min_pressure = S.breath_pressure
		var/safe_max_pressure = S.hazard_high_pressure
		var/safe_min_pressure = S.hazard_low_pressure
		var/comfortable_max_pressure = S.warning_high_pressure
		var/comfortable_min_pressure = S.warning_low_pressure

		// On ideal planets, clamp against the comfortability limit pressures, since it shouldn't hit any extremes
		if(habitability == HABITABILITY_IDEAL)
			. = clamp(., comfortable_min_pressure, comfortable_max_pressure)
		// On okay planets, clamp against the safety limit pressures, so it's uncomfortable, but not harmful
		else
			. = clamp(., safe_min_pressure + 1, safe_max_pressure - 1) //Safety check inclusively compares against those values, so remove/add one from both

		// Ensure we at least have the minimum breathable pressure
		. = max(., breathed_min_pressure)
