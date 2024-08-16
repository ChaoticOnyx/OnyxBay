/datum/space_level
	var/path
	var/list/traits
	var/travel_chance = 0
	/// The base turf type
	var/base_turf = /turf/space

	/// Set to TRUE so this level will be initialized in SSmapping initialization sequence.
	var/lateloading_level = FALSE

	/**
	 * Certified atmos shitfuckery.
	 */
	/// Temperature of standard exterior atmosphere.
	var/exterior_atmos_temp = 20 CELSIUS
	/// Gas mixture datum returned to exterior return_air. Set to assoc list of material to moles to initialize the gas datum.
	var/datum/gas_mixture/exterior_atmosphere

/datum/space_level/New()
	var/list/traits_map = list()

	for(var/T in traits)
		traits_map += list("[T]" = TRUE)

	traits = traits_map
	if(!islist(exterior_atmosphere))
		exterior_atmosphere = new
	else
		var/datum/gas_mixture/atmos = new
		var/list/gases = exterior_atmosphere
		atmos.gas = gases.Copy()
		exterior_atmosphere = atmos
	exterior_atmosphere.temperature = exterior_atmos_temp

/datum/space_level/proc/remove_trait(trait)
	traits["[trait]"] = FALSE

/datum/space_level/proc/add_trait(trait)
	traits["[trait]"] = TRUE

/datum/space_level/proc/has_trait(trait)
	return traits[trait]

/datum/space_level/proc/generate(z)
	return

/datum/space_level/proc/get_exterior_atmosphere()
	if(!exterior_atmosphere)
		return

	var/datum/gas_mixture/gas = new
	gas.copy_from(exterior_atmosphere)
	return gas

/datum/space_level/proc/assume_atmosphere(datum/gas_mixture/gas)
	if(!istype(gas))
		CRASH("Space level tried to assume non-existent atmosphere!")

	exterior_atmosphere = gas

/datum/space_level/proc/make_space_atmosphere()
	if(istype(exterior_atmosphere))
		QDEL_NULL(exterior_atmosphere)

	exterior_atmosphere = new
